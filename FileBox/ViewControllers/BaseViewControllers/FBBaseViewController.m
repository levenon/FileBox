//
//  FBBaseViewController.m
//  FileBox
//
//  Created by Marike Jave on 16/4/13.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import "FBBaseViewController.h"

@implementation FBBaseViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}

@end
