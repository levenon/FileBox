//
//  XLFFormTextField.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "XLFLimitTextField.h"

extern NSInteger KDefualtWidth ;

typedef NS_ENUM(NSInteger, XLFLineMode){

    XLFLineModeScaleToFillAll,
    XLFLineModeScaleToFillContent
};
typedef NS_ENUM(NSInteger, XLFLineStyle){

    XLFLineStyleNone,
    XLFLineStyleSolid,
    XLFLineStyleDot
};
typedef NS_ENUM(NSInteger, XLFFormTextFieldStyle){

    XLFFormTextFieldStyleDefault       = 0,            // No line , no title , no detail text
    XLFFormTextFieldStyleTitle         = 1 << 1,       // Title enable
    XLFFormTextFieldStyleDetail        = 1 << 2,       // Detail text enable
    XLFFormTextFieldStyleUnderline     = 1 << 3        // Underline enable
};

@interface XLFFormTextField : XLFLimitTextField

@property (strong , nonatomic) NSString *evTitle ;
//@property (strong , nonatomic , readonly) UILabel *evlbTitle ;
@property (assign , nonatomic) CGFloat evTitleWidth;                // Default is KDefualtWidth
@property (strong , nonatomic) UIFont *evTitleFont;                 // Default is [UIFont systemFontOfSize:13].
@property (strong , nonatomic) UIColor *evTitleColor;               // Default is blackColor.
@property (assign , nonatomic) NSTextAlignment evTitleAlignment;    // Default is NSTextAlignmentLeft.

@property (strong , nonatomic) NSString *evDetail ;
//@property (strong , nonatomic , readonly) UILabel *evlbDetail ;
@property (assign , nonatomic) CGFloat evDetailWidth;               // Default is KDefualtWidth.
@property (strong , nonatomic) UIFont *evDetailFont;                // Default is [UIFont systemFontOfSize:13].
@property (strong , nonatomic) UIColor *evDetailColor;              // Default is blackColor.
@property (assign , nonatomic) NSTextAlignment evDetailAlignment;   // Default is NSTextAlignmentLeft.

@property (assign , nonatomic) XLFLineStyle evLineStyle;            // If evStyle & TextFieldStyleUnderline is NO , the line is invisible , default is LineStyleNone.
@property (assign , nonatomic) XLFLineMode evLineMode;
@property (strong , nonatomic) UIColor *evLineColor;                // Default is blackColor. if line image is nil, line color is enable, or use line image.
@property (strong , nonatomic) UIImage *evLineImage;                // Default is nil.

@property (assign , nonatomic , readonly) XLFFormTextFieldStyle evStyle ;  // Default is FormTextFieldStyleDefault.
- (id)initWithFrame:(CGRect)frame style:(XLFFormTextFieldStyle)style;

@end

