//
//  FBFileManager.m
//  FileBox
//
//  Created by Marike Jave on 15/2/7.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import "FBFileManager.h"
#import "FBLockManager.h"
#import "FBFolderSelectorVC.h"

@interface FBFileManager ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate, FBFolderSelectorVCDelegate>

@end

@implementation FBFileManager

+ (id)sharedInstance;{

    static FBFileManager *manager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FBFileManager alloc] init];
    });
    return manager;
}

+ (void)load;{
    [super load];

    [[self sharedInstance] efConfig];
}

- (void)dealloc{

    [self efDeregisterNotification];
}

- (void)efConfig;{

    [self setEvFileDirectory:SDDocumentDirectory];
    [self efRegisterNotification];
}

#pragma mark - register notification

- (void)efRegisterNotification{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotificationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)efDeregisterNotification{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)efHandleOpenURL:(NSURL *)url;{

    if ([url isFileURL]) {

        return [self efOpenFileAtURL:url];
    }
    return YES;
}

- (BOOL)efOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;{

    if ([url isFileURL]) {

        return [self efOpenFileAtURL:url];
    }
    return YES;
}


- (BOOL)efOpenFileAtURL:(NSURL*)url;{

    void (^blcShowPreview)() = ^(){

        FBFolderSelectorVC *etFolderSelector = [[FBFolderSelectorVC alloc] init];
        [etFolderSelector setEvCurrentPath:SDDocumentDirectory];
        [etFolderSelector setEvWillMoveFilePath:[url path]];
        [etFolderSelector setEvDelegate:self];

        [[self evVisibleViewController] presentViewController:[[XLFBaseNavigationController alloc] initWithRootViewController:etFolderSelector] animated:YES completion:nil];
    };

    if ([[FBLockManager sharedInstance] evIsVerifySuccess]) {
        blcShowPreview();
    }
    else{

        [FBLockManager efVerifyWithResultBlock:^(BOOL success) {

            if (success) {

                blcShowPreview();
            }
        }];
    }

    return YES;
}

#pragma mark - actions

- (IBAction)didNotificationDidEnterBackground:(id)sender{

    [NSFileManager removeItemAtPath:SDDocumentFile(@"Inbox") error:nil];
}

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController{

    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index;{

    return [self evCurrentFileURL];
}

+ (BOOL)efMoveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error NS_AVAILABLE(10_5, 2_0);{
    BOOL result = [NSFileManager moveItemAtPath:srcPath toPath:dstPath error:error];

    if (result) {
        BOOL needLock = [FBLockManager efNeedLockForFilePath:srcPath];
        if (needLock) {
            [FBLockManager efRemoveLockForFilePath:srcPath];
            [FBLockManager efSetNeedLock:needLock forFilePath:dstPath];
        }
    }
    return result;
}

+ (BOOL)efRemoveItemAtPath:(NSString *)path error:(NSError **)error NS_AVAILABLE(10_5, 2_0);{
    BOOL result = [NSFileManager removeItemAtPath:path error:error];

    if (result) {

        [FBLockManager efRemoveLockForFilePath:path];
    }
    return result;
}

+ (BOOL)efMoveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError **)error NS_AVAILABLE(10_6, 4_0);{

    NSAssert([srcURL isFileURL], @"srcURL is not file url.");
    NSAssert([dstURL isFileURL], @"dstURL is not file url.");

    BOOL result = [NSFileManager moveItemAtURL:srcURL toURL:dstURL error:error];

    if (result) {
        BOOL needLock = [FBLockManager efNeedLockForFilePath:[srcURL path]];
        if (needLock) {
            [FBLockManager efRemoveLockForFilePath:[srcURL path]];
            [FBLockManager efSetNeedLock:needLock forFilePath:[dstURL path]];
        }
    }
    return result;
}

+ (BOOL)efRemoveItemAtURL:(NSURL *)URL error:(NSError **)error NS_AVAILABLE(10_6, 4_0);{

    NSAssert([URL isFileURL], @"URL is not file url.");

    BOOL result = [NSFileManager removeItemAtURL:URL error:error];

    if (result) {

        [FBLockManager efRemoveLockForFilePath:[URL path]];
    }
    return result;
}

#pragma mark - FBFolderSelectorVCDelegate

- (void)epFolderSelectorVC:(FBFolderSelectorVC*)vc didSelectedFolderPath:(NSString*)folderPath;{

    NSString *etFileName = [[vc evWillMoveFilePath] lastPathComponent];
    NSString *etFilePath = [folderPath stringByAppendingPathComponent:etFileName];

    NSError *etError = nil;

    if ([NSFileManager copyItemAtPath:[vc evWillMoveFilePath] toPath:etFilePath error:&etError]) {

        [self setEvCurrentFileURL:[NSURL fileURLWithPath:etFilePath]];

        QLPreviewController *previewController = [[QLPreviewController alloc] init];
        previewController.dataSource = self;
        previewController.delegate = self;

        // start previewing the document at the current section index
        previewController.currentPreviewItemIndex = 0;

        [[vc navigationController] dismissViewControllerAnimated:YES completion:^{

            [[[self evVisibleViewController] navigationController] popToRootViewControllerAnimated:YES];
            [[[self evVisibleViewController] navigationController] pushViewController:previewController animated:YES];
        }];
    }
    else{

        NIF_ERROR(@"%@",etError);
    }
}

