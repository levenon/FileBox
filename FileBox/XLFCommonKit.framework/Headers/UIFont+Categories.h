//
//  UIFont+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-2.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIFont(Transform)

/**
 
 字体单位转换成像素
 
 windows和mac上的字号是统一的。
 
 英文字体的1磅，相当于1/72 英寸，约等于1/2.8mm。
 
 12PT的字打印出来约为4.2mm。网页中12px的字才相当于12像素。
 
 虽然 四号=(14/72)*96=18.6px 更接近 19px，但是因为 18px 是点阵，所以系统还是优先显示点阵字号的。
 
 换句话说：四号=18px
 
 */
/**
 *  单位转换  像素  转换成 点
 *
 *  @param pixel 像素
 *
 *  @return 点
 */
+(CGFloat) fontSizeFromPixel:(NSInteger)pixel __deprecated;
/**
 *  单位转换  寸  转换成 点
 *
 *  @param inch 寸
 *
 *  @return 点
 */
+(CGFloat) fontSizeFromInch:(CGFloat)inch __deprecated;
/**
 *  单位转换  毫米  转换成 点
 *
 *  @param millimeter 毫米
 *
 *  @return 点
 */
+(CGFloat) fontSizeFromMillimeter:(CGFloat)millimeter __deprecated;

/**
 *  通过像素值创建系统字体
 *
 *  @param pixel 像素
 *
 *  @return UIFont
 */
+ (UIFont *)systemFontOfPixel:(NSInteger)pixel __deprecated;

/**
 *  通过英寸值创建系统字体
 *
 *  @param inch 英寸
 *
 *  @return UIFont
 */
+ (UIFont *)systemFontOfInch:(CGFloat)inch __deprecated;

/**
 *  通过毫米值创建系统字体
 *
 *  @param millimeter 毫米
 *
 *  @return UIFont
 */
+ (UIFont *)systemFontOfMillimeter:(CGFloat)millimeter __deprecated;

/**
 *  通过像素值创建系统加粗字体
 *
 *  @param pixel 像素
 *
 *  @return UIFont
 */
+ (UIFont *)boldSystemFontOfPixel:(NSInteger)pixel __deprecated;

/**
 *  通过英寸值创建系统粗体字
 *
 *  @param inch 英寸
 *
 *  @return UIFont
 */
+ (UIFont *)boldSystemFontOfInch:(CGFloat)inch __deprecated;

/**
 *  通过毫米值创建系统粗体字
 *
 *  @param millimeter 毫米
 *
 *  @return UIFont
 */
+ (UIFont *)boldSystemFontOfMillimeter:(CGFloat)millimeter __deprecated;

/**
 *  通过像素值创建系统斜体字
 *
 *  @param pixel 像素
 *
 *  @return UIFont
 */
+ (UIFont *)italicSystemFontOfPixel:(NSInteger)pixel __deprecated;

/**
 *  通过英寸值创建系统斜体字
 *
 *  @param 英寸
 *
 *  @return UIFont
 */
+ (UIFont *)italicSystemFontOfInch:(CGFloat)inch __deprecated;

/**
 *  通过毫米值创建系统斜体字
 *
 *  @param millimeter 毫米
 *
 *  @return UIFont
 */
+ (UIFont *)italicSystemFontOfMillimeter:(CGFloat)millimeter __deprecated;

/**
 *  通过字体名称和像素值创建字体
 *
 *  @param fontName 字体名称
 *  @param pixel    像素
 *
 *  @return UIFont
 */
+ (UIFont *)fontWithName:(NSString *)fontName pixel:(NSInteger)pixel __deprecated;

/**
 *  通过字体名称和英寸值创建字体
 *
 *  @param fontName 字体名称
 *  @param inch     英寸
 *
 *  @return UIFont
 */
+ (UIFont *)fontWithName:(NSString *)fontName inch:(CGFloat)inch __deprecated;

/**
 *  通过字体名称和毫米值创建字体
 *
 *  @param fontName     字体名称
 *  @param millimeter   毫米值
 *
 *  @return UIFont
 */
+ (UIFont *)fontWithName:(NSString *)fontName millimeter:(CGFloat)millimeter __deprecated;

/**
 *  通过字体描述符和像素值创建字体
 *
 *  @param fontName     字体名称
 *  @param pixel        像素值
 *
 *  @return UIFont
 */
+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)descriptor pixel:(NSInteger)pixel __deprecated;

/**
 *  通过字体描述符和英寸值创建字体
 *
 *  @param fontName     字体名称
 *  @param inch         英寸值
 *
 *  @return UIFont
 */
+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)descriptor inch:(CGFloat)inch __deprecated;

/**
 *  通过字体描述符和毫米值创建字体
 *
 *  @param fontName     字体名称
 *  @param millimeter   毫米值
 *
 *  @return UIFont
 */
+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)descriptor millimeter:(CGFloat)millimeter __deprecated;

@end
