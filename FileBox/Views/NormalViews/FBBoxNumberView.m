//
//  FBBoxNumberView
//  FileBox
//
//  Created by Marke Jave on 16/4/15.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import "FBBoxNumberView.h"

@implementation FBBoxNumberView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setEvNumberOfBoxes:1];
    }
    return self;
}

- (void)setEvNumberOfBoxes:(NSInteger)evNumberOfBoxes{
    
    _evCurrentNumber = MAX(evNumberOfBoxes, 1);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    
    CGContextRef etCurrentContext = UIGraphicsGetCurrentContext();
    
    CGFloat etInteritemSpacing = 1.f;
    
    CGFloat etItemWidth = (CGRectGetWidth(rect) - etInteritemSpacing) / [self evNumberOfBoxes];
    
    CGFloat etItemHeight = CGRectGetHeight(rect) - etInteritemSpacing * 2;
    
    CGContextSetFillColorWithColor(etCurrentContext, [[self tintColor] CGColor]);
    
    for (NSInteger nIndex = 0; nIndex < [self evCurrentNumber]; nIndex++) {
        
        CGContextFillRect(etCurrentContext, CGRectMake(etInteritemSpacing + (etItemWidth + etInteritemSpacing) * nIndex, etInteritemSpacing, etItemWidth, etItemHeight));
    }
}

@end
