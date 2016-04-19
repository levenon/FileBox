
//
//  FBVideoPlayer.m
//  FileBox
//
//  Created by Marke Jave on 16/4/15.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import "FBVideoPlayer.h"

#import "FBLogger.h"

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0

const char * FBVideoPlayerDecodeQueueIdentifier = "com.marikejave.filebox.videoPlayerDecodeQueueIdentifier";

@implementation FBMovieParameter

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setEvMinBufferedDuration:NSNotFound];
        [self setEvMaxBufferedDuration:NSNotFound];
        [self setEvDeinterlacingEnable:NSNotFound];
    }
    return self;
}

@end

@interface FBVideoPlayer ()

@property(nonatomic, strong) XLFMulticastDelegate<FBVideoPlayerDelegate> *evDelegates;

@property(nonatomic, strong) FBMovieDecoder             *evDecoder;

@property(nonatomic, strong) FBAudioPlayer              *evAudioPlayer;

@property(nonatomic, assign) id<FBMovieRenderView>      evvRenderContent;

@property(nonatomic, copy  ) NSString                   *evResourcePath;

@property(nonatomic, strong) FBMovieParameter           *evParameter;

@property(nonatomic, strong) dispatch_queue_t           evAsynDecodeQueue;

@property(nonatomic, strong) FBArtworkFrame             *evArtworkFrame;

@property(nonatomic, strong) NSMutableArray<FBVideoFrame *> *evDecodedVideoFrames;

@property(nonatomic, strong) NSMutableArray<FBAudioFrame *> *evDecodedAudioFrames;

@property(nonatomic, strong) NSMutableArray<FBSubtitleFrame *> *evDecodedSubtitleFrames;

@property(nonatomic, assign) CGFloat                 	evBufferedDuration;

@property(nonatomic, assign) BOOL                       evHasBuffered;

@property(nonatomic, assign, getter = evIsPlaying)      BOOL evPlay;

@property(nonatomic, assign, getter = evIsDecoding)     BOOL evDecode;

@property(nonatomic, assign, getter = evBeingInterrupted)   BOOL evInterrupted;

@property(nonatomic, strong) NSData                     *evCurrentAudioFrame;

@property(nonatomic, assign) NSUInteger                 evCurrentAudioPositon;

@property(nonatomic, assign) NSTimeInterval             evTickCorrectionInterval;

@property(nonatomic, assign) NSTimeInterval             evTickCorrectionPosition;

@property(nonatomic, assign) NSUInteger                 evTickCounter;

@end

@implementation FBVideoPlayer

+ (NSMutableDictionary *)shareMovieHistoryCache{
    
    static NSMutableDictionary *etMovieHistoryCache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        etMovieHistoryCache = [NSMutableDictionary dictionary];
    });
    return etMovieHistoryCache;
}

- (instancetype)initWithPath:(NSString *)path
                   parameter:(FBMovieParameter *)parameter
                  renderView:(id<FBMovieRenderView>)renderView;{
    self = [super init];
    if (self) {
        
        [self setEvResourcePath:path];
        [self setEvParameter:parameter];
        [self setEvvRenderContent:renderView];
        
        [self _efInitialDecoder];
    }
    return self;
}

#pragma mark - accessory

- (XLFMulticastDelegate<FBVideoPlayerDelegate> *)evDelegates{
    
    if (!_evDelegates) {
        
        _evDelegates = [[XLFMulticastDelegate<FBVideoPlayerDelegate> alloc] init];
    }
    return _evDelegates;
}

- (FBAudioPlayer *)evAudioPlayer{
    
    if (!_evAudioPlayer) {
        
        _evAudioPlayer = [[FBAudioPlayer alloc] init];
    }
    return _evAudioPlayer;
}

- (FBMovieDecoder *)evDecoder{
    
    if (!_evDecoder) {
        
        _evDecoder = [[FBMovieDecoder alloc] init];
    }
    return _evDecoder;
}

- (FBMovieParameter *)evParameter{
    
    if (!_evParameter) {
        
        _evParameter = [[FBMovieParameter alloc] init];
    }
    return _evParameter;
}

- (dispatch_queue_t)evAsynDecodeQueue{
    
    if (!_evAsynDecodeQueue) {
        
        _evAsynDecodeQueue = dispatch_queue_create(FBVideoPlayerDecodeQueueIdentifier, DISPATCH_QUEUE_SERIAL);;
    }
    return _evAsynDecodeQueue;
}

- (NSMutableArray<FBVideoFrame *> *)evDecodedVideoFrames{
    
    if (!_evDecodedVideoFrames) {
        
        _evDecodedVideoFrames = [NSMutableArray array];
    }
    return _evDecodedVideoFrames;
}

- (NSMutableArray<FBAudioFrame *> *)evDecodedAudioFrames{
    
    if (!_evDecodedAudioFrames) {
        
        _evDecodedAudioFrames = [NSMutableArray array];
    }
    return _evDecodedAudioFrames;
}

- (NSMutableArray<FBSubtitleFrame *> *)evDecodedSubtitleFrames{
    
    if (!_evDecodedSubtitleFrames) {
        
        _evDecodedSubtitleFrames = [NSMutableArray array];
    }
    return _evDecodedSubtitleFrames;
}

- (CGFloat)evDuration{
    
    return [[self evDecoder] duration];
}

- (void)setEvPosition:(CGFloat)evPosition{
    
    BOOL etIsPlaying = [self evIsPlaying];
    
    [self setEvPlay:NO];
    
    [self _efUpdateAudioStatus:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        [self _efUpdatePosition:evPosition playMode:etIsPlaying];
    });
}

#pragma mark - private

- (void)_efInitialDecoder{
    
    [self _efSetupAudioPlayer];
    
    [self _efSetupDecoder];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        
        NSError *error = nil;
        if (![[self evDecoder] openFile:[self evResourcePath] error:&error] || error) {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self _efFailedSetupDecoderWithError:error];
            });
        }
    });
}

- (void)_efSetupDecoder{
    
    [[self evDecoder] setAudioPlayer:[self evAudioPlayer]];
    
    [self _efSetupPlayParameter];
    
    [self _efSetupRenderView];
}

- (void)_efSetupAudioPlayer{
    
    [[self evAudioPlayer] activateAudioSession];
    
    @weakify(self);
    [[self evAudioPlayer] setOutputBlock:^(float *outData, UInt32 numFrames, UInt32 numChannels) {
        @strongify(self);
        
        [self efAudioCallbackFillData:outData numFrames:numFrames numChannels:numChannels];
    }];
}

- (void)_efSetupPlayParameter{
    
    CGFloat etMinBufferedDuration, etMaxBufferedDuration;
    
    if ([[self evDecoder] isNetwork]) {
        
        etMinBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
        etMaxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
        
    } else {
        
        etMinBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
        etMaxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
    }
    
    if (![[self evDecoder] validVideo]) {
        etMinBufferedDuration *= 10.0; // increase for audio
    }
    
    if (etMaxBufferedDuration < etMinBufferedDuration) {
        etMaxBufferedDuration = etMinBufferedDuration * 2;
    }
    // allow to tweak some parameters at runtime
    if ([[self evParameter] evMinBufferedDuration] == NSNotFound) {
        [[self evParameter] setEvMinBufferedDuration:etMinBufferedDuration];
    }
    
    if ([[self evParameter] evMaxBufferedDuration] == NSNotFound) {
        [[self evParameter] setEvMaxBufferedDuration:etMaxBufferedDuration];
    }
}

- (void)_efSetupRenderView{
    
    [[self evvRenderContent] epSetupWithDecoder:[self evDecoder]];
}

- (void)_efFailedSetupDecoderWithError:(NSError *)error{
    
    if ([self evDelegates] && [[self evDelegates] hasDelegateThatRespondsToSelector:@selector(epVideoPlayer:didFailedSetupWithError:)]) {
        
        [[self evDelegates] epVideoPlayer:self didFailedSetupWithError:error];
    }
    
    if ([self evvRenderContent] && [[self evvRenderContent] respondsToSelector:@selector(epDecoder:didFailedSetupWithError:)]) {
        
        [[self evvRenderContent] epDecoder:[self evDecoder] didFailedSetupWithError:error];
    }
}

#pragma mark - public

- (void)efRegisterNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarning)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)efDeregisterNotification{
    
    [[self evDelegates] removeAllDelegates];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc{
    
    [self efPause];
    
    [self efDeregisterNotification];
    
    [self setEvDelegates:nil];
    
    [self setEvAudioPlayer:nil];
    
    [self setEvDecoder:nil];
    
    [self setEvvRenderContent:nil];
    
    [self setEvResourcePath:nil];
    
    [self setEvParameter:nil];
    
    [self setEvAsynDecodeQueue:nil];
    
    [self setEvArtworkFrame:nil];
    
    [[self evDecodedVideoFrames] removeAllObjects];
    [self setEvDecodedVideoFrames:nil];
    
    [[self evDecodedAudioFrames] removeAllObjects];
    [self setEvDecodedAudioFrames:nil];
}

#pragma mark - actions

- (void)applicationWillResignActive:(NSNotification *)notification{
    
    [self efPause];
}

- (void)didReceiveMemoryWarning{
    
    [self efPause];
    
    [self efFreeBufferedFrames];
    
    if ([self evIsPlaying] && [[self evParameter] evMaxBufferedDuration]) {
        
        [[self evParameter] setEvMaxBufferedDuration:0];
        [[self evParameter] setEvMinBufferedDuration:0];
        
        [self efPlay];
        
        LoggerStream(0, @"didReceiveMemoryWarning, disable buffering and continue efPlaying");
    }
    else {
        
        // force ffmpeg to free allocated memory
        [self efFreeBufferedFrames];
        
        [[self evDecoder] closeFile];
        [[self evDecoder] openFile:nil error:nil];
        
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                    message:NSLocalizedString(@"Out of memory", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Close", nil)
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - public

-(void)efPlay{
    
    if ([self evIsPlaying]) {
        return;
    }
    
    if (![[self evDecoder] validVideo] &&
        ![[self evDecoder] validAudio]) {
        
        return;
    }
    
    if ([self evBeingInterrupted]) {
        return;
    }
    
    [self setEvPlay:YES];
    [self setEvInterrupted:NO];
    [self setEvTickCorrectionInterval:0];
    [self setEvTickCounter:0];
    
    [self _efAsyncDecodeFrames];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self tick];
    });
    
    if ([[self evDecoder] validAudio]) {
        [self _efUpdateAudioStatus:YES];
    }
    
    [self efRegisterNotification];
    LoggerStream(1, @"efPlay movie");
}

- (void)efPause{
    
    if (![self evIsPlaying]) {
        return;
    }
    
    [self setEvPlay:NO];
    
    [self _efUpdateAudioStatus:NO];
    
    if ([self evPosition] == 0 || [[self evDecoder] isEOF]) {
        [[[self class] shareMovieHistoryCache] removeObjectForKey:[self evResourcePath]];
    }
    else if (![[self evDecoder] isNetwork]) {
        [[[self class] shareMovieHistoryCache] setValue:[NSNumber numberWithFloat:_evPosition]
                                                 forKey:[self evResourcePath]];
    }
    
    [self efDeregisterNotification];
    LoggerStream(1, @"efPause movie");
}

- (void)restorePlay{
    
    NSNumber *etHistoryProgress = [[[self class] shareMovieHistoryCache] valueForKey:[[self evDecoder] resourcePath]];
    
    if (etHistoryProgress) {
        
        [self _efUpdatePosition:[etHistoryProgress floatValue] playMode:YES];
    }
    else {
        
        [self efPlay];
    }
}

- (void)efAudioCallbackFillData:(float *)outData
                    numFrames:(UInt32)numFrames
                  numChannels:(UInt32)numChannels{
    
    if ([self evHasBuffered]) {
        
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        
        while (numFrames > 0) {
            
            if (![self evCurrentAudioFrame]) {
                
                @synchronized([self evDecodedAudioFrames]) {
                    
                    NSUInteger etAudioFrameCount = [[self evDecodedAudioFrames] count];
                    
                    if (etAudioFrameCount) {
                        
                        FBAudioFrame *frame = [[self evDecodedAudioFrames] firstObject];
                        
                        if ([[self evDecoder] validVideo]) {
                            
                            const CGFloat etPositionDelta = [self evPosition] - [frame position];
                            
                            if (etPositionDelta < -0.1) {
                                
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
                                break;
                            }
                            
                            [[self evDecodedAudioFrames] removeObjectAtIndex:0];
                            
                            if (etPositionDelta > 0.1 && etAudioFrameCount > 1) {
                                
                                continue;
                            }
                        }
                        else {
                            
                            _evPosition = [frame position];
                            
                            [[self evDecodedAudioFrames] removeObjectAtIndex:0];
                            
                            [self setEvBufferedDuration:[self evBufferedDuration] - [frame duration]];
                        }
                        
                        [self setEvCurrentAudioPositon:0];
                        [self setEvCurrentAudioFrame:[frame samples]];
                    }
                }
            }
            
            if ([self evCurrentAudioFrame]) {
                
                const void *bytes = (Byte *)[[self evCurrentAudioFrame] bytes] + [self evCurrentAudioPositon];
                const NSUInteger bytesLeft = ([[self evCurrentAudioFrame] length] - [self evCurrentAudioPositon]);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft) {
                    self.evCurrentAudioPositon += bytesToCopy;
                }
                else {
                    [self setEvCurrentAudioFrame:nil];
                }
                
            }
            else {
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                
                break;
            }
        }
    }
}

- (void)_efUpdateAudioStatus:(BOOL)play{
    
    FBAudioPlayer *audioPlayer = [self evAudioPlayer];
    
    if (play && [[self evDecoder] validAudio]) {
        
        [audioPlayer play];
        
        LoggerAudio(2, @"audio device smr:%d fmt:%d chn:%d",
                    (int)audioPlayer.samplingRate,
                    (int)audioPlayer.numBytesPerSample,
                    (int)audioPlayer.numOutputChannels);
        
    } else {
        
        [audioPlayer pause];
    }
}

- (BOOL)_efAppendFrames:(NSArray *)frames{
    
    if ([[self evDecoder] validVideo]) {
        
        @synchronized([self evDecodedVideoFrames]) {
            
            for (FBVideoFrame *frame in frames) {
                
                if ([frame type] == FBMovieFrameTypeVideo) {
                    
                    [[self evDecodedVideoFrames] addObject:frame];
                    
                    self.evBufferedDuration += [frame duration];
                }
            }
        }
    }
    
    if ([[self evDecoder] validAudio]) {
        
        @synchronized([self evDecodedAudioFrames]) {
            
            for (FBAudioFrame *frame in frames) {
                
                if ([frame type] == FBMovieFrameTypeAudio) {
                    
                    [[self evDecodedAudioFrames] addObject:frame];
                    
                    if (![[self evDecoder] validVideo]) {
                        
                        self.evBufferedDuration += [frame duration];
                    }
                }
            }
        }
    }
    
    if (![[self evDecoder] validVideo]) {
        
        @synchronized([self evArtworkFrame]) {
            
            for (FBMovieFrame *frame in frames) {
                if (frame.type == FBMovieFrameTypeArtwork) {
                    self.evArtworkFrame = (FBArtworkFrame *)frame;
                }
            }
        }
    }
    
    if ([[self evDecoder] validSubtitles]) {
        
        @synchronized([self evDecodedSubtitleFrames]) {
            
            for (FBSubtitleFrame *frame in frames) {
                if ([frame type] == FBMovieFrameTypeSubtitle) {
                    [[self evDecodedSubtitleFrames] addObject:frame];
                }
            }
        }
    }
    
    return self.evIsPlaying && [self evBufferedDuration] < [[self evParameter] evMaxBufferedDuration];
}

