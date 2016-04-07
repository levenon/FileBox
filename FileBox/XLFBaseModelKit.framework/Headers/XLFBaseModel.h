//
//  XLFBaseModel.h
//  XLFBaseModelKit
//
//  Created by Marike Jave on 14-4-3.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Property(a)   @synthesize a=_##a

@protocol XLFBaseModelInterface <NSObject>

@optional

+ (BOOL)instancesRespondToSelector:(SEL)aSelector;

+ (Class)superEndClass;

@property (nonatomic , copy , setter = setAttributes:) NSDictionary* dictionary;

+ (id)model;
+ (id)modelWithAttributes:(NSDictionary* )attributes;

- (id)initWithAttributes:(NSDictionary* )attributes;


//if this model has contained model array , this method must be overrided.
- (Class)arrayModelClassWithPropertyName:(NSString*)propertyName;

@end

@interface NSObject (XLFBaseModel)

//- (id)modelWithClass:(Class)_class;
//- (id)modelWithClass:(Class)_class attribute:(NSDictionary*)attribute;
//
//- (NSArray*)modelsWithClass:(Class)_class;
//- (NSArray*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;

@end

@interface NSObject (RunTime)<XLFBaseModelInterface>

@property (nonatomic , copy , setter = setAttributes:) NSDictionary* dictionary;

//+ (id)superEndClass;

+ (id)model;
+ (id)modelWithAttributes:(NSDictionary* )attributes;

- (id)initWithAttributes:(NSDictionary* )attributes;

@end

@interface NSDictionary (XLFBaseModel)

- (id)modelWithClass:(Class)_class;
+ (id)modelWithClass:(Class)_class attribute:(NSDictionary*)attribute;

@end

@interface NSDictionary (UnknownClass)

- (id)modelWithUnKnownClass:(Class)unknownClass;
+ (id)modelWithUnKnownClass:(Class)unknownClass attribute:(NSDictionary*)attribute;

@end

@interface NSArray (XLFBaseModel)

- (NSArray*)modelsWithClass:(Class)_class;
+ (NSArray*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;

@end

@interface NSMutableArray (XLFBaseModel)

+ (NSMutableArray*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;

@end

@interface NSSet (XLFBaseModel)

+ (NSSet*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;

@end

@interface NSMutableSet (XLFBaseModel)

+ (NSMutableSet*)modelsWithClass:(Class)_class attributes:(NSArray*)attributes;

@end

@interface XLFBaseModel : NSObject<XLFBaseModelInterface>

@property (nonatomic , copy , setter = setAttributes:) NSDictionary* dictionary;

+ (id)superEndClass;

+ (id)model;
+ (id)modelWithAttributes:(NSDictionary* )attributes;

- (id)init;
- (id)initWithAttributes:(NSDictionary* )attributes;

//if this model has contained model array , this method must be overrided.
- (Class)arrayModelClassWithPropertyName:(NSString*)propertyName;

- (void)clear;

@end

@interface XLFBaseModel (Coding)<NSCoding>

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

@interface XLFBaseModel (Copying)<NSCopying>

- (id)copyWithZone:(NSZone*)zone;

- (void)copyModel:(XLFBaseModel *)model;

@end

@interface XLFBaseModel (MutableCopying)<NSMutableCopying>

- (id)mutableCopyWithZone:(NSZone*)zone;

@end

@interface XLFBaseModel (KVO)

- (void)addObserverForNewValue:(NSObject *)observer;
- (void)addObserverForOldValueChanged:(NSObject *)observer;

- (void)addObserverForNewValue:(NSObject *)observer keyPaths:(NSArray *)keyPaths;
- (void)addObserverForOldValueChanged:(NSObject *)observer keyPaths:(NSArray *)keyPaths;

- (void)removeAllObserver;
- (void)removeObserver:(NSObject *)observer;
- (void)removeObserver:(NSObject *)observer keyPaths:(NSArray *)keyPaths;

- (NSArray *)observableKeypaths;

@end

@interface XLFBaseModel (KV)

- (void)removeObjectForKey:(NSString*)aKey;
- (void)setObject:(id)anObject forKey:(NSString*)aKey;
- (id)objectForKey:(NSString*)aKey;

@end


