//
//  NSDictionary+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSDictionary (Geometry)

/**
 *  转换成CGRect
 *
 *  @param @{@"x":@10,@"y":@100,@"width":@100,@"height":@100}
 *
 *  @return
 */
- (CGRect)rectValue;

/**
 *  转换成CGPoint
 *
 *  @param @{@"x":@10,@"y":@100}
 *
 *  @return
 */
- (CGPoint)pointValue;

/**
 *  转换成CGSize
 *
 *  @param @{@"width":@100,@"height":@100}
 *
 *  @return
 */
- (CGSize)sizeValue;

@end
