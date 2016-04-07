//
//  UIActionSheet+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 15/1/27.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet(Categories)

+ (UIActionSheet*)actionSheetWithTitle:(NSString *)title;

+ (UIActionSheet*)actionSheetWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate;

+ (UIActionSheet*)actionSheetWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString*)cancelButtonTitle;

+ (UIActionSheet*)actionSheetWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonIndex:(NSInteger)nIndex buttonTitles:(NSString *)buttonTitles, ...;

+ (void)showActionSheetWithTitle:(NSString *)title;
+ (void)showActionSheetWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate;
+ (void)showActionSheetWithTitle:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString*)cancelButtonTitle;
+ (UIActionSheet *)showInView:(UIView *)view title:(NSString *)title delegate:(id<UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
