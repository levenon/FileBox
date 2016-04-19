//
//  FBMovieDecoder.m
//  FBMovie
//
//  Created by Kolyvan on 15.10.12.
//  Copyright (c)2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/FBMovie
//  this file is part of FBMovie
//  FBMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import "FBMovieDecoder.h"
#import <Accelerate/Accelerate.h>
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "libavutil/pixdesc.h"

#import "FBLogger.h"
#import "FBAudioPlayer.h"

////////////////////////////////////////////////////////////////////////////////
NSString * FBMovieErrorDomain = @"ru.kolyvan.FBMovie";
static void FFLog(void* context, int level, const char* format, va_list args);

static NSError * FBMovieErrorConstructor (NSInteger code, id info){
    
    NSDictionary *userInfo = nil;
    
    if ([info isKindOfClass:[NSDictionary class]]) {
        
        userInfo = info;
        
    } else if ([info isKindOfClass:[NSString class]]) {
        
        userInfo = @{ NSLocalizedDescriptionKey :info };
    }
    
    return [NSError errorWithDomain:FBMovieErrorDomain
                               code:code
                           userInfo:userInfo];
}

static NSString * errorMessage (FBMovieError errorCode){
    
    switch (errorCode) {
        case FBMovieErrorNone:
            return @"";
            
        case FBMovieErrorOpenFile:
            return NSLocalizedString(@"Unable to open file", nil);
            
        case FBMovieErrorStreamInfoNotFound:
            return NSLocalizedString(@"Unable to find stream information", nil);
            
        case FBMovieErrorStreamNotFound:
            return NSLocalizedString(@"Unable to find stream", nil);
            
        case FBMovieErrorCodecNotFound:
            return NSLocalizedString(@"Unable to find codec", nil);
            
        case FBMovieErrorOpenCodec:
            return NSLocalizedString(@"Unable to open codec", nil);
            
        case FBMovieErrorAllocateFrame:
            return NSLocalizedString(@"Unable to allocate frame", nil);
            
        case FBMovieErroSetupScaler:
            return NSLocalizedString(@"Unable to setup scaler", nil);
            
        case FBMovieErroReSampler:
            return NSLocalizedString(@"Unable to setup resampler", nil);
            
        case FBMovieErroUnsupported:
            return NSLocalizedString(@"The ability is not supported", nil);
    }
}

////////////////////////////////////////////////////////////////////////////////

static BOOL audioCodecIsSupported(AVCodecContext *audio, FBAudioPlayer * audioPlayer){
    
    if (audio->sample_fmt == AV_SAMPLE_FMT_S16) {
        
        return  (int)audioPlayer.samplingRate == audio->sample_rate &&
        audioPlayer.numOutputChannels == audio->channels;
    }
    return NO;
}

#ifdef DEBUG
static void fillSignal(SInt16 *outData,  UInt32 numFrames, UInt32 numChannels){
    
    static float phase = 0.0;
    
    for (int i=0; i < numFrames; ++i)
    {
        for (int iChannel = 0; iChannel < numChannels; ++iChannel)
        {
            float theta = phase * M_PI * 2;
            outData[i*numChannels + iChannel] = sin(theta)* (float)INT16_MAX;
        }
        phase += 1.0 / (44100 / 440.0);
        if (phase > 1.0)phase = -1;
    }
}

static void fillSignalF(float *outData,  UInt32 numFrames, UInt32 numChannels){
    
    static float phase = 0.0;
    
    for (int i=0; i < numFrames; ++i)
    {
        for (int iChannel = 0; iChannel < numChannels; ++iChannel)
        {
            float theta = phase * M_PI * 2;
            outData[i*numChannels + iChannel] = sin(theta);
        }
        phase += 1.0 / (44100 / 440.0);
        if (phase > 1.0)phase = -1;
    }
}

static void testConvertYUV420pToRGB(AVFrame * frame, uint8_t *outbuf, int linesize, int height){
    
    const int linesizeY = frame->linesize[0];
    const int linesizeU = frame->linesize[1];
    const int linesizeV = frame->linesize[2];
    
    assert(height == frame->height);
    assert(linesize  <= linesizeY * 3);
    assert(linesizeY == linesizeU * 2);
    assert(linesizeY == linesizeV * 2);
    
    uint8_t *pY = frame->data[0];
    uint8_t *pU = frame->data[1];
    uint8_t *pV = frame->data[2];
    
    const int width = linesize / 3;
    
    for (int y = 0; y < height; y += 2) {
        
        uint8_t *dst1 = outbuf + y       * linesize;
        uint8_t *dst2 = outbuf + (y + 1)* linesize;
        
        uint8_t *py1  = pY  +  y       * linesizeY;
        uint8_t *py2  = py1 +            linesizeY;
        uint8_t *pu   = pU  + (y >> 1)* linesizeU;
        uint8_t *pv   = pV  + (y >> 1)* linesizeV;
        
        for (int i = 0; i < width; i += 2) {
            
            int Y1 = py1[i];
            int Y2 = py2[i];
            int Y3 = py1[i+1];
            int Y4 = py2[i+1];
            
            int U = pu[(i >> 1)] - 128;
            int V = pv[(i >> 1)] - 128;
            
            int dr = (int)(             1.402f * V);
            int dg = (int)(0.344f * U + 0.714f * V);
            int db = (int)(1.772f * U);
            
            int r1 = Y1 + dr;
            int g1 = Y1 - dg;
            int b1 = Y1 + db;
            
            int r2 = Y2 + dr;
            int g2 = Y2 - dg;
            int b2 = Y2 + db;
            
            int r3 = Y3 + dr;
            int g3 = Y3 - dg;
            int b3 = Y3 + db;
            
            int r4 = Y4 + dr;
            int g4 = Y4 - dg;
            int b4 = Y4 + db;
            
            r1 = r1 > 255 ? 255 :r1 < 0 ? 0 :r1;
            g1 = g1 > 255 ? 255 :g1 < 0 ? 0 :g1;
            b1 = b1 > 255 ? 255 :b1 < 0 ? 0 :b1;
            
            r2 = r2 > 255 ? 255 :r2 < 0 ? 0 :r2;
            g2 = g2 > 255 ? 255 :g2 < 0 ? 0 :g2;
            b2 = b2 > 255 ? 255 :b2 < 0 ? 0 :b2;
            
            r3 = r3 > 255 ? 255 :r3 < 0 ? 0 :r3;
            g3 = g3 > 255 ? 255 :g3 < 0 ? 0 :g3;
            b3 = b3 > 255 ? 255 :b3 < 0 ? 0 :b3;
            
            r4 = r4 > 255 ? 255 :r4 < 0 ? 0 :r4;
            g4 = g4 > 255 ? 255 :g4 < 0 ? 0 :g4;
            b4 = b4 > 255 ? 255 :b4 < 0 ? 0 :b4;
            
            dst1[3*i + 0] = r1;
            dst1[3*i + 1] = g1;
            dst1[3*i + 2] = b1;
            
            dst2[3*i + 0] = r2;
            dst2[3*i + 1] = g2;
            dst2[3*i + 2] = b2;
            
            dst1[3*i + 3] = r3;
            dst1[3*i + 4] = g3;
            dst1[3*i + 5] = b3;
            
            dst2[3*i + 3] = r4;
            dst2[3*i + 4] = g4;
            dst2[3*i + 5] = b4;
        }
    }
}
#endif

