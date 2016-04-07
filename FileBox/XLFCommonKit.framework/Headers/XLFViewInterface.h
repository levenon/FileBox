//
//  XLFViewInterface
//  XLFCommonKit
//
//  Created by Marike Jave on 14-8-25.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#define TableViewCellEvdgAlign  10

@protocol XLFModelViewInterface <NSObject>


+ (id)alloc;
+ (BOOL)conformsToProtocol:(Protocol *)aProtocol;
+ (BOOL)instancesRespondToSelector:(SEL)aSelector;
+ (BOOL)resolveClassMethod:(SEL)sel;

@optional

+ (BOOL)respondsToSelector:(SEL)aSelector;

@property(nonatomic, strong) id evModel;
@property(nonatomic, strong) id evOtherModel;

@end

@protocol XLFViewConstructor <NSObject>

@optional
- (void)epCreateSubViews;
- (void)epConfigSubViews;
- (void)epConfigSubViewsDefault;
- (void)epRelayoutSubViews;
- (void)epRelayoutSubViews:(CGRect)bounds;

// default to all
- (void)epInstallConstraints;

@end

@protocol XLFTableViewCellDelegate <NSObject>

@optional
- (BOOL)epShouldDeleteTableViewCell:(id)tableViewCell;
- (void)epDidDeleteTableViewCell:(id)tableViewCell;
- (BOOL)epShouldExpendTableViewCell:(id)tableViewCell;
- (void)epDidExpendTableViewCell:(id)tableViewCell;
- (void)epDidRefreshTableViewCell:(id)tableViewCell userInfo:(id)userInfo;
- (void)epDidReloadTableViewTriggerByCell:(id)tableViewCell;

@end

@protocol XLFTableViewCellInterface <XLFModelViewInterface>
@optional
+ (CGFloat)epTableView:(UITableView *)tableView heightWithModel:(id)model;
+ (CGFloat)epTableView:(UITableView *)tableView heightWithModel:(id)model otherModel:(id)other;

@property(nonatomic, assign) id evDelegate;

@end

@protocol XLFViewDelegate <NSObject>
@optional
- (BOOL)epShouldDelete:(id)view;
- (void)epDidDelete:(id)view;
- (void)epDidCallback:(id)view userInfo:(id)userInfo;
@end

@protocol XLFViewInterface <XLFModelViewInterface, XLFViewConstructor>

@optional
@property(nonatomic, assign) id evDelegate;

@end