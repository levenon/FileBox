//
//  XLFPinView.h
//  XLFPinInputViewController
//
//  Created by Marike Jave on 21.4.14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XLFPinView;

@protocol XLFPinViewDelegate <NSObject>

@required
- (NSUInteger)pinLengthForPinView:(XLFPinView *)pinView;
- (BOOL)pinView:(XLFPinView *)pinView isPinValid:(NSString *)pin;
- (void)cancelButtonTappedInPinView:(XLFPinView *)pinView;
- (void)correctPinWasEnteredInPinView:(XLFPinView *)pinView;
- (void)incorrectPinWasEnteredInPinView:(XLFPinView *)pinView;

@end

@interface XLFPinView : UIView

@property (nonatomic, weak) id<XLFPinViewDelegate> delegate;
@property (nonatomic, copy) NSString *promptTitle;
@property (nonatomic, strong) UIColor *promptColor;
@property (nonatomic, assign) BOOL hideLetters;

- (instancetype)initWithDelegate:(id<XLFPinViewDelegate>)delegate;

@end
