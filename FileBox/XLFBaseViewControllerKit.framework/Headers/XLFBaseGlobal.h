//
//  XLFBaseGlobal.h
//  XLFBaseViewControllerKit
//
//  Created by Marike Jave on 15/3/18.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum  {

    XLFNavButtonTypeLeft,
    XLFNavButtonTypeRight,

} XLFNavButtonType;

typedef void (^NavButtonClickBlock)(XLFNavButtonType navButtonType, NSInteger currentTabIndex);

#define UIViewAutoresizingFlexibleAll   (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin)


extern UIImage* const   egfBackgroundImage();
extern UIColor* const   egfBackgroudColor();
extern UIImage* const   egfNavBackgroundImage();
extern UIImage* const   egfNavLeftBackgroundImage();
extern UIImage* const   egfNavRightBackgroundImage();
extern UIImage* const   egfNavBackIconImage();
extern NSString* const  egfNavBackTitle();
extern NSString* const  egfBackIgnoreVCClassName();

extern void egfRegisterGlobalBackgroundColor(UIColor* color);
extern void egfRegisterGlobalBackgroundImage(UIImage* image);
extern void egfRegisterGlobalNavBackgroundImage(UIImage* image);
extern void egfRegisterGlobalNavLeftBackgroundImage(UIImage* image);
extern void egfRegisterGlobalNavRightBackgroundImage(UIImage* image);
extern void egfRegisterGlobalNavBackIconImage(UIImage* image);
extern void egfRegisterGlobalNavBackTitle(NSString* title);
extern void egfRegisterGlobalBackIgnoreVCClassName(NSString* clsName);

