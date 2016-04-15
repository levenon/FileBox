//
//  FBVideoPlayer.h
//  FileBox
//
//  Created by Marke Jave on 16/4/15.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBMovieDecoder.h"
#import "FBAudioPlayer.h"
#import "FBMovieRenderView.h"

enum {
    
    FBMovieInfoSectionGeneral,
    FBMovieInfoSectionVideo,
    FBMovieInfoSectionAudio,
    FBMovieInfoSectionSubtitles,
    FBMovieInfoSectionMetadata,
    FBMovieInfoSectionCount,
};

enum {
    
    FBMovieInfoGeneralFormat,
    FBMovieInfoGeneralBitrate,
    FBMovieInfoGeneralCount,
};

@interface FBMovieParameter :NSObject

@property(nonatomic, assign)CGFloat minBufferedDuration;

@property(nonatomic, assign)CGFloat maxBufferedDuration;

@property(nonatomic, assign)CGFloat deinterlacingEnable;

@end

@interface FBVideoPlayer : NSObject

@property (nonatomic, assign)CGFloat                 bufferedDuration;
@property (nonatomic, assign)CGFloat                 minBufferedDuration;
@property (nonatomic, assign)CGFloat                 maxBufferedDuration;
@property (nonatomic, assign)BOOL                    buffered;

@property (nonatomic, assign)BOOL                    savedIdleTimer;

@property (nonatomic, strong)FBMovieParameter        *parameter;

@property (nonatomic, assign)BOOL                    playing;
@property (nonatomic, assign)BOOL                    decoding;
@property (nonatomic, strong)FBArtworkFrame          *artworkFrame;

@property (nonatomic, strong)FBMovieDecoder          *decoder;
@property (nonatomic, strong)dispatch_queue_t        dispatchQueue;
@property (nonatomic, strong)NSMutableArray          *videoFrames;
@property (nonatomic, strong)NSMutableArray          *audioFrames;
@property (nonatomic, strong)NSMutableArray          *subtitles;
@property (nonatomic, strong)NSData                  *currentAudioFrame;
@property (nonatomic, assign)NSUInteger              currentAudioFramePos;
@property (nonatomic, assign)CGFloat                 moviePosition;

@property (nonatomic, assign)NSTimeInterval          tickCorrectionTime;
@property (nonatomic, assign)NSTimeInterval          tickCorrectionPosition;
@property (nonatomic, assign)NSUInteger              tickCounter;

@property (nonatomic, assign)id<FBMovieRenderView>   glView;

- (instancetype)initWithRenderView:(id<FBMovieRenderView>)renderView;

@end
