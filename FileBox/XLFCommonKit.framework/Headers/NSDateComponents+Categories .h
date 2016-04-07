//
//  NSDateComponents.h
//  XLFCommonKit
//
//  Created by Marike Jave on 15/8/26.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents(Categories)

+ (NSDateComponents*)componentsWithDateComponents:(NSDateComponents *)dateComponents;

//- (void)clone:(NSDateComponents*)dateComponents;
- (void)monthOffset:(NSInteger)month;
+ (NSDateComponents*)nowDateComponents:(NSCalendarUnit)unitFlags;
+ (NSDateComponents*)components:(NSCalendarUnit)unitFlags fromDate:(NSDate*)date;
- (NSDate *)date;

@end
