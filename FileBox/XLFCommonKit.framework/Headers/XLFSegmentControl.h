//
//  XLFSegmentControl.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>

enum XLFSelectionIndicatorMode {
    
    XLFSelectionIndicatorNone = 0,
    XLFSelectionIndicatorResizesToStringWidth = 1, // Indicator width will only be as big as the text width
    XLFSelectionIndicatorFillsSegment = 2 , // Indicator width will fill the whole segment
};

enum XLFSelectionIndicatorPosition {
    
    XLFSelectionIndicatorPositionUp = 0, // Indicator width will only be as big as the text width
    XLFSelectionIndicatorPositionDown = 1 , // Indicator width will fill the whole segment
};

enum XLFTextVerticalAlignment {
    
    XLFTextVerticalAlignmentTop = 0,
    XLFTextVerticalAlignmentCenter,
    XLFTextVerticalAlignmentBottom
};

enum XLFTextHorizontalAlignment {
    
    XLFTextHorizontalAlignmentLeft = NSTextAlignmentLeft,
    XLFTextHorizontalAlignmentCenter = NSTextAlignmentCenter,
    XLFTextHorizontalAlignmentRight = NSTextAlignmentRight,
};

enum XLFSeparatorStyle {
    
    XLFSeparatorStyleNone,
    XLFSeparatorStyleVerticalCenter  = 1<<0,
    XLFSeparatorStyleVerticalFlank   = 1<<1,
    XLFSeparatorStyleHorizontalTop   = 1<<2,
    XLFSeparatorStyleHorizontalBottom= 1<<3,
    
    XLFSeparatorStyleVerticalAll     = XLFSeparatorStyleVerticalCenter | XLFSeparatorStyleVerticalFlank,
    XLFSeparatorStyleHorizontalAll   = XLFSeparatorStyleHorizontalTop | XLFSeparatorStyleHorizontalBottom,
    XLFSeparatorStyleAll             = XLFSeparatorStyleVerticalAll | XLFSeparatorStyleHorizontalAll
};

@interface XLFSegmentItem : NSObject

@property (assign, nonatomic) UIEdgeInsets titleEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets subTitleEdgeInsets;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subTitle;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *selectedImage;

- (instancetype)initWithTitle:(NSString*)title;

- (instancetype)initWithImage:(UIImage*)image;

@end

@interface XLFSegmentControl : UIControl

@property (nonatomic, copy) void (^indexChangeBlock)(NSUInteger index , BOOL cancel); // you can also use addTarget:action:forControlEvents:

@property (nonatomic, strong) IBOutletCollection(XLFSegmentItem) NSArray *items;

@property (nonatomic, strong) UIFont *font; // default is [UIFont fontWithName:@"Avenir-Light" size:19.0f]
@property (nonatomic, strong) UIFont *subTextFont; // default is [UIFont fontWithName:@"Avenir-Light" size:19.0f]

@property (nonatomic, strong) UIFont *selectedFont; // default is [UIFont fontWithName:@"Avenir-Light" size:19.0f]
@property (nonatomic, strong) UIFont *selectedSubTextFont; // default is [UIFont fontWithName:@"Avenir-Light" size:19.0f]

@property (nonatomic, strong) UIColor *textColor; // default is [UIColor blackColor]
@property (nonatomic, strong) UIColor *subTextColor; // default is [UIColor blackColor]

@property (nonatomic, strong) UIColor *selectedTextColor; // default is [UIColor blackColor]
@property (nonatomic, strong) UIColor *selectedSubTextColor; // default is [UIColor blackColor]

@property (nonatomic, strong) UIColor *itemBackgroundColor; // default is [UIColor whiteColor]
@property (nonatomic, strong) UIColor *selectedItemBackgroundColor; // default is [UIColor whiteColor]

@property (nonatomic, strong) UIColor *selectionIndicatorColor; // default is 52, 181, 229
@property (nonatomic, strong) UIImage *selectionIndicatorImage; // default is nil

@property (nonatomic, assign) enum XLFTextVerticalAlignment singleLineTextVerticalAlignment; // Default is XLFTextVerticalAlignmentTop
@property (nonatomic, assign) enum XLFTextHorizontalAlignment singleLineTextHorizontalAlignment; // Default is XLFTextHorizontalAlignmentCenter

@property (nonatomic, assign) enum XLFSelectionIndicatorMode selectionIndicatorMode; // Default is XLFSelectionIndicatorResizesToStringWidth
@property (nonatomic, assign) enum XLFSelectionIndicatorPosition selectionIndicatorPosition;
@property (nonatomic, assign) BOOL      doubleClickCancel;
@property (nonatomic, assign) CGFloat   animateDuration;

@property (nonatomic, assign   ) NSInteger    selectedSegmentIndex;
@property (nonatomic, readonly ) CGFloat      height;// default is 32.0
@property (nonatomic, readwrite) CGFloat      selectionIndicatorHeight;// default is 5.0, if indicator is image, size is to auto fit.
@property (nonatomic, readwrite) UIEdgeInsets segmentEdgeInset;// default is UIEdgeInsetsMake(0, 5, 0, 5)

@property (nonatomic, assign, readonly) NSInteger numberOfSegments ;

@property (nonatomic, assign) enum       XLFSeparatorStyle            separatorStyle;// default is XLFSeparatorStyleNone
@property (nonatomic, strong) UIColor   *separatorColor              ;// default is the standard separator gray

@property (nonatomic, assign) CGFloat   separatorThick              ;// default is 1

@property (nonatomic, assign) BOOL       separatorOutsideOfIndicator ;// default is YES

- (id)initWithItems:(NSArray *)items;

- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated;

- (void)setItem:(XLFSegmentItem*)item atIndex:(NSInteger)nIndex;

- (void)selectCancel ;

@end
