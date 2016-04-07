//
//  UISearchBar+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-12-31.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (Categories)

@property (strong, nonatomic, readonly) UITextField* textField;

@property (strong, nonatomic) UIColor* textColor;
@property (strong, nonatomic) UIFont* font;

@end
