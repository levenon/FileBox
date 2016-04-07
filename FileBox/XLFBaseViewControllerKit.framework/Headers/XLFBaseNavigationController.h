//
//  BaseNaviGationController.h
//  XLFBaseViewControllerKit
//
//  Created by Marike Jave on 15/3/18.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIViewController (UINavigationButtonAnimate)

- (void)viewAppearFromLeft;
- (void)viewAppearFromRight;
- (void)viewDisappearFromLeft;
- (void)viewDisappearFromRight;

@end

@interface XLFBaseNavigationController : UINavigationController

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate;

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated;

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completeBlock:(void(^)(XLFBaseNavigationController *navgationController))completeBlock;

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completeBlock:(void(^)(XLFBaseNavigationController *navgationController))completeBlock;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated completeBlock:(void(^)(XLFBaseNavigationController *navgationController))completeBlock;

- (void)pushViewController:(UIViewController *)viewController followByViewController:(UIViewController *)followByViewController animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController replaceViewController:(UIViewController *)followByViewController animated:(BOOL)animated;

@end
