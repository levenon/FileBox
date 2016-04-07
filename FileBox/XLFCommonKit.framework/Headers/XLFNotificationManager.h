//
//  XLFNotificationManager.h
//  XLFrivingCustomer
//
//  Created by Marike Jave on 15/10/15.
//  Copyright © 2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const XLFNotificationManagerDidReceiveNotification;

@protocol XLFNotificationAps <NSObject>

@property(nonatomic, copy  ) NSString *alert;
@property(nonatomic, copy  ) NSString *badge;
@property(nonatomic, copy  ) NSString *sound;

@property(nonatomic, assign) BOOL contentAvailable;

@end

@protocol XLFNotificationCustomContent <NSObject>

@property(nonatomic, assign) NSInteger notificationCustomContentType;
@property(nonatomic, strong) id object;

@end

@interface XLFNotification : NSObject

@property(nonatomic, strong) id<XLFNotificationAps> aps;
@property(nonatomic, strong) id<XLFNotificationCustomContent> customContent;

- (id)initWithNotificationAps:(id<XLFNotificationAps>)notificationAps customContent:(id<XLFNotificationCustomContent>)customContent;

+ (id)notificationWithNotificationAps:(id<XLFNotificationAps>)notificationAps customContent:(id<XLFNotificationCustomContent>)customContent;

@end


@protocol XLFNotificationHandleDelegate <NSObject>

@optional

- (BOOL)epDidHandleNoitification:(id<XLFNotificationCustomContent>)notificationUserInfo;

@end

@interface XLFNotificationHandle : NSObject

@property(nonatomic, assign, readonly) NSInteger evType;

@property(nonatomic, assign, readonly) BOOL evForever;

@property(nonatomic, copy  , readonly) void (^ evblcNotificationHandle)(id<XLFNotificationCustomContent>notificationUserInfo);

@property(nonatomic, assign, readonly) id<XLFNotificationHandleDelegate> evDelgate;

@end

@interface XLFNotificationManager : NSObject

@property(nonatomic, strong, readonly) NSArray<XLFNotificationCustomContent> *evNotificationUserInfos;
@property(nonatomic, strong, readonly) NSArray<XLFNotificationHandle *> *evNotificationHandles;

@property(nonatomic, strong) NSArray<NSNumber *> *evAllowInactiveNotificationTypes;

+ (id)shareManager;

+ (void)efHandleNotification:(XLFNotification *)notification backgroundFetch:(BOOL)backgroundFetch;

+ (XLFNotificationHandle *)efRegisterNotificationHandle:(void(^)(id<XLFNotificationCustomContent> notificationUserInfo))notificationHandle
                                                   type:(NSInteger)type
                                         relationObject:(id)relationObject;

+ (XLFNotificationHandle *)efRegisterNotificationHandle:(void(^)(id<XLFNotificationCustomContent> notificationUserInfo))notificationHandle
                                                   type:(NSInteger)type
                                                forever:(BOOL)forever
                                         relationObject:(id)relationObject;

+ (XLFNotificationHandle *)efRegisterNotificationHandleDelegate:(id<XLFNotificationHandleDelegate>)delegate
                                                           type:(NSInteger)type
                                                 relationObject:(id)relationObject;

+ (XLFNotificationHandle *)efRegisterNotificationHandleDelegate:(id<XLFNotificationHandleDelegate>)delegate
                                                           type:(NSInteger)type
                                                        forever:(BOOL)forever
                                                 relationObject:(id)relationObject;

+ (void)efRemoveNotificationHandlesDelegate:(id<XLFNotificationHandleDelegate>)delegate type:(NSInteger)type;

+ (void)efRemoveNotificationHandlesDelegate:(id<XLFNotificationHandleDelegate>)delegate forever:(BOOL)forever;

+ (void)efRemoveNotificationHandlesDelegate:(id<XLFNotificationHandleDelegate>)delegate type:(NSInteger)type forever:(BOOL)forever;

+ (void)efRemoveNotificationHandlesDelegate:(id<XLFNotificationHandleDelegate>)delegate;

+ (void)efRemoveNotificationHandlesWithType:(NSInteger)type;

+ (void)efRemoveNotificationUserInfosWithType:(NSInteger)type;

@end