- (BOOL)_efBeginDecodeFrames{
    
    //NSAssert(dispatch_get_current_queue()== _evAsynDecodeQueue, @"bugcheck");
    
    NSArray *frames = nil;
    
    if ([[self evDecoder] validVideo] || [[self evDecoder] validAudio]) {
        
        frames = [[self evDecoder] decodeFrames:0];
    }
    
    if (frames && [frames count]) {
        
        return [self _efAppendFrames:frames];
    }
    return NO;
}

- (void)_efWillAsyncDecodeFrames{
    
}

- (void)_efAsyncDecodeFrames{
    
    if (![self evDecoder]) {
        return;
    }
    
    @weakify(self);
    dispatch_async([self evAsynDecodeQueue], ^{
        @strongify(self);
        
        if (![self evIsPlaying]){
            return;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self _efWillAsyncDecodeFrames];
        });
        
        const CGFloat etBeginDuration = [[self evDecoder] isNetwork] ? .0f :0.1f;
        
        [self setEvDecode:YES];
        
        BOOL etContinueDecode = YES;
        
        while (etContinueDecode) {
            etContinueDecode = NO;
            
            @autoreleasepool {
                
                FBMovieDecoder *etMovieDecoder = [self evDecoder];
                
                if ([etMovieDecoder validVideo] || [etMovieDecoder validAudio]) {
                    
                    NSArray *etDecodedFrames = [etMovieDecoder decodeFrames:etBeginDuration];
                    
                    if ([etDecodedFrames count]) {
                        
                        etContinueDecode = [self _efAppendFrames:etDecodedFrames];
                    }
                }
            }
        }
        
        [self setEvDecode:NO];
    });
}

- (void)_efWillLoadBuffers{
    
    if ([self evDelegates] && [[self evDelegates] hasDelegateThatRespondsToSelector:@selector(epWillBeginLoadingBuffersInVideoPlayer:)]) {
        
        [[self evDelegates] epWillBeginLoadingBuffersInVideoPlayer:self];
    }
}

- (void)_efDidLoadedBuffers{
    
    if ([self evDelegates] && [[self evDelegates] hasDelegateThatRespondsToSelector:@selector(epDidEndLoadingBuffersInVideoPlayer:)]) {
        
        [[self evDelegates] epDidEndLoadingBuffersInVideoPlayer:self];
    }
}

- (void)_efDidUpdatePosition{
    
    if ([self evDelegates] && [[self evDelegates] hasDelegateThatRespondsToSelector:@selector(epVideoPlayer:didUpdatePosition:)]) {
        [[self evDelegates] epVideoPlayer:self didUpdatePosition:[self evPosition]];
    }
}

- (void)tick{
    
    if ([self evHasBuffered] && (([self evBufferedDuration] > [[self evParameter] evMinBufferedDuration]) || [[self evDecoder] isEOF])) {
        
        [self setEvTickCorrectionInterval:0];
        [self setEvHasBuffered:NO];
        
        [self _efDidLoadedBuffers];
    }
    
    CGFloat interval = 0;
    
    if (![self evHasBuffered]) {
        
        interval = [self _efPresentFrame];
    }
    if ([self evIsPlaying]) {
        
        const NSUInteger allFramesBufferCount = [[self evDecoder] validVideo] * [[self evDecodedVideoFrames] count] + [[self evDecoder] validAudio] * [[self evDecodedAudioFrames] count];
        
        if (!allFramesBufferCount) {
            
            if ([[self evDecoder] isEOF]) {
                
                [self efPause];
                [self _efDidUpdatePosition];
                return;
            }
            
            if ([[self evParameter] evMinBufferedDuration] > 0 && ![self evHasBuffered]) {
                
                [self setEvHasBuffered:YES];
                
                [self _efWillLoadBuffers];
            }
        }
        
        if (!allFramesBufferCount ||
            !([self evBufferedDuration] > [[self evParameter] evMinBufferedDuration]) ) {
            
            [self _efAsyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            
            [self tick];
        });
    }
    
    if ((self.evTickCounter++ % 3)== 0){
        [self _efDidUpdatePosition];
    }
}

