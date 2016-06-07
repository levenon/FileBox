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

@property(nonatomic, assign) NSUInteger evMinBufferedDuration;

@property(nonatomic, assign) NSUInteger evMaxBufferedDuration;

@property(nonatomic, assign) NSUInteger evDeinterlacingEnable;

@end

@class FBVideoPlayer;

@protocol FBVideoPlayerDelegate <NSObject>

- (void)epVideoPlayer:(FBVideoPlayer *)videoPlayer didFailedSetupWithError:(NSError *)error;

- (void)epVideoPlayer:(FBVideoPlayer *)videoPlayer didUpdatePlayState:(BOOL)playState;

- (void)epVideoPlayer:(FBVideoPlayer *)videoPlayer didUpdatePosition:(CGFloat)position;

- (void)epWillBeginLoadingBuffersInVideoPlayer:(FBVideoPlayer *)videoPlayer;

- (void)epDidEndLoadingBuffersInVideoPlayer:(FBVideoPlayer *)videoPlayer;

@end

@interface FBVideoPlayer : NSObject

@property(nonatomic, assign) CGFloat evPosition;

@property(nonatomic, assign, readonly) CGFloat evDuration;

@property(nonatomic, assign, readonly, getter=evIsOver) BOOL evOver;

@property(nonatomic, assign, readonly, getter=evIsPlaying) BOOL evPlay;

@property(nonatomic, copy  , readonly) NSString              *evResourcePath;

@property(nonatomic, strong, readonly) FBMovieParameter      *evParameter;

@property(nonatomic, assign, readonly) id<FBMovieRenderView> evvRenderContent;

@property(nonatomic, strong, readonly) XLFMulticastDelegate<FBVideoPlayerDelegate> *evDelegates;

- (instancetype)initWithPath:(NSString *)path
                   parameter:(FBMovieParameter *)parameter
                  renderView:(id<FBMovieRenderView>)renderView;

- (void)efPlay;
- (void)efPause;

@end
