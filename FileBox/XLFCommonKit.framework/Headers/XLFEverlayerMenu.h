//
//  XLFEverlayerMenu.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
@class XLFEverlayerMenu;
@protocol EverlayerMenuDelegate <NSObject>
- (void)epEverlayerMenu:(XLFEverlayerMenu*)menu didSelectIndex:(NSInteger)nIndex;
@end
@interface XLFEverlayerMenu : UIView
@property(assign , nonatomic) id<EverlayerMenuDelegate> evDelegate;
@property(strong , nonatomic) NSArray *evMemuTitles;

- (id)initWithMemuTitles:(NSArray *)memuTitles delegate:(id<EverlayerMenuDelegate>)delegate superView:(UIView *)superView;;

@end
