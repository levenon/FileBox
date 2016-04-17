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

@end

@implementation FBMovieViewController

+ (id)movieViewControllerWithContentPath:(NSString *)path
                               parameter:(FBMovieParameter *)parameter;{
    
    [[FBAudioPlayer shareAudioPlayer] activateAudioSession];
    
    return [[FBMovieViewController alloc] initWithContentPath:path parameter:parameter];
}

- (id)initWithContentPath:(NSString *)path
                parameter:(FBMovieParameter *)parameter;{
    self = [super init];
    if (self){
        
        NSAssert(path.length, @"empty path");
        
        [self setEvParameter:parameter];
        [self setEvResourcePath:path];
    }
    return self;
}

- (void)loadView{
    [super loadView];
    
    [[self view] addSubview:[self evvRenderContent]];
    [[self view] addSubview:[self evvVideoPlayerControl]];
    
    [self _efInstallConstraints];
}

#pragma mark - accessory

- (FBMovieGLView *)evvRenderContent{
    
    if (!_evvRenderContent) {
        
        _evvRenderContent = [FBMovieGLView emptyFrameView];
    }
    return _evvRenderContent;
}

- (FBVideoPlayer *)evVideoPlayer{
    
    if (!_evVideoPlayer) {
        
        _evVideoPlayer = [[FBVideoPlayer alloc] initWithPath:[self evResourcePath]
                                                  renderView:[self evvRenderContent]
                                                   parameter:[self evParameter]];
    }
    return _evVideoPlayer;
}

- (FBVideoPlayerControlView *)evvVideoPlayerControl{
    
    if (!_evvVideoPlayerControl) {
        
        _evvVideoPlayerControl = [[FBVideoPlayerControlView alloc] initWithPlayer:[self evVideoPlayer]];
    }
    return _evvVideoPlayerControl;
}

#pragma mark - private

- (void)_efInstallConstraints{
    
    @weakify(self);
    [[self evvRenderContent] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    [[self evvVideoPlayerControl] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

- (void)dealloc{
    
    [self pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_dispatchQueue){
        // Not needed as of ARC.
        //        dispatch_release(_dispatchQueue);
        _dispatchQueue = NULL;
    }
    
    LoggerStream(1, @"%@ dealloc", self);
}

- (void)loadView{
    
    // LoggerStream(1, @"loadView");
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.tintColor = [UIColor blackColor];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.center = self.view.center;
    _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:_activityIndicatorView];
    
    CGFloat width = bounds.size.width;
    
#ifdef DEBUG
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,40,width-40,40)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = [UIColor redColor];
    _messageLabel.hidden = YES;
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.numberOfLines = 2;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_messageLabel];
#endif
    
    if (_decoder){
        
        [self setupPresentView];
        
    }
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
    if (self.playing){
        
        [self pause];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0){
            
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self play];
            
            LoggerStream(0, @"didReceiveMemoryWarning, disable buffering and continue playing");
            
        } else {
            
            // force ffmpeg to free allocated memory
            [_decoder closeFile];
            [_decoder openFile:nil error:nil];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                        message:NSLocalizedString(@"Out of memory", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }
        
    } else {
        
        [self freeBufferedFrames];
        [_decoder closeFile];
        [_decoder openFile:nil error:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.presentingViewController)
        [self fullscreenMode:YES];
    
    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
    
    if (_decoder){
        
        [self restorePlay];
        
    } else {
        
        [_activityIndicatorView startAnimating];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
    [_activityIndicatorView stopAnimating];
    
    if (_decoder){
        
        [self pause];
        
        if (_moviePosition == 0 || _decoder.isEOF)
            [FBMovieViewControllerHistory removeObjectForKey:_decoder.path];
        else if (!_decoder.isNetwork)
            [FBMovieViewControllerHistory setValue:[NSNumber numberWithFloat:_moviePosition]
                        forKey:_decoder.path];
    }
    
    if (_fullscreen)
        [self fullscreenMode:NO];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    
    [_activityIndicatorView stopAnimating];
    _buffered = NO;
    _interrupted = YES;
    
    LoggerStream(1, @"viewWillDisappear %@", self);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)applicationWillResignActive:(NSNotification *)notification{
    
    [self pause];
    
    LoggerStream(1, @"applicationWillResignActive");
}

#pragma mark - gesture recognizer

- (void)handlePan:(UIPanGestureRecognizer *)sender{
    
    if (sender.state == UIGestureRecognizerStateEnded){
        
        const CGPoint vt = [sender velocityInView:self.view];
        const CGPoint pt = [sender translationInView:self.view];
        const CGFloat sp = MAX(0.1, log10(fabs(vt.x))- 1.0);
        const CGFloat sc = fabs(pt.x)* 0.33 * sp;
        if (sc > 10){
            
            const CGFloat ff = pt.x > 0 ? 1.0 :-1.0;
            [self setMoviePosition:_moviePosition + ff * MIN(sc, 600.0)];
        }
        //LoggerStream(2, @"pan %.2f %.2f %.2f sec", pt.x, vt.x, sc);
    }
}

#pragma mark - public

-(void)play{
    
    if (self.playing)
        return;
    
    if (!_decoder.validVideo &&
        !_decoder.validAudio){
        
        return;
    }
    
    if (_interrupted)
        return;
    
    self.playing = YES;
    _interrupted = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    
#ifdef DEBUG
    _debugStartTime = -1;
#endif
    
    [self asyncDecodeFrames];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
    
    if (_decoder.validAudio)
        [self enableAudio:YES];
    
    LoggerStream(1, @"play movie");
}

- (void)pause{
    
    if (!self.playing)
        return;
    
    self.playing = NO;
    //_interrupted = YES;
    [self enableAudio:NO];
    LoggerStream(1, @"pause movie");
}

- (void)setMoviePosition:(CGFloat)position{
    
    BOOL playMode = self.playing;
    
    self.playing = NO;
    [self enableAudio:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self updatePosition:position playMode:playMode];
    });
}

