//
//  XLFPinNumPadView.h
//  XLFPinInputViewController
//
//  Created by Marike Jave on 20.4.14.
//  Copyright (c) 2014 Marike Jave. All rights reserved.
//

@import UIKit;

@class XLFPinNumPadView;

@protocol XLFPinNumPadViewDelegate <NSObject>

@required
- (void)pinNumPadView:(XLFPinNumPadView *)pinNumPadView numberTapped:(NSUInteger)number;

@end

@interface XLFPinNumPadView : UIView

@property (nonatomic, weak) id<XLFPinNumPadViewDelegate> delegate;
@property (nonatomic, assign) BOOL hideLetters;

- (instancetype)initWithDelegate:(id<XLFPinNumPadViewDelegate>)delegate;

@end
