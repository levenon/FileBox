//
//  UIViewController+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 15/3/18.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Categories)

+ (id)viewController;
+ (id)viewControllerFromNib;
+ (id)viewControllerFromNib:(NSString*)nibName;

+(id)viewControllerFromStoryboard:(NSString*)storyboardName;
+(id)viewControllerFromStoryboard:(NSString*)storyboardName storyboardId:(NSString*)storyboardId;

@end
