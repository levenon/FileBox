//
//  RunTime.h
//  XLFBaseModelKit
//
//  Created by Marike Jave on 14-4-3.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XLFBaseModelInterface;

@interface XLFRunTime : NSObject

+(NSArray *)ivarList:(Class)instance;
+(NSArray *)ivarNameList:(Class)instance;
+(NSArray *)allIvarNameList:(Class<XLFBaseModelInterface>)instance; // 包括父类成员变量
+(NSArray *)allIvarList:(Class<XLFBaseModelInterface>)instance;     // 包括父类成员变量
+(id)ivarValue:(NSObject<XLFBaseModelInterface> *)instance ivarName:(NSString *)ivarName;
+(void)setIvarValue:(NSObject<XLFBaseModelInterface> *)instance ivarName:(NSString *)ivarName value:(id)value;
+(NSString *)ivarType:(NSObject<XLFBaseModelInterface> *)instance ivarName:(NSString *)ivarName;

+(NSInteger)sizeOfObject:(id)object;
+(NSData *)archivedDataWithRootObject:(id)object;

+(id)initWithCoder:(NSCoder *)aDecoder withInstance:(id<XLFBaseModelInterface>)instance;
+(void)encodeWithCoder:(NSCoder *)aCoder withInstance:(id<XLFBaseModelInterface>)instance;
+(void)setAttributes:(NSDictionary*)attributes withInstance:(id<XLFBaseModelInterface>)instance;
+(NSDictionary *)attributeWithInstance:(id<XLFBaseModelInterface>)instance;

+ (void)removeObjectForKey:(NSString*)aKey withInstance:(id<XLFBaseModelInterface>)instance;
+ (void)setObject:(id)anObject forKey:(NSString*)aKey withInstance:(id<XLFBaseModelInterface>)instance;
+ (id)objectForKey:(NSString*)aKey withInstance:(id<XLFBaseModelInterface>)instance;

+(void)clearWithInstance:(id<XLFBaseModelInterface>)instance;

@end
