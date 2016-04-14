//
//  FBLockManager.m
//  FileBox
//
//  Created by Marike Jave on 15/2/9.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import "FBLockManager.h"

static NSString * const egLockKeyArchiveFileName = @"lockManager.archive";
static NSString * const egLockKeyKey = @"egLockKeyKey";
static NSString * const egPasswordKey = @"egPasswordKey";
static NSString * const egPasswordEnableKey = @"egPasswordEnableKey";
static NSString * const kDidInstalledKey = @"kDidInstalledKey";

NSString * const kNotificationVerifyHasChanged = @"kNotificationVerifyHasChanged";

@interface FBLockManager ()<XLFPinViewControllerDelegate>

@property (nonatomic, strong) UIAlertView *evatAlert;

@property (nonatomic, strong) XLFPinViewController *evPasswordInputVC;

@property (nonatomic, strong) NSMutableDictionary *evMutLockKey;

@property (nonatomic, assign, getter=evIsVerifySuccess) BOOL evVerifySuccess;

@property (nonatomic, assign, getter=evIsResetPassword) BOOL evResetPassword;

@property (nonatomic, assign, getter=evIsSecondInput) BOOL evSecondInput;

@property (nonatomic, assign, getter=evIsVerifying) BOOL evVerifying;

@property (nonatomic, copy) NSString *evPassword;

@property (nonatomic, copy) NSString *evFirstInputPassword;

@property (nonatomic, copy) NSMutableArray* evblcMutVerifySuccesses;

@end

@implementation FBLockManager

#pragma mark - accessory

- (NSDictionary*)evLockKey{

    return [self evMutLockKey];
}

- (NSMutableDictionary*)evMutLockKey{

    if (!_evMutLockKey) {
        
        _evMutLockKey = [NSMutableDictionary dictionary];
    }
    return _evMutLockKey;
}

- (NSMutableArray*)evblcMutVerifySuccesses{
    if (!_evblcMutVerifySuccesses) {
        _evblcMutVerifySuccesses = [NSMutableArray array];
    }
    return _evblcMutVerifySuccesses;
}

- (void)setEvPassword:(NSString *)evPassword{
    if (_evPassword != evPassword) {

        _evPassword = evPassword;

        [self _efUpdateToDisk];
    }
}

- (void)setEvPasswordEnable:(BOOL)evPasswordEnable{

    if (_evPasswordEnable != evPasswordEnable) {

        _evPasswordEnable = evPasswordEnable;

        [self _efUpdateToDisk];
    }
}

- (void)setEvatAlert:(UIAlertView *)evatAlert{

    if (_evatAlert != evatAlert) {

        [_evatAlert dismissWithClickedButtonIndex:[_evatAlert cancelButtonIndex] animated:NO];

        _evatAlert = evatAlert;
    }
}

- (void)setEvVerifySuccess:(BOOL)evVerifySuccess{

    if (_evVerifySuccess != evVerifySuccess) {

        _evVerifySuccess = evVerifySuccess;
    }

    if ([[self evblcMutVerifySuccesses] count]) {

        for (VerifySuccessBlock blcVerifySuccess in [self evblcMutVerifySuccesses]) {

            blcVerifySuccess(_evVerifySuccess);
        }
    }
    [self _efClearStatus];

    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVerifyHasChanged object:self];
}

- (BOOL)evCanEvaluatePolicy{
    
    return [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                  error:nil];
}

- (BOOL)evNeedSetPassword{
    return [[FBLockManager sharedInstance] evIsPasswordEnable] && ![[[FBLockManager sharedInstance] evPassword] length];
}

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init 

+ (void)load{
    [super load];

    if(![NSFileManager fileExistsAtPath:SDArchiverDirectory]){
        [NSFileManager createDirectoryAtPath:SDArchiverDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [[self sharedInstance] _efInitFromDisk];
}

+ (FBLockManager*)sharedInstance{

    static FBLockManager*  egLockManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        egLockManager =  [[self alloc] init];
    });

    return egLockManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotificationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didNotificationDidFinishLaunching:) name:UIApplicationDidFinishLaunchingNotification object:nil];

    }
    return self;
}

#pragma mark - private

