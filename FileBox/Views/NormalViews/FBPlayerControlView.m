//
//  FBPlayerControlView.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "FBPlayerControlView.h"

@interface FBPlayerControlView ()

/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *evbtnStart;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel                 *evlbCurrentTime;
/** 视频总时长label */
@property (nonatomic, strong) UILabel                 *evlbTotalTime;
/** 滑杆 */
@property (nonatomic, strong) UISlider                *evsldPlayProgress;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *evbtnSwitchFullScreen;
/** 锁定按钮 */
@property (nonatomic, strong) UIButton                *evbtnLockScreen;
/** 快进快退提示信息 */
@property (nonatomic, strong) UILabel                 *evlbProgressIndicator;
/** 返回按钮*/
@property (nonatomic, strong) UIButton                *evbtnStepBackward;
/** topView */
@property (nonatomic, strong) UIImageView             *evimgvTopGradientBackground;
/** bottomView*/
@property (nonatomic, strong) UIImageView             *evimgvBottomGradientBackground;

@end

@implementation FBPlayerControlView

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        [self addSubview:self.evimgvTopGradientBackground];
        [self addSubview:self.evimgvBottomGradientBackground];
        [self.evimgvBottomGradientBackground addSubview:self.evbtnStart];
        [self.evimgvBottomGradientBackground addSubview:self.evlbCurrentTime];
        [self.evimgvBottomGradientBackground addSubview:self.evpgvPlayProgress];
        [self.evimgvBottomGradientBackground addSubview:self.evsldPlayProgress];
        [self.evimgvBottomGradientBackground addSubview:self.evbtnSwitchFullScreen];
        [self.evimgvBottomGradientBackground addSubview:self.evlbTotalTime];
        
        [self.evimgvTopGradientBackground addSubview:self.downLoadBtn];
        [self addSubview:self.evbtnLockScreen];
        [self addSubview:self.evbtnStepBackward];
        [self addSubview:self.evaiLoading];
        [self addSubview:self.evbtnReplay];
        [self addSubview:self.evlbProgressIndicator];
        // 添加子控件的约束
        [self makeSubViewsConstraints];
        
        [self.evaiLoading stopAnimating];
        self.evlbProgressIndicator.hidden = YES;
        self.evbtnReplay.hidden       = YES;
        self.downLoadBtn.hidden     = YES;
        // 初始化时重置controlView
        [self resetControlView];
    }
    return self;
}

- (void)makeSubViewsConstraints{
    
    [self.evbtnStepBackward mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(15);
        make.top.equalTo(self.mas_top).offset(5);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.evimgvTopGradientBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    [self.downLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.trailing.equalTo(self.evimgvTopGradientBackground.mas_trailing).offset(-10);
        make.centerY.equalTo(self.evbtnStepBackward.mas_centerY);
    }];
    
    [self.evimgvBottomGradientBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.evbtnStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.evimgvBottomGradientBackground.mas_leading).offset(5);
        make.bottom.equalTo(self.evimgvBottomGradientBackground.mas_bottom).offset(-5);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.evlbCurrentTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.evbtnStart.mas_trailing).offset(-3);
        make.centerY.equalTo(self.evbtnStart.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [self.evbtnSwitchFullScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.trailing.equalTo(self.evimgvBottomGradientBackground.mas_trailing).offset(-5);
        make.centerY.equalTo(self.evbtnStart.mas_centerY);
    }];
    
    [self.evlbTotalTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.evbtnSwitchFullScreen.mas_leading).offset(3);
        make.centerY.equalTo(self.evbtnStart.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [self.evpgvPlayProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.evlbCurrentTime.mas_trailing).offset(4);
        make.trailing.equalTo(self.evlbTotalTime.mas_leading).offset(-4);
        make.centerY.equalTo(self.evbtnStart.mas_centerY);
    }];
    
    [self.evsldPlayProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.evlbCurrentTime.mas_trailing).offset(4);
        make.trailing.equalTo(self.evlbTotalTime.mas_leading).offset(-4);
        make.centerY.equalTo(self.evlbCurrentTime.mas_centerY).offset(-0.25);
    }];
    
    [self.evbtnLockScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.evlbProgressIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(40);
        make.center.equalTo(self);
    }];
    
    [self.evaiLoading mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.evbtnReplay mas_makeConstraints:^(MASConstraintMaker *make) {
         make.center.equalTo(self);
    }];
}


#pragma mark - Public Method

/** 重置ControlView */
- (void)resetControlView{
    
    self.evsldPlayProgress.value      = 0;
    self.evpgvPlayProgress.progress  = 0;
    self.evlbCurrentTime.text  = @"00:00";
    self.evlbTotalTime.text    = @"00:00";
    self.evlbProgressIndicator.hidden = YES;
    self.evbtnReplay.hidden       = YES;
    self.backgroundColor        = [UIColor clearColor];
}

- (void)showControlView{
    
    self.evimgvTopGradientBackground.alpha    = 1;
    self.evimgvBottomGradientBackground.alpha = 1;
    self.evbtnLockScreen.alpha         = 1;
}

- (void)hideControlView{
    
    self.evimgvTopGradientBackground.alpha    = 0;
    self.evimgvBottomGradientBackground.alpha = 0;
    self.evbtnLockScreen.alpha         = 0;
}

#pragma mark - getter

