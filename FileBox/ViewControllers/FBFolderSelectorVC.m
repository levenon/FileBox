//
//  FBFolderSelectorVC.m
//  FileBox
//
//  Created by Marike Jave on 15/2/9.
//  Copyright (c)2015年 Marike Jave. All rights reserved.
//

#import "FBFolderSelectorVC.h"
#import "FBLockManager.h"
#import "FBFileManager.h"

@interface FBFolderSelectorVC ()<FBFolderSelectorVCDelegate>

@property (nonatomic, strong)NSMutableArray *evFolders;

@property (nonatomic, strong)UILabel *evlbPrompt;

@property (nonatomic, strong)UIBarButtonItem *evbbiSelectCurrentFolder;

@property (nonatomic, strong)UIBarButtonItem *evbbiAddFolder;

@property (nonatomic, strong)UIAlertView *evatAlert;

@end

@implementation FBFolderSelectorVC

- (void)loadView{
    [super loadView];
    
    [[self tableView] setRowHeight:60];
    [[self tableView] setTableFooterView:[UIView emptyFrameView]];
    
    [self setTitle:select([[self evCurrentPath] isEqualToString:SDDocumentDirectory], NSLocalizedString(@"13", @"Select Folder"), [[self evCurrentPath] lastPathComponent])];
    
    [[self evbbiSelectCurrentFolder] setEnabled:![[[self evWillMoveFilePath] stringByDeletingLastPathComponent] isEqualToString:[self evCurrentPath]]];
    
    [self efSetBarButtonItems:@[[self evbbiAddFolder],[self evbbiSelectCurrentFolder]] type:XLFNavButtonTypeRight];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self efLoadFiles];
    [self efReloadData];
}

#pragma mark - normal

- (void)efLoadFiles;{
    
    NSError *etError = nil;
    
    if (![NSFileManager fileExistsAtPath:[self evCurrentPath]]) {
        [NSFileManager createDirectoryAtPath:[self evCurrentPath] withIntermediateDirectories:YES attributes:nil error:&etError];
        
        NSAssert(!etError, [etError description]);
    }
    
    NSArray* etFolders = nil;
    
    if ([[self evCurrentPath] isEqualToString:[[self evWillMoveFilePath] stringByDeletingLastPathComponent]]) {
        etFolders = [NSFileManager foldersOfDirectoryAtPath:[self evCurrentPath] notIncludeFolderName:[[self evWillMoveFilePath] lastPathComponent] error:&etError];
    }
    else{
        etFolders = [NSFileManager foldersOfDirectoryAtPath:[self evCurrentPath] error:&etError];
    }
    
    NSAssert(!etError, [etError description]);
    
    [[self evFolders] removeAllObjects];
    
    for (NSString *etFileName in etFolders) {
        if (![FBLockManager efNeedLockForFilePath:[[self evCurrentPath] stringByAppendingPathComponent:etFileName]]) {
            [[self evFolders] addObject:etFileName];
        }
    }
    if ([[self evCurrentPath] isEqualToString:SDDocumentDirectory]) {
        [[self evFolders] removeObject:@"Inbox"];
    }
}

- (void)efReloadData{
    
    [[self tableView] reloadData];
    [[self evlbPrompt] removeFromSuperview];
    if (![[self evFolders] count]) {
        [[self tableView] addSubview:[self evlbPrompt]];
    }
}

- (BOOL)efOpenFolder:(NSString*)folderPath;{
    
    NSArray *childFolders = [NSFileManager foldersOfDirectoryAtPath:folderPath error:nil];
    if (childFolders && [childFolders count]) {
        
        BOOL etIsDirectory = NO;
        BOOL etIsExist = [NSFileManager fileExistsAtPath:folderPath isDirectory:&etIsDirectory];
        
        if (etIsExist && etIsDirectory) {
            
            FBFolderSelectorVC *etFolderSelectorVC = [[FBFolderSelectorVC alloc] init];
            [etFolderSelectorVC setEvWillMoveFilePath:[self evWillMoveFilePath]];
            [etFolderSelectorVC setEvCurrentPath:folderPath];
            [etFolderSelectorVC setEvDelegate:self];
            
            [[self navigationController] pushViewController:etFolderSelectorVC animated:YES];
            
            return YES;
        }
    }
    return NO;
}

- (BOOL)efSelectFolder:(NSString*)folderPath;{
    
    BOOL etIsDirectory = NO;
    BOOL etIsExist = [NSFileManager fileExistsAtPath:folderPath isDirectory:&etIsDirectory];
    
    if (etIsExist && etIsDirectory) {
        if ([self evDelegate] && [[self evDelegate] respondsToSelector:@selector(epFolderSelectorVC:didSelectedFolderPath:)]) {
            [[self evDelegate] epFolderSelectorVC:self didSelectedFolderPath:folderPath];
            return YES;
        }
    }
    return NO;
}

- (void)efShowAddFolderAlert:(NSString*)title{
    
    UIAlertView *etAlert = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"4", @"Please input the correct folder name")delegate:self cancelButtonTitle:NSLocalizedString(@"1", @"Cancel")otherButtonTitles:NSLocalizedString(@"15", @"Add"), nil];
    [etAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [etAlert show];
    
    [self setEvatAlert:etAlert];
}


#pragma mark - accessory

- (NSMutableArray*)evFolders{
    if (!_evFolders) {
        
        _evFolders = [NSMutableArray array];
    }
    return _evFolders;
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

- (UIBarButtonItem *)evbbiAddFolder{
    if (!_evbbiAddFolder) {
        _evbbiAddFolder = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didClickAdd:)];
    }
    return _evbbiAddFolder;
}

- (UIBarButtonItem *)evbbiSelectCurrentFolder{
    if (!_evbbiSelectCurrentFolder) {
        _evbbiSelectCurrentFolder =  [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"14", @"Current Folder") style:UIBarButtonItemStyleDone target:self action:@selector(didClickSelectCurrentPath:)];
    }
    return _evbbiSelectCurrentFolder;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[self evFolders] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *esIdCell = @"CellName";
    UITableViewCell *etCell = [tableView dequeueReusableCellWithIdentifier:esIdCell];
    
    if (!etCell) {
        
        etCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:esIdCell];
        [etCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    NSString *etFolderName  = [[self evFolders] objectAtIndex:indexPath.row];
    NSString *etFolderPath = [[self evCurrentPath] stringByAppendingPathComponent:etFolderName];
    NSString *etWillMoveFolderPath = [[self evWillMoveFilePath] stringByDeletingLastPathComponent];
    NSString *etWillMoveFolderName = [etWillMoveFolderPath lastPathComponent];
    
    [[etCell textLabel] setText:etFolderName];
    [[etCell imageView] setImage:[UIImage imageNamed:@"folder"]];
    
    if ([etFolderPath isEqualToString:etWillMoveFolderPath] ||
        ![[NSFileManager foldersOfDirectoryAtPath:etFolderPath notIncludeFolderName:etWillMoveFolderName error:nil] count]) {
        
        [etCell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return etCell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;{
    
    NSString *etFilePath = [[self evCurrentPath] stringByAppendingPathComponent:[[self evFolders] objectAtIndex:[indexPath row]]];
    
    [self efOpenFolder:etFilePath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *etFolderName  = [[self evFolders] objectAtIndex:indexPath.row];
    NSString *etFolderPath = [[self evCurrentPath] stringByAppendingPathComponent:etFolderName];
    NSString *etWillMoveFolderPath = [[self evWillMoveFilePath] stringByDeletingLastPathComponent];
    NSString *etWillMoveFolderName = [etWillMoveFolderPath lastPathComponent];
    
    if (![etFolderPath isEqualToString:etWillMoveFolderPath] &&
        ![[NSFileManager foldersOfDirectoryAtPath:etFolderPath notIncludeFolderName:etWillMoveFolderName error:nil] count]) {
        
        [self efSelectFolder:etFolderPath];
    }
    else{
        
        [self efOpenFolder:etFolderPath];
    }
}

- (void)epFolderSelectorVC:(FBFolderSelectorVC*)vc didSelectedFolderPath:(NSString*)folderPath;{
    
    if ([self evDelegate] && [[self evDelegate] respondsToSelector:@selector(epFolderSelectorVC:didSelectedFolderPath:)]) {
        [[self evDelegate] epFolderSelectorVC:self didSelectedFolderPath:folderPath];
    }
}

#pragma mark - actions 

- (IBAction)didClickSelectCurrentPath:(id)sender{
    
    [self efSelectFolder:[self evCurrentPath]];
}

- (IBAction)didClickAdd:(id)sender {
    
    [self efShowAddFolderAlert:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex != [alertView cancelButtonIndex]) {
        
        NSString *etFolderName = [[alertView textFieldAtIndex:0] text];
        NSString *etFolderPath = [[self evCurrentPath] stringByAppendingPathComponent:etFolderName];
        
        if ([etFolderName length]) {
            
            BOOL etIsDirectory = NO;
            if ((![NSFileManager fileExistsAtPath:etFolderPath isDirectory:&etIsDirectory] ||! etIsDirectory)&&
                [NSFileManager createDirectoryAtPath:etFolderPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                
                [[self evFolders] insertObject:etFolderName atIndex:0];
                [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else{
                
                [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:NO];
                
                [self efShowAddFolderAlert:NSLocalizedString(@"7", @"Folder already exists")];
            }
        }
        else{
            
            [self efShowAddFolderAlert:NSLocalizedString(@"7", @"Folder already exists")];
        }
    }
}


@end
