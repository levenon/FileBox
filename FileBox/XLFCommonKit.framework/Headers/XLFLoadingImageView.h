//
//  XLFLoadingImageView
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    
    XLFLoadingStyleDefault = 1,
	XLFLoadingStyleBlackBackground = 2

}XLFLoadingStyle;

@interface XLFLoadingImageView : UIImageView
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)UILabel *progressLabel;
@property(nonatomic, assign)XLFLoadingStyle loadingStyle;
- (void)beginAnimationLoading;
- (void)stopAnimationLoading;
- (void)setText:(NSString *)aText;
- (id)initWithFrame:(CGRect)frame withStyle:(XLFLoadingStyle)style withTitle:(NSString *)t;
@end
