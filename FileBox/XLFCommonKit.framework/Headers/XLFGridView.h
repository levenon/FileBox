//
//  XLFGridView.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-29.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "XLFGridViewCell.h"
/*!
 @enum DTGridViewScrollPosition
 @abstract Used to determine how to position a grid view cell on screen when scrolling to it.
 @constant DTGridViewScrollPositionNone Aligns the cell such that the shortest distance to display as much of the cell is used.
 @constant DTGridViewScrollPositionTopLeft Aligns the cell so that it is in the top left of the grid view.
 @constant DTGridViewScrollPositionTopCenter Aligns the cell so that it is in the top center of the grid view.
 @constant DTGridViewScrollPositionTopRight Aligns the cell so that it is in the top right of the grid view.
 @constant DTGridViewScrollPositionMiddleLeft Aligns the cell so that it is in the middle left of the grid view.
 @constant DTGridViewScrollPositionMiddleCenter Aligns the cell so that it is in the middle center of the grid view.
 @constant DTGridViewScrollPositionMiddleRight Aligns the cell so that it is in the middle right of the grid view.
 @constant DTGridViewScrollPositionBottomLeft Aligns the cell so that it is in the bottom left of the grid view.
 @constant DTGridViewScrollPositionBottomCenter Aligns the cell so that it is in the bottom center of the grid view.
 @constant DTGridViewScrollPositionBottomRight Aligns the cell so that it is in the bottom right of the grid view.
 @discussion In most cases you will want to use DTGridViewScrollPositionNone to just bring the cell to the screen using the quickest route. In the case where the cell is too big to display completely on screen, the position will still be used, in that the center aligned cells will have their middle in the center of the screen, with their edges outside the screen bounds equally as much.
*/
typedef enum {
	DTGridViewScrollPositionNone = 0,
	DTGridViewScrollPositionTopLeft,
	DTGridViewScrollPositionTopCenter,
	DTGridViewScrollPositionTopRight,
	DTGridViewScrollPositionMiddleLeft,
	DTGridViewScrollPositionMiddleCenter,
	DTGridViewScrollPositionMiddleRight,
	DTGridViewScrollPositionBottomLeft,
	DTGridViewScrollPositionBottomCenter,
	DTGridViewScrollPositionBottomRight
} DTGridViewScrollPosition;
/*!
 @enum DTGridViewEdge
 @abstract Categorizes beverages into groups of similar types.
 @constant DTGridViewEdgeTop Sweet, carbonated, non-alcoholic beverages.
 @constant DTGridViewEdgeBottom Sweet, carbonated, non-alcoholic beverages.
 @constant DTGridViewEdgeLeft Sweet, carbonated, non-alcoholic beverages.
 @constant DTGridViewEdgeRight Sweet, carbonated, non-alcoholic beverages.
 @discussion Extended discussion goes here.
 Lorem ipsum....
*/
typedef enum {
	DTGridViewEdgeTop,
	DTGridViewEdgeBottom,
	DTGridViewEdgeLeft,
	DTGridViewEdgeRight
} DTGridViewEdge;
struct DTOutset {
	CGFloat top;
	CGFloat bottom;
	CGFloat left;
	CGFloat right;
};
@class XLFGridView;
@protocol XLFGridViewDelegate <UIScrollViewDelegate>
@optional
/*!
 Called when the grid view loads.
 */
- (void)gridViewDidLoad:(XLFGridView *)gridView;
- (void)gridView:(XLFGridView *)gridView selectionMadeAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
- (void)gridView:(XLFGridView *)gridView scrolledToEdge:(DTGridViewEdge)edge;
- (void)pagedGridView:(XLFGridView *)gridView didScrollToRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
- (void)gridView:(XLFGridView *)gridView didProgrammaticallyScrollToRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
@end
#pragma mark -
@protocol XLFGridViewDataSource
/*!
 Asks the data source to return the number of rows in the grid view.
 The grid view object requesting this information.
 @return The number of rows in the grid view.
 */
- (NSInteger)numberOfRowsInGridView:(XLFGridView *)gridView;
/*!
 @abstract Asks the data source to return the number of columns for the given row in the grid view.
 @para The grid view object requesting this information.
 @para The index of the given row.
 @return The number of colums in the row of the grid view.
 */
- (NSInteger)numberOfColumnsInGridView:(XLFGridView *)gridView forRowWithIndex:(NSInteger)index;
- (CGFloat)gridView:(XLFGridView *)gridView heightForRow:(NSInteger)rowIndex;
- (CGFloat)gridView:(XLFGridView *)gridView widthForCellAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
- (XLFGridViewCell *)gridView:(XLFGridView *)gridView viewForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;
@optional
- (NSInteger)spacingBetweenRowsInGridView:(XLFGridView *)gridView;
- (NSInteger)spacingBetweenColumnsInGridView:(XLFGridView *)gridView;
@end
#pragma mark -
/*!
 @class XLFGridView
 @abstract 
 @discussion 
*/
@interface XLFGridView : UIScrollView <UIScrollViewDelegate, XLFGridViewCellDelegate> {
	
