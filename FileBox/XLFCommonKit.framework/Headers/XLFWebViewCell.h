//
//  XLFWebViewCell.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-11.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "XLFViewInterface.h"

@interface XLFWebViewCell : UITableViewCell<XLFTableViewCellInterface>

@property(assign , nonatomic) id<XLFTableViewCellDelegate> evDelegate;

@end
