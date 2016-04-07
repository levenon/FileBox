//
//  UIView+Categories
//  XLFCommonKit
//
//  Created by Marike Jave on 14-8-28.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CALayer(Extended)
@property (nonatomic , assign) CGPoint origin;
@property (nonatomic , assign) CGFloat left;
@property (nonatomic , assign) CGFloat top;
@property (nonatomic , assign , readonly) CGPoint termination;
@property (nonatomic , assign , readonly) CGFloat right;  // right
@property (nonatomic , assign , readonly) CGFloat bottom;  // bottom
@property (nonatomic , assign) CGSize  size;
@property (nonatomic , assign) CGFloat width;
@property (nonatomic , assign) CGFloat height;

@end

@interface UIView(Extended)
@property (nonatomic , assign) CGPoint origin;
@property (nonatomic , assign) CGFloat left;
@property (nonatomic , assign) CGFloat top;
@property (nonatomic , assign , readonly) CGPoint termination;
@property (nonatomic , assign , readonly) CGFloat right;  // right
@property (nonatomic , assign , readonly) CGFloat bottom;  // bottom
@property (nonatomic , assign) CGSize  size;
@property (nonatomic , assign) CGFloat width;
@property (nonatomic , assign) CGFloat height;

// 在UIView中递归查找指定Tag的UIView
- (UIView *)subViewWithTag:(NSInteger)tag;
@end

@interface UIView(Create)
+(id)view;
+(id)emptyFrameView;
+(id)viewFromNib;
+(id)viewFromNibName:(NSString*)nibName;

@end

@interface UIView (Loading)

@property(nonatomic, strong, readonly) UIActivityIndicatorView *evaivLoading;

- (void)startLoading;
- (void)stopLoading;

@end

CG_EXTERN CGRect CGRectMakePS(CGPoint pt, CGSize sz);
CG_EXTERN CGRect CGRectMakePWH(CGPoint pt, CGFloat width, CGFloat height);
CG_EXTERN CGRect CGRectMakeXYS(CGFloat x, CGFloat y, CGSize sz);

CG_EXTERN CGSize  CGRectGetSize(CGRect rect);
CG_EXTERN CGPoint CGRectGetOrigin(CGRect rect);
CG_EXTERN CGPoint CGRectGetCenter(CGRect rect);
CG_EXTERN CGPoint CGRectGetTermination(CGRect rect);

