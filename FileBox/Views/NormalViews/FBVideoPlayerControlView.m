    //
//  FBVideoPlayerControlView
//

#import <MediaPlayer/MediaPlayer.h>

#import "FBVideoPlayerControlView.h"

#import "FBVideoPlayer.h"

#import "FBBrightnessView.h"

static NSString * egFormatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSMutableString *format = [(isLeft && seconds >= 0.5 ? @"-" : @"")mutableCopy];
    if (h != 0) [format appendFormat:@"%ld:%0.2ld", h, m];
    else        [format appendFormat:@"%ld", m];
    [format appendFormat:@":%0.2ld", s];
    
    return format;
}


@interface MPVolumeSlider : UISlider

@end

typedef NS_OPTIONS(NSInteger, FBMoviePanControlType) {
    
    FBMoviePanControlTypeNone       = 0,
    FBMoviePanControlTypeProgress   = 1 << 0,
    FBMoviePanControlTypeVolume     = 1 << 1,
    FBMoviePanControlTypeBrightness = 1 << 2,
};

@interface FBVideoPlayerControlView ()<XLFViewConstructor, FBVideoPlayerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong) FBVideoPlayer           *evPlayer;

@property(nonatomic, strong) UIView                  *evvContent;

@property(nonatomic, strong) UIButton                *evbtnStart;

@property(nonatomic, strong) UILabel                 *evlbCurrentTime;

@property(nonatomic, strong) UILabel                 *evlbTotalTime;

@property(nonatomic, strong) UISlider                *evsldPlayProgress;

@property(nonatomic, strong) UIButton                *evbtnLockScreen;

@property(nonatomic, strong) UILabel                 *evlbProgressIndicator;

@property(nonatomic, strong) UIButton                *evbtnStepBackward;

@property(nonatomic, strong) UIImageView             *evimgvTopGradientBackground;

@property(nonatomic, strong) UIImageView             *evimgvBottomGradientBackground;

@property(nonatomic, strong) UISlider                *evsldVolume;

@property(nonatomic, strong) UIPanGestureRecognizer  *evpgrPanInContent;

@property(nonatomic, strong) UITapGestureRecognizer  *evpgrTapInContent;

@property(nonatomic, assign) FBMoviePanControlType   evMoviePanControlType;

@end

@implementation FBVideoPlayerControlView

- (void)dealloc{
    
    [[[self evPlayer] evDelegates] removeDelegate:self];
    
    [self setEvPlayer:nil];
    [self setEvbtnStart:nil];
    [self setEvlbCurrentTime:nil];
    [self setEvlbTotalTime:nil];
    [self setEvsldPlayProgress:nil];
    [self setEvbtnLockScreen:nil];
    [self setEvlbProgressIndicator:nil];
    [self setEvbtnStepBackward:nil];
    [self setEvimgvTopGradientBackground:nil];
    [self setEvimgvBottomGradientBackground:nil];
    [self setEvsldVolume:nil];
    [self setEvpgrPanInContent:nil];
    [self setEvpgrTapInContent:nil];
    
    [self setEvvContent:nil];
}

- (instancetype)initWithPlayer:(FBVideoPlayer *)player;{
    self = [super initWithFrame:CGRectZero];

    if (self) {
        
        [self setEvPlayer:player];
        [[player evDelegates] addDelegate:self];
        
        [self epCreateSubViews];
        [self epConfigSubViewsDefault];
        [self epInstallConstraints];
    }
    return self;
}

- (void)epCreateSubViews{
    
    [self setEvvContent:[UIView emptyFrameView]];
    [self setEvbtnStart:[UIButton emptyFrameView]];
    [self setEvlbCurrentTime:[UILabel emptyFrameView]];
    [self setEvlbTotalTime:[UILabel emptyFrameView]];
    [self setEvsldPlayProgress:[UISlider emptyFrameView]];
    [self setEvbtnLockScreen:[UIButton emptyFrameView]];
    [self setEvlbProgressIndicator:[UILabel emptyFrameView]];
    [self setEvbtnStepBackward:[UIButton emptyFrameView]];
    [self setEvimgvTopGradientBackground:[UIImageView emptyFrameView]];
    [self setEvimgvBottomGradientBackground:[UIImageView emptyFrameView]];
    [self setEvpgrPanInContent:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanInContent:)]];
    [self setEvpgrTapInContent:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapInContent:)]];
    
    [self addSubview:[self evvContent]];
    
    [[self evvContent] addSubview:[self evimgvTopGradientBackground]];
    [[self evvContent] addSubview:[self evimgvBottomGradientBackground]];
    [[self evvContent] addSubview:[self evbtnStart]];
    [[self evvContent] addSubview:[self evlbCurrentTime]];
    [[self evvContent] addSubview:[self evlbTotalTime]];
    [[self evvContent] addSubview:[self evsldPlayProgress]];
    [[self evvContent] addSubview:[self evbtnStepBackward]];
    
    [self addSubview:[self evlbProgressIndicator]];
    [self addSubview:[self evbtnLockScreen]];
    
    [self addGestureRecognizer:[self evpgrPanInContent]];
    [self addGestureRecognizer:[self evpgrTapInContent]];
}

