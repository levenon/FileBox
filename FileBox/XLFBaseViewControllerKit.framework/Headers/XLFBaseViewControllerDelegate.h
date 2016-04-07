//
//  XLFBaseViewControllerDelegate
//  XLFBaseViewControllerKit
//
//  Created by Marike Jave on 15/3/18.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XLFBaseGlobal.h"

@class XLFBaseNavigationController;

@protocol XLFBaseViewControllerDelegate_Protect <NSObject>

@property(assign, nonatomic, getter=isBeingUnload) BOOL beingUnload;

@property(assign, nonatomic, getter=isBeingLoad) BOOL beingLoad;

@end

@protocol XLFBaseViewControllerDelegate <NSObject,UIGestureRecognizerDelegate>
@optional

@property(nonatomic, strong) UIImage   *evBackgroundImage;//默认背景图片,注意使用该方法，整个App的背景将会都将会被改变

@property(nonatomic, strong) UIImage   *evNavgationBarBackgroundImage;//默认导航背景图片,注意使用该方法，整个App的背景将会都将会被改变

@property(nonatomic, strong) UIImage   *evNavgationBarShadowImage;

@property(nonatomic, strong) UIColor   *evNavgationBarTintColor;

@property(nonatomic, strong) UIColor   *evNavgationBarBarTintColor;

@property(nonatomic, strong) NSDictionary *evNavgationBarTitleTextAttributes;

@property(nonatomic, assign) BOOL evNavigationBarTranslucent;

@end