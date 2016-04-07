//
//  XLFPinInputCirclesView.h
//  XLFPinInputViewController
//
//  Created by Marike Jave on 20.4.14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//

@import UIKit;

typedef void (^XLFPinInputCirclesViewShakeCompletionBlock)(void);

@interface XLFPinInputCirclesView : UIView

@property (nonatomic, assign) NSUInteger pinLength;

- (instancetype)initWithPinLength:(NSUInteger)pinLength;

- (void)fillCircleAtPosition:(NSUInteger)position;
- (void)unfillCircleAtPosition:(NSUInteger)position;
- (void)unfillAllCircles;
- (void)shakeWithCompletion:(XLFPinInputCirclesViewShakeCompletionBlock)completion;

@end
