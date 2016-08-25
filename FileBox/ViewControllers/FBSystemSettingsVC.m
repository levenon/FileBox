//
//  FBSystemSettingsVC.m
//  FileBox
//
//  Created by Marike Jave on 15/3/22.
//  Copyright (c)2015年 Marike Jave. All rights reserved.
//

#import "FBSystemSettingsVC.h"
#import "FBLockManager.h"

@interface FBSystemSettingsVC ()<UIAlertViewDelegate>

@property(nonatomic, strong)NSMutableArray *evMutItems;

@end

@implementation FBSystemSettingsVC

- (void)dealloc{
    
    [[self evMutItems] removeAllObjects];
    [self setEvMutItems:nil];
}

- (void)loadView{
    [super loadView];

    [[self tableView] setTableFooterView:[UIView emptyFrameView]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - accessor 

- (NSMutableArray *)evMutItems{

    if (!_evMutItems) {

        _evMutItems = [NSMutableArray array];

        NSMutableArray *etSectionFirst = [NSMutableArray array];
        BOOL etPasswordEnable = [[FBLockManager sharedInstance] evIsPasswordEnable];

        [etSectionFirst addObject:@{@"title":NSLocalizedString(@"18", @"Enable Password"),
                                    @"accessory":[NSNumber numberWithBool:etPasswordEnable],
                                    @"destination":@"didClickEnablePassword:"}];

        if (etPasswordEnable) {
            [etSectionFirst addObject:[self etRestPasswordItem]];
        }

        NSMutableArray *etSectionSecond = [NSMutableArray arrayWithArray:
                                           @[@{@"title":NSLocalizedString(@"22", @"Go to score"),
                                               @"destination":@"didClickPraise:",
                                               @"accessoryType":[NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator]},
                                             @{@"title":NSLocalizedString(@"24", @"Author"),
                                               @"detail":@"Marike Jave"}]];

        [_evMutItems addObject:etSectionFirst];
        [_evMutItems addObject:etSectionSecond];
    }
    return _evMutItems;
}

- (NSDictionary*)etRestPasswordItem{

    return @{@"title":select([[[FBLockManager sharedInstance] evPassword] length], NSLocalizedString(@"19", @"Reset Password"), NSLocalizedString(@"17", @"Set Password")),
             @"destination":@"didClickResetPassword:",
             @"accessoryType":[NSNumber numberWithInteger:UITableViewCellAccessoryDisclosureIndicator]};
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [[self evMutItems] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[self evMutItems] objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return select(section, 30, 20);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary *etItem = [[[self evMutItems] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    UITableViewCell *etCell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellDefault"];
    if (!etCell) {

        etCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellDefault"];
    }
    [[etCell textLabel] setText:ntoe([etItem objectForKey:@"title"])];
    [[etCell detailTextLabel] setText:ntoe([etItem objectForKey:@"detail"])];
    [etCell setSelectionStyle:select([etItem objectForKey:@"destination"], UITableViewCellSelectionStyleGray, UITableViewCellSelectionStyleNone)];

    if ([etItem objectForKey:@"accessory"]) {
        UISwitch *etswtEnablePassword = [[UISwitch alloc] init];
        [etswtEnablePassword addTarget:self action:@selector(didClickEnablePassword:)forControlEvents:UIControlEventTouchUpInside];
        [etswtEnablePassword setOn:[[etItem objectForKey:@"accessory"] boolValue]];
        [etCell setAccessoryView:etswtEnablePassword];
    }
    if ([etItem objectForKey:@"accessoryType"]) {
        [etCell setAccessoryType:[[etItem objectForKey:@"accessoryType"] integerValue]];
    }

    return etCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *etItem = [[[self evMutItems] objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    NSString *etSelectorName = [etItem objectForKey:@"destination"];

    if ([etSelectorName length] && [indexPath row]) {

        SEL etSelector = NSSelectorFromString(etSelectorName);
        [self performSelector:etSelector withObject:etItem];
    }
}

#pragma mark - action

- (IBAction)didClickEnablePassword:(UISwitch*)sender{

    if ([sender isOn]) {

        [[[self evMutItems] objectAtIndex:0] insertObject:[self etRestPasswordItem] atIndex:1];
        [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {

        [[[self evMutItems] objectAtIndex:0] removeObjectAtIndex:1];
        [[self tableView] deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    [[FBLockManager sharedInstance] setEvPasswordEnable:[sender isOn]];
}

- (IBAction)didClickResetPassword:(id)sender{

    if ([[[FBLockManager sharedInstance] evPassword] length]) {

        [FBLockManager efResetPasswordWithResultBlock:nil];
    }
    else{
        [FBLockManager efResetPasswordWithResultBlock:^(BOOL success) {

            if (success) {
                
                [[[self evMutItems] objectAtIndex:0] replaceObjectAtIndex:1 withObject:[self etRestPasswordItem]];
                [[self tableView] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }
}

- (IBAction)didClickPraise:(id)sender{

    [XLFAppManager efCommentApplication];
}

@end