	NSObject<XLFGridViewDataSource> *dataSource;
	
	CGPoint cellOffset;
	
	UIEdgeInsets outset;
	
	NSMutableArray *gridCells;
	
	NSMutableArray *freeCells;
	NSMutableArray *cellInfoForCellsOnScreen;
	
	NSMutableArray *gridRows;
	NSMutableArray *rowHeights;
	NSMutableArray *rowPositions;
	
	NSMutableArray *cellsOnScreen;
	
	CGPoint oldContentOffset;
	BOOL hasResized;
	
	BOOL hasLoadedData;
		
	NSInteger numberOfRows;
	
	NSUInteger rowIndexOfSelectedCell;
	NSUInteger columnIndexOfSelectedCell;
	
	NSTimer *decelerationTimer;
	NSTimer *draggingTimer;
    BOOL isVertical;
    
    NSInteger touchTimes;
}
/*!
 @abstract The object that acts as the data source of the receiving grid view.
 @discussion The data source must adopt the XLFGridViewDataSource protocol. The data source is not retained.
*/
@property (nonatomic, assign) IBOutlet NSObject<XLFGridViewDataSource> *dataSource;
@property (nonatomic, assign) BOOL isVertical;//default is NO;
/*!
 @abstract The object that acts as the delegate of the receiving grid view.
 @discussion The delegate must adopt the XLFGridViewDelegate protocol. The delegate is not retained.
*/
@property (nonatomic, assign) IBOutlet id<XLFGridViewDelegate> delegate;
/*!
 @abstract The object that acts as the delegate of the receiving grid view.
 @deprecated This property is depricated and you should now use the standard delegate property.
 */
@property (nonatomic, assign) IBOutlet id<XLFGridViewDelegate> gridDelegate;
/*!
 @abstract The offset for each cell with respect to the cells above and to the right.
 @discussion The x and y values can be either positive or negative; Using negative will overlay the cells by that amount, the outcome of this can never be gauranteed what the ordering of cells will be though.
*/
@property (assign) CGPoint cellOffset;
@property (assign) UIEdgeInsets outset;
@property (nonatomic, retain) NSMutableArray *gridCells;
@property (nonatomic) NSInteger numberOfRows;
#pragma mark -
#pragma mark Subclass methods
// These methods can be overridden by subclasses. 
// They should never need to be called from outside classes.
- (void)didEndMoving;
- (void)didEndDragging;
- (void)didEndDecelerating;
- (CGFloat)findWidthForRow:(NSInteger)row column:(NSInteger)column;
- (NSInteger)findNumberOfRows;
- (NSInteger)findNumberOfColumnsForRow:(NSInteger)row;
- (CGFloat)findHeightForRow:(NSInteger)row;
- (XLFGridViewCell *)findViewForRow:(NSInteger)row column:(NSInteger)column;
#pragma mark -
#pragma mark Regular methods
/*!
 @abstract Returns a reusable grid view cell object located by its identifier.
 @param identifier A string identifying the cell object to be reused.
 @discussion For performance reasons, grid views should always reuse their cells. This works like the table view's reuse policy.
*/
- (XLFGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
/*!
 @abstract Returns a grid view cell object located by its row and column positions.
 @param rowIndex The index of the row of the wanted cell.
 @param columnIndex The index of the column of the wanted cell.
 @return The grid view cell of the grid or nil if the cell is not visible or the indexes is out of range.
 */
- (XLFGridViewCell *)cellForRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex;
/*!
 @abstract A constant that identifies a relative position in the receiving table view (top, middle, bottom) for row when scrolling concludes. See “Table View Scroll Position” a descriptions of valid constants.
 @param rowIndex The index of the row to scroll to.
 @param columnIndex The index of the column to scroll to.
 @param position The position the cell should be in once scrolled to.
 @param animated If this 
*/
- (void)scrollViewToRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(DTGridViewScrollPosition)position animated:(BOOL)animated;
- (void)selectRow:(NSUInteger)rowIndex column:(NSUInteger)columnIndex scrollPosition:(DTGridViewScrollPosition)position animated:(BOOL)animated;
/*!
 @abstract This method should be used by subclasses to know when the grid did appear on screen.
*/
- (void)didLoad;
/*!
 @abstract Call this to reload the grid view's data.
*/
- (void)reloadData;
@end