- (void)epConfigSubViewsDefault{
    
    [self setBackgroundColor:[UIColor clearColor]];
    [[self evvContent] setBackgroundColor:[UIColor clearColor]];
    
    [[[self evPlayer] evDelegates] addDelegate:self];
    
    [[self evbtnStepBackward] setImage:[UIImage imageNamed:@"FBMovie.bundle/play_back_full"] forState:UIControlStateNormal];
    [[self evbtnStepBackward] addTarget:self action:@selector(didClickStepBackward:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self evaivLoading] setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [[self evaivLoading] setBackgroundColor:[UIColor clearColor]];
    
    [[self evlbProgressIndicator] setHidden:YES];
    
    [[self evimgvTopGradientBackground] setImage:[UIImage imageNamed:@"FBMovie.bundle/top_shadow"]];
    [[self evimgvBottomGradientBackground] setImage:[UIImage imageNamed:@"FBMovie.bundle/bottom_shadow"]];
    
    [[self evbtnLockScreen] setImage:[UIImage imageNamed:@"FBMovie.bundle/unlock-nor"] forState:UIControlStateNormal];
    [[self evbtnLockScreen] setImage:[UIImage imageNamed:@"FBMovie.bundle/lock-nor"] forState:UIControlStateSelected];
    [[self evbtnLockScreen] addTarget:self action:@selector(didClickLockScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self evbtnStart] setImage:[UIImage imageNamed:@"FBMovie.bundle/kr-video-player-play"] forState:UIControlStateNormal];
    [[self evbtnStart] setImage:[UIImage imageNamed:@"FBMovie.bundle/kr-video-player-pause"] forState:UIControlStateSelected];
    [[self evbtnStart] addTarget:self action:@selector(didClickStart:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self evlbCurrentTime] setText:@"00:00"];
    [[self evlbCurrentTime] setTextColor:[UIColor whiteColor]];
    [[self evlbCurrentTime] setTextAlignment:NSTextAlignmentCenter];
    [[self evlbCurrentTime] setFont:[UIFont systemFontOfSize:12.0f]];
    
    [[self evlbTotalTime] setText:@"00:00"];
    [[self evlbTotalTime] setTextColor:[UIColor whiteColor]];
    [[self evlbTotalTime] setTextAlignment:NSTextAlignmentCenter];
    [[self evlbTotalTime] setFont:[UIFont systemFontOfSize:12.0f]];
    
    [[self evsldPlayProgress] setMinimumTrackTintColor:[UIColor whiteColor]];
    [[self evsldPlayProgress] setMaximumTrackTintColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6]];
    [[self evsldPlayProgress] setThumbImage:[UIImage imageNamed:@"FBMovie.bundle/slider"] forState:UIControlStateNormal];
    [[self evsldPlayProgress] addTarget:self action:@selector(didChangedPlayProgress:) forControlEvents:UIControlEventValueChanged];
    
    [[self evlbProgressIndicator] setAlpha:0];
    [[self evlbProgressIndicator] setTextColor:[UIColor whiteColor]];
    [[self evlbProgressIndicator] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"FBMovie.bundle/Management_Mask"]]];
    
    [[self evpgrPanInContent] setDelegate:self];
}

- (void)epInstallConstraints{
    
    @weakify(self);
    [[self evvContent] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    [self.evbtnStepBackward mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.leading.equalTo(self.evvContent.mas_leading).offset(15);
        make.top.equalTo(self.evvContent.mas_top).offset(5);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.evimgvTopGradientBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    [self.evimgvBottomGradientBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.evbtnStart mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.leading.equalTo(self.evimgvBottomGradientBackground.mas_leading).offset(5);
        make.bottom.equalTo(self.evimgvBottomGradientBackground.mas_bottom).offset(-5);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.evlbCurrentTime mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.leading.equalTo(self.evbtnStart.mas_trailing).offset(-3);
        make.centerY.equalTo(self.evbtnStart.mas_centerY);
        make.width.mas_equalTo(60);
    }];
    
    [self.evlbTotalTime mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.trailing.equalTo(self.evimgvBottomGradientBackground.mas_trailing).offset(-5);
        make.centerY.equalTo(self.evbtnStart.mas_centerY);
        make.width.mas_equalTo(60);
    }];
    
    [self.evsldPlayProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.leading.equalTo(self.evlbCurrentTime.mas_trailing).offset(4);
        make.trailing.equalTo(self.evlbTotalTime.mas_leading).offset(-4);
        make.centerY.equalTo(self.evlbCurrentTime.mas_centerY).offset(-0.25);
    }];
    
    [self.evbtnLockScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.leading.equalTo(self.mas_leading).offset(15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.evlbProgressIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(40);
        make.center.equalTo(self);
    }];
}

- (void)epConfigSubViews{
    
}

#pragma mark - public

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    [[FBBrightnessView shareInstance] efRegisterObserver];
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
    
    [[FBBrightnessView shareInstance] efDeregisterObserver];
}

#pragma mark - accessory

- (BOOL)evIsControlDisplay{
    
    return ![[self evvContent] isHidden];
}

- (void)setEvControlDisplay:(BOOL)evControlDisplay{
    
    [[self evvContent] setHidden:!evControlDisplay];
}

- (BOOL)evIsLockedScreen{
    
    return [[self evbtnLockScreen] isSelected];
}

- (void)setEvLockedScreen:(BOOL)evLockedScreen{
    
    [[self evbtnLockScreen] setSelected:evLockedScreen];
}

- (UISlider *)evsldVolume{
    
    if (!_evsldVolume) {
        
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        
        for (UIView *view in [volumeView subviews]) {
            
            if ([view isKindOfClass:[MPVolumeSlider class]]) {
                
                _evsldVolume = (UISlider *)view;
                break;
            }
        }
    }
    return _evsldVolume;
}

#pragma mark - private

- (void)_efUpdateProgressIndicatorDisplayState:(BOOL)display{
    
    @weakify(self);
    [UIView animateWithDuration:0 animations:^{
        @strongify(self);
        
        [[self evlbProgressIndicator] setAlpha:display];
    }];
}

- (void)_efWillUpdatePlayPositionOffset:(CGFloat)positionOffset{
    
    NSInteger etDuration = [[self evPlayer] evDuration];
    
    NSInteger etDestinatePosition = [self _efDestinatePositionWithPositionOffset:positionOffset];
    
    NSString *etTimeNoticeIndicator = fmts(@"%@ %ld:%ld / %ld:%ld", select(positionOffset > 0, @">>", @"<<"), etDestinatePosition / 60, etDestinatePosition % 60, etDuration / 60, etDuration % 60);
    
    [[self evlbProgressIndicator] setText:etTimeNoticeIndicator];
}

- (void)_efDidUpdatePlayPositionOffset:(CGFloat)positionOffset{
    
    NSInteger etDestinatePosition = [self _efDestinatePositionWithPositionOffset:positionOffset];
    
    [[self evPlayer] setEvPosition:etDestinatePosition];
}

- (CGFloat)_efDestinatePositionWithPositionOffset:(CGFloat)positionOffset{
    
    NSInteger etDestinatePosition = [[self evPlayer] evPosition] + positionOffset;
    
    NSInteger etDuration = [[self evPlayer] evDuration];
    
    etDestinatePosition = MIN(etDuration, MAX(etDestinatePosition, 0));
    
    return etDestinatePosition;
}

- (void)_efUpdateContentDisplay:(BOOL)display{
    
    if (display) {
        [[self evvContent] setHidden:NO];
        [[self evvContent] setAlpha:0];
    }
    @weakify(self);
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        
        [[self evvContent] setAlpha:display];
    } completion:^(BOOL finished) {
        
        [[self evvContent] setHidden:!display];
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    CGPoint etLocation = [touch locationInView:self];
    
    return ![self evIsLockedScreen] && ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] || (etLocation.y < (CGRectGetHeight([self bounds]) - 40) && ![[self evPlayer] evIsOver]));
}

#pragma mark - actions

- (IBAction)didTapInContent:(id)sender{
    
    if (![self evIsLockedScreen]) {
        [self _efUpdateContentDisplay:![self evIsControlDisplay]];
    }
}

