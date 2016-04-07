//
//  XLFDatePickerView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 15/9/8.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XLFDatePickerView;

@protocol XLFDatePickerViewDelegate <NSObject>

- (void)epDatePickerView:(XLFDatePickerView *)datePickerView didSelectDateComponents:(NSDateComponents *)selectedDateComponents;

@end

@interface XLFDatePickerView : UIView

@property(nonatomic, assign, readonly) id<XLFDatePickerViewDelegate> evDelegate;

@property(nonatomic, strong, readonly) NSDate *evBeginDate;

@property(nonatomic, strong, readonly) NSDate *evEndDate;

@property(nonatomic, assign, readonly) BOOL evFutureSelectable;

- (instancetype)initWithDelegate:(id<XLFDatePickerViewDelegate>)delegate
                       beginDate:(NSDate *)beginDate
                         endDate:(NSDate *)endDate
                     futureSelectable:(BOOL)futureSelectable
                   calendarUnits:(NSNumber *)calendarUnits,...; // 顺序如下： 年 月 日 时 分 秒

- (void)efShow;
- (void)efShowInView:(UIView *)inView;

@end