- (UIButton *)evbtnStepBackward{
    
    if (!_evbtnStepBackward) {
        _evbtnStepBackward = [UIButton emptyFrameView];
        [_evbtnStepBackward setImage:[UIImage imageNamed:@"FBMovie.bundle/play_back_full"] forState:UIControlStateNormal];
    }
    return _evbtnStepBackward;
}

- (UIImageView *)evimgvTopGradientBackground{
    
    if (!_evimgvTopGradientBackground) {
        _evimgvTopGradientBackground                        = [UIImageView emptyFrameView];
        _evimgvTopGradientBackground.userInteractionEnabled = YES;
        _evimgvTopGradientBackground.image                  = [UIImage imageNamed:@"FBMovie.bundle/top_shadow"];
    }
    return _evimgvTopGradientBackground;
}

- (UIImageView *)evimgvBottomGradientBackground{
    
    if (!_evimgvBottomGradientBackground) {
        _evimgvBottomGradientBackground                        = [UIImageView emptyFrameView];
        _evimgvBottomGradientBackground.userInteractionEnabled = YES;
        _evimgvBottomGradientBackground.image                  = [UIImage imageNamed:@"FBMovie.bundle/bottom_shadow"];
    }
    return _evimgvBottomGradientBackground;
}

- (UIButton *)evbtnLockScreen{
    
    if (!_evbtnLockScreen) {
        _evbtnLockScreen = [UIButton emptyFrameView];
        [_evbtnLockScreen setImage:[UIImage imageNamed:@"FBMovie.bundle/unlock-nor"] forState:UIControlStateNormal];
        [_evbtnLockScreen setImage:[UIImage imageNamed:@"FBMovie.bundle/lock-nor"] forState:UIControlStateSelected];
    }
    return _evbtnLockScreen;
}

- (UIButton *)evbtnStart{
    
    if (!_evbtnStart) {
        _evbtnStart = [UIButton buttonWithType:UIButtonTypeCustom];
        [_evbtnStart setImage:[UIImage imageNamed:@"FBMovie.bundle/kr-video-player-play"] forState:UIControlStateNormal];
        [_evbtnStart setImage:[UIImage imageNamed:@"FBMovie.bundle/kr-video-player-pause"] forState:UIControlStateSelected];
    }
    return _evbtnStart;
}

- (UILabel *)evlbCurrentTime{
    
    if (!_evlbCurrentTime) {
        _evlbCurrentTime               = [[UILabel emptyFrameView];
        _evlbCurrentTime.textColor     = [UIColor whiteColor];
        _evlbCurrentTime.font          = [UIFont systemFontOfSize:12.0f];
        _evlbCurrentTime.textAlignment = NSTextAlignmentCenter;
    }
    return _evlbCurrentTime;
}

- (UIProgressView *)evpgvPlayProgress{
    
    if (!_evpgvPlayProgress) {
        _evpgvPlayProgress                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _evpgvPlayProgress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        _evpgvPlayProgress.trackTintColor    = [UIColor clearColor];
    }
    return _evpgvPlayProgress;
}

- (UISlider *)evsldPlayProgress{
    
    if (!_evsldPlayProgress) {
        _evsldPlayProgress                       = [[UISlider emptyFrameView];
        // 设置slider
        [_evsldPlayProgress setThumbImage:[UIImage imageNamed:@"FBMovie.bundle/slider"] forState:UIControlStateNormal];

        _evsldPlayProgress.minimumTrackTintColor = [UIColor whiteColor];
        _evsldPlayProgress.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6];
    }
    return _evsldPlayProgress;
}

- (UILabel *)evlbTotalTime{
    
    if (!_evlbTotalTime) {
        _evlbTotalTime               = [[UILabel emptyFrameView];
        _evlbTotalTime.textColor     = [UIColor whiteColor];
        _evlbTotalTime.font          = [UIFont systemFontOfSize:12.0f];
        _evlbTotalTime.textAlignment = NSTextAlignmentCenter;
    }
    return _evlbTotalTime;
}

- (UIButton *)evbtnSwitchFullScreen{
    
    if (!_evbtnSwitchFullScreen) {
        _evbtnSwitchFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        [_evbtnSwitchFullScreen setImage:[UIImage imageNamed:@"FBMovie.bundle/kr-video-player-fullscreen"] forState:UIControlStateNormal];
        [_evbtnSwitchFullScreen setImage:[UIImage imageNamed:@"FBMovie.bundle/kr-video-player-shrinkscreen"] forState:UIControlStateSelected];
    }
    return _evbtnSwitchFullScreen;
}

- (UILabel *)evlbProgressIndicator{
    
    if (!_evlbProgressIndicator) {
        _evlbProgressIndicator                 = [[UILabel emptyFrameView];
        _evlbProgressIndicator.textColor       = [UIColor whiteColor];
        _evlbProgressIndicator.textAlignment   = NSTextAlignmentCenter;
        // 设置快进快退label
        _evlbProgressIndicator.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FBMovie.bundle/Management_Mask"]];
    }
    return _evlbProgressIndicator;
}

- (UIActivityIndicatorView *)evaiLoading{
    
    if (!_evaiLoading) {
        _evaiLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _evaiLoading;
}

- (UIButton *)evbtnReplay{
    
    if (!_evbtnReplay) {
        _evbtnReplay = [UIButton buttonWithType:UIButtonTypeCustom];
        [_evbtnReplay setImage:[UIImage imageNamed:@"FBMovie.bundle/repeat_video"] forState:UIControlStateNormal];
    }
    return _evbtnReplay;
}

@end
