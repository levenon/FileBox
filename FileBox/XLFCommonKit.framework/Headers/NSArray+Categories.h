//
//  NSArray+Extended.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-3-17.
// Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Categories)

- (id)objectAtIndexWithSafety:(NSUInteger)index;

@end

@interface NSMutableArray (Categories)

- (void)intersectSet:(NSArray *)otherArray;
- (void)minusSet:(NSArray *)otherArray;
- (void)unionSet:(NSArray *)otherArray;

@end