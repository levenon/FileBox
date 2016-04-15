
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

@end

@implementation FBVideoPlayer

+ (void)initialize{

    if (!FBMovieViewControllerHistory) {
        FBMovieViewControllerHistory = [NSMutableDictionary dictionary];
    }
}


- (instancetype)initWithRenderView:(id<FBMovieRenderView>)renderView;{
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
