//
//  FBFolderSelectorVC.h
//  FileBox
//
//  Created by Marike Jave on 15/2/9.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <XLFBaseViewControllerKit/XLFBaseViewControllerKit.h>
#import <XLFCommonKit/XLFCommonKit.h>

@class FBFolderSelectorVC;

@protocol FBFolderSelectorVCDelegate <NSObject>

- (void)epFolderSelectorVC:(FBFolderSelectorVC*)vc didSelectedFolderPath:(NSString*)folderPath;

@end

@interface FBFolderSelectorVC : XLFBaseTableViewController

@property(nonatomic, assign) id<FBFolderSelectorVCDelegate> evDelegate;

@property(nonatomic, copy) NSString *evCurrentPath;
@property(nonatomic, copy) NSString *evWillMoveFilePath;

@end

