//
//  NSIndexPath+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 15/11/25.
//  Copyright © 2015年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSIndexPath (Categories)

+ (NSArray *)indexPathsInSection:(NSInteger)section fromIndex:(NSInteger)nIndex count:(NSInteger)count;

+ (NSArray *)indexPathsFromIndex:(NSInteger)nIndex count:(NSInteger)count;

@end
