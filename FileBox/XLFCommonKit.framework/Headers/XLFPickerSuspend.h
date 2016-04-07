//
//  XLFPickerSuspend.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-10.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol PickerItemInterface <NSObject>
@property(nonatomic, copy) NSString *name;
@end
@protocol PickerDelegate <NSObject>
- (void)epDidPickSelectedItems:(NSArray*)selectedItems userInfo:(id)userInfo;
@end
@interface XLFPickerSuspend : NSObject
@property (assign , nonatomic) id<PickerDelegate> evDelegate;
@property (strong , nonatomic , readonly) NSArray *components ;
@property (assign , nonatomic) id evUserInfo;
@property (assign , nonatomic, setter = show:) BOOL isShow;
+ (XLFPickerSuspend*)sharedInstance;
+ (void)reset;
+ (void)addComponent:(NSArray*)component;
+ (void)selectRow:(NSInteger)row component:(NSInteger)component;
+ (void)showWithDelegate:(id<PickerDelegate>)delegate userInfo:(id)userInfo;

@end
