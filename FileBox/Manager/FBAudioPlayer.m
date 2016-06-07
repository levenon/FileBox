//
//  FBAudioManager
//  FBMovie
//
//  Created by Kolyvan on 23.10.12.
//  Copyright (c)2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/FBMovie
//  this file is part of FBMovie
//  FBMovie is licenced under the LGPL v3, see lgpl-3.0.txt

// ios-only and output-only version of Novocaine https://github.com/alexbw/novocaine
// Copyright (c)2012 Alex Wiltschko


#import "FBAudioPlayer.h"
#import "TargetConditionals.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#import "FBLogger.h"

#define MAX_FRAME_SIZE 4096
#define MAX_CHAN       2

#define MAX_SAMPLE_DUMPED 5

static BOOL checkError(OSStatus error, const char *operation);
static void sessionPropertyListener(void *inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void *inData);
static void sessionInterruptionListener(void *inClientData, UInt32 inInterruption);
static OSStatus renderCallback (void *inRefCon, AudioUnitRenderActionFlags	*ioActionFlags, const AudioTimeStamp * inTimeStamp, UInt32 inOutputBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData);


@interface FBAudioPlayer() {
    
    float                       *_outData;
    AudioUnit                   _audioUnit;
    AudioStreamBasicDescription _outputFormat;
}

@property (nonatomic, assign) UInt32                    numOutputChannels;
@property (nonatomic, assign) Float64                   samplingRate;
@property (nonatomic, assign) UInt32                    numBytesPerSample;
@property (nonatomic, assign) Float32                   outputVolume;
@property (nonatomic, assign) BOOL                      playing;
@property (nonatomic, strong) NSString                  *audioRoute;
@property (nonatomic, assign) BOOL                      playAfterSessionEndInterruption;

@end

@implementation FBAudioPlayer

- (id)init{
    
    self = [super init];
    if (self) {
        
        _outData = (float *)calloc(MAX_FRAME_SIZE*MAX_CHAN, sizeof(float));
        _outputVolume = 0.5;        
    }	
    return self;
}

- (void)dealloc{
    
    [self pause];
    
    if (_outData) {
        
        free(_outData);
        _outData = NULL;
    }
    
    [self setAudioRoute:nil];
    [self setOutputBlock:nil];
}

- (void)setOutputVolume:(Float32)outputVolume{
    
    if (_outputVolume == outputVolume ) {
        
        _outputVolume = outputVolume;
        
        UInt32 size = sizeof(outputVolume);
        
        AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                size,
                                &_outputVolume);
    }
}

#pragma mark - private

// Debug:dump the current frame data. Limited to 20 samples.

#define dumpAudioSamples(prefix, dataBuffer, samplePrintFormat, sampleCount, channelCount)\
{ \
NSMutableString *dump = [NSMutableString stringWithFormat:prefix]; \
for (int i = 0; i < MIN(MAX_SAMPLE_DUMPED, sampleCount); i++)\
{ \
for (int j = 0; j < channelCount; j++)\
{ \
[dump appendFormat:samplePrintFormat, dataBuffer[j + i * channelCount]]; \
} \
[dump appendFormat:@"\n"]; \
} \
LoggerAudio(3, @"%@", dump); \
}

#define dumpAudioSamplesNonInterleaved(prefix, dataBuffer, samplePrintFormat, sampleCount, channelCount)\
{ \
NSMutableString *dump = [NSMutableString stringWithFormat:prefix]; \
for (int i = 0; i < MIN(MAX_SAMPLE_DUMPED, sampleCount); i++)\
{ \
for (int j = 0; j < channelCount; j++)\
{ \
[dump appendFormat:samplePrintFormat, dataBuffer[j][i]]; \
} \
[dump appendFormat:@"\n"]; \
} \
LoggerAudio(3, @"%@", dump); \
}

- (BOOL)checkAudioRoute{
    
    // Check what the audio route is.
    UInt32 propertySize = sizeof(CFStringRef);
    CFStringRef route;
    if (checkError(AudioSessionGetProperty(kAudioSessionProperty_AudioRoute,
                                           &propertySize,
                                           &route),
                   "Couldn't check the audio route"))
        return NO;
    
    _audioRoute = CFBridgingRelease(route);
    LoggerAudio(1, @"AudioRoute:%@", _audioRoute);
    return YES;
}

- (BOOL)setupAudio{
    
    // --- Audio Session Setup ---
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    //UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    if (checkError(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                           sizeof(sessionCategory),
                                           &sessionCategory),
                   "Couldn't set audio category"))
        return NO;
    
    
    if (checkError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                                   sessionPropertyListener,
                                                   (__bridge void *)(self)),
                   "Couldn't add audio session property listener"))
    {
        // just warning
    }
    
    if (checkError(AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                   sessionPropertyListener,
                                                   (__bridge void *)(self)),
                   "Couldn't add audio session property listener"))
    {
        // just warning
    }
    
    // Set the buffer size, this will affect the number of samples that get rendered every time the audio callback is fired
    // A small number will get you lower latency audio, but will make your processor work harder
    
