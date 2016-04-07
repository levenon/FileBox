//
//  UIView+Genie.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-27.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BCRectEdge) {
    
    BCRectEdgeTop    = 0,
    BCRectEdgeLeft   = 1,
    BCRectEdgeBottom = 2,
    BCRectEdgeRight  = 3
};
@interface UIView (Genie)
/*
 * After the animation has completed the view's transform will be changed to match the destination's rect, i.e.
 * view's transform (and thus the frame) will change, however the bounds and center will *not* change.
 */
- (void)genieInTransitionWithDuration:(NSTimeInterval)duration
                      destinationRect:(CGRect)destRect
                      destinationEdge:(BCRectEdge)destEdge
                           completion:(void (^)())completion;

/*
 * After the animation has completed the view's transform will be changed to CGAffineTransformIdentity.
 */
- (void)genieOutTransitionWithDuration:(NSTimeInterval)duration
                             startRect:(CGRect)startRect
                             startEdge:(BCRectEdge)startEdge
                            completion:(void (^)())completion;
@end
