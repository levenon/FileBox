//
//  KXMovieDecoder.h
//  KXmovie
//
//  Created by Kolyvan on 15.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/KXmovie
//  this file is part of KXMovie
//  KXMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

extern NSString * KXmovieErrorDomain;

typedef enum {
    
    KXMovieErrorNone,
    KXMovieErrorOpenFile,
    KXMovieErrorStreamInfoNotFound,
    KXMovieErrorStreamNotFound,
    KXMovieErrorCodecNotFound,
    KXMovieErrorOpenCodec,
    KXMovieErrorAllocateFrame,
    KXMovieErroSetupScaler,
    KXMovieErroReSampler,
    KXMovieErroUnsupported,
    
} KXMovieError;

typedef enum {
    
    KXMovieFrameTypeAudio,
    KXMovieFrameTypeVideo,
    KXMovieFrameTypeArtwork,
    KXMovieFrameTypeSubtitle,
    
} KXMovieFrameType;

typedef enum {
        
    KXVideoFrameFormatRGB,
    KXVideoFrameFormatYUV,
    
} KXVideoFrameFormat;

@interface KXMovieFrame : NSObject
@property (readonly, nonatomic) KXMovieFrameType type;
@property (readonly, nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@end

@interface KXAudioFrame : KXMovieFrame
@property (readonly, nonatomic, strong) NSData *samples;
@end

@interface KXVideoFrame : KXMovieFrame
@property (readonly, nonatomic) KXVideoFrameFormat format;
@property (readonly, nonatomic) int width;
@property (readonly, nonatomic) int height;
@end

@interface KXVideoFrameRGB : KXVideoFrame
@property (readonly, nonatomic) NSUInteger linesize;
@property (readonly, nonatomic, strong) NSData *rgb;
- (UIImage *) asImage;
@end

@interface KXVideoFrameYUV : KXVideoFrame
@property (readonly, nonatomic, strong) NSData *luma;
@property (readonly, nonatomic, strong) NSData *chromaB;
@property (readonly, nonatomic, strong) NSData *chromaR;
@end

@interface KXArtworkFrame : KXMovieFrame
@property (readonly, nonatomic, strong) NSData *picture;
- (UIImage *) asImage;
@end

@interface KXSubtitleFrame : KXMovieFrame
@property (readonly, nonatomic, strong) NSString *text;
@end

typedef BOOL(^KXMovieDecoderInterruptCallback)();

@interface KXMovieDecoder : NSObject

@property (readonly, nonatomic, strong) NSString *path;
@property (readonly, nonatomic) BOOL isEOF;
@property (readwrite,nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@property (readonly, nonatomic) CGFloat fps;
@property (readonly, nonatomic) CGFloat sampleRate;
@property (readonly, nonatomic) NSUInteger frameWidth;
@property (readonly, nonatomic) NSUInteger frameHeight;
@property (readonly, nonatomic) NSUInteger audioStreamsCount;
@property (readwrite,nonatomic) NSInteger selectedAudioStream;
@property (readonly, nonatomic) NSUInteger subtitleStreamsCount;
@property (readwrite,nonatomic) NSInteger selectedSubtitleStream;
@property (readonly, nonatomic) BOOL validVideo;
@property (readonly, nonatomic) BOOL validAudio;
@property (readonly, nonatomic) BOOL validSubtitles;
@property (readonly, nonatomic, strong) NSDictionary *info;
@property (readonly, nonatomic, strong) NSString *videoStreamFormatName;
@property (readonly, nonatomic) BOOL isNetwork;
@property (readonly, nonatomic) CGFloat startTime;
@property (readwrite, nonatomic) BOOL disableDeinterlacing;
@property (readwrite, nonatomic, strong) KXMovieDecoderInterruptCallback interruptCallback;

+ (id) movieDecoderWithContentPath: (NSString *) path
                             error: (NSError **) perror;

- (BOOL) openFile: (NSString *) path
            error: (NSError **) perror;

-(void) closeFile;

- (BOOL) setupVideoFrameFormat: (KXVideoFrameFormat) format;

- (NSArray *) decodeFrames: (CGFloat) minDuration;

@end

@interface KXMovieSubtitleASSParser : NSObject

+ (NSArray *) parseEvents: (NSString *) events;
+ (NSArray *) parseDialogue: (NSString *) dialogue
                  numFields: (NSUInteger) numFields;
+ (NSString *) removeCommandsFromEventText: (NSString *) text;

@end