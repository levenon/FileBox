//
//  FBFileManager.h
//  FileBox
//
//  Created by Marike Jave on 15/2/7.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLFCommonKit/XLFCommonKit.h>

@interface FBFileManager : NSObject

@property (nonatomic, copy) NSString *evFileDirectory;
@property (nonatomic, strong) NSURL *evCurrentFileURL;

+ (id)sharedInstance;

- (BOOL)efHandleOpenURL:(NSURL *)url;

- (BOOL)efOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

+ (BOOL)efMoveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error NS_AVAILABLE(10_5, 2_0);

+ (BOOL)efRemoveItemAtPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);

+ (BOOL)efMoveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error NS_AVAILABLE(10_6, 4_0);

+ (BOOL)efRemoveItemAtURL:(NSURL *)URL error:(NSError **)error NS_AVAILABLE(10_6, 4_0);

+ (UIImage*)efIconByFilePath:(NSString*)filePath;

@end