static void avStreamFPSTimeBase(AVStream *st, CGFloat defaultTimeBase, CGFloat *pFPS, CGFloat *pTimeBase){
    
    CGFloat fps, timebase;
    
    if (st->time_base.den && st->time_base.num)
        timebase = av_q2d(st->time_base);
    else if(st->codec->time_base.den && st->codec->time_base.num)
        timebase = av_q2d(st->codec->time_base);
    else
        timebase = defaultTimeBase;
    
    if (st->codec->ticks_per_frame != 1) {
        LoggerStream(0, @"WARNING:st.codec.ticks_per_frame=%d", st->codec->ticks_per_frame);
        //timebase *= st->codec->ticks_per_frame;
    }
    
    if (st->avg_frame_rate.den && st->avg_frame_rate.num)
        fps = av_q2d(st->avg_frame_rate);
    else if (st->r_frame_rate.den && st->r_frame_rate.num)
        fps = av_q2d(st->r_frame_rate);
    else
        fps = 1.0 / timebase;
    
    if (pFPS)
        *pFPS = fps;
    if (pTimeBase)
        *pTimeBase = timebase;
}

static NSArray *collectStreams(AVFormatContext *formatCtx, enum AVMediaType codecType){
    
    NSMutableArray *ma = [NSMutableArray array];
    for (NSInteger i = 0; i < formatCtx->nb_streams; ++i)
        if (codecType == formatCtx->streams[i]->codec->codec_type)
            [ma addObject:[NSNumber numberWithInteger:i]];
    return [ma copy];
}

static NSData * copyFrameData(UInt8 *src, int linesize, int width, int height){
    
    width = MIN(linesize, width);
    NSMutableData *md = [NSMutableData dataWithLength:width * height];
    Byte *dst = md.mutableBytes;
    for (NSUInteger i = 0; i < height; ++i) {
        memcpy(dst, src, width);
        dst += width;
        src += linesize;
    }
    return md;
}

static BOOL isNetworkPath (NSString *path){
    
    NSRange r = [path rangeOfString:@":"];
    if (r.location == NSNotFound)
        return NO;
    NSString *scheme = [path substringToIndex:r.length];
    if ([scheme isEqualToString:@"file"])
        return NO;
    return YES;
}

static int interrupt_callback(void *ctx);

////////////////////////////////////////////////////////////////////////////////

@interface FBMovieFrame()
@property (readwrite, nonatomic)CGFloat position;
@property (readwrite, nonatomic)CGFloat duration;
@end

@implementation FBMovieFrame
@end

@interface FBAudioFrame()
@property (readwrite, nonatomic, strong)NSData *samples;
@end

@implementation FBAudioFrame
- (FBMovieFrameType)type { return FBMovieFrameTypeAudio; }
@end

@interface FBVideoFrame()
@property (readwrite, nonatomic)int width;
@property (readwrite, nonatomic)int height;
@end

@implementation FBVideoFrame
- (FBMovieFrameType)type { return FBMovieFrameTypeVideo; }
@end

@interface FBVideoFrameRGB ()
@property (readwrite, nonatomic)NSUInteger linesize;
@property (readwrite, nonatomic, strong)NSData *rgb;
@end

@implementation FBVideoFrameRGB
- (FBVideoFrameFormat)format { return FBVideoFrameFormatRGB; }
- (UIImage *)asImage{
    
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(self.rgb));
    if (provider) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace) {
            CGImageRef imageRef = CGImageCreate(self.width,
                                                self.height,
                                                8,
                                                24,
                                                self.linesize,
                                                colorSpace,
                                                kCGBitmapByteOrderDefault,
                                                provider,
                                                NULL,
                                                YES, // NO
                                                kCGRenderingIntentDefault);
            
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            CGColorSpaceRelease(colorSpace);
        }
        CGDataProviderRelease(provider);
    }
    
    return image;
}
@end

@interface FBVideoFrameYUV()
@property (readwrite, nonatomic, strong)NSData *luma;
@property (readwrite, nonatomic, strong)NSData *chromaB;
@property (readwrite, nonatomic, strong)NSData *chromaR;
@end

@implementation FBVideoFrameYUV
- (FBVideoFrameFormat)format { return FBVideoFrameFormatYUV; }
@end

@interface FBArtworkFrame()
@property (readwrite, nonatomic, strong)NSData *picture;
@end

@implementation FBArtworkFrame
- (FBMovieFrameType)type { return FBMovieFrameTypeArtwork; }
- (UIImage *)asImage{
    
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(self.picture));
    if (provider) {
        
        CGImageRef imageRef = CGImageCreateWithJPEGDataProvider(provider,
                                                                NULL,
                                                                YES,
                                                                kCGRenderingIntentDefault);
        if (imageRef) {
            
            image = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        CGDataProviderRelease(provider);
    }
    
    return image;
    
}
@end

@interface FBSubtitleFrame()
@property (readwrite, nonatomic, strong)NSString *text;
@end

@implementation FBSubtitleFrame
- (FBMovieFrameType)type { return FBMovieFrameTypeSubtitle; }
@end

////////////////////////////////////////////////////////////////////////////////

@interface FBMovieDecoder ()

@property (nonatomic, assign) BOOL               isNetwork;
@property (nonatomic, assign) BOOL               isEOF;
@property (nonatomic, copy  ) NSString           *resourcePath;
@property (nonatomic, assign) AVFormatContext    *formatCtx;
@property (nonatomic, assign) AVCodecContext     *videoCodecCtx;
@property (nonatomic, assign) AVCodecContext     *audioCodecCtx;
@property (nonatomic, assign) AVCodecContext     *subtitleCodecCtx;
@property (nonatomic, assign) AVFrame            *videoFrame;
@property (nonatomic, assign) AVFrame            *audioFrame;
@property (nonatomic, assign) int                videoStream;
@property (nonatomic, assign) int                audioStream;
@property (nonatomic, assign) int                subtitleStream;
@property (nonatomic, assign) AVPicture          picture;
@property (nonatomic, assign) BOOL               pictureValid;
@property (nonatomic, assign) struct SwsContext  *swsContext;
@property (nonatomic, assign) CGFloat            videoTimeBase;
@property (nonatomic, assign) CGFloat            audioTimeBase;
@property (nonatomic, strong) NSArray            *videoStreams;
@property (nonatomic, strong) NSArray            *audioStreams;
@property (nonatomic, strong) NSArray            *subtitleStreams;
@property (nonatomic, assign) SwrContext         *swrContext;
@property (nonatomic, assign) void               *swrBuffer;
@property (nonatomic, assign) NSUInteger         swrBufferSize;
@property (nonatomic, strong) NSDictionary       *info;
@property (nonatomic, assign) FBVideoFrameFormat videoFrameFormat;
@property (nonatomic, assign) NSUInteger         artworkStream;
@property (nonatomic, assign) NSInteger          subtitleASSEvents;

@end

@implementation FBMovieDecoder

- (CGFloat)duration{
    
    if (!self.formatCtx)
        return 0;
    if (self.formatCtx->duration == AV_NOPTS_VALUE)
        return MAXFLOAT;
    return (CGFloat)self.formatCtx->duration / AV_TIME_BASE;
}

- (void)setPosition:(CGFloat)position{
    
    _position = position;
    self.isEOF = NO;
	   
    if (self.videoStream != -1) {
        int64_t ts = (int64_t)(position / self.videoTimeBase);
        avformat_seek_file(self.formatCtx, self.videoStream, ts, ts, ts, AVSEEK_FLAG_FRAME);
        avcodec_flush_buffers(self.videoCodecCtx);
    }
    
    if (self.audioStream != -1) {
        int64_t ts = (int64_t)(position / self.audioTimeBase);
        avformat_seek_file(self.formatCtx, self.audioStream, ts, ts, ts, AVSEEK_FLAG_FRAME);
        avcodec_flush_buffers(self.audioCodecCtx);
    }
}

- (int)frameWidth{
    
    return self.videoCodecCtx ? self.videoCodecCtx->width :0;
}

- (int)frameHeight{
    
    return self.videoCodecCtx ? self.videoCodecCtx->height :0;
}

- (CGFloat)sampleRate{
    
    return self.audioCodecCtx ? self.audioCodecCtx->sample_rate :0;
}

- (NSUInteger)audioStreamsCount{
    
    return [self.audioStreams count];
}

- (NSUInteger)subtitleStreamsCount{
    
    return [self.subtitleStreams count];
}

- (NSInteger)selectedAudioStream{
    
    if (self.audioStream == -1)
        return -1;
    NSNumber *n = [NSNumber numberWithInteger:self.audioStream];
    return [self.audioStreams indexOfObject:n];
}

- (void)setSelectedAudioStream:(NSInteger)selectedAudioStream{
    
    int audioStream = [self.audioStreams[selectedAudioStream] intValue];
    [self closeAudioStream];
    FBMovieError errCode = [self openAudioStream:audioStream];
    if (FBMovieErrorNone != errCode) {
        LoggerAudio(0, @"%@", errorMessage(errCode));
    }
}

- (NSInteger)selectedSubtitleStream{
    
    if (self.subtitleStream == -1)
        return -1;
    return [self.subtitleStreams indexOfObject:@(self.subtitleStream)];
}

- (void)setSelectedSubtitleStream:(NSInteger)selected{
    
    [self closeSubtitleStream];
    
    if (selected == -1) {
        
        self.subtitleStream = -1;
        
    } else {
        
        int subtitleStream = [self.subtitleStreams[selected] intValue];
        FBMovieError errCode = [self openSubtitleStream:subtitleStream];
        if (FBMovieErrorNone != errCode) {
            LoggerStream(0, @"%@", errorMessage(errCode));
        }
    }
}

- (BOOL)validAudio{
    
    return self.audioStream != -1;
}

- (BOOL)validVideo{
    
    return self.videoStream != -1;
}

- (BOOL)validSubtitles{
    
    return self.subtitleStream != -1;
}

- (NSDictionary *)info{
    
    if (!self.info) {
        
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        
        if (self.formatCtx) {
            
            const char *formatName = self.formatCtx->iformat->name;
            [md setValue:[NSString stringWithCString:formatName encoding:NSUTF8StringEncoding]
                  forKey:@"format"];
            
            if (self.formatCtx->bit_rate) {
                
                [md setValue:[NSNumber numberWithInt:self.formatCtx->bit_rate]
                      forKey:@"bitrate"];
            }
            
            if (self.formatCtx->metadata) {
                
                NSMutableDictionary *md1 = [NSMutableDictionary dictionary];
                
                AVDictionaryEntry *tag = NULL;
                while((tag = av_dict_get(self.formatCtx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX))) {
                    
                    [md1 setValue:[NSString stringWithCString:tag->value encoding:NSUTF8StringEncoding]
                           forKey:[NSString stringWithCString:tag->key encoding:NSUTF8StringEncoding]];
                }
                
                [md setValue:[md1 copy] forKey:@"metadata"];
            }
            
            char buf[256];
            
            if (self.videoStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for (NSNumber *n in self.videoStreams) {
                    AVStream *st = self.formatCtx->streams[n.integerValue];
                    avcodec_string(buf, sizeof(buf), st->codec, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Video:"])
                        s = [s substringFromIndex:@"Video:".length];
                    [ma addObject:s];
                }
                md[@"video"] = ma.copy;
            }
            
            if (self.audioStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for (NSNumber *n in self.audioStreams) {
                    AVStream *st = self.formatCtx->streams[n.integerValue];
                    
                    NSMutableString *ms = [NSMutableString string];
                    AVDictionaryEntry *lang = av_dict_get(st->metadata, "language", NULL, 0);
                    if (lang && lang->value) {
                        [ms appendFormat:@"%s ", lang->value];
                    }
                    
                    avcodec_string(buf, sizeof(buf), st->codec, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Audio:"])
                        s = [s substringFromIndex:@"Audio:".length];
                    [ms appendString:s];
                    
                    [ma addObject:ms.copy];
                }
                md[@"audio"] = ma.copy;
            }
            
            if (self.subtitleStreams.count) {
                NSMutableArray *ma = [NSMutableArray array];
                for (NSNumber *n in self.subtitleStreams) {
                    AVStream *st = self.formatCtx->streams[n.integerValue];
                    
                    NSMutableString *ms = [NSMutableString string];
                    AVDictionaryEntry *lang = av_dict_get(st->metadata, "language", NULL, 0);
                    if (lang && lang->value) {
                        [ms appendFormat:@"%s ", lang->value];
                    }
                    
                    avcodec_string(buf, sizeof(buf), st->codec, 1);
                    NSString *s = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
                    if ([s hasPrefix:@"Subtitle:"])
                        s = [s substringFromIndex:@"Subtitle:".length];
                    [ms appendString:s];
                    
                    [ma addObject:ms.copy];
                }
                md[@"subtitles"] = ma.copy;
            }
            
        }
        
        self.info = [md copy];
    }
    
    return self.info;
}

- (NSString *)videoStreamFormatName{
    
    if (!self.videoCodecCtx)
        return nil;
    
    if (self.videoCodecCtx->pix_fmt == AV_PIX_FMT_NONE)
        return @"";
    
    const char *name = av_get_pix_fmt_name(self.videoCodecCtx->pix_fmt);
    return name ? [NSString stringWithCString:name encoding:NSUTF8StringEncoding] :@"?";
}

- (CGFloat)startTime{
    
    if (self.videoStream != -1) {
        
        AVStream *st = self.formatCtx->streams[self.videoStream];
        if (AV_NOPTS_VALUE != st->start_time)
            return st->start_time * self.videoTimeBase;
        return 0;
    }
    
    if (self.audioStream != -1) {
        
        AVStream *st = self.formatCtx->streams[self.audioStream];
        if (AV_NOPTS_VALUE != st->start_time)
            return st->start_time * self.audioTimeBase;
        return 0;
    }
    
    return 0;
}

+ (void)initialize{
    
    av_log_set_callback(FFLog);
    av_register_all();
    avformat_network_init();
}

+ (id)movieDecoderWithContentPath:(NSString *)resourcePath
                      audioPlayer:(FBAudioPlayer *)audioPlayer
                            error:(NSError **)error;{
    
    return [[[self class] alloc] initWithContentPath:resourcePath audioPlayer:audioPlayer error:error];
}

- (id)initWithContentPath:(NSString *)resourcePath
              audioPlayer:(FBAudioPlayer *)audioPlayer
                    error:(NSError **)error;{
    self = [super init];
    if (self) {
        
        [self setAudioPlayer:audioPlayer];
        
        [self openFile:resourcePath error:error];
    }
    return self;
}

- (void)dealloc{
    
    LoggerStream(2, @"%@ dealloc", self);
    
    [self closeFile];
    
    [self setAudioPlayer:nil];
    [self setResourcePath:nil];
    [self setInfo:nil];
    [self setInterruptCallback:nil];
    [self setVideoFrame:nil];
    [self setAudioFrame:nil];
    [self setSubtitleStreams:nil];
}

#pragma mark - private

- (BOOL)openFile:(NSString *)resourcePath
           error:(NSError **)perror{
    
    NSAssert(resourcePath, @"nil path");
    NSAssert(!self.formatCtx, @"already open");
    
    self.isNetwork = isNetworkPath(resourcePath);
    
    static BOOL needNetworkInit = YES;
    if (needNetworkInit && self.isNetwork) {
        
        needNetworkInit = NO;
        avformat_network_init();
    }
    
    [self setResourcePath:resourcePath];
    
    FBMovieError errCode = [self openInput:resourcePath];
    
    if (errCode == FBMovieErrorNone) {
        
        FBMovieError videoErr = [self openVideoStream];
        FBMovieError audioErr = [self openAudioStream];
        
        self.subtitleStream = -1;
        
        if (videoErr != FBMovieErrorNone &&
            audioErr != FBMovieErrorNone) {
            
            errCode = videoErr; // both fails
            
        } else {
            
            self.subtitleStreams = collectStreams(self.formatCtx, AVMEDIA_TYPE_SUBTITLE);
        }
    }
    
    if (errCode != FBMovieErrorNone) {
        
        [self closeFile];
        NSString *errMsg = errorMessage(errCode);
        LoggerStream(0, @"%@, %@", errMsg, [[self resourcePath] lastPathComponent]);
        if (perror) {
            *perror = FBMovieErrorConstructor(errCode, errMsg);
        }
        return NO;
    }
    
    return YES;
}

- (FBMovieError)openInput:(NSString *)path{
    
    AVFormatContext *formatCtx = NULL;
    
    if (self.interruptCallback) {
        
        formatCtx = avformat_alloc_context();
        if (!formatCtx)
            return FBMovieErrorOpenFile;
        
        AVIOInterruptCB cb = {interrupt_callback, (__bridge void *)(self)};
        formatCtx->interrupt_callback = cb;
    }
    
    if (avformat_open_input(&formatCtx, [path cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL)< 0) {
        
        if (formatCtx)
            avformat_free_context(formatCtx);
        return FBMovieErrorOpenFile;
    }
    
    if (avformat_find_stream_info(formatCtx, NULL)< 0) {
        
        avformat_close_input(&formatCtx);
        return FBMovieErrorStreamInfoNotFound;
    }
    
    av_dump_format(formatCtx, 0, [path.lastPathComponent cStringUsingEncoding:NSUTF8StringEncoding], false);
    
    self.formatCtx = formatCtx;
    return FBMovieErrorNone;
}

- (FBMovieError)openVideoStream{
    
    FBMovieError errCode = FBMovieErrorStreamNotFound;
    self.videoStream = -1;
    self.artworkStream = -1;
    self.videoStreams = collectStreams(self.formatCtx, AVMEDIA_TYPE_VIDEO);
    for (NSNumber *n in self.videoStreams) {
        
        const int iStream = n.intValue;
        
        if (0 == (self.formatCtx->streams[iStream]->disposition & AV_DISPOSITION_ATTACHED_PIC)) {
            
            errCode = [self openVideoStream:iStream];
            if (errCode == FBMovieErrorNone)
                break;
            
        } else {
            
            self.artworkStream = iStream;
        }
    }
    
    return errCode;
}

- (FBMovieError)openVideoStream:(int)videoStream{
    
    // get a pointer to the codec context for the video stream
    AVCodecContext *codecCtx = self.formatCtx->streams[videoStream]->codec;
    
    // find the decoder for the video stream
    AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
    if (!codec)
        return FBMovieErrorCodecNotFound;
    
    // inform the codec that we can handle truncated bitstreams -- i.e.,
    // bitstreams where frame boundaries can fall in the middle of packets
    //if(codec->capabilities & CODEC_CAP_TRUNCATED)
    //    self.codecCtx->flags |= CODEC_FLAG_TRUNCATED;
    
    // open codec
    if (avcodec_open2(codecCtx, codec, NULL)< 0)
        return FBMovieErrorOpenCodec;
    
    self.videoFrame = av_frame_alloc();
    
    if (!self.videoFrame) {
        avcodec_close(codecCtx);
        return FBMovieErrorAllocateFrame;
    }
    
    self.videoStream = videoStream;
    self.videoCodecCtx = codecCtx;
    
    // determine fps
    
    AVStream *st = self.formatCtx->streams[self.videoStream];
    avStreamFPSTimeBase(st, 0.04, &_fps, &_videoTimeBase);
    
    LoggerVideo(1, @"video codec size:%d:%d fps:%.3f tb:%f",
                self.frameWidth,
                self.frameHeight,
                self.fps,
                self.videoTimeBase);
    
    LoggerVideo(1, @"video start time %f", st->start_time * self.videoTimeBase);
    LoggerVideo(1, @"video disposition %d", st->disposition);
    
    return FBMovieErrorNone;
}

- (FBMovieError)openAudioStream{
    
    FBMovieError errCode = FBMovieErrorStreamNotFound;
    self.audioStream = -1;
    self.audioStreams = collectStreams(self.formatCtx, AVMEDIA_TYPE_AUDIO);
    for (NSNumber *n in self.audioStreams) {
        
        errCode = [self openAudioStream:n.intValue];
        if (errCode == FBMovieErrorNone)
            break;
    }
    return errCode;
}

- (FBMovieError)openAudioStream:(int)audioStream{
    
    AVCodecContext *codecCtx = self.formatCtx->streams[audioStream]->codec;
    SwrContext *swrContext = NULL;
    
    FBAudioPlayer *audioPlayer = [self audioPlayer];
    AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
    if(!codec)
        return FBMovieErrorCodecNotFound;
    
    if (avcodec_open2(codecCtx, codec, NULL)< 0)
        return FBMovieErrorOpenCodec;
    
    if (!audioCodecIsSupported(codecCtx, audioPlayer)) {
        
        swrContext = swr_alloc_set_opts(NULL,
                                        av_get_default_channel_layout(audioPlayer.numOutputChannels),
                                        AV_SAMPLE_FMT_S16,
                                        audioPlayer.samplingRate,
                                        av_get_default_channel_layout(codecCtx->channels),
                                        codecCtx->sample_fmt,
                                        codecCtx->sample_rate,
                                        0,
                                        NULL);
        
        if (!swrContext ||
            swr_init(swrContext)) {
            
            if (swrContext)
                swr_free(&swrContext);
            avcodec_close(codecCtx);
            
            return FBMovieErroReSampler;
        }
    }
    
    self.audioFrame = av_frame_alloc();
    
    if (!self.audioFrame) {
        if (swrContext)
            swr_free(&swrContext);
        avcodec_close(codecCtx);
        return FBMovieErrorAllocateFrame;
    }
    
    self.audioStream = audioStream;
    self.audioCodecCtx = codecCtx;
    self.swrContext = swrContext;
    
    AVStream *st = self.formatCtx->streams[self.audioStream];
    avStreamFPSTimeBase(st, 0.025, 0, &_audioTimeBase);
    
    LoggerAudio(1, @"audio codec smr:%.d fmt:%d chn:%d tb:%f %@",
                self.audioCodecCtx->sample_rate,
                self.audioCodecCtx->sample_fmt,
                self.audioCodecCtx->channels,
                self.audioTimeBase,
                self.swrContext ? @"resample" :@"");
    
    return FBMovieErrorNone;
}

- (FBMovieError)openSubtitleStream:(int)subtitleStream{
    
    AVCodecContext *codecCtx = self.formatCtx->streams[subtitleStream]->codec;
    
    AVCodec *codec = avcodec_find_decoder(codecCtx->codec_id);
    if(!codec)
        return FBMovieErrorCodecNotFound;
    
    const AVCodecDescriptor *codecDesc = avcodec_descriptor_get(codecCtx->codec_id);
    if (codecDesc && (codecDesc->props & AV_CODEC_PROP_BITMAP_SUB)) {
        // Only text based subtitles supported
        return FBMovieErroUnsupported;
    }
    
    if (avcodec_open2(codecCtx, codec, NULL)< 0)
        return FBMovieErrorOpenCodec;
    
    self.subtitleStream = subtitleStream;
    self.subtitleCodecCtx = codecCtx;
    
    if (codecDesc) {
        
        LoggerStream(1, @"subtitle codec:'%s' mode:%d enc:%s",
                     codecDesc->name,
                     codecCtx->sub_charenc_mode,
                     codecCtx->sub_charenc);
    }
    
    self.subtitleASSEvents = -1;
    
    if (codecCtx->subtitle_header_size) {
        
        NSString *s = [[NSString alloc] initWithBytes:codecCtx->subtitle_header
                                               length:codecCtx->subtitle_header_size
                                             encoding:NSASCIIStringEncoding];
        
        if (s.length) {
            
            NSArray *fields = [FBMovieSubtitleASSParser parseEvents:s];
            if (fields.count && [fields.lastObject isEqualToString:@"Text"]) {
                self.subtitleASSEvents = fields.count;
                LoggerStream(2, @"subtitle ass events:%@", [fields componentsJoinedByString:@","]);
            }
        }
    }
    
    return FBMovieErrorNone;
}

-(void)closeFile{
    
    [self closeAudioStream];
    [self closeVideoStream];
    [self closeSubtitleStream];
    
    self.videoStreams = nil;
    self.audioStreams = nil;
    self.subtitleStreams = nil;
    
    if (self.formatCtx) {
        
        self.formatCtx->interrupt_callback.opaque = NULL;
        self.formatCtx->interrupt_callback.callback = NULL;
        
        avformat_close_input(&_formatCtx);
        
        self.formatCtx = NULL;
    }
}

- (void)closeVideoStream{
    
    self.videoStream = -1;
    
    [self closeScaler];
    
    if (self.videoFrame) {
        
        av_free(self.videoFrame);
        self.videoFrame = NULL;
    }
    
    if (self.videoCodecCtx) {
        
        avcodec_close(self.videoCodecCtx);
        self.videoCodecCtx = NULL;
    }
}

- (void)closeAudioStream{
    
    self.audioStream = -1;
    
    if (self.swrBuffer) {
        
        free(self.swrBuffer);
        self.swrBuffer = NULL;
        self.swrBufferSize = 0;
    }
    
    if (self.swrContext) {
        
        swr_free(&_swrContext);
        self.swrContext = NULL;
    }
    
    if (self.audioFrame) {
        
        av_free(self.audioFrame);
        self.audioFrame = NULL;
    }
    
    if (self.audioCodecCtx) {
        
        avcodec_close(self.audioCodecCtx);
        self.audioCodecCtx = NULL;
    }
}

- (void)closeSubtitleStream{
    
    self.subtitleStream = -1;
    
    if (self.subtitleCodecCtx) {
        
        avcodec_close(self.subtitleCodecCtx);
        self.subtitleCodecCtx = NULL;
    }
}

- (void)closeScaler{
    
    if (self.swsContext) {
        sws_freeContext(self.swsContext);
        self.swsContext = NULL;
    }
    
    if (self.pictureValid) {
        avpicture_free(&_picture);
        self.pictureValid = NO;
    }
}

- (BOOL)setupScaler{
    
    [self closeScaler];
    
    self.pictureValid = avpicture_alloc(&_picture,
                                    PIX_FMT_RGB24,
                                    self.videoCodecCtx->width,
                                    self.videoCodecCtx->height)== 0;
    
    if (!self.pictureValid)
        return NO;
    
    self.swsContext = sws_getCachedContext(self.swsContext,
                                       self.videoCodecCtx->width,
                                       self.videoCodecCtx->height,
                                       self.videoCodecCtx->pix_fmt,
                                       self.videoCodecCtx->width,
                                       self.videoCodecCtx->height,
                                       PIX_FMT_RGB24,
                                       SWS_FAST_BILINEAR,
                                       NULL, NULL, NULL);
    
    return self.swsContext != NULL;
}

- (FBVideoFrame *)handleVideoFrame{
    
    if (!self.videoFrame->data[0])
        return nil;
    
    FBVideoFrame *frame;
    
    if (self.videoFrameFormat == FBVideoFrameFormatYUV) {
        
        FBVideoFrameYUV * yuvFrame = [[FBVideoFrameYUV alloc] init];
        
        yuvFrame.luma = copyFrameData(self.videoFrame->data[0],
                                      self.videoFrame->linesize[0],
                                      self.videoCodecCtx->width,
                                      self.videoCodecCtx->height);
        
        yuvFrame.chromaB = copyFrameData(self.videoFrame->data[1],
                                         self.videoFrame->linesize[1],
                                         self.videoCodecCtx->width / 2,
                                         self.videoCodecCtx->height / 2);
        
        yuvFrame.chromaR = copyFrameData(self.videoFrame->data[2],
                                         self.videoFrame->linesize[2],
                                         self.videoCodecCtx->width / 2,
                                         self.videoCodecCtx->height / 2);
        
        frame = yuvFrame;
        
    } else {
        
        if (!self.swsContext &&
            ![self setupScaler]) {
            
            LoggerVideo(0, @"fail setup video scaler");
            return nil;
        }
        
        sws_scale(self.swsContext,
                  (const uint8_t **)self.videoFrame->data,
                  self.videoFrame->linesize,
                  0,
                  self.videoCodecCtx->height,
                  self.picture.data,
                  self.picture.linesize);
        
        
        FBVideoFrameRGB *rgbFrame = [[FBVideoFrameRGB alloc] init];
        
        rgbFrame.linesize = self.picture.linesize[0];
        rgbFrame.rgb = [NSData dataWithBytes:self.picture.data[0]
                                      length:rgbFrame.linesize * self.videoCodecCtx->height];
        frame = rgbFrame;
    }
    
    frame.width = self.videoCodecCtx->width;
    frame.height = self.videoCodecCtx->height;
    frame.position = av_frame_get_best_effort_timestamp(self.videoFrame)* self.videoTimeBase;
    
    const int64_t frameDuration = av_frame_get_pkt_duration(self.videoFrame);
    if (frameDuration) {
        
        frame.duration = frameDuration * self.videoTimeBase;
        frame.duration += self.videoFrame->repeat_pict * self.videoTimeBase * 0.5;
        
        //if (self.videoFrame->repeat_pict > 0) {
        //    LoggerVideo(0, @"self.videoFrame.repeat_pict %d", self.videoFrame->repeat_pict);
        //}
        
    } else {
        
        // sometimes, ffmpeg unable to determine a frame duration
        // as example yuvj420p stream from web camera
        frame.duration = 1.0 / self.fps;
    }
    
#if 0
    LoggerVideo(2, @"VFD:%.4f %.4f | %lld ",
                frame.position,
                frame.duration,
                av_frame_get_pkt_pos(self.videoFrame));
#endif
    
    return frame;
}

- (FBAudioFrame *)handleAudioFrame{
    
    if (!self.audioFrame->data[0])
        return nil;
    
    FBAudioPlayer *audioPlayer = [self audioPlayer];
    
    const NSUInteger numChannels = [audioPlayer numOutputChannels];
    NSInteger numFrames;
    
    void * audioData;
    
    if (self.swrContext) {
        
        const int ratio = MAX(1, audioPlayer.samplingRate / self.audioCodecCtx->sample_rate)*
        MAX(1, audioPlayer.numOutputChannels / self.audioCodecCtx->channels)* 2;
        
        const int bufSize = av_samples_get_buffer_size(NULL,
                                                       audioPlayer.numOutputChannels,
                                                       self.audioFrame->nb_samples * ratio,
                                                       AV_SAMPLE_FMT_S16,
                                                       1);
        
        if (!self.swrBuffer || self.swrBufferSize < bufSize) {
            self.swrBufferSize = bufSize;
            self.swrBuffer = realloc(self.swrBuffer, self.swrBufferSize);
        }
        
        Byte *outbuf[2] = { self.swrBuffer, 0 };
        
        numFrames = swr_convert(self.swrContext,
                                outbuf,
                                self.audioFrame->nb_samples * ratio,
                                (const uint8_t **)self.audioFrame->data,
                                self.audioFrame->nb_samples);
        
        if (numFrames < 0) {
            LoggerAudio(0, @"fail resample audio");
            return nil;
        }
        
        //int64_t delay = swr_get_delay(self.swrContext, audioManager.samplingRate);
        //if (delay > 0)
        //    LoggerAudio(0, @"resample delay %lld", delay);
        
        audioData = self.swrBuffer;
        
    } else {
        
        if (self.audioCodecCtx->sample_fmt != AV_SAMPLE_FMT_S16) {
            NSAssert(false, @"bucheck, audio format is invalid");
            return nil;
        }
        
        audioData = self.audioFrame->data[0];
        numFrames = self.audioFrame->nb_samples;
    }
    
    const NSUInteger numElements = numFrames * numChannels;
    NSMutableData *data = [NSMutableData dataWithLength:numElements * sizeof(float)];
    
    float scale = 1.0 / (float)INT16_MAX ;
    vDSP_vflt16((SInt16 *)audioData, 1, data.mutableBytes, 1, numElements);
    vDSP_vsmul(data.mutableBytes, 1, &scale, data.mutableBytes, 1, numElements);
    
    FBAudioFrame *frame = [[FBAudioFrame alloc] init];
    frame.position = av_frame_get_best_effort_timestamp(self.audioFrame)* self.audioTimeBase;
    frame.duration = av_frame_get_pkt_duration(self.audioFrame)* self.audioTimeBase;
    frame.samples = data;
    
    if (frame.duration == 0) {
        // sometimes ffmpeg can't determine the duration of audio frame
        // especially of wma/wmv format
        // so in this case must compute duration
        frame.duration = frame.samples.length / (sizeof(float)* numChannels * audioPlayer.samplingRate);
    }
    
#if 0
    LoggerAudio(2, @"AFD:%.4f %.4f | %.4f ",
                frame.position,
                frame.duration,
                frame.samples.length / (8.0 * 44100.0));
#endif
    
    return frame;
}

- (FBSubtitleFrame *)handleSubtitle:(AVSubtitle *)pSubtitle{
    
    NSMutableString *ms = [NSMutableString string];
    
    for (NSUInteger i = 0; i < pSubtitle->num_rects; ++i) {
        
        AVSubtitleRect *rect = pSubtitle->rects[i];
        if (rect) {
            
            if (rect->text) { // rect->type == SUBTITLE_TEXT
                
                NSString *s = [NSString stringWithUTF8String:rect->text];
                if (s.length)[ms appendString:s];
                
            } else if (rect->ass && self.subtitleASSEvents != -1) {
                
                NSString *s = [NSString stringWithUTF8String:rect->ass];
                if (s.length) {
                    
                    NSArray *fields = [FBMovieSubtitleASSParser parseDialogue:s numFields:self.subtitleASSEvents];
                    if (fields.count && [fields.lastObject length]) {
                        
                        s = [FBMovieSubtitleASSParser removeCommandsFromEventText:fields.lastObject];
                        if (s.length)[ms appendString:s];
                    }
                }
            }
        }
    }
    
    if (!ms.length)
        return nil;
    
    FBSubtitleFrame *frame = [[FBSubtitleFrame alloc] init];
    frame.text = [ms copy];
    frame.position = pSubtitle->pts / AV_TIME_BASE + pSubtitle->start_display_time;
    frame.duration = (CGFloat)(pSubtitle->end_display_time - pSubtitle->start_display_time)/ 1000.f;
    
#if 0
    LoggerStream(2, @"SUB:%.4f %.4f | %@",
                 frame.position,
                 frame.duration,
                 frame.text);
#endif
    
    return frame;
}

- (BOOL)interruptDecoder{
    
    if (self.interruptCallback)
        return self.interruptCallback();
    return NO;
}

#pragma mark - public

- (BOOL)setupVideoFrameFormat:(FBVideoFrameFormat)format{
    
    if (format == FBVideoFrameFormatYUV &&
        self.videoCodecCtx &&
        (self.videoCodecCtx->pix_fmt == AV_PIX_FMT_YUV420P || self.videoCodecCtx->pix_fmt == AV_PIX_FMT_YUVJ420P)) {
        
        self.videoFrameFormat = FBVideoFrameFormatYUV;
        return YES;
    }
    
    self.videoFrameFormat = FBVideoFrameFormatRGB;
    return self.videoFrameFormat == format;
}

- (NSArray *)decodeFrames:(CGFloat)minDuration{
    
    if (self.videoStream == -1 &&
        self.audioStream == -1)
        return nil;
    
    NSMutableArray *result = [NSMutableArray array];
    
    AVPacket packet;
    
    CGFloat decodedDuration = 0;
    
    BOOL finished = NO;
    
    while (!finished) {
        
        if (av_read_frame(self.formatCtx, &packet)< 0) {
            self.isEOF = YES;
            break;
        }
        
        if (packet.stream_index ==self.videoStream) {
            
            int pktSize = packet.size;
            
            while (pktSize > 0) {
                
                int gotframe = 0;
                int len = avcodec_decode_video2(self.videoCodecCtx,
                                                self.videoFrame,
                                                &gotframe,
                                                &packet);
                
                if (len < 0) {
                    LoggerVideo(0, @"decode video error, skip packet");
                    break;
                }
                
                if (gotframe) {
                    
                    if (self.deinterlacingEnable &&
                        self.videoFrame->interlaced_frame) {
                        
                        avpicture_deinterlace((AVPicture*)self.videoFrame,
                                              (AVPicture*)self.videoFrame,
                                              self.videoCodecCtx->pix_fmt,
                                              self.videoCodecCtx->width,
                                              self.videoCodecCtx->height);
                    }
                    
                    FBVideoFrame *frame = [self handleVideoFrame];
                    if (frame) {
                        
                        [result addObject:frame];
                        
                        _position = frame.position;
                        decodedDuration += frame.duration;
                        if (decodedDuration > minDuration)
                            finished = YES;
                    }
                }
                
                if (0 == len)
                    break;
                
                pktSize -= len;
            }
            
        } else if (packet.stream_index == self.audioStream) {
            
            int pktSize = packet.size;
            
            while (pktSize > 0) {
                
                int gotframe = 0;
                int len = avcodec_decode_audio4(self.audioCodecCtx,
                                                self.audioFrame,
                                                &gotframe,
                                                &packet);
                
                if (len < 0) {
                    LoggerAudio(0, @"decode audio error, skip packet");
                    break;
                }
                
                if (gotframe) {
                    
                    FBAudioFrame * frame = [self handleAudioFrame];
                    if (frame) {
                        
                        [result addObject:frame];
                        
                        if (self.videoStream == -1) {
                            
                            _position = frame.position;
                            decodedDuration += frame.duration;
                            if (decodedDuration > minDuration)
                                finished = YES;
                        }
                    }
                }
                
                if (0 == len)
                    break;
                
                pktSize -= len;
            }
            
        } else if (packet.stream_index == self.artworkStream) {
            
            if (packet.size) {
                
                FBArtworkFrame *frame = [[FBArtworkFrame alloc] init];
                frame.picture = [NSData dataWithBytes:packet.data length:packet.size];
                [result addObject:frame];
            }
            
        } else if (packet.stream_index == self.subtitleStream) {
            
            int pktSize = packet.size;
            
            while (pktSize > 0) {
                
                AVSubtitle subtitle;
                int gotsubtitle = 0;
                int len = avcodec_decode_subtitle2(self.subtitleCodecCtx,
                                                   &subtitle,
                                                   &gotsubtitle,
                                                   &packet);
                
                if (len < 0) {
                    LoggerStream(0, @"decode subtitle error, skip packet");
                    break;
                }
                
                if (gotsubtitle) {
                    
                    FBSubtitleFrame *frame = [self handleSubtitle:&subtitle];
                    if (frame) {
                        [result addObject:frame];
                    }
                    avsubtitle_free(&subtitle);
                }
                
                if (0 == len)
                    break;
                
                pktSize -= len;
            }
        }
        
        av_free_packet(&packet);
    }
    
    return result;
}

@end

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

static int interrupt_callback(void *ctx){
    
    if (!ctx)
        return 0;
    __unsafe_unretained FBMovieDecoder *p = (__bridge FBMovieDecoder *)ctx;
    const BOOL r = [p interruptDecoder];
    if (r)LoggerStream(1, @"DEBUG:INTERRUPT_CALLBACK!");
    return r;
}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

@implementation FBMovieSubtitleASSParser

+ (NSArray *)parseEvents:(NSString *)events{
    
    NSRange r = [events rangeOfString:@"[Events]"];
    if (r.location != NSNotFound) {
        
        NSUInteger pos = r.location + r.length;
        
        r = [events rangeOfString:@"Format:"
                          options:0
                            range:NSMakeRange(pos, events.length - pos)];
        
        if (r.location != NSNotFound) {
            
            pos = r.location + r.length;
            r = [events rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                        options:0
                                          range:NSMakeRange(pos, events.length - pos)];
            
            if (r.location != NSNotFound) {
                
                NSString *format = [events substringWithRange:NSMakeRange(pos, r.location - pos)];
                NSArray *fields = [format componentsSeparatedByString:@","];
                if (fields.count > 0) {
                    
                    NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
                    NSMutableArray *ma = [NSMutableArray array];
                    for (NSString *s in fields) {
                        [ma addObject:[s stringByTrimmingCharactersInSet:ws]];
                    }
                    return ma;
                }
            }
        }
    }
    
    return nil;
}

+ (NSArray *)parseDialogue:(NSString *)dialogue
                 numFields:(NSUInteger)numFields{
    
    if ([dialogue hasPrefix:@"Dialogue:"]) {
        
        NSMutableArray *ma = [NSMutableArray array];
        
        NSRange r = {@"Dialogue:".length, 0};
        NSUInteger n = 0;
        
        while (r.location != NSNotFound && n++ < numFields) {
            
            const NSUInteger pos = r.location + r.length;
            
            r = [dialogue rangeOfString:@","
                                options:0
                                  range:NSMakeRange(pos, dialogue.length - pos)];
            
            const NSUInteger len = r.location == NSNotFound ? dialogue.length - pos :r.location - pos;
            NSString *p = [dialogue substringWithRange:NSMakeRange(pos, len)];
            p = [p stringByReplacingOccurrencesOfString:@"\\N" withString:@"\n"];
            [ma addObject:p];
        }
        
        return ma;
    }
    
    return nil;
}

+ (NSString *)removeCommandsFromEventText:(NSString *)text{
    
    NSMutableString *ms = [NSMutableString string];
    
    NSScanner *scanner = [NSScanner scannerWithString:text];
    while (!scanner.isAtEnd) {
        
        NSString *s;
        if ([scanner scanUpToString:@"{\\" intoString:&s]) {
            
            [ms appendString:s];
        }
        
        if (!([scanner scanString:@"{\\" intoString:nil] &&
              [scanner scanUpToString:@"}" intoString:nil] &&
              [scanner scanString:@"}" intoString:nil])) {
            
            break;
        }
    }
    
    return ms;
}

@end

static void FFLog(void* context, int level, const char* format, va_list args) {
    @autoreleasepool {
        //Trim time at the beginning and new line at the end
        NSString* message = [[NSString alloc] initWithFormat:[NSString stringWithUTF8String:format] arguments:args];
        switch (level) {
            case 0:
            case 1:
                LoggerStream(0, @"%@", [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
                break;
            case 2:
                LoggerStream(1, @"%@", [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
                break;
            case 3:
            case 4:
                LoggerStream(2, @"%@", [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
                break;
            default:
                LoggerStream(3, @"%@", [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]);
                break;
        }
    }
}

