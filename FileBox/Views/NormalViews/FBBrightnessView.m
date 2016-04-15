//
//  FBBrightnessView.m
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

#import "FBBrightnessView.h"

#import "FBBoxNumberView.h"

@interface FBBrightnessView ()

@property(nonatomic, strong) UIImageView *evimgvBackground;

@property(nonatomic, strong) UILabel *evlbTitle;

@property(nonatomic, strong) UIImageView *evimgvIndicator;

@property(nonatomic, strong) FBBoxNumberView *evvBrightnessValue;

@property(nonatomic, strong) NSTimer *evDisplayTimeoutTimer;

@end

@implementation FBBrightnessView

+ (FBBrightnessView *)shareInstance;{
    
    static FBBrightnessView *etvShareBrightness = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        etvShareBrightness = [FBBrightnessView emptyFrameView];
    });
    
    return etvShareBrightness;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self epCreateSubViews];
        [self epConfigSubViewsDefault];
        [self epInstallConstraints];
    }
    return self;
}

- (void)epCreateSubViews{
    
    [self setEvimgvBackground:[UIImageView emptyFrameView]];
    [self setEvlbTitle:[UILabel emptyFrameView]];
    [self setEvimgvIndicator:[UIImageView emptyFrameView]];
    [self setEvvBrightnessValue:[FBBoxNumberView emptyFrameView]];
    
    [self addSubview:[self evimgvBackground]];
    [self addSubview:[self evlbTitle]];
    [self addSubview:[self evimgvIndicator]];
    [self addSubview:[self evvBrightnessValue]];
}

- (void)epConfigSubViewsDefault{
    
    [self setUserInteractionEnabled:NO];
    
    [[self evimgvBackground] setImage:[UIImage imageWithColor:[UIColor colorWithRed:0.9 green:0.91 blue:0.92 alpha:1]]];
    
    [[self evlbTitle] setText:@"亮度"];
    [[self evlbTitle] setFont:[UIFont systemFontOfSize:15]];
    [[self evlbTitle] setTextColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.42 alpha:1]];
    
    [[self evimgvIndicator] setImage:[UIImage imageNamed:@"FBMovie.bundle/playgesture_BrightnessSun6"]];
    
    [[self evvBrightnessValue] setTintColor:[UIColor whiteColor]];
    [[self evvBrightnessValue] setBackgroundColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.42 alpha:1]];
    [[self evvBrightnessValue] setEvNumberOfBoxes:15];
}

- (void)epInstallConstraints{
    
    @weakify(self);
    
    [[self evimgvBackground] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    [[self evlbTitle] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.mas_top).offset(12);
        make.centerX.equalTo(self.mas_centerX).offset(0);
    }];
    
    [[self evimgvIndicator] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.evlbTitle.mas_bottom).offset(15);
        make.centerX.equalTo(self.mas_centerX).offset(0);
    }];
    
    [[self evvBrightnessValue] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.evimgvIndicator.mas_bottom).offset(15);
        make.bottom.equalTo(self.mas_bottom).offset(-15);
        make.left.equalTo(self.mas_left).offset(13);
        make.right.equalTo(self.mas_right).offset(-13);
        
        make.height.equalTo(@7);
        make.width.equalTo(@129);
    }];
}

- (void)epConfigSubViews{
    
    
}

#pragma mark - private

- (void)_efScheduleDisplayTimeoutTimer{
 
    [self _efDestoryDisplayTimeoutTimer];
    
    [self setEvDisplayTimeoutTimer:[NSTimer timerWithTimeInterval:3 target:self selector:@selector(didTriggerDisplayTimeout:) userInfo:nil repeats:NO]];
    
    [[NSRunLoop mainRunLoop] addTimer:[self evDisplayTimeoutTimer] forMode:NSDefaultRunLoopMode];
}

- (void)_efDestoryDisplayTimeoutTimer{
    
    if ([self evDisplayTimeoutTimer]) {
        
        [[self evDisplayTimeoutTimer] invalidate];
    }
    [self setEvDisplayTimeoutTimer:nil];
}

- (void)_efDisplayConent{
    
    [self setAlpha:0];
    
    UIWindow *etKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    [etKeyWindow addSubview:self];
    
    @weakify(self);
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.centerX.equalTo(etKeyWindow.mas_centerX).offset(0);
        make.centerY.equalTo(etKeyWindow.mas_centerY).offset(0);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        
        [self setAlpha:1.0];
    }];
}

- (void)_efDismissContent{
    
    @weakify(self);
    
    [UIView animateWithDuration:0.3 animations:^{
        @strongify(self);
        
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        @strongify(self);
        
        [self removeFromSuperview];
    }];
}

#pragma mark - public

- (void)efRegisterObserver;{
    
    [self efRegisterNotification];
}

- (void)efDeregisterObserver;{
    
    [self efDeregisterNotification];
}

- (void)efRegisterNotification{
    
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew
                               context:NULL];
}

- (void)efDeregisterNotification{
    
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
}

#pragma mark - actions

- (IBAction)didTriggerDisplayTimeout:(id)sender{
    
    [self _efDismissContent];
}

#pragma makr - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    [self _efDisplayConent];
    
    NSInteger level = [change[@"new"] floatValue] *  15;
    
    [[self evvBrightnessValue] setEvCurrentNumber:level];
    
    [self _efScheduleDisplayTimeoutTimer];
}

- (void)dealloc {
    
    [self efDeregisterObserver];
}


@end