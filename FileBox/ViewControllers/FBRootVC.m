//
//  FBRootVC
//  FileBox
//
//  Created by Marike Jave on 15/2/4.
//  Copyright (c)2015年 Marike Jave. All rights reserved.
//
#import <QuickLook/QuickLook.h>
#import <LocalAuthentication/LocalAuthentication.h>

#import "FBRootVC.h"
#import "FBFolderPreviewVC.h"
#import "FBFolderSelectorVC.h"
#import "FBSystemSettingsVC.h"
#import "FBMovieViewController.h"

#import "FBFileManager.h"
#import "FBLockManager.h"

#import "FBFileSummaryCell.h"

#import "FBVideoPlayer.h"

static NSString* const kDidShowWarnningAlertForVerifyFailed = @"kDidShowWarnningAlertForVerifyFailed";

@interface FBRootVC ()<UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIAlertViewDelegate, FBFolderSelectorVCDelegate>

@property (nonatomic, strong) NSMutableArray *evFiles;

@property (nonatomic, strong) UITableView *evtbvContainer;
@property (nonatomic, strong) UILabel *evlbPrompt;
@property (nonatomic, strong) UIAlertView *evaltvPasswordInput;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *evbbiVerify;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *evbbiAdd;
@property (nonatomic, strong) UIBarButtonItem *evbbiSetting;
@property (nonatomic, strong) UIAlertView *evatAlert;

@end

@implementation FBRootVC

- (void)dealloc{
    
    [self efDeregisterNotification];
}

- (void)loadView{
    [super loadView];
    
    [self efSetBarButtonItem:[self evbbiAdd] type:XLFNavButtonTypeRight];
    
    [[self view] addSubview:[self evtbvContainer]];
    [[self view] addSubview:[self evlbPrompt]];
    
    [self _efInstallConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self efRegisterNotification];
    
#if !DEBUG
    [self performSelector:@selector(_efVerifyPassword)withObject:nil afterDelay:0.5f];
#endif
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
#if !DEBUG
    if ([[FBLockManager sharedInstance] evIsVerifySuccess]) {
        [self _efLoadFiles];
    }
#else
    [self _efLoadFiles];
#endif
    [self _efReloadData];
}

#pragma mark - accessory

- (UIBarButtonItem *)evbbiDefaultBack{
    return nil;
}

- (NSMutableArray*)evFiles{
    if (!_evFiles) {
        
        _evFiles = [NSMutableArray array];
    }
    return _evFiles;
}

- (UITableView *)evtbvContainer{
    
    if (!_evtbvContainer) {
        
        _evtbvContainer = [UITableView emptyFrameView];
        [_evtbvContainer setRowHeight:60];
        [_evtbvContainer setDelegate:self];
        [_evtbvContainer setDataSource:self];
        [_evtbvContainer setTableFooterView:[UIView emptyFrameView]];
    }
    return _evtbvContainer;
}

- (UILabel*)evlbPrompt{
    if (!_evlbPrompt) {
        
        _evlbPrompt = [UILabel emptyFrameView];
        [_evlbPrompt setText:NSLocalizedString(@"10", @"No any file")];
        [_evlbPrompt setTextAlignment:NSTextAlignmentCenter];
        [_evlbPrompt setTextColor:[UIColor lightGrayColor]];
    }
    return _evlbPrompt;
}

- (UIBarButtonItem *)evbbiSetting{
    
    if (!_evbbiSetting) {
        
        _evbbiSetting = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cog"] style:UIBarButtonItemStylePlain target:self action:@selector(didClickSetting:)];
    }
    return _evbbiSetting;
}

- (UIBarButtonItem *)evbbiVerify{
    
    if (!_evbbiVerify) {
        _evbbiVerify = [[UIBarButtonItem alloc] initWithTitle:@"Unlock" style:UIBarButtonItemStyleDone target:self action:@selector(didClickVerify:)];
        
        [_evbbiVerify setPossibleTitles:[NSSet setWithObjects:NSLocalizedString(@"32", @"Unlock"), NSLocalizedString(@"17", @"Set Password"), nil]];
    }
    return _evbbiVerify;
}

- (UIBarButtonItem *)evbbiAdd{
    if (!_evbbiAdd) {
        _evbbiAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didClickAdd:)];
    }
    return _evbbiAdd;
}

- (void)setEvaltvPasswordInput:(UIAlertView *)evaltvPasswordInput{
    
    if (_evaltvPasswordInput != evaltvPasswordInput) {
        
        if (_evaltvPasswordInput) {
            
            [_evaltvPasswordInput dismissWithClickedButtonIndex:0 animated:NO];
        }
        
        _evaltvPasswordInput = evaltvPasswordInput;
    }
}

- (void)setEvatAlert:(UIAlertView *)evatAlert{
    
    if (_evatAlert != evatAlert) {
        
        [_evatAlert dismissWithClickedButtonIndex:[_evatAlert cancelButtonIndex] animated:NO];
        
        _evatAlert = evatAlert;
    }
}

#pragma mark - register notification

- (void)efRegisterNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotificationVerifyHasChanged:)name:kNotificationVerifyHasChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotificationDidEnterBackground:)name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)efDeregisterNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private

- (void)_efInstallConstraints{
    
    @weakify(self);
    
    [[self evtbvContainer] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
    
    [[self evlbPrompt] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.view).insets(UIEdgeInsetsZero);
    }];
}

- (void)_efLoadFiles;{
    
    NSError *etError = nil;
    
    if (![NSFileManager fileExistsAtPath:SDDocumentDirectory]) {
        [NSFileManager createDirectoryAtPath:SDDocumentDirectory withIntermediateDirectories:YES attributes:nil error:&etError];
        
        NSAssert(!etError, [etError description]);
    }
    
    NSArray* etFiles = [NSFileManager contentsOfDirectoryAtPath:SDDocumentDirectory error:&etError];
    
    NSAssert(!etError, [etError description]);
    
    [[self evFiles] removeAllObjects];
    [[self evFiles] addObjectsFromArray:etFiles];
    [[self evFiles] removeObject:@"Inbox"];
}

- (void)_efVerifyPassword;{
    
    [FBLockManager efVerifyWithResultBlock:^(BOOL success) {
        
        [self _efUpdateVerify:success];
    }];
}

- (void)_efShowCancelWarnningAlert{
    
    UIAlertView* etAlert = [UIAlertView alertWithMessage:NSLocalizedString(@"21", @"Not through the verification, you will not be able to see any information")];
    
    [self setEvatAlert:etAlert];
    
    [NSUserDefaults setBool:YES forKey:kDidShowWarnningAlertForVerifyFailed];
}

- (void)_efShowEidtFolderAlert:(NSString*)title message:(NSString*)message placeholder:(NSString*)placeholder userInfo:(id)userInfo{
    
    UIAlertView *etAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"1", @"Cancel")otherButtonTitles:NSLocalizedString(@"2", @"Sure"), nil];
    [etAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [etAlert setEvUserInfo:userInfo];
    [[etAlert textFieldAtIndex:0] setText:placeholder];
    
    [etAlert show];
    
    [self setEvatAlert:etAlert];
}

- (void)_efReloadData{
    
    [[self evtbvContainer] reloadData];
    [self _efUpdatePrompInfo];
    
    if (![[FBLockManager sharedInstance] evCanEvaluatePolicy]) {
        
        if ([[FBLockManager sharedInstance] evNeedSetPassword]) {
            
            [[self evbbiVerify] setTitle:NSLocalizedString(@"17", @"Set Password")];
        }
        else if([[FBLockManager sharedInstance] evIsPasswordEnable]) {
            
            [[self evbbiVerify] setTitle:NSLocalizedString(@"32", @"Unlock")];
        }
    }
    
    if ([[FBLockManager sharedInstance] evIsVerifySuccess] || (![[FBLockManager sharedInstance] evCanEvaluatePolicy] && ![[FBLockManager sharedInstance] evIsPasswordEnable])) {
        
        [self efSetBarButtonItem:[self evbbiSetting] type:XLFNavButtonTypeLeft];
    }
    else{
        
        [self efSetBarButtonItem:[self evbbiVerify] type:XLFNavButtonTypeLeft];
    }
}

