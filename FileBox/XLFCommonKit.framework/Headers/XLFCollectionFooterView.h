//
//  XLFCollectionFooterView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
@interface XLFCollectionFooterView : UICollectionReusableView{
    
    UIActivityIndicatorView *gear;
	UILabel *statusLabel;
	
	UIView	*_backgroundView;
}
@property (nonatomic, strong)  UIActivityIndicatorView *gear;
@property (nonatomic, strong)  UILabel *statusLabel;
@property (nonatomic, strong)  UIView	*backgroundView;
- (id)initWithFrame:(CGRect)frame title:(NSString *)aTitle;
- (void)startAnimating;
- (void)stopAnimating;
- (void)startAnimatingWithTitle:(NSString *)aTitle;
- (void)stopAnimatingWithTitle:(NSString *)aTitle;
@end
