//
//  FBFolderPreviewVC.m
//  FileBox
//
//  Created by Marike Jave on 15/2/5.
//  Copyright (c)2015年 Marike Jave. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import "FBFolderPreviewVC.h"
#import "FBFolderSelectorVC.h"
#import "FBFileManager.h"

#import "FBFileSummaryCell.h"

@interface FBFolderPreviewVC ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate, FBFolderSelectorVCDelegate>

@property (nonatomic, strong)NSMutableArray *evFiles;

@property (nonatomic, strong)UILabel *evlbPrompt;

@property (nonatomic, strong)UIAlertView *evatAlert;

@end

@implementation FBFolderPreviewVC

- (void)dealloc{

    [self efDeregisterNotification];
}

- (void)loadView{
    [super loadView];

    [[self tableView] setTableFooterView:[UIView emptyFrameView]];
    [[self tableView] setRowHeight:60];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setTitle:[[self evPath] lastPathComponent]];
    [self efSetBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didClickAdd:)] type:XLFNavButtonTypeRight];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotificationDidEnterBackground:)name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self efLoadFiles];
    [self efReloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - normal

- (void)efLoadFiles;{

    NSError *etError = nil;

    if (![NSFileManager fileExistsAtPath:[self evPath]]) {
        [NSFileManager createDirectoryAtPath:[self evPath] withIntermediateDirectories:YES attributes:nil error:&etError];

        NSAssert(!etError, [etError description]);
    }

    NSArray* etFiles = [NSFileManager contentsOfDirectoryAtPath:[self evPath] error:&etError];

    NSAssert(!etError, [etError description]);

    [[self evFiles] removeAllObjects];
    [[self evFiles] addObjectsFromArray:etFiles];
}

- (void)efReloadData{

    [[self tableView] reloadData];

    [self _efUpdatePrompInfo];
}

- (void)_efShowEidtFolderAlert:(NSString*)title message:(NSString*)message placeholder:(NSString*)placeholder userInfo:(id)userInfo{

    UIAlertView *etAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"1", @"Cancel")otherButtonTitles:NSLocalizedString(@"2", @"Sure"), nil];
    [etAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [etAlert setEvUserInfo:userInfo];
    [[etAlert textFieldAtIndex:0] setText:placeholder];

    [etAlert show];

    [self setEvatAlert:etAlert];
}

- (void)_efCreateFolder:(NSString*)folderName;{

    BOOL etIsDirectory = NO;
    NSString *etFolderPath = [[self evPath] stringByAppendingPathComponent:folderName];

    if (![NSFileManager fileExistsAtPath:etFolderPath isDirectory:&etIsDirectory] || !etIsDirectory) {

        if ([NSFileManager createDirectoryAtPath:etFolderPath withIntermediateDirectories:YES attributes:nil error:nil]) {

            [[self evFiles] insertObject:folderName atIndex:0];
            [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self _efUpdatePrompInfo];
        }
        else{

            [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:NO];

            [self _efShowEidtFolderAlert:NSLocalizedString(@"3", @"New Folder")message:NSLocalizedString(@"4",@"Please input the correct folder name")placeholder:folderName userInfo:nil];
        }
    }
    else{

        [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:NO];

        [self _efShowEidtFolderAlert:NSLocalizedString(@"3", @"New Folder")message:NSLocalizedString(@"6", @"file or folder already exists")placeholder:folderName userInfo:nil];
    }
}