- (void)_efClearStatus;{

    [self setEvFirstInputPassword:nil];
    [self setEvResetPassword:NO];
    [self setEvSecondInput:NO];
    [self setEvPasswordInputVC:nil];
    [[self evblcMutVerifySuccesses] removeAllObjects];
}

- (void)_efInitFromDisk;{

    NSDictionary *archiver = [NSKeyedUnarchiver unarchiveObjectWithFile:SDArchiverFolder(egLockKeyArchiveFileName)];

    [self setEvMutLockKey:[archiver objectForKey:egLockKeyKey]];
    [self setEvPassword:[archiver objectForKey:egPasswordKey]];
    [self setEvPasswordEnable:[[archiver objectForKey:egPasswordEnableKey] boolValue]];
}

- (BOOL)_efUpdateToDisk;{

    NSMutableDictionary *archiver = [NSMutableDictionary dictionary];
    [archiver setObject:[self evLockKey] forKey:egLockKeyKey];
    [archiver setObject:ntoe([self evPassword]) forKey:egPasswordKey];
    [archiver setObject:[NSNumber numberWithBool:[self evIsPasswordEnable]] forKey:egPasswordEnableKey];

    return [NSKeyedArchiver archiveRootObject:archiver toFile:SDArchiverFolder(egLockKeyArchiveFileName)];
}

- (void)_efClearAllData;{

    [self _efClearAllDataNotSaveToDisk];

    [self _efUpdateToDisk];
}

- (void)_efClearAllDataNotSaveToDisk;{

    [[self evMutLockKey] removeAllObjects];
}

- (void)_efRemoveLockForFilePath:(NSString*)filePath;{

    NSAssert(filePath, @"filePath can't be nil");
    [[self evMutLockKey] removeObjectForKey:filePath];
    [self _efUpdateToDisk];
}

- (void)_efSetNeedLock:(BOOL)lock forFilePath:(NSString*)filePath;{

    NSAssert(filePath, @"filePath can't be nil");
    if (lock) {

        [[self evMutLockKey] setObject:[NSNumber numberWithBool:lock] forKey:filePath];
    }
    else{
        [[self evMutLockKey] removeObjectForKey:filePath];
    }

    [self _efUpdateToDisk];
}

- (BOOL)_efNeedLockForFilePath:(NSString*)filePath;{

    NSAssert(filePath, @"filePath can't be nil");

    return [[[self evMutLockKey] objectForKey:filePath] boolValue];
}

- (void)_efInputPassword:(BOOL)reset;{

    [self setEvResetPassword:reset];
    [self setEvPasswordInputVC:[self _efShowPinViewAnimated:YES reset:reset]];
}

- (XLFPinViewController*)_efShowPinViewAnimated:(BOOL)animated reset:(BOOL)reset{

    XLFPinViewController *etPasswordInputVC = [[XLFPinViewController alloc] initWithDelegate:self];

    [etPasswordInputVC setPromptTitle:NSLocalizedString(@"16", @"Please input password")];
    [etPasswordInputVC setPromptColor:[UIColor grayColor]];
    [[etPasswordInputVC view] setTintColor:[UIColor grayColor]];

    // for a solid background color, use this:
    [etPasswordInputVC setBackgroundColor:[UIColor whiteColor]];
    [etPasswordInputVC setTranslucentBackground:YES];

    [[self evVisibleViewController] setModalPresentationStyle:UIModalPresentationCurrentContext];

    [[self evVisibleViewController] presentViewController:etPasswordInputVC animated:animated completion:nil];
    return etPasswordInputVC;
}

