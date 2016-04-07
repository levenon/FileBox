//
//  UIColor+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-8-25.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>

//颜色获取
#define UIColorWithHexRGB( hex )                            [UIColor colorWithHexRGB:hex]

#define UIColorWithHexRGBA( hex )                           [UIColor colorWithHexRGBA:hex]
#define UIColorWithHexRGBAndAlpha(hex, a)                   [UIColor colorWithHexRGB:hex alpha:a]

#define UIColorWithRGB(r, g, b)                             [UIColor colorWithRed:(r) green:(g) blue:(b) alpha:1.0]
#define UIColorWith255RGB(r, g, b)                             [UIColor colorWithRed:(r/255.) green:(g/255.) blue:(b/255.) alpha:1.0]

#define UIColorWith255RGBA(r, g, b, a)                         [UIColor colorWithRed:(r/255.) green:(g/255.) blue:(b/255.) alpha:(a)]
#define UIColorWithRGBA(r, g, b, a)                         [UIColor colorWithRed:(r) green:(g) blue:(b) alpha:(a)]

@interface UIColor(Transform)
/**
 *  16进制颜色转换成UIColor
 *
 *  @param  hexValue 16进制颜色（无透明度值）
 *
 *  @return UIColor
 */
+(UIColor *)colorWithHexRGB:(NSUInteger)hexValue;
/**
 *  16进制颜色转换成UIColor
 *
 *  @param  hexValue 16进制颜色（有透明度值）
 *
 *  @return UIColor
 */
+(UIColor *)colorWithHexRGBA:(NSUInteger)hexValue;

/**
 *  16进制颜色转换成UIColor
 *
 *  @param hexValue 16进制颜色
 *  @param alpha    透明度
 *
 *  @return UIColor
 */
+(UIColor *)colorWithHexRGB:(NSUInteger)hexValue alpha:(CGFloat)alpha;

@end
