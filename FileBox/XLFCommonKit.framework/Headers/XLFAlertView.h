//
//  XLFAlertView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#define AlertViewDefaultWidth 280.0f
#define AlertBottomHeight 45.0f //放Button 的地方默认高度

typedef void (^AlertViewBlock)(id alertView,NSInteger buttonIndex);

typedef enum{
    
    AlertTypeForNone,//无图标
    AlertTypeForWarning, //警告
    AlertTypeForChoice, //选择
    AlertTypeForConfirm,//确认
} AlertType;
@protocol AlertViewDelegate;
@interface XLFAlertView : UIView
@property (nonatomic, weak) id <AlertViewDelegate> delegate;
@property (nonatomic, copy)     NSString *title;
@property (nonatomic, copy)     NSString *message;
@property (nonatomic, copy)    NSArray *buttonsTitle;
@property (nonatomic, copy)     AlertViewBlock blockAfterDismiss;
@property (nonatomic, copy )   NSDictionary* info;
@property (nonatomic, copy)     NSString* iconName; //图标名称。 不设置，系统会使用默认的警告图标

#pragma mark -  视图
//层次 透明层、内容层
@property(nonatomic, readonly)UIView *blackBackgroundView;
@property(nonatomic, readonly)UIView *contentPanelView;
//基本结构  标题-内容-底部按钮 (上，中，下)
@property(nonatomic, readonly)UIView *titleView;
@property(nonatomic, readonly)UIView *contentView;
//注意如果 button 为nil 则表示不显示
@property(nonatomic, readonly)UIView *bottomView;

//默认内容，如果没有设置则不显示
@property(nonatomic, readonly)UILabel *titleLabel;
@property(nonatomic, readonly)UILabel *contentLabel;

#pragma  mark - 快捷弹出框
+(XLFAlertView*)showAlertView:(NSString*)message;
+(XLFAlertView*)showAlertView:(NSString*)message
                     delegate:(id<AlertViewDelegate>)delegate;
+(XLFAlertView*)showAlertViewWithTitle:(NSString*)title
                               Message:(NSString*)message
                          ButtonsTitle:(NSArray*)buttonsTitle
                              UserInfo:(NSDictionary*)userInfo
                              delegate:(id<AlertViewDelegate>)delegate;

#pragma mark - 初始化
+(id)alertViewWithTitle:(NSString*)title
                Message:(NSString*)message
           ButtonsTitle:(NSArray*)buttonsTitle
                   Info:(NSDictionary*)info
           AfterDismiss:(AlertViewBlock)block
              AlertType:(AlertType)alertType;

- (id)initWithTitle:(NSString*)title
           Message:(NSString*)message
      ButtonsTitle:(NSArray*)buttonsTitle
              Info:(NSDictionary*)info
      AfterDismiss:(AlertViewBlock)block
         AlertType:(AlertType)alertType;
//设置属性
- (void)setAttributesWithTitle:(NSString*)title
                      Message:(NSString*)message
                 ButtonsTitle:(NSArray*)buttonsTitle
                         Info:(NSDictionary*)info
                 AfterDismiss:(AlertViewBlock)block
                    AlertType:(AlertType)alertType;

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
#pragma  mark - 显示退出
- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;
@end
@protocol  AlertViewDelegate <NSObject>

@optional
//数据源
- (UIView*)XLFAlertView:(XLFAlertView *)alertView viewForTitleView:(UIView*)titleView;
- (UIView*)XLFAlertView:(XLFAlertView *)alertView viewForContentView:(UIView*)contentView;
- (UIButton*)XLFAlertView:(XLFAlertView *)alertView buttonForIndex:(NSInteger)buttonIndex;
- (CGFloat)AlertViewOfWidth:(XLFAlertView *)alertView;
- (CGFloat)AlertViewOfTopPadding:(XLFAlertView *)alertView;
- (CGFloat)XLFAlertView:(XLFAlertView *)alertView HeightForTitleView:(UIView*)titleView;
- (CGFloat)XLFAlertView:(XLFAlertView *)alertView HeightForContentView:(UIView*)contentView;
- (CGFloat)XLFAlertView:(XLFAlertView *)alertView HeightForBottomView:(UIView*)BottomView;
//代理
- (void)AlertViewWillDismiss:(XLFAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)AlertViewDidDismiss:(XLFAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)AlertViewWillShow:(XLFAlertView *)alertView; // before animation and showing view
- (void)AlertViewDidShow:(XLFAlertView *)alertView;  // after animation
@end

