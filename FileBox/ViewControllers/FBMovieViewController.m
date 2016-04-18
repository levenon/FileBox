//
//  ViewController.m
//  FBMovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c)2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/FBMovie
//  this file is part of FBMovie
//  FBMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import "FBMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#import "FBMovieGLView.h"
#import "FBVideoPlayerControlView.h"
#import "FBLogger.h"
#import "FBVideoPlayer.h"


@interface FBMovieViewController ()

@property(nonatomic, strong) FBVideoPlayer *evVideoPlayer;

@property(nonatomic, strong) FBMovieGLView *evvRenderContent;

@property(nonatomic, strong) FBVideoPlayerControlView *evvVideoPlayerControl;

@property(nonatomic, strong) FBMovieParameter *evParameter;

@property(nonatomic, strong) NSString *evResourcePath;

@property(nonatomic, assign) BOOL evIdleTimerDisabled;

@property (nonatomic, assign, getter=evIsPlaying) BOOL evPlay;

@property (nonatomic, assign, getter=evIsPlayingAtLastTime) BOOL evPlayAtLastTime;

@end

@implementation FBMovieViewController

+ (id)movieViewControllerWithContentPath:(NSString *)path
                               parameter:(FBMovieParameter *)parameter;{
    
    return [[FBMovieViewController alloc] initWithContentPath:path parameter:parameter];
}

- (id)initWithContentPath:(NSString *)path
                parameter:(FBMovieParameter *)parameter;{
    self = [super init];
    if (self) {
        
        NSAssert(path.length, @"empty path");
        
        [self setEvParameter:parameter];
        [self setEvResourcePath:path];
        
        [self setEvPlayAtLastTime:YES];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    [[self view] setBackgroundColor:[UIColor blackColor]];
    [[self view] setTintColor:[UIColor blackColor]];
    
    [[self view] addSubview:[self evvRenderContent]];
    [[self view] addSubview:[self evvVideoPlayerControl]];
    
    [self _efInstallConstraints];
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self setEvIdleTimerDisabled:[[UIApplication sharedApplication] isIdleTimerDisabled]];
    
    if ([self evIsPlayingAtLastTime]) {
        [[self evVideoPlayer] efPlay];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:[self evIdleTimerDisabled]];
    
    [self setEvPlayAtLastTime:[[self evVideoPlayer] evIsPlaying]];
    
    [[self evVideoPlayer] efPause];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation{
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) ;
}

#pragma mark - accessory

- (FBMovieGLView *)evvRenderContent{
    
    if (!_evvRenderContent) {
        
        _evvRenderContent = [[FBMovieGLView alloc] initWithFrame:[[self view] bounds]];
        _evvRenderContent.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return _evvRenderContent;
}

- (FBVideoPlayer *)evVideoPlayer{
    
    if (!_evVideoPlayer) {
        
        _evVideoPlayer = [[FBVideoPlayer alloc] initWithPath:[self evResourcePath]
                                                   parameter:[self evParameter]
                                                  renderView:[self evvRenderContent]];
    }
    return _evVideoPlayer;
}

- (FBVideoPlayerControlView *)evvVideoPlayerControl{
    
    if (!_evvVideoPlayerControl) {
        
        _evvVideoPlayerControl = [[FBVideoPlayerControlView alloc] initWithPlayer:[self evVideoPlayer]];
    }
    return _evvVideoPlayerControl;
}

- (BOOL)evIsPlaying{
    
    return [[self evVideoPlayer] evIsPlaying];
}

- (UIImage *)evNavigationBarBackgroundImage{
    
    return [UIImage new];
}

#pragma mark - private

- (void)_efInstallConstraints{
    
    @weakify(self);
    [[self evvRenderContent] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
    
    [[self evvVideoPlayerControl] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - public

- (void)efPlay{
    
    [[self evVideoPlayer] efPlay];
}

- (void)efPause{
    
    [[self evVideoPlayer] efPause];
}

@end