- (CGFloat)tickCorrection{
    
    if ([self evHasBuffered]){
        return 0;
    }
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (![self evTickCorrectionInterval]) {
        
        _evTickCorrectionInterval = now;
        _evTickCorrectionPosition = [self evPosition];
        return 0;
    }
    
    NSTimeInterval dPosition = [self evPosition] - _evTickCorrectionPosition;
    NSTimeInterval dTime = now - _evTickCorrectionInterval;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_evTickCounter % 200)== 0)
    //    LoggerStream(1, @"tick correction %.4f", correction) ;
    
    if (correction > 1.f || correction < -1.f) {
        
        LoggerStream(1, @"tick correction reset %.2f", correction) ;
        correction = 0;
        _evTickCorrectionInterval = 0;
    }
    
    return correction;
}

- (CGFloat)_efPresentFrame{
    
    CGFloat interval = 0;
    
    if ([[self evDecoder] validVideo] || [[self evDecoder] validAudio]) {
        
        FBVideoFrame *frame;
        
        @synchronized([self evDecodedVideoFrames]) {
            
            if ([[self evDecodedVideoFrames] count] > 0) {
                
                frame = [[self evDecodedVideoFrames] firstObject];
                [[self evDecodedVideoFrames] removeObjectAtIndex:0];
                
                self.evBufferedDuration -= [frame duration];
            }
        }
        
        if (frame) {
            interval = [self presentVideoFrame:frame];
        }
        
    }
    else if ([[self evDecoder] validAudio]) {
        
        if ([self evArtworkFrame]) {
            
            interval = [self presentVideoFrame:[self evArtworkFrame]];
        }
    }
    
    return interval;
}

- (CGFloat)presentVideoFrame:(FBMovieFrame *)frame{
    
    if ([self evvRenderContent]) {
        
        [[self evvRenderContent] epRenderWithFrame:frame];
    }
    
    _evPosition = [frame position];
    
    return [frame duration];
}

- (BOOL)subtitleForPosition:(CGFloat)position
                     actual:(NSArray **)pActual
                   outdated:(NSArray **)pOutdated{
    
    if (![[self evDecodedSubtitleFrames] count]) {
        return NO;
    }
    
    NSMutableArray *actual = nil;
    NSMutableArray *outdated = nil;
    
    for (FBSubtitleFrame *subtitle in [self evDecodedSubtitleFrames]) {
        
        if (position < [subtitle position]) {
            // assume what subtitles sorted by position
            break;
        }
        else if (position >= ([subtitle position] + [subtitle duration]) ) {
            
            if (pOutdated) {
                if (!outdated) {
                    outdated = [NSMutableArray array];
                }
                [outdated addObject:subtitle];
            }
        }
        else {
            
            if (pActual) {
                if (!actual) {
                    actual = [NSMutableArray array];
                }
                [actual addObject:subtitle];
            }
        }
    }
    
    if (pActual) {
        *pActual = actual;
    }
    if (pOutdated) {
        *pOutdated = outdated;
    }
    return [actual count] || [outdated count];
}

- (void)_efUpdatePosition:(CGFloat)position
                 playMode:(BOOL)playMode{
    
    [self efFreeBufferedFrames];
    
    position = MIN([[self evDecoder] duration] - 1, MAX(0, position) );
    
    @weakify(self);
    dispatch_async(_evAsynDecodeQueue, ^{
        @strongify(self);
        
        [[self evDecoder] setPosition:position];
        
        if (playMode) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _evPosition = position;
                [self efPlay];
            });
        }
        else {
            
            [self _efBeginDecodeFrames];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _evPosition = position;
                
                [self _efPresentFrame];
                
                [self _efDidUpdatePosition];
            });
        }
    });
}

- (void)efFreeBufferedFrames{
    
    @synchronized([self evDecodedVideoFrames]) {
        [[self evDecodedVideoFrames] removeAllObjects];
    }
    
    @synchronized([self evDecodedAudioFrames]) {
        
        [[self evDecodedAudioFrames] removeAllObjects];
        [self setEvCurrentAudioFrame:nil];
    }
    
    @synchronized([self evDecodedSubtitleFrames]) {
        [[self evDecodedSubtitleFrames] removeAllObjects];
    }
    
    [self setEvBufferedDuration:0];
}

@end
