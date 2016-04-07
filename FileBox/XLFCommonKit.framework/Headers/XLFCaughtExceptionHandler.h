//
//  XLFCaughtExceptionHandler.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-11.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <Foundation/Foundation.h>
@interface XLFCaughtExceptionHandler : NSObject{

    BOOL dismissed;
}

+ (void)efInstallUncaughtExceptionHandler;
+ (void)efUnInstallUncaughtExceptionHandler;

@end