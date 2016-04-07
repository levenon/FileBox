//
//  XLFThemeManager.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-4.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - 字体、颜色、图片类别
/**
 *  注意：themeManager 类暂时只支持，字体大小，颜色，背景的切换
 */
@interface XLFThemeManager : NSObject
/**
 *  @brief  共享实例对象
 *
 *  @return 返回共享实例对象
 */
+ (instancetype)sharedInstance;

/**
 *  注册主题
 *
 *  @param themeConfigName 主题配置信息名字
 *  @discussion  这里的全局只针对当前运行的程序，如果还需要存储，需要结合UserManager 一起使用
 */
- (void)registerThemeWithConfigName:(NSString*)themeConfigName  forViewContrller:(UIViewController*)vc;

#pragma mark - 屏幕尺寸
+ (CGRect)themeScreenFrame;
+ (CGFloat)themeScreenHeight;
+ (CGFloat)themeScreenWidth;
+ (CGFloat)themeScreenStatusBarHeigth;

#pragma mark - Custom
- (UIColor*)colorWithHexString:(NSString *)color;
- (UIColor*)colorWithBackgroundColorMark:(NSInteger)mark;
- (UIColor*)colorWithTextColorMark:(NSInteger)mark;
- (UIImage*)imageWithNameFromeTheme:(NSString*)imageName;
- (UIFont*)fontWithFontMark:(NSInteger)mark;

@end

