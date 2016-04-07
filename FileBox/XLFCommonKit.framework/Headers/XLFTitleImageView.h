//
//  XLFTitleImageView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-24.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface XLFTitleImageView : UIImageView
@property(nonatomic , copy  ) NSString *evTitle;
@property(nonatomic , strong) UIFont *evFont;
@property(nonatomic , strong) UIColor *evTextColor;
@property(nonatomic , assign) NSTextAlignment evTextAlignment;
@property(nonatomic , assign) UIEdgeInsets evEdgeInset;
@end