- (void)_efUpdatePrompInfo;{
    
    [[self evlbPrompt] setHidden:[[self evFiles] count]];
}

- (void)_efUpdateVerify:(BOOL)success;{
    
    if (!success && ![NSUserDefaults boolForKey:kDidShowWarnningAlertForVerifyFailed]) {
        
        [self _efShowCancelWarnningAlert];
    }
}

- (void)_efCreateFolder:(NSString*)folderName;{
    
    BOOL etIsDirectory = NO;
    
    if (![NSFileManager fileExistsAtPath:SDDocumentFile(folderName) isDirectory:&etIsDirectory] || !etIsDirectory) {
        if ([NSFileManager createDirectoryAtPath:SDDocumentFile(folderName) withIntermediateDirectories:YES attributes:nil error:nil]) {
            [[self evFiles] insertObject:folderName atIndex:0];
            [[self evtbvContainer] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self _efUpdatePrompInfo];
        }
        else{
            [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:NO];
            [self _efShowEidtFolderAlert:NSLocalizedString(@"3", @"New Folder") message:NSLocalizedString(@"4", @"Please input the correct folder name") placeholder:folderName userInfo:nil];
        }
    }
    else{
        
        [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:NO];
        
        [self _efShowEidtFolderAlert:NSLocalizedString(@"3", @"New Folder") message:NSLocalizedString(@"7", @"folder already exists")placeholder:folderName userInfo:nil];
    }
}

