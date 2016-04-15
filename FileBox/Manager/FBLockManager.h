//
//  FBLockManager.h
//  FileBox
//
//  Created by Marike Jave on 15/2/9.
//  Copyright (c)2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>

typedef void(^VerifySuccessBlock)(BOOL success);

extern NSString * const kNotificationVerifyHasChanged;

@interface FBLockManager :NSObject

@property (nonatomic, strong, readonly)NSDictionary *evLockKey;
@property (nonatomic, assign, getter=evIsVerifySuccess, readonly)BOOL evVerifySuccess;
@property (nonatomic, assign, getter=evNeedSetPassword, readonly)BOOL evNeedSetPassword;
@property (nonatomic, assign, getter=evIsPasswordEnable)BOOL evPasswordEnable;

@property (nonatomic, assign, readonly)BOOL evCanEvaluatePolicy;

@property (nonatomic, copy, readonly)NSString *evPassword;

+ (FBLockManager*)sharedInstance;

+ (BOOL)efUpdateToDisk;

+ (void)efClearAllData;

+ (void)efClearAllDataNotSaveToDisk;

+ (void)efRemoveLockForFilePath:(NSString*)filePath;

+ (void)efSetNeedLock:(BOOL)need forFilePath:(NSString*)filePath;

+ (BOOL)efNeedLockForFilePath:(NSString*)filePath;

+ (void)efVerifyWithResultBlock:(VerifySuccessBlock)resultBlock;

+ (void)efResetPasswordWithResultBlock:(VerifySuccessBlock)resultBlock;

@end
