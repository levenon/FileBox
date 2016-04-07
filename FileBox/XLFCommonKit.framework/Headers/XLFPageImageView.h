//
//  FPHPageImageView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>

@class XLFPageImageView;

@protocol XLFPageImageViewDelegate <NSObject>

- (NSUInteger)numberOfItemsInPageImageView:(XLFPageImageView *)pageImageView;
- (NSUInteger)numberOfVisibleItemInPageImageView:(XLFPageImageView *)pageImageView;
- (CGFloat)itemWidthForPageImageView:(XLFPageImageView *)pageImageView;
- (UIView *)pageImageView:(XLFPageImageView *)pageImageView viewForItemAtIndex:(NSUInteger)index;

@optional
- (void)pageImageViewDidScroll:(XLFPageImageView *)pageImageView;
- (void)pageImageView:(XLFPageImageView *)pageImageView didSelectItemAtIndex:(NSInteger)index;

@end
@interface XLFPageImageView : UIScrollView
@property (nonatomic , strong , readonly) NSArray       *evItems;
@property (nonatomic , strong , readonly) NSArray       *evVisibleItems;
@property (nonatomic , assign , readonly) CGFloat        evItemWidth;
@property (nonatomic , assign , readonly) CGFloat        evNumberOfItems;
@property (nonatomic , assign , readonly) CGFloat        evNumberOfVisiableItems;

@property (nonatomic , assign) NSInteger      evCurrentIndex;
@property (nonatomic , assign) IBOutlet id<XLFPageImageViewDelegate> evDelegate;
- (void)reloadData;

//- (void)deleteItemAtIndex:(NSInteger)nIndex;

@end
