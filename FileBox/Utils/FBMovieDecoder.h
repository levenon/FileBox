//
//  FBMovieDecoder.h
//  FBMovie
//
//  Created by Kolyvan on 15.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/FBMovie
//  this file is part of FBMovie
//  FBMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

extern NSString * FBMovieErrorDomain;

typedef enum {
    
    FBMovieErrorNone,
    FBMovieErrorOpenFile,
    FBMovieErrorStreamInfoNotFound,
    FBMovieErrorStreamNotFound,
    FBMovieErrorCodecNotFound,
    FBMovieErrorOpenCodec,
    FBMovieErrorAllocateFrame,
    FBMovieErroSetupScaler,
    FBMovieErroReSampler,
    FBMovieErroUnsupported,
    
} FBMovieError;

typedef enum {
    
    FBMovieFrameTypeAudio,
    FBMovieFrameTypeVideo,
    FBMovieFrameTypeArtwork,
    FBMovieFrameTypeSubtitle,
    
} FBMovieFrameType;

typedef enum {
    
    FBVideoFrameFormatRGB,
    FBVideoFrameFormatYUV,
    
} FBVideoFrameFormat;

@interface FBMovieFrame :NSObject
@property (readonly, nonatomic) FBMovieFrameType type;
@property (readonly, nonatomic) CGFloat position;
@property (readonly, nonatomic) CGFloat duration;
@end

@interface FBAudioFrame :FBMovieFrame
@property (readonly, nonatomic, strong)NSData *samples;
@end

@interface FBVideoFrame :FBMovieFrame
@property (readonly, nonatomic) FBVideoFrameFormat format;
@property (readonly, nonatomic) int width;
@property (readonly, nonatomic) int height;
@end

@interface FBVideoFrameRGB :FBVideoFrame
@property (readonly, nonatomic) NSUInteger linesize;
@property (readonly, nonatomic, strong)NSData *rgb;
- (UIImage *)asImage;
@end

@interface FBVideoFrameYUV :FBVideoFrame
@property (readonly, nonatomic, strong)NSData *luma;
@property (readonly, nonatomic, strong)NSData *chromaB;
@property (readonly, nonatomic, strong)NSData *chromaR;
@end

@interface FBArtworkFrame :FBMovieFrame
@property (readonly, nonatomic, strong)NSData *picture;
- (UIImage *)asImage;
@end

@interface FBSubtitleFrame :FBMovieFrame
@property (readonly, nonatomic, strong)NSString *text;
@end

typedef BOOL(^FBMovieDecoderInterruptCallback)();

@class FBAudioPlayer;
@interface FBMovieDecoder :NSObject

@property (readonly, nonatomic, copy   ) NSString                        *resourcePath;
@property (readonly, nonatomic         ) BOOL                            isEOF;
@property (readwrite,nonatomic         ) CGFloat                         position;
@property (readonly, nonatomic         ) CGFloat                         duration;
@property (readonly, nonatomic         ) CGFloat                         fps;
@property (readonly, nonatomic         ) CGFloat                         sampleRate;
@property (readonly, nonatomic         ) int                             frameWidth;
@property (readonly, nonatomic         ) int                             frameHeight;
@property (readonly, nonatomic         ) NSUInteger                      audioStreamsCount;
@property (readwrite,nonatomic         ) NSInteger                       selectedAudioStream;
@property (readonly, nonatomic         ) NSUInteger                      subtitleStreamsCount;
@property (readwrite,nonatomic         ) NSInteger                       selectedSubtitleStream;
@property (readonly, nonatomic         ) BOOL                            validVideo;
@property (readonly, nonatomic         ) BOOL                            validAudio;
@property (readonly, nonatomic         ) BOOL                            validSubtitles;
@property (readonly, nonatomic, strong ) NSDictionary                    *info;
@property (readonly, nonatomic, copy   ) NSString                        *videoStreamFormatName;
@property (readonly, nonatomic         ) BOOL                            isNetwork;
@property (readonly, nonatomic         ) CGFloat                         startTime;
@property (readwrite, nonatomic        ) BOOL                            deinterlacingEnable;
@property (readwrite, nonatomic, strong) FBMovieDecoderInterruptCallback interruptCallback;

@property (nonatomic, strong) FBAudioPlayer *audioPlayer;

+ (id)movieDecoderWithContentPath:(NSString *)resourcePath
                      audioPlayer:(FBAudioPlayer *)audioPlayer
                            error:(NSError **)error;


- (id)initWithContentPath:(NSString *)resourcePath
          audioPlayer:(FBAudioPlayer *)audioPlayer
                error:(NSError **)error;

- (BOOL)openFile:(NSString *)resourcePath
           error:(NSError **)perror;

- (void)closeFile;

- (BOOL)setupVideoFrameFormat:(FBVideoFrameFormat)format;

- (NSArray *)decodeFrames:(CGFloat)minDuration;

@end

@interface FBMovieSubtitleASSParser :NSObject

+ (NSArray *)parseEvents:(NSString *)events;
+ (NSArray *)parseDialogue:(NSString *)dialogue
                 numFields:(NSUInteger)numFields;
+ (NSString *)removeCommandsFromEventText:(NSString *)text;

@end