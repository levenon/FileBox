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

@class FBVideoPlayer;

@protocol FBVideoPlayerDelegate <NSObject>

- (void)epVideoPlayer:(FBVideoPlayer *)videoPlayer didUpdatePosition:(CGFloat)position;

@end

@interface FBVideoPlayer : NSObject

@property(nonatomic, assign) CGFloat evPosition;

@property(nonatomic, assign) CGFloat evDuration;

@property(nonatomic, assign, getter=evIsOver) BOOL evOver;

@property(nonatomic, assign, getter=evIsPlaying) BOOL evPlay;

@property(nonatomic, strong, readonly) FBMovieParameter      *parameter;

@property(nonatomic, assign, readonly) id<FBMovieRenderView> evvRenderContent;

@property(nonatomic, strong) XLFMulticastDelegate<FBVideoPlayerDelegate> *evProgressDelegates;

- (instancetype)initWithPath:(NSString *)path
                  renderView:(id<FBMovieRenderView>)renderView
                   parameter:(FBMovieParameter *)parameter;

- (void)efPlay;
- (void)efPause;

@end
