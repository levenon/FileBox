//
//  XLFTouchTableView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-10.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
@protocol UITableViewTouchDelegate ;
@interface XLFTouchTableView : UITableView
@property(nonatomic,assign)id <UITableViewTouchDelegate> touchDelegate;
@end
@protocol UITableViewTouchDelegate <NSObject>
@optional
- (void)tableView:(UITableView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView
 touchesCancelled:(NSSet *)touches
        withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView
     touchesEnded:(NSSet *)touches
        withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView
     touchesMoved:(NSSet *)touches
        withEvent:(UIEvent *)event;
@end