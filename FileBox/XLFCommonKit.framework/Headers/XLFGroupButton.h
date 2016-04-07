//
//  XLFGroupButton.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-4-9.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
@class XLFGroupButton;
typedef void(^UserDefinedButtonClickedBlock)(XLFGroupButton *button,NSInteger index);
@interface XLFGroupButton : UIButton
@property(nonatomic,strong)id additionalProperty;
- (id)initWithFrame:(CGRect)frame andDictionary:(NSDictionary *)params;
- (void)setButtonWithDictionary:(NSDictionary *)params;
- (void)setDataWithDictionary:(NSDictionary *)params;
// 创建Button Group
- (NSMutableArray *)createBtnGroup;
// 加入Button Group
- (void)addToBtnGroup:(NSMutableArray *)btnGroup;
@end
