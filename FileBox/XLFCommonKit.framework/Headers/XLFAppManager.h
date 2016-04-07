//
//  XLFAppManager
//  XLFCommonKit
//
//  Created by Marike Jave on 15/4/8.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLFAppManager : NSObject

+ (id)sharedInstance;

+ (void)efCommentApplication;

+ (void)efCheckVersion;

+ (void)efRegisterAppId:(NSString*)appId;

@end
