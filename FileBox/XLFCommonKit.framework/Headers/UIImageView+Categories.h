//
//  UIImageView+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 15/4/29.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Categories)


/**
 *  返回当前图片在矩形中的均值
 *
 *  @param rect      矩形区域
 *
 *  @return UIColor  返回颜色
 */
- (UIColor *)averageColorInRect:(CGRect)dstRect;

@end
