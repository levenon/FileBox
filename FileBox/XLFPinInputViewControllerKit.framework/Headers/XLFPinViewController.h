//
//  XLFPinViewController.h
//  XLFPinViewController
//
//  Created by Marike Jave on 11.4.14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//

@import UIKit;

@class XLFPinViewController;

// when using translucentBackground assign this tag to the view that should be blurred

@protocol XLFPinViewControllerDelegate <NSObject>

@required
- (NSUInteger)pinLengthForPinViewController:(XLFPinViewController *)pinViewController;
- (BOOL)pinViewController:(XLFPinViewController *)pinViewController isPinValid:(NSString *)pin;
- (BOOL)userCanRetryInPinViewController:(XLFPinViewController *)pinViewController;

@optional
- (void)incorrectPinEnteredInPinViewController:(XLFPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(XLFPinViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(XLFPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:(XLFPinViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:(XLFPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(XLFPinViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasCancelled:(XLFPinViewController *)pinViewController;

@end

@interface XLFPinViewController : UIViewController

@property (nonatomic, weak) id<XLFPinViewControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *backgroundColor; // is only used if translucentBackground == NO
@property (nonatomic, assign) BOOL translucentBackground;
@property (nonatomic, copy) NSString *promptTitle;
@property (nonatomic, strong) UIColor *promptColor;
@property (nonatomic, assign) BOOL hideLetters;

- (instancetype)initWithDelegate:(id<XLFPinViewControllerDelegate>)delegate;

- (void)clear;

@end