- (IBAction)didPanInContent:(UIPanGestureRecognizer *)sender{
    
    CGPoint etLocationPoint = [sender locationInView:self];
    CGPoint etVeloctyPoint = [sender velocityInView:self];
    CGPoint etTranslationOffset = [sender translationInView:self];
    
    switch ([sender state]) {
        case UIGestureRecognizerStateBegan:{
            
            CGFloat etHorizontalVelocty= fabs(etVeloctyPoint.x);
            CGFloat etVerticalVelocty = fabs(etVeloctyPoint.y);
            // 水平移动
            if (etHorizontalVelocty > etVerticalVelocty) {
                self.evMoviePanControlType |= FBMoviePanControlTypeProgress;
                
                [self _efWillUpdatePlayPositionOffset:etTranslationOffset.x / 10];
                [self _efUpdateProgressIndicatorDisplayState:YES];
            }
            // 垂直移动
            else if (etHorizontalVelocty < etVerticalVelocty) {
                
                // 调节亮度
                if (etLocationPoint.x < CGRectGetWidth([self bounds]) / 2.) {
                    
                    self.evMoviePanControlType |= FBMoviePanControlTypeBrightness;
                }
                else{
                    
                    self.evMoviePanControlType |= FBMoviePanControlTypeVolume;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            
            if ([self evMoviePanControlType] & FBMoviePanControlTypeProgress) {
                
                const CGFloat etPositionOffset = fabs(etTranslationOffset.x) * 0.33 * MAX(0.1, log10( fabs( etVeloctyPoint.x )) - 1.0);
        
                if (etPositionOffset > 10) {
                    
                    [self _efWillUpdatePlayPositionOffset:(-1 + 2 * (etTranslationOffset.x > 0)) * MIN(etPositionOffset, 600.0)];
                }
            }
            else if ([self evMoviePanControlType] & FBMoviePanControlTypeBrightness) {
                
                [UIScreen mainScreen].brightness -= etVeloctyPoint.y / 10000;
            }
            else if ([self evMoviePanControlType] & FBMoviePanControlTypeVolume) {
                
                [self evsldVolume].value -= etVeloctyPoint.y / 10000;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            
            if ([self evMoviePanControlType] & FBMoviePanControlTypeProgress) {
                
                [self _efUpdateProgressIndicatorDisplayState:NO];
                
                const CGFloat etPositionOffset = fabs(etTranslationOffset.x) * 0.33 * MAX(0.1, log10( fabs( etVeloctyPoint.x )) - 1.0);
                
                if (etPositionOffset > 10) {
                    
                    [self _efDidUpdatePlayPositionOffset:(-1 + 2 * (etTranslationOffset.x > 0)) * MIN(etPositionOffset, 600.0)];
                }
            }
            else if ([self evMoviePanControlType] & FBMoviePanControlTypeBrightness) {
                
            }
            else if ([self evMoviePanControlType] & FBMoviePanControlTypeVolume) {
                
            }
            
            [self setEvMoviePanControlType:FBMoviePanControlTypeNone];
            break;
        }
        default:
            break;
    }
}

- (IBAction)didClickStepBackward:(id)sender{
    
    [[self evVisibleViewController] efBack];
}

- (IBAction)didClickLockScreen:(UIButton *)sender{
    
    [self setEvLockedScreen:![self evIsLockedScreen]];
    
    if ([self evIsLockedScreen]) {
        [self _efUpdateContentDisplay:NO];
    }
}

- (IBAction)didClickStart:(UIButton *)sender{
    [sender setSelected:![sender isSelected]];
    
    if ([[self evPlayer] evIsPlaying]) {
        
        [[self evPlayer] efPause];
    }
    else{
        
        [[self evPlayer] efPlay];
    }
}

- (IBAction)didChangedPlayProgress:(UISlider *)sender{
    
    [[self evPlayer] setEvPosition:[[self evPlayer] evDuration] * [sender value]];
}

#pragma mark - FBVideoPlayerDelegate

- (void)epVideoPlayer:(FBVideoPlayer *)videoPlayer didFailedSetupWithError:(NSError *)error;{
    
    if ([self superview]) {
        [self stopLoading];
    }
}

- (void)epVideoPlayer:(FBVideoPlayer *)videoPlayer didUpdatePosition:(CGFloat)position;{
    
    NSString *etCurrentTime = egFormatTimeInterval(position, NO);
    
    NSString *etLeftTime = egFormatTimeInterval([videoPlayer evDuration] - position, NO);
    
    [[self evlbCurrentTime] setText:etCurrentTime];
    
    [[self evlbTotalTime] setText:etLeftTime];
    
    [[self evsldPlayProgress] setValue:position/[videoPlayer evDuration] animated:YES];
}

- (void)epWillBeginLoadingBuffersInVideoPlayer:(FBVideoPlayer *)videoPlayer;{

    [self startLoading];
}

- (void)epDidEndLoadingBuffersInVideoPlayer:(FBVideoPlayer *)videoPlayer;{
    
    [self stopLoading];
}

@end