- (void)_efVerifyWithResultBlock:(VerifySuccessBlock)resultBlock;{

    [[self evblcMutVerifySuccesses] addObject:resultBlock];

    if (![self evIsVerifying]) {

        [self setEvVerifying:YES];

        if (IOS_VERSION > 8.0) {

            NSError *etAuthError = nil;
            LAContext *etContext = [[LAContext alloc] init];

            if ([self evIsPasswordEnable] && ![[self evPassword] length]) {
                [etContext setLocalizedFallbackTitle:NSLocalizedString(@"17", @"Set Password")];
            }
            else if (![self evIsPasswordEnable]){
                [etContext setLocalizedFallbackTitle:@""];
            }

            if ([etContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                       error:&etAuthError]) {

                [etContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                          localizedReason:NSLocalizedString(@"20", @"Please verify fingerprint")
                                    reply:^(BOOL success, NSError *error) {

                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                                            if (!success && [error code] == LAErrorUserFallback) {

                                                [self _efInputPassword:![[self evPassword] length]];
                                            }
                                            else{

                                                [self setEvVerifySuccess:success];
                                            }
                                            [self setEvVerifying:NO];
                                        }];
                                    }];
            }
            else if([self evIsPasswordEnable]){

                [self _efInputPassword:![[self evPassword] length]];
            }
        }
        else if([self evIsPasswordEnable]){

            [self _efInputPassword:![[self evPassword] length]];
        }
    }
}


#pragma mark - public

+ (BOOL)efUpdateToDisk;{

    return [[self sharedInstance] _efUpdateToDisk];
}

+ (void)efClearAllData;{

    [[self sharedInstance] _efClearAllData];
}

+ (void)efClearAllDataNotSaveToDisk;{

    [[self sharedInstance] _efClearAllDataNotSaveToDisk];
}

+ (void)efRemoveLockForFilePath:(NSString*)filePath;{

    [[self sharedInstance] _efRemoveLockForFilePath:filePath];
}

+ (void)efSetNeedLock:(BOOL)need forFilePath:(NSString*)filePath;{

    [[self sharedInstance] _efSetNeedLock:need forFilePath:filePath];
}

+ (BOOL)efNeedLockForFilePath:(NSString*)filePath;{

    return [[self sharedInstance] _efNeedLockForFilePath:filePath];
}

+ (void)efVerifyWithResultBlock:(void(^)(BOOL success))resultBlock;{

    [[self sharedInstance] _efVerifyWithResultBlock:resultBlock];
}

+ (void)efResetPasswordWithResultBlock:(VerifySuccessBlock)resultBlock;{

    if (resultBlock) {

        [[[self sharedInstance] evblcMutVerifySuccesses] addObject:resultBlock];
    }
    [[self sharedInstance] _efInputPassword:YES];
}

#pragma mark - actions

- (IBAction)didNotificationDidEnterBackground:(id)sender{

    [[self evatAlert] dismissWithClickedButtonIndex:[[self evatAlert] cancelButtonIndex] animated:YES];
    [[self evPasswordInputVC] dismissViewControllerAnimated:NO completion:nil];
    [self _efClearStatus];
}

- (IBAction)didNotificationDidFinishLaunching:(id)sender{

    if (![NSUserDefaults boolForKey:kDidInstalledKey]) {
        [NSUserDefaults setBool:YES forKey:kDidInstalledKey];
        [self setEvPasswordEnable:YES];
    }
}

#pragma mark - XLFPinViewControllerDelegate

- (NSUInteger)pinLengthForPinViewController:(XLFPinViewController *)pinViewController{
    return 4;
}

- (BOOL)pinViewController:(XLFPinViewController *)pinViewController isPinValid:(NSString *)pin{

    // 设置密码， 再次输入密码，密码验证
    if ([self evIsResetPassword]){

        if ([self evIsSecondInput]) {

            return [[self evFirstInputPassword] isEqualToString:pin];
        }

        [pinViewController setPromptTitle:NSLocalizedString(@"31", @"Please input password again")];
        [self setEvFirstInputPassword:pin];
        [self setEvSecondInput:YES];
        return NO;
    }
    else{

        return [pin isEqualToString:[self evPassword]];
    }
    return NO;
}

- (BOOL)userCanRetryInPinViewController:(XLFPinViewController *)pinViewController{

    return ![self evIsResetPassword] || ([self evIsResetPassword] && [self evIsSecondInput]);
}

- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(XLFPinViewController *)pinViewController{

    if ([self evIsResetPassword] && [self evIsSecondInput]) {
        [self setEvPassword:[self evFirstInputPassword]];
    }
    [self setEvVerifySuccess:YES];
    [self setEvVerifying:NO];
}

- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(XLFPinViewController *)pinViewController{

    [self setEvVerifySuccess:NO];
    [self setEvVerifying:NO];
}


@end
