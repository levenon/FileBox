//
//  XLFLabelView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-3-6.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface XLFUserDefinedLabelView : UIView
@property(nonatomic,strong,readonly)UILabel *evContentLabel;
@property(nonatomic,strong)NSString *evText;
@property(nonatomic,strong)NSAttributedString *evAttributedString;
- (id)initWithFrame:(CGRect)frame
        frameInsets:(UIEdgeInsets)frameInsets
backgroundImageFile:(NSString *)backgroundImageFile
backgroundImageInsets:(UIEdgeInsets)backgroundImageInsets
        labelInsets:(UIEdgeInsets)labelInsets
               font:(UIFont *)font
          textColor:(UIColor *)textColor;
- (id)initWithFrame:(CGRect)frame
       frameInsets:(UIEdgeInsets)frameInsets
   backgroundImage:(UIImage *)backgroundImage
backgroundImageInsets:(UIEdgeInsets)backgroundImageInsets
       labelInsets:(UIEdgeInsets)labelInsets
              font:(UIFont *)font
         textColor:(UIColor *)textColor;
@end