- (void)_efRenameFileName:(NSString*)fileName indexPath:(NSIndexPath*)indexPath;{

    BOOL etIsDirectory = NO;
    NSString *etSourceFileName = [[self evFiles] objectAtIndex:[indexPath row]];
    NSString *etResultFileName = [fileName mutableCopy];
    NSString *etSouceFilePath = [[self evPath] stringByAppendingPathComponent:etSourceFileName];
    NSString *etResultFilePath = [[self evPath] stringByAppendingPathComponent:etSourceFileName];

    if (![NSFileManager fileExistsAtPath:etResultFilePath isDirectory:&etIsDirectory] || etIsDirectory) {

        if ([NSFileManager moveItemAtPath:etSouceFilePath toPath:etResultFilePath error:nil]) {

            [NSFileManager removeItemAtPath:etSouceFilePath error:nil];
            [[self evFiles] replaceObjectAtIndex:[indexPath row] withObject:etResultFileName];
            [[self tableView] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else{

        [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:NO];

        [self _efShowEidtFolderAlert:NSLocalizedString(@"9",@"Rename")message:NSLocalizedString(@"6", @"file or folder already exists")placeholder:fileName userInfo:indexPath];
    }
}

- (void)_efUpdatePrompInfo;{

    [[self evlbPrompt] removeFromSuperview];

    if (![[self evFiles] count]) {

        [[self tableView] addSubview:[self evlbPrompt]];
    }
}

#pragma mark - accessory

- (NSMutableArray*)evFiles{
    if (!_evFiles) {

        _evFiles = [NSMutableArray array];
    }
    return _evFiles;
}

- (UILabel*)evlbPrompt{
    if (!_evlbPrompt) {

        _evlbPrompt = [[UILabel alloc] initWithFrame:[[self tableView] bounds]];
        [_evlbPrompt setText:NSLocalizedString(@"10", @"No any file")];
        [_evlbPrompt setTextAlignment:NSTextAlignmentCenter];
        [_evlbPrompt setTextColor:[UIColor lightGrayColor]];
    }
    return _evlbPrompt;
}

- (void)setEvatAlert:(UIAlertView *)evatAlert{

    if (_evatAlert != evatAlert) {

        [_evatAlert dismissWithClickedButtonIndex:[_evatAlert cancelButtonIndex] animated:NO];

        _evatAlert = evatAlert;
    }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [[self evFiles] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FBFileSummaryCell *etFileSummaryCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBFileSummaryCell class])];
    
    if (!etFileSummaryCell) {
        
        etFileSummaryCell = [[FBFileSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([FBFileSummaryCell class])];
    }
    
    NSString *etFileName  = [[self evFiles] objectAtIndex:indexPath.row];
    
    [etFileSummaryCell setEvFilePath:[[self evPath] stringByAppendingPathComponent:etFileName]];
    
    return etFileSummaryCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;{

}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{

    __weak typeof(self)etWeakSelf = self;

    //    BOOL needLock = [FBLockManager efNeedLockForFilePath:etFilePath];
    //
    //    UITableViewRowAction *etLockRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:select(needLock, @"解锁", @"加锁")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
    //
    //        if (needLock) {
    //            [FBLockManager efRemoveLockForFilePath:etFilePath];
    //        }
    //        else{
    //            [FBLockManager efSetNeedLock:!needLock forFilePath:etFilePath];
    //        }
    //        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //    }];

    UITableViewRowAction *etRenameRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"9", @"Rename")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            [etWeakSelf _efShowEidtFolderAlert:NSLocalizedString(@"9", @"Rename")message:NSLocalizedString(@"30",@"Please input the folder name")placeholder:[[self evFiles] objectAtIndex:[indexPath row]] userInfo:indexPath];
        }];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];

    UITableViewRowAction *etMoveRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"11", @"Move")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        NSString *etFilePath = [[self evPath] stringByAppendingPathComponent:[[etWeakSelf evFiles] objectAtIndex:[indexPath row]]];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            FBFolderSelectorVC *etFolderSelector = [[FBFolderSelectorVC alloc] init];
            [etFolderSelector setEvCurrentPath:SDDocumentDirectory];
            [etFolderSelector setEvWillMoveFilePath:etFilePath];
            [etFolderSelector setEvDelegate:self];

            [[self evVisibleViewController] presentViewController:[[XLFBaseNavigationController alloc] initWithRootViewController:etFolderSelector]
                                                         animated:YES
                                                       completion:nil];
        }];
    }];

    UITableViewRowAction *etDeleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"12", @"Delete")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        NSString *etFilePath = [[self evPath] stringByAppendingPathComponent:[[etWeakSelf evFiles] objectAtIndex:[indexPath row]]];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            NSError *etError = nil;
            BOOL state = [FBFileManager efRemoveItemAtPath:etFilePath error:&etError];
            NSAssert(!etError, [etError description]);

            if (state) {

                [[etWeakSelf evFiles] removeObjectAtIndex:[indexPath row]];
                [[etWeakSelf tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

                [self _efUpdatePrompInfo];
            }
        }];
    }];

    //    [etLockRowAction setBackgroundColor:[UIColor lightGrayColor]];
    [etRenameRowAction setBackgroundColor:[UIColor brownColor]];
    [etMoveRowAction setBackgroundColor:[UIColor grayColor]];
    [etDeleteRowAction setBackgroundColor:[UIColor redColor]];
    
    return @[etDeleteRowAction, etMoveRowAction, etRenameRowAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *filePath = [[self evPath] stringByAppendingPathComponent:[[self evFiles] objectAtIndex:[indexPath row]]];
    BOOL isDirectory = NO;
    BOOL isExist = [NSFileManager fileExistsAtPath:filePath isDirectory:&isDirectory];

    if (isExist && isDirectory) {

        FBFolderPreviewVC *folderVC = [[FBFolderPreviewVC alloc] init];
        [folderVC setEvPath:filePath];

        [[self navigationController] pushViewController:folderVC animated:YES];
    }
    else{

        QLPreviewController *previewController = [[QLPreviewController alloc] init];
        previewController.dataSource = self;
        previewController.delegate = self;

        // start previewing the document at the current section index
        previewController.currentPreviewItemIndex = [indexPath row];
        [[self navigationController] pushViewController:previewController animated:YES];
    }
}

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController{

    return [[self evFiles] count];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index;{
    NSString *path = [[self evPath] stringByAppendingPathComponent:[[self evFiles] objectAtIndex:index]];
    return [NSURL fileURLWithPath:path];
}

#pragma mark - FBFolderSelectorVCDelegate

- (void)epFolderSelectorVC:(FBFolderSelectorVC*)vc didSelectedFolderPath:(NSString*)folderPath;{

    NSString *etFileName = [[vc evWillMoveFilePath] lastPathComponent];
    NSInteger etIndex = [[self evFiles] indexOfObject:etFileName];

    NSError *etError = nil;
    if ([FBFileManager efMoveItemAtPath:[vc evWillMoveFilePath] toPath:[folderPath stringByAppendingPathComponent:etFileName] error:&etError]) {

        [[self evFiles] removeObjectAtIndex:etIndex];
        [[self tableView] deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:etIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self _efUpdatePrompInfo];

        [[vc navigationController] dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        NIF_ERROR(@"%@",etError);
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex != [alertView cancelButtonIndex]) {

        NSString *etFileName = [[alertView textFieldAtIndex:0] text];
        if ([etFileName length]) {

            if ([alertView evUserInfo]) {

                [self _efRenameFileName:etFileName indexPath:[alertView evUserInfo]];
            }
            else{

                [self _efCreateFolder:etFileName];
            }
        }
        else{

            [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:NO];

            [self _efShowEidtFolderAlert:select([alertView evUserInfo], NSLocalizedString(@"9", @"Rename"), NSLocalizedString(@"3", @"New Folder"))message:NSLocalizedString(@"8", @"file or folder's name can not be empty")placeholder:etFileName userInfo:[alertView evUserInfo]];
        }
    }
}

- (IBAction)didClickAdd:(id)sender {

    [self _efShowEidtFolderAlert:NSLocalizedString(@"3", @"New Folder")message:NSLocalizedString(@"4", @"Please input the correct folder name")placeholder:nil userInfo:nil];
}

- (IBAction)didNotificationDidEnterBackground:(id)sender{

    [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:YES];
}

@end
