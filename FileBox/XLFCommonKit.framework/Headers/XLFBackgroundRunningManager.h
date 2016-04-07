//
//  XLFBackgroundRunningManager.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-11-25.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XLFBackgroundRunningManager : NSObject

+ (XLFBackgroundRunningManager *)sharedInstance;

- (void)efRunningInBackground:(void (^)())backgroundBlock;

@end