+ (UIImage*)efIconByFilePath:(NSString*)filePath;{

    NSString *etExtension = [filePath pathExtension];

    if ([etExtension isEqualToString:@"doc"]||[etExtension isEqualToString:@"docx"]) {
        return [UIImage imageNamed:@"word"];
    }

    if ([etExtension isEqualToString:@"xls"]||[etExtension isEqualToString:@"xlsx"]) {
        return [UIImage imageNamed:@"excel"];
    }

    if ([etExtension isEqualToString:@"ppt"]||[etExtension isEqualToString:@"pptx"]) {
        return [UIImage imageNamed:@"powerpoint"];
    }

    if ([etExtension isEqualToString:@"mp3"]||[etExtension isEqualToString:@"wma"]||
        [etExtension isEqualToString:@"aac"]||[etExtension isEqualToString:@"midi"]||
        [etExtension isEqualToString:@"mid"]||[etExtension isEqualToString:@"mmf"]||
        [etExtension isEqualToString:@"amr"]) {

        UIImage *etImage= [UIImage audioThumbImage:filePath];

        if (etImage) {
            return [etImage scaleToSize:CGSizeMake(44, 44) stretch:NO];
        }
        return [UIImage imageNamed:@"windows_media_player"];
    }

    if ([etExtension isEqualToString:@"wmv"]||[etExtension isEqualToString:@"wm"]||
        [etExtension isEqualToString:@"asf"]||[etExtension isEqualToString:@"asx"]||
        [etExtension isEqualToString:@"rm"]||[etExtension isEqualToString:@"ra"]||
        [etExtension isEqualToString:@"rmvb"]||[etExtension isEqualToString:@"rma"]||
        [etExtension isEqualToString:@"mpg"]||[etExtension isEqualToString:@"mpeg"]||
        [etExtension isEqualToString:@"mpe"]||[etExtension isEqualToString:@"vob"]||
        [etExtension isEqualToString:@"mov"]||[etExtension isEqualToString:@"3gp"]||
        [etExtension isEqualToString:@"mp4"]||[etExtension isEqualToString:@"m4v"]||
        [etExtension isEqualToString:@"avi"]||[etExtension isEqualToString:@"flv"]||
        [etExtension isEqualToString:@"dat"]||[etExtension isEqualToString:@"f4v"]) {

        UIImage *etImage= [UIImage videoThumbImage:filePath];

        if (etImage) {
            return [etImage scaleToSize:CGSizeMake(44, 44)];
        }
        return [UIImage imageNamed:@"windows_media_player"];
    }

    if ([etExtension isEqualToString:@"bmp"]||[etExtension isEqualToString:@"pcx"]||
        [etExtension isEqualToString:@"tiff"]||[etExtension isEqualToString:@"gif"]||
        [etExtension isEqualToString:@"jpeg"]||[etExtension isEqualToString:@"jpg"]||
        [etExtension isEqualToString:@"tga"]||[etExtension isEqualToString:@"exif"]||
        [etExtension isEqualToString:@"fpx"]||[etExtension isEqualToString:@"svg"]||
        [etExtension isEqualToString:@"psd"]||[etExtension isEqualToString:@"cdr"]||
        [etExtension isEqualToString:@"pcd"]||[etExtension isEqualToString:@"dxf"]||
        [etExtension isEqualToString:@"ufo"]||[etExtension isEqualToString:@"eps"]||
        [etExtension isEqualToString:@"png"]||[etExtension isEqualToString:@"ai"]) {

        UIImage *etImage= [UIImage imageWithContentsOfFile:filePath];

        if (etImage) {
            return [etImage scaleToSize:CGSizeMake(44, 44) stretch:NO];
        }
        return [UIImage imageNamed:@"pictures"];
    }

    if (![etExtension length]) {

        BOOL isDirectory = NO;
        if (![NSFileManager fileExistsAtPath:filePath isDirectory:&isDirectory] || isDirectory) {

            return [UIImage imageNamed:@"folder"];
        }
        else{

            UIImage *etImage= [UIImage imageWithContentsOfFile:filePath];

            if (etImage) {
                return [etImage scaleToSize:CGSizeMake(44, 44) stretch:NO];
            }
        }
    }

    return [UIImage imageNamed:@"documents"];
}

@end
