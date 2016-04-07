//
//  XLFTipsView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-10.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef _TipsEnums_
#define _TipsEnums_
typedef enum{
    
    TipsVerticalPostionForCenter = 0,//默认居中
    TipsVerticalPostionForBelowNavGation,
    TipsVerticalPostionForBottom//注意显示在下面的，如果传递view过来，则需要使用有箭头的图标
} TipsVerticalPostion;//提示垂直位置，上中下

typedef enum {
    
    TipsTypeForNone,
    TipsTypeForSuccess,
    TipsTypeForFail,
    TipsTypeForWorning,
} TipsType;//提示类型
typedef enum {
    
    TipsPositionTypeForTopBelowNavGation,
    TipsPositionTypeForCenter,
    TipsPositionTypeForBottom,//注意显示在下面的，如果传递view过来，则需要使用有箭头的图标
    
} TipsPositionType;//提示显示位置，上中下
#endif
@interface XLFTipsView : UIView
@property(nonatomic, strong) UILabel *tipsContentLabel;
@property(nonatomic, strong) UIImageView *tipsIconImageView;
@property(nonatomic, strong) UIImageView *tipsBackgroundImageView;
@property(nonatomic, assign) TipsType tipsType;
@property(nonatomic, assign) TipsVerticalPostion tipsPositionType;
- (void)setAttributeWithTipsMessage:(NSString*)tipsMessage
                 TipsIconImageName:(NSString*)tipsIconImageName
                          TipsType:(TipsType)tipsType
                  TipsPositionType:(TipsVerticalPostion)tipsPositionType;
#pragma mark - 显示
- (void)showInView:(UIView*)needShowView WithAnimated:(BOOL)animated;
#pragma mark - 隐藏
/*
 @abstract 隐藏提示
 @param hideAfterDelay 设置多久之后隐藏
 */
- (void)hideAfterDelay:(NSTimeInterval)hideAfterDelay;
- (void)hideWithAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;
#pragma mark - 移除
/*
 @abstract 移除视图
 */
- (void)removeWithAnimated:(BOOL)animated;
@end
