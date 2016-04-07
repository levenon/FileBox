//
//  XLFBaseCategory.h
//  XLFBaseViewControllerKit
//
//  Created by Marike Jave on 15/3/18.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "XLFBaseGlobal.h"

@protocol XLFLayoutConstraintProtocol <NSObject>

//iPhone4S,iPhone5/5s,iPhone6
//竖屏：(w:Compact h:Regular)
//横屏：(w:Compact h:Compact)
//
//iPhone6 Plus
//竖屏：(w:Compact h:Regular)
//横屏：(w:Regular h:Compact)
//
//iPad
//竖屏：(w:Regular h:Regular)
//横屏：(w:Regular h:Regular)
//
//Apple Watch
//竖屏：(w:Compact h:Compact)
//横屏：(w:Compact h:Compact)

// default constraint
- (void)epUpdateConstraints;

// iphone portrait (h:Compact v:Regular)
- (void)epUpdateIPhonePortraitConstraints;

// iphone landscape (h:Compact v:Compact)
- (void)epUpdateIPhoneLandscapeConstraints;

// iphone landscape (h:Regular v:Compact)
- (void)epUpdateIPhone6PlusLandscapeConstraints;

// ipad portrait (h:Regular v:Regular)
- (void)epUpdateIPadPortraitConstraints;
// ipad landscape (h:Regular v:Regular)
- (void)epUpdateIPadLandscapeConstraints;

// iwatch portrait (h:Compact v:Compact)
- (void)epUpdateIWatchdPortraitConstraints;
// iwatch landscape (h:Compact v:Compact)
//- (void)epUpdateIWatchLandscapeConstraints;

// TV (h:Regular v:Compact)
- (void)epUpdateTVConstraints;

@end

@class XLFBaseNavigationController;
@protocol XLFBaseViewControllerDelegate;

@interface UINavigationController (XLFBaseViewControllerKit)

@property(strong, nonatomic, readonly) UIViewController*    evVisibleViewController;
@property(assign, nonatomic, readonly) CGRect               evNavigationBarFrame;
@property(assign, nonatomic, readonly) CGRect               evTabBarFrame;
@property(assign, nonatomic, readonly) CGRect               evToolBarFrame;

- (void)copyNavgationBarStyle:(UIViewController*)viewController;
@end

@interface UITabBarController (XLFBaseViewControllerKitXLFBaseViewControllerKit)

@property(strong, nonatomic, readonly) UIViewController*    evVisibleViewController;
@property(assign, nonatomic, readonly) CGRect               evNavigationBarFrame;
@property(assign, nonatomic, readonly) CGRect               evTabBarFrame;
@property(assign, nonatomic, readonly) CGRect               evToolBarFrame;

@end

@interface UIViewController (XLFBaseViewControllerKit)

@property(strong, nonatomic, readonly) XLFBaseNavigationController *evBaseNavigationController;
@property(strong, nonatomic, readonly) UIViewController<XLFBaseViewControllerDelegate> *evPreviousViewController;
@property(strong, nonatomic, readonly) UIViewController<XLFBaseViewControllerDelegate> *evNextViewController;
@property(strong, nonatomic, readonly) UIBarButtonItem*     evbbiDefaultBack;
@property(strong, nonatomic, readonly) UIViewController*    evVisibleViewController;
@property(assign, nonatomic, readonly) CGRect               evNavigationBarFrame;
@property(assign, nonatomic, readonly) CGRect               evTabBarFrame;
@property(assign, nonatomic, readonly) CGRect               evToolBarFrame;

- (void)efBack;

- (void)efBack:(void (^)())complete;

