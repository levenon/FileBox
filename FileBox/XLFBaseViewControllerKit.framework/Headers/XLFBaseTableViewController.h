//
//  XLFBaseTableViewController.h
//  XLFBaseViewControllerKit
//
//  Created by Marike Jave on 15/3/18.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "XLFBaseViewControllerDelegate.h"

@class XLFBaseNavigationController;

@interface XLFBaseTableViewController : UITableViewController<XLFBaseViewControllerDelegate>

@property(nonatomic, assign, readonly, getter=isBeingUnload) BOOL beingUnload;

@property(nonatomic, assign, readonly, getter=isBeingLoad) BOOL beingLoad;

@property(nonatomic, strong, readonly) UIImageView *evimgvContentBackground;

@property(nonatomic, strong) UIImage   *evBackgroundImage;//默认背景图片,注意使用该方法，整个App的背景将会都将会被改变

@end

