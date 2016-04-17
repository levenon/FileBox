
//
//  FBVideoPlayer.m
//  FileBox
//
//  Created by Marke Jave on 16/4/15.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import "FBVideoPlayer.h"

static NSMutableDictionary * FBMovieViewControllerHistory;

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0


@implementation FBMovieParameter

- (instancetype)init{
    self = [super init];
    if (self){
        [self setMinBufferedDuration:NSNotFound];
        [self setMaxBufferedDuration:NSNotFound];
        [self setDeinterlacingEnable:YES];
    }
    return self;
}

@end

@interface FBVideoPlayer ()

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

@end

@implementation FBVideoPlayer

+ (void)initialize{

    if (!FBMovieViewControllerHistory) {
        FBMovieViewControllerHistory = [NSMutableDictionary dictionary];
    }
}

- (instancetype)initWithPath:(NSString *)path
                  renderView:(id<FBMovieRenderView>)renderView
                   parameter:(FBMovieParameter *)parameter;{
    self = [super init];
    if (self) {
        
        _moviePosition = 0;
        
        __weak FBMovieViewController *weakSelf = self;
        
        FBMovieDecoder *decoder = [[FBMovieDecoder alloc] init];
        
        decoder.interruptCallback = ^BOOL(){
            
            __strong FBMovieViewController *strongSelf = weakSelf;
            return strongSelf ? [strongSelf interruptDecoder] :YES;
        };
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSError *error = nil;
            [decoder openFile:path error:&error];
            
            __strong FBMovieViewController *strongSelf = weakSelf;
            if (strongSelf){
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [strongSelf setMovieDecoder:decoder withError:error];
                });
            }
        });
    }
    return self;
}

@end
