//
//  NSFileManager+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-11-22.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager(Categories)

+ (BOOL)fileExistsAtPath:(NSString *)path;
+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory;
+ (BOOL)isReadableFileAtPath:(NSString *)path;
+ (BOOL)isWritableFileAtPath:(NSString *)path;
+ (BOOL)isExecutableFileAtPath:(NSString *)path;
+ (BOOL)isDeletableFileAtPath:(NSString *)path;

+ (BOOL)isFileAtPath:(NSString *)path error:(NSError **)error;
+ (BOOL)isFolderAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)error NS_AVAILABLE(10_5, 2_0);
+ (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary *)attr;

+ (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error NS_AVAILABLE(10_5, 2_0);
+ (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error NS_AVAILABLE(10_5, 2_0);
+ (BOOL)linkItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error NS_AVAILABLE(10_5, 2_0);
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);

+ (BOOL)copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error NS_AVAILABLE(10_6, 4_0);
+ (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error NS_AVAILABLE(10_6, 4_0);
+ (BOOL)linkItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error NS_AVAILABLE(10_6, 4_0);
+ (BOOL)removeItemAtURL:(NSURL *)URL error:(NSError **)error NS_AVAILABLE(10_6, 4_0);

+ (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);
+ (NSArray *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);
+ (NSDictionary *)attributesOfFileSystemForPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);

+ (NSArray *)foldersOfDirectoryAtPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);
+ (NSArray *)filesOfDirectoryAtPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);

+ (NSArray *)foldersOfDirectoryAtPath:(NSString *)path notIncludeFolderName:(NSString*)notIncludeFolderName error:(NSError **)error NS_AVAILABLE(10_5, 2_0);
+ (NSArray *)filesOfDirectoryAtPath:(NSString *)path notIncludeFileName:(NSString*)notIncludeFileName error:(NSError **)error NS_AVAILABLE(10_5, 2_0);;

@end
