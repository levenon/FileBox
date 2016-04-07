//
//  XLFPinNumButton.h
//  XLFPinViewController
//
//  Created by Marike Jave on 14.4.14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//

@import UIKit;

@interface XLFPinNumButton : UIButton

@property (nonatomic, readonly, assign) NSUInteger number;
@property (nonatomic, readonly, copy) NSString *letters;

- (instancetype)initWithNumber:(NSUInteger)number letters:(NSString *)letters;

+ (CGFloat)diameter;

@end