#pragma mark - actions

- (void)doneDidTouch:(id)sender{
    
    if (self.presentingViewController || !self.navigationController)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)playDidTouch:(id)sender{
    
    if (self.playing)
        [self pause];
    else
        [self play];
}

- (void)forwardDidTouch:(id)sender{
    
    [self setMoviePosition:_moviePosition + 10];
}

- (void)rewindDidTouch:(id)sender{
    
    [self setMoviePosition:_moviePosition - 10];
}

- (void)progressDidChange:(id)sender{
    
    NSAssert(_decoder.duration != MAXFLOAT, @"bugcheck");
    UISlider *slider = sender;
    [self setMoviePosition:slider.value * _decoder.duration];
}

#pragma mark - private

- (void)setMovieDecoder:(FBMovieDecoder *)decoder
              withError:(NSError *)error{
    
    LoggerStream(2, @"setMovieDecoder");
    
    if (!error && decoder){
        
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("FBMovie", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        _audioFrames    = [NSMutableArray array];
        
        if (_decoder.subtitleStreamsCount){
            _subtitles = [NSMutableArray array];
        }
        
        if (_decoder.isNetwork){
            
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
            
        } else {
            
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
        
        // allow to tweak some parameters at runtime
        if ([self parameter]){
            
            if ([[self parameter] minBufferedDuration] != NSNotFound){
                _minBufferedDuration = [[self parameter] minBufferedDuration];
            }
            
            if ([[self parameter] maxBufferedDuration] != NSNotFound){
                _maxBufferedDuration = [[self parameter] maxBufferedDuration];
            }
            
            if ([[self parameter] maxBufferedDuration] != NSNotFound){
                _decoder.deinterlacingEnable = [[self parameter] deinterlacingEnable];
            }
            
            if (_maxBufferedDuration < _minBufferedDuration){
                _maxBufferedDuration = _minBufferedDuration * 2;
            }
        }
        
        LoggerStream(2, @"buffered limit:%.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
        
        if (self.isViewLoaded){
            
            [self setupPresentView];
            
            if (_activityIndicatorView.isAnimating){
                
                [_activityIndicatorView stopAnimating];
                // if (self.view.window)
                [self restorePlay];
            }
        }
        
    } else {
        
        if (self.isViewLoaded && self.view.window){
            
            [_activityIndicatorView stopAnimating];
            if (!_interrupted)
                [self handleDecoderMovieError:error];
        }
    }
}

- (void)restorePlay{
    
    NSNumber *n = [FBMovieViewControllerHistory valueForKey:_decoder.path];
    if (n)
        [self updatePosition:n.floatValue playMode:YES];
    else
        [self play];
}

- (void)setupPresentView{
    
    CGRect bounds = self.view.bounds;
    
    if (_decoder.validVideo){
        _glView = [[FBMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
    }
    
    if (!_glView){
        
        LoggerVideo(0, @"fallback to use RGB video frame and UIKit");
        [_decoder setupVideoFrameFormat:FBVideoFrameFormatRGB];
        _imageView = [[UIImageView alloc] initWithFrame:bounds];
        _imageView.backgroundColor = [UIColor blackColor];
    }
    
    UIView *frameView = [self frameView];
    frameView.contentMode = UIViewContentModeScaleAspectFit;
    frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view insertSubview:frameView atIndex:0];
    
    if (_decoder.validVideo){
        
        [self setupUserInteraction];
        
    } else {
        
        _imageView.image = [UIImage imageNamed:@"kxmovie.bundle/music_icon.png"];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)setupUserInteraction{
    
    UIView * view = [self frameView];
    view.userInteractionEnabled = YES;
    
//        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//        _panGestureRecognizer.enabled = NO;
//    
//        [view addGestureRecognizer:_panGestureRecognizer];
}

- (UIView *)frameView{
    
    return _glView ? _glView :_imageView;
}

- (void)audioCallbackFillData:(float *)outData
                    numFrames:(UInt32)numFrames
                  numChannels:(UInt32)numChannels{
    
    //fillSignalF(outData,numFrames,numChannels);
    //return;
    
    if (_buffered){
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        
        while (numFrames > 0){
            
            if (!_currentAudioFrame){
                
                @synchronized(_audioFrames){
                    
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0){
                        
                        FBAudioFrame *frame = _audioFrames[0];
                        
#ifdef DUMP_AUDIO_DATA
                        LoggerAudio(2, @"Audio frame position:%f", frame.position);
#endif
                        if (_decoder.validVideo){
                            
                            const CGFloat delta = _moviePosition - frame.position;
                            
                            if (delta < -0.1){
                                
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
#ifdef DEBUG
                                LoggerStream(0, @"desync audio (outrun)wait %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 1;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                break; // silence and exit
                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                            
                            if (delta > 0.1 && count > 1){
                                
#ifdef DEBUG
                                LoggerStream(0, @"desync audio (lags)skip %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 2;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                continue;
                            }
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;
                    }
                }
            }
            
            if (_currentAudioFrame){
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //LoggerStream(1, @"silence audio");
#ifdef DEBUG
                _debugAudioStatus = 3;
                _debugAudioStatusTS = [NSDate date];
#endif
                break;
            }
        }
    }
}

- (void)enableAudio:(BOOL)on{
    
    FBAudioPlayer *audioPlayer = [FBAudioPlayer shareAudioPlayer];
    
    if (on && _decoder.validAudio){
        
        audioPlayer.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels){
            
            [self audioCallbackFillData:outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioPlayer play];
        
        LoggerAudio(2, @"audio device smr:%d fmt:%d chn:%d",
                    (int)audioPlayer.samplingRate,
                    (int)audioPlayer.numBytesPerSample,
                    (int)audioPlayer.numOutputChannels);
        
    } else {
        
        [audioPlayer pause];
        audioPlayer.outputBlock = nil;
    }
}

- (BOOL)addFrames:(NSArray *)frames{
    
    if (_decoder.validVideo){
        
        @synchronized(_videoFrames){
            
            for (FBMovieFrame *frame in frames)
                if (frame.type == FBMovieFrameTypeVideo){
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio){
        
        @synchronized(_audioFrames){
            
            for (FBMovieFrame *frame in frames)
                if (frame.type == FBMovieFrameTypeAudio){
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo)
                        _bufferedDuration += frame.duration;
                }
        }
        
        if (!_decoder.validVideo){
            
            for (FBMovieFrame *frame in frames)
                if (frame.type == FBMovieFrameTypeArtwork)
                    self.artworkFrame = (FBArtworkFrame *)frame;
        }
    }
    
    if (_decoder.validSubtitles){
        
        @synchronized(_subtitles){
            
            for (FBMovieFrame *frame in frames)
                if (frame.type == FBMovieFrameTypeSubtitle){
                    [_subtitles addObject:frame];
                }
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

- (BOOL)decodeFrames{
    
    //NSAssert(dispatch_get_current_queue()== _dispatchQueue, @"bugcheck");
    
    NSArray *frames = nil;
    
    if (_decoder.validVideo ||
        _decoder.validAudio){
        
        frames = [_decoder decodeFrames:0];
    }
    
    if (frames.count){
        return [self addFrames:frames];
    }
    return NO;
}

- (void)asyncDecodeFrames{
    
    if (self.decoding)
        return;
    
    __weak FBMovieViewController *weakSelf = self;
    __weak FBMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f :0.1f;
    
    self.decoding = YES;
    dispatch_async(_dispatchQueue, ^{
        
        {
            __strong FBMovieViewController *strongSelf = weakSelf;
            if (!strongSelf.playing)
                return;
        }
        
        BOOL good = YES;
        while (good){
            
            good = NO;
            
            @autoreleasepool {
                
                __strong FBMovieDecoder *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio)){
                    
                    NSArray *frames = [decoder decodeFrames:duration];
                    if (frames.count){
                        
                        __strong FBMovieViewController *strongSelf = weakSelf;
                        if (strongSelf)
                            good = [strongSelf addFrames:frames];
                    }
                }
            }
        }
        
        {
            __strong FBMovieViewController *strongSelf = weakSelf;
            if (strongSelf)strongSelf.decoding = NO;
        }
    });
}

- (void)tick{
    
    if (_buffered && ((_bufferedDuration > _minBufferedDuration)|| _decoder.isEOF)){
        
        _tickCorrectionTime = 0;
        _buffered = NO;
        [_activityIndicatorView stopAnimating];
    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing){
        
        const NSUInteger leftFrames =
        (_decoder.validVideo ? _videoFrames.count :0)+
        (_decoder.validAudio ? _audioFrames.count :0);
        
        if (0 == leftFrames){
            
            if (_decoder.isEOF){
                
                [self pause];
                return;
            }
            
            if (_minBufferedDuration > 0 && !_buffered){
                
                _buffered = YES;
                [_activityIndicatorView startAnimating];
            }
        }
        
        if (!leftFrames ||
            !(_bufferedDuration > _minBufferedDuration)){
            
            [self asyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    }
}

- (CGFloat)tickCorrection{
    
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime){
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200)== 0)
    //    LoggerStream(1, @"tick correction %.4f", correction);
    
    if (correction > 1.f || correction < -1.f){
        
        LoggerStream(1, @"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat)presentFrame{
    
    CGFloat interval = 0;
    
    if (_decoder.validVideo){
        
        FBVideoFrame *frame;
        
        @synchronized(_videoFrames){
            
            if (_videoFrames.count > 0){
                
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
        
    } else if (_decoder.validAudio){
        
        //interval = _bufferedDuration * 0.5;
        
        if (self.artworkFrame){
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }
    
#ifdef DEBUG
    if (self.playing && _debugStartTime < 0)
        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
#endif
    
    return interval;
}

- (CGFloat)presentVideoFrame:(FBVideoFrame *)frame{
    
    if (_glView){
        
        [_glView render:frame];
        
    } else {
        
        FBVideoFrameRGB *rgbFrame = (FBVideoFrameRGB *)frame;
        _imageView.image = [rgbFrame asImage];
    }
    
    _moviePosition = frame.position;
    
    return frame.duration;
}

- (BOOL)subtitleForPosition:(CGFloat)position
                     actual:(NSArray **)pActual
                   outdated:(NSArray **)pOutdated{
    
    if (!_subtitles.count)
        return NO;
    
    NSMutableArray *actual = nil;
    NSMutableArray *outdated = nil;
    
    for (FBSubtitleFrame *subtitle in _subtitles){
        
        if (position < subtitle.position){
            
            break; // assume what subtitles sorted by position
            
        } else if (position >= (subtitle.position + subtitle.duration)){
            
            if (pOutdated){
                if (!outdated)
                    outdated = [NSMutableArray array];
                [outdated addObject:subtitle];
            }
            
        } else {
            
            if (pActual){
                if (!actual)
                    actual = [NSMutableArray array];
                [actual addObject:subtitle];
            }
        }
    }
    
    if (pActual)*pActual = actual;
    if (pOutdated)*pOutdated = outdated;
    
    return actual.count || outdated.count;
}

- (void)fullscreenMode:(BOOL)on{
    
    _fullscreen = on;
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarHidden:on withAnimation:UIStatusBarAnimationNone];
    // if (!self.presentingViewController){
    //[self.navigationController setNavigationBarHidden:on animated:YES];
    //[self.tabBarController setTabBarHidden:on animated:YES];
    // }
}

- (void)setMoviePositionFromDecoder{
    
    _moviePosition = _decoder.position;
}

- (void)setDecoderPosition:(CGFloat)position{
    
    _decoder.position = position;
}

- (void)updatePosition:(CGFloat)position
              playMode:(BOOL)playMode{
    
    [self freeBufferedFrames];
    
    position = MIN(_decoder.duration - 1, MAX(0, position));
    
    __weak FBMovieViewController *weakSelf = self;
    
    dispatch_async(_dispatchQueue, ^{
        
        if (playMode){
            
            {
                __strong FBMovieViewController *strongSelf = weakSelf;
                if (!strongSelf)return;
                [strongSelf setDecoderPosition:position];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong FBMovieViewController *strongSelf = weakSelf;
                if (strongSelf){
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf play];
                }
            });
            
        } else {
            
            {
                __strong FBMovieViewController *strongSelf = weakSelf;
                if (!strongSelf)return;
                [strongSelf setDecoderPosition:position];
                [strongSelf decodeFrames];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong FBMovieViewController *strongSelf = weakSelf;
                if (strongSelf){
                    
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf presentFrame];
                }
            });
        }
    });
}

- (void)freeBufferedFrames{
    
    @synchronized(_videoFrames){
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames){
        
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    if (_subtitles){
        @synchronized(_subtitles){
            [_subtitles removeAllObjects];
        }
    }
    
    _bufferedDuration = 0;
}

- (void)handleDecoderMovieError:(NSError *)error{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (BOOL)interruptDecoder{
    
    //if (!_decoder)
    //    return NO;
    return _interrupted;
}

@end

