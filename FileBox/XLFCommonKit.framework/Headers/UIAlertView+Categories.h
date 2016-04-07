//
//  UIAlertView+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-3-31.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIAlertView (Categories)

+ (UIAlertView*)alertWithMessage:(NSString *)message;
+ (UIAlertView*)alertWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertView*)alertWithTitle:(NSString *)title message:(NSString *)message delegate:delegate;
+ (UIAlertView*)alertWithTitle:(NSString *)title message:(NSString *)message delegate:delegate tag:(NSInteger)aTag;
+ (UIAlertView*)alertWithTitle:(NSString *)title message:(NSString *)message delegate:delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
