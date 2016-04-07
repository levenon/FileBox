//
//  SVStatusHUD.h
//
//  Created by Marike Jave on 17.11.11.
//  Copyright 2011 Marike Jave. All rights reserved.
//
//  https://github.com/samvermette/SVStatusHUD
//
#import <UIKit/UIKit.h>
@interface SVStatusHUD : UIView
+ (void)showWithImage:(UIImage*)image;
+ (void)showWithImage:(UIImage*)image status:(NSString*)string;
+ (void)showWithImage:(UIImage*)image status:(NSString*)string duration:(NSTimeInterval)duration;
/**
 * Show the error HUD and hides them after duration.
 *
 * @param view The view that is going to be searched for HUD subviews.
 *
 */
+ (void)showErrorWithStatus:(NSString *)status ;
+ (void)showErrorWithStatus:(NSString *)status duration:(NSTimeInterval)duration ;
/**
 * Show the success HUD and hides them after duration .
 *
 * @param view The view that is going to be searched for HUD subviews.
 *
 */
+ (void)showSuccessWithStatus:(NSString *)status ;
+ (void)showSuccessWithStatus:(NSString *)status duration:(NSTimeInterval)duration ;
/**
 * Show the warning HUD and hides them after duration .
 *
 * @param view The view that is going to be searched for HUD subviews.
 *
 */
+ (void)showWarningWithStatus:(NSString *)status ;
+ (void)showWarningWithStatus:(NSString *)status duration:(NSTimeInterval)duration ;

@end