#if !TARGET_IPHONE_SIMULATOR
    Float32 preferredBufferSize = 0.0232;
    if (checkError(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                                           sizeof(preferredBufferSize),
                                           &preferredBufferSize),
                   "Couldn't set the preferred buffer duration")) {
        
        // just warning
    }
#endif
    
    if (checkError(AudioSessionSetActive(YES),
                   "Couldn't activate the audio session"))
        return NO;
    
    [self checkSessionProperties];
    
    // ----- Audio Unit Setup -----
    
    // Describe the output unit.
    
    AudioComponentDescription description = {0};
    description.componentType = kAudioUnitType_Output;
    description.componentSubType = kAudioUnitSubType_RemoteIO;
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent component = AudioComponentFindNext(NULL, &description);
    if (checkError(AudioComponentInstanceNew(component, &_audioUnit),
                   "Couldn't create the output audio unit"))
        return NO;
    
    UInt32 size;
    
    // Check the output stream format
    size = sizeof(AudioStreamBasicDescription);
    if (checkError(AudioUnitGetProperty(_audioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &_outputFormat,
                                        &size),
                   "Couldn't get the hardware output stream format"))
        return NO;
    
    
    _outputFormat.mSampleRate = _samplingRate;
    if (checkError(AudioUnitSetProperty(_audioUnit,
                                        kAudioUnitProperty_StreamFormat,
                                        kAudioUnitScope_Input,
                                        0,
                                        &_outputFormat,
                                        size),
                   "Couldn't set the hardware output stream format")) {
        
        // just warning
    }
    
    _numBytesPerSample = _outputFormat.mBitsPerChannel / 8;
    _numOutputChannels = _outputFormat.mChannelsPerFrame;
    
    LoggerAudio(2, @"Current output bytes per sample:%d", _numBytesPerSample);
    LoggerAudio(2, @"Current output num channels:%d", _numOutputChannels);
    
    // Slap a render callback on the unit
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
    if (checkError(AudioUnitSetProperty(_audioUnit,
                                        kAudioUnitProperty_SetRenderCallback,
                                        kAudioUnitScope_Input,
                                        0,
                                        &callbackStruct,
                                        sizeof(callbackStruct)),
                   "Couldn't set the render callback on the audio unit"))
        return NO;
    
    if (checkError(AudioUnitInitialize(_audioUnit),
                   "Couldn't initialize the audio unit"))
        return NO;
    
    return YES;
}

- (BOOL)checkSessionProperties{
    
    [self checkAudioRoute];
    
    // Check the number of output channels.
    UInt32 newNumChannels;
    UInt32 size = sizeof(newNumChannels);
    if (checkError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputNumberChannels,
                                           &size,
                                           &newNumChannels),
                   "Checking number of output channels"))
        return NO;
    
    LoggerAudio(2, @"We've got %u output channels", newNumChannels);
    
    // Get the hardware sampling rate. This is settable, but here we're only reading.
    size = sizeof(_samplingRate);
    if (checkError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate,
                                           &size,
                                           &_samplingRate),
                   "Checking hardware sampling rate"))
        
        return NO;
    
    LoggerAudio(2, @"Current sampling rate:%f", _samplingRate);
    
    size = sizeof(_outputVolume);
    if (checkError(AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                           &size,
                                           &_outputVolume),
                   "Checking current hardware output volume"))
        return NO;
    
    LoggerAudio(1, @"Current output volume:%f", _outputVolume);
    
    return YES;	
}

- (BOOL)renderFrames:(UInt32)numFrames
              ioData:(AudioBufferList *)ioData{
    
    for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
        memset(ioData->mBuffers[iBuffer].mData, 0, ioData->mBuffers[iBuffer].mDataByteSize);
    }
    
    if (_playing && _outputBlock ) {
        
        // Collect data to render from the callbacks
        _outputBlock(_outData, numFrames, _numOutputChannels);
        
        // Put the rendered data into the output buffer
        if (_numBytesPerSample == 4)// then we've already got floats
        {
            float zero = 0.0;
            
            for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
                
                int thisNumChannels = ioData->mBuffers[iBuffer].mNumberChannels;
                
                for (int iChannel = 0; iChannel < thisNumChannels; ++iChannel) {
                    vDSP_vsadd(_outData+iChannel, _numOutputChannels, &zero, (float *)ioData->mBuffers[iBuffer].mData, thisNumChannels, numFrames);
                }
            }
        }
        else if (_numBytesPerSample == 2)// then we need to convert SInt16 -> Float (and also scale)
        {
            //            dumpAudioSamples(@"Audio frames decoded by FFmpeg:\n",
            //                             _outData, @"% 12.4f ", numFrames, _numOutputChannels);
            
            float scale = (float)INT16_MAX;
            vDSP_vsmul(_outData, 1, &scale, _outData, 1, numFrames*_numOutputChannels);
            
#ifdef DUMP_AUDIO_DATA
            LoggerAudio(2, @"Buffer %u - Output Channels %u - Samples %u",
                        (uint)ioData->mNumberBuffers, (uint)ioData->mBuffers[0].mNumberChannels, (uint)numFrames);
#endif
            
            for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
                
                int thisNumChannels = ioData->mBuffers[iBuffer].mNumberChannels;
                
                for (int iChannel = 0; iChannel < thisNumChannels; ++iChannel) {
                    vDSP_vfix16(_outData+iChannel, _numOutputChannels, (SInt16 *)ioData->mBuffers[iBuffer].mData+iChannel, thisNumChannels, numFrames);
                }
#ifdef DUMP_AUDIO_DATA
                dumpAudioSamples(@"Audio frames decoded by FFmpeg and reformatted:\n",
                                 ((SInt16 *)ioData->mBuffers[iBuffer].mData),
                                 @"% 8d ", numFrames, thisNumChannels);
#endif
            }
            
        }        
    }
    
    return noErr;
}

