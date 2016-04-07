//
//  NSAttributedString+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 15/1/30.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Categories)

- (CGFloat)widthWithLimitHeight:(CGFloat)height;

- (CGFloat)heightWithLimitWidth:(CGFloat)width;

@end