- (void)efShowImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
                          allowsEditing:(BOOL)allowsEditing
                               delegate:(id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate;

- (void)efShowCameraWithCaptureMode:(UIImagePickerControllerCameraCaptureMode)cameraCaptureMode
                        qualityType:(UIImagePickerControllerQualityType)qualityType
                       cameraDevice:(UIImagePickerControllerCameraDevice)cameraDevice
                    cameraFlashMode:(UIImagePickerControllerCameraFlashMode)cameraFlashMode
                      allowsEditing:(BOOL)allowsEditing
                           delegate:(id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate;

- (void)efRefresh;

- (void)efBackgroundFetchDataResult:(void (^)(NSError *error, id result))callback;
/**
 *  主题化，刷新支持
 */
- (void)efUpdateViewForTheme;

#pragma mark - 导航

/**
 *   设置背景
 *
 *  @param backgroudImage 视图背景图片
 *  @param isGlobal       是否是全局的，如果是则整个App的背景图片将会被替换
 */
- (void)efSetBackgroudImage:(UIImage*)backgroudImage
                   isGlobal:(BOOL)isGlobal;
- (void)efSetBackgroudColor:(UIColor*)backgroudColor
                   isGlobal:(BOOL)isGlobal;

/**
 *  设置导航
 *
 *  @param backgroundImageName  背景
 *  @param backgroundImage      导航背景图片
 *  @param tintColor tint 颜色
 *  @param titleFont  标题字体
 *  @param titleColor 标题颜色
 */
- (void)efSetNavBarBackgroundImage:(UIImage *)backgroundImage
                         tintColor:(UIColor*)tintColor
                         titleFont:(UIFont*)titleFont
                        titleColor:(UIColor*)titleColor;
- (void)efSetNavBarBackgroundImage:(UIImage *)image;

#pragma mark - 下一级控制器的返回按钮
// 当进入同一导航控制器的下一个视图控制器时，左边的bar item会显示这个
// Bar button item to use for the back button in the child navigation item.
@property (nonatomic,strong,readonly) UIBarButtonItem *evBackBarButtonItem;
- (void)efSetBackButtonTitle:(NSString*)title;
- (void)efSetBackButtonImage:(UIImage*)image;
- (void)efSetBackButton:(UIBarButtonItem*)backButton;
// 隐藏当前返回按钮
@property (nonatomic,assign) BOOL      evHiddenBackButton;//是否隐藏返回按钮，默认不隐藏
// If YES, this navigation item will hide the back button when it's on top of the stack.
- (void)efSetHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated;
/* By default, the leftItemsSupplementBackButton property is NO. In this case,
 the back button is not drawn and the left item or items replace it. If you
 would like the left items to appear in addition to the back button (as opposed to instead of it)
 set leftItemsSupplementBackButton to YES.
 */
@property(nonatomic) BOOL evLeftItemsSupplementBackButton;
@property (nonatomic,strong,readonly) UIBarButtonItem   *evLeftBarItem;
@property (nonatomic,strong,readonly) UIBarButtonItem   *evRightBarItem;
@property (nonatomic,strong,readonly) NSArray   *evLeftBarItems;
@property (nonatomic,strong,readonly) NSArray   *evRightBarItems;
- (UIBarButtonItem*)efSetBarButtonItemWithTitle:(NSString*)title
                                        forBack:(BOOL)forBack
                                           type:(XLFNavButtonType)type;
- (UIBarButtonItem*)efSetBarButtonItemWithImage:(UIImage*)image
                                        forBack:(BOOL)forBack
                                           type:(XLFNavButtonType)type;
- (void)efSetBarButtonItem:(UIBarButtonItem*)barButtonItem
                      type:(XLFNavButtonType)type;
- (void)efSetBarButtonItems:(NSArray*)barButtonItems
                       type:(XLFNavButtonType)type;
- (void)efAddBarButtonItem:(UIBarButtonItem*)barButtonItem
                      type:(XLFNavButtonType)type;
- (void)efInsertBarButtonItem:(UIBarButtonItem*)barButtonItem
                      atIndex:(NSUInteger)nIndex
                         type:(XLFNavButtonType)type;
- (void)efInsertBarButtonItem:(UIBarButtonItem*)barButtonItem
                        after:(UIBarButtonItem*)afterBarButtonItem
                         type:(XLFNavButtonType)type;
- (void)efRemoveBarButtonItem:(UIBarButtonItem*)barButtonItem
                         type:(XLFNavButtonType)type;
- (void)efRemoveBarButtonItems:(NSArray*)barButtonItems
                          type:(XLFNavButtonType)type;
- (void)efRemoveBarButtonItemsAtIndex:(NSInteger)nIndex
                                 type:(XLFNavButtonType)type;

- (IBAction)didClickNavBackButton:(id)sender;


#pragma mark - 屏幕尺寸，为了解决3.5 英寸 和  4.英寸屏幕问题
#pragma mark   注意，必须在[super viewDidLoad] 之后调用有效
/**
 *  获取正文内容尺寸
 *  @param  isIncludeTabBar  是否包含tabBar导航，如果包含tabbar（值为YES），
 则对应的内容尺寸需要减去tabBar所占用的高度
 *  @return 返回正文内容尺寸
 */
- (CGRect)efGetContentFrameIncludeTabBar:(BOOL)isIncludeTabBar __deprecated ;
/**
 *  系统会自动处理获取正确的尺寸
 *  @return 返回正文内容尺寸
 */
- (CGRect)efGetContentFrame __deprecated;

@end

@interface UIView(XLFBaseViewControllerKit)

@property(strong, nonatomic, readonly) UIViewController*    evVisibleViewController;
@property(assign, nonatomic, readonly) CGRect               evNavigationBarFrame;
@property(assign, nonatomic, readonly) CGRect               evTabBarFrame;
@property(assign, nonatomic, readonly) CGRect               evToolBarFrame;

- (void)efRefresh;

@end

@interface UITransitionCoordinatorTransformer : NSObject

@property(nonatomic, copy) void (^animation)(id<UIViewControllerTransitionCoordinatorContext> context);

@property(nonatomic, copy) void (^completion)(id<UIViewControllerTransitionCoordinatorContext> context);

@end

@interface UIView(RotateDevice)

- (NSArray<UITransitionCoordinatorTransformer *> *)viewWillTransitionToSize:(CGSize)size
                                                  withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator;
- (NSArray<UITransitionCoordinatorTransformer *> *)willTransitionToTraitCollection:(UITraitCollection *)newCollection
                                                         withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator;

@end

@interface NSObject(XLFBaseViewControllerKit)

@property(strong, nonatomic, readonly) UIViewController*    evVisibleViewController;
@property(assign, nonatomic, readonly) CGRect               evNavigationBarFrame;
@property(assign, nonatomic, readonly) CGRect               evTabBarFrame;
@property(assign, nonatomic, readonly) CGRect               evToolBarFrame;

- (void)efDeregisterNotification;
- (void)efRegisterNotification;

- (void)efRefresh;

@end