#pragma mark - public

- (void)activateAudioSession{
    
    checkError(AudioSessionInitialize(NULL,
                                      kCFRunLoopDefaultMode,
                                      sessionInterruptionListener,
                                      (__bridge void *)(self)),
               "Couldn't initialize audio session");
    [self checkAudioRoute];
    [self setupAudio];
}

- (void)deactivateAudioSession{
    
    checkError(AudioUnitUninitialize(_audioUnit),
               "Couldn't uninitialize the audio unit");
    
    /*
     fails with error (-10851)? 
     
     checkError(AudioUnitSetProperty(_audioUnit,
     kAudioUnitProperty_SetRenderCallback,
     kAudioUnitScope_Input,
     0,
     NULL,
     0),
     "Couldn't clear the render callback on the audio unit");
     */
    
    checkError(AudioComponentInstanceDispose(_audioUnit),
               "Couldn't dispose the output audio unit");
    
    checkError(AudioSessionSetActive(NO),
               "Couldn't deactivate the audio session");        
    
    checkError(AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange,
                                                              sessionPropertyListener,
                                                              (__bridge void *)(self)),
               "Couldn't remove audio session property listener");
    
    checkError(AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume,
                                                              sessionPropertyListener,
                                                              (__bridge void *)(self)),
               "Couldn't remove audio session property listener");
}

- (void)pause{
    
    if (_playing) {
        
        _playing = checkError(AudioOutputUnitStop(_audioUnit), "Couldn't stop the output unit");
        
        [self deactivateAudioSession];
    }
}

- (BOOL)play{
    
    if (!_playing) {
        
        [self activateAudioSession];
        
        _playing = !checkError(AudioOutputUnitStart(_audioUnit), "Couldn't start the output unit");
    }
    
    return _playing;
}

@end

#pragma mark - callbacks

static void sessionPropertyListener(void *                  inClientData,
                                    AudioSessionPropertyID  inID,
                                    UInt32                  inDataSize,
                                    const void *            inData) {
    
    FBAudioPlayer *sm = (__bridge FBAudioPlayer *)inClientData;
    
    if (inID == kAudioSessionProperty_AudioRouteChange) {
        
        if ([sm checkAudioRoute]) {
            [sm checkSessionProperties];
        }
        
    } else if (inID == kAudioSessionProperty_CurrentHardwareOutputVolume) {
        
        if (inData && inDataSize == 4) {
            
            sm.outputVolume = *(float *)inData;
        }
    }
}

static void sessionInterruptionListener(void *inClientData, UInt32 inInterruption) {
    
    FBAudioPlayer *sm = (__bridge FBAudioPlayer *)inClientData;
    
    if (inInterruption == kAudioSessionBeginInterruption) {
        
        LoggerAudio(2, @"Begin interuption");
        sm.playAfterSessionEndInterruption = sm.playing;
        [sm pause];
        
    } else if (inInterruption == kAudioSessionEndInterruption) {
        
        LoggerAudio(2, @"End interuption");
        if (sm.playAfterSessionEndInterruption) {
            sm.playAfterSessionEndInterruption = NO;
            [sm play];
        }
    }
}

static OSStatus renderCallback (void						*inRefCon,
                                AudioUnitRenderActionFlags	* ioActionFlags,
                                const AudioTimeStamp 		* inTimeStamp,
                                UInt32						inOutputBusNumber,
                                UInt32						inNumberFrames,
                                AudioBufferList				* ioData) {
    
    FBAudioPlayer *sm = (__bridge FBAudioPlayer *)inRefCon;
    return [sm renderFrames:inNumberFrames ioData:ioData];
}

static BOOL checkError(OSStatus error, const char *operation) {
    
    if (error == noErr)
        return NO;
    
    char str[20] = {0};
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1)= CFSwapInt32HostToBig(error);
    if (isprint(str[1])&& isprint(str[2])&& isprint(str[3])&& isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    
    LoggerStream(0, @"Error:%s (%s)\n", operation, str);
    
    //exit(1);
    
    return YES;
}