- (void)_efRenameFileName:(NSString*)fileName indexPath:(NSIndexPath*)indexPath;{
    
    BOOL etIsDirectory = NO;
    NSString *etSourceFileName = [[self evFiles] objectAtIndex:[indexPath row]];
    NSString *etResultFileName = [fileName mutableCopy];
    
    if (![NSFileManager fileExistsAtPath:SDDocumentFile(etResultFileName) isDirectory:&etIsDirectory] || etIsDirectory) {
        if ([NSFileManager moveItemAtPath:SDDocumentFile(etSourceFileName) toPath:SDDocumentFile(etResultFileName)error:nil]) {
            
            [NSFileManager removeItemAtPath:SDDocumentFile(etSourceFileName) error:nil];
            [[self evFiles] replaceObjectAtIndex:[[self evFiles] indexOfObject:etSourceFileName] withObject:etResultFileName];
            [[self evtbvContainer] reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else{
        
        [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:NO];
        
        [self _efShowEidtFolderAlert:NSLocalizedString(@"9", @"Rename")message:NSLocalizedString(@"6", @"file or folder already exists")placeholder:fileName userInfo:indexPath];
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
    
    [etFileSummaryCell setEvFilePath:SDDocumentFile(etFileName)];
    
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
    //        [evtbvContainer reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //    }];
    
    UITableViewRowAction *etRenameRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"9", @"Rename")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [etWeakSelf _efShowEidtFolderAlert:NSLocalizedString(@"9", @"Rename")message:NSLocalizedString(@"30", @"Please input the folder name")placeholder:[[self evFiles] objectAtIndex:[indexPath row]] userInfo:indexPath];
        }];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    UITableViewRowAction *etMoveRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"11", @"Move")handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSString *etFilePath = SDDocumentFile([[etWeakSelf evFiles] objectAtIndex:[indexPath row]]);
        
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
        
        NSString *etFilePath = SDDocumentFile([[etWeakSelf evFiles] objectAtIndex:[indexPath row]]);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSError *etError = nil;
            BOOL state = [FBFileManager efRemoveItemAtPath:etFilePath error:&etError];
            NSAssert(!etError, [etError description]);
            
            if (state) {
                
                [[etWeakSelf evFiles] removeObjectAtIndex:[indexPath row]];
                [[etWeakSelf evtbvContainer] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
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
    
    NSString *filePath = SDDocumentFile([[self evFiles] objectAtIndex:[indexPath row]]);
    BOOL isDirectory = NO;
    BOOL isExist = [NSFileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    if (isExist && isDirectory) {
        
        FBFolderPreviewVC *folderVC = [[FBFolderPreviewVC alloc] init];
        [folderVC setEvPath:filePath];
        
        [[self navigationController] pushViewController:folderVC animated:YES];
    }
    else if ([FBFileManager efFileTypeWithFilePath:filePath] == FBFileTypeVideo) {
        
        FBMovieParameter *parameter = [[FBMovieParameter alloc] init];
        
        // increase buffering for .wmv, it solves problem with delaying audio frames
        if ([[filePath pathExtension] isEqualToString:@"wmv"]) {
            [parameter setEvMinBufferedDuration:5.0];
        }
        
        // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
        if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
            [parameter setEvDeinterlacingEnable:NO];
        }
        
        FBMovieViewController *etMovieVC = [FBMovieViewController movieViewControllerWithContentPath:filePath parameter:parameter];
        
        [[self navigationController] pushViewController:etMovieVC animated:YES];
    }
    else {
        
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

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index;{
    
    return [NSURL fileURLWithPath:SDDocumentFile([[self evFiles] objectAtIndex:index])];
}

#pragma mark - FBFolderSelectorVCDelegate

- (void)epFolderSelectorVC:(FBFolderSelectorVC*)vc didSelectedFolderPath:(NSString*)folderPath;{
    
    NSString *etFileName = [[vc evWillMoveFilePath] lastPathComponent];
    NSInteger etIndex = [[self evFiles] indexOfObject:etFileName];
    
    NSError *etError = nil;
    if ([FBFileManager efMoveItemAtPath:[vc evWillMoveFilePath] toPath:[folderPath stringByAppendingPathComponent:etFileName] error:&etError]) {
        
        [[self evFiles] removeObjectAtIndex:etIndex];
        [[self evtbvContainer] deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:etIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - actions

- (IBAction)didNotificationDidEnterBackground:(id)sender{
    
    [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:YES];
    
    [[self navigationController] popToRootViewControllerAnimated:NO];
    
    [self setEvaltvPasswordInput:nil];
}

- (IBAction)didNotificationVerifyHasChanged:(id)sender{
    
    BOOL success = [[FBLockManager sharedInstance] evIsVerifySuccess];
    
    if (success) {
        
        [self _efLoadFiles];
    }
    else{
        
        [[self evFiles] removeAllObjects];
    }
    
    [self _efReloadData];
    [[self evbbiAdd] setEnabled:success];
}

- (IBAction)didClickVerify:(UIBarButtonItem*)sender {
    
    if ([[sender title] isEqualToString:NSLocalizedString(@"17", @"Set Password")]) {
        
        [FBLockManager efResetPasswordWithResultBlock:^(BOOL success) {
            
            [self _efUpdateVerify:success];
        }];
    }
    else {
        
        [self _efVerifyPassword];
    }
}

- (IBAction)didClickSetting:(id)sender{
    
    FBSystemSettingsVC *etSettingVC = [[FBSystemSettingsVC alloc] initWithStyle:UITableViewStyleGrouped];
    
    [[self navigationController] pushViewController:etSettingVC animated:YES];
}

- (IBAction)didClickAdd:(id)sender {
    
    [self _efShowEidtFolderAlert:NSLocalizedString(@"3", @"New Folder")message:NSLocalizedString(@"30", @"Please input the folder name")placeholder:nil userInfo:nil];
}

@end
