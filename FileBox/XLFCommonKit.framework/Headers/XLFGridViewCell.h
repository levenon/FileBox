//
//  XLFGridViewCell.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "XLFGridViewCellInfoProtocol.h"
@protocol XLFGridViewCellDelegate;
/*!
 @class XLFGridViewCell
 @abstract 
 @discussion 
*/
@interface XLFGridViewCell : UIView <XLFGridViewCellInfoProtocol> {
	NSUInteger xPosition, yPosition;
	NSString *identifier;
	
	BOOL selected;
	BOOL highlighted;
	
	id<XLFGridViewCellDelegate> delegate;
	
}
@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL highlighted;
- (id)initWithReuseIdentifier:(NSString *)identifier;
- (void)prepareForReuse;
@end
@protocol XLFGridViewCellDelegate
- (void)gridViewCellWasTouched:(XLFGridViewCell *)gridViewCell;
@end
