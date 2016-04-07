//
//  XLFStaticTableView.h
//  XLFrivingCustomer
//
//  Created by Marike Jave on 15/9/9.
//  Copyright (c) 2015年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLFViewInterface.h"

@class XLFLimitTextField;

typedef NS_ENUM(NSInteger, XLFTableViewCellLayoutStyle) {
    
    XLFTableViewCellLayoutStyleDefault,
    XLFTableViewCellLayoutStyleAutolayout,
};

@interface XLFNormalCellModel : NSObject{
    
@protected
    CGFloat _evHeight;
    Class<XLFTableViewCellInterface> __unsafe_unretained _evCellClass;
}

@property(nonatomic, assign) XLFTableViewCellLayoutStyle evLayoutStyle;

@property(nonatomic, assign) CGFloat evHeight;
@property(nonatomic, assign) BOOL evEditable;

@property(nonatomic, copy  ) NSString *evTitle;
@property(nonatomic, copy  ) UIFont *evTitleFont;
@property(nonatomic, strong) UIColor *evTitleColor;
@property(nonatomic, assign) NSTextAlignment evTitleAlignment;
@property(nonatomic, assign) NSInteger evTitleNumberOfLines;
@property(nonatomic, assign) NSLineBreakMode evTitleLineBreakMode;

@property(nonatomic, copy  ) NSString *evSubTitle;
@property(nonatomic, copy  ) UIFont *evSubTitleFont;
@property(nonatomic, strong) UIColor *evSubTitleColor;
@property(nonatomic, assign) NSTextAlignment evSubTitleAlignment;
@property(nonatomic, assign) NSInteger evSubTitleNumberOfLines;
@property(nonatomic, assign) NSLineBreakMode evSubTitleLineBreakMode;

@property(nonatomic, assign) UITableViewCellStyle evStyle;
@property(nonatomic, assign) UITableViewCellSelectionStyle evSelectionStyle;
@property(nonatomic, assign) UITableViewCellAccessoryType evAccessoryType;

@property(nonatomic, strong) UIColor *evBackgroundColor;
@property(nonatomic, strong) UIColor *evContentColor;

@property(nonatomic, strong) UIImage *evImage;
@property(nonatomic, strong) UIImage *evAccessoryImage;
@property(nonatomic, strong) UIView *evDetailAccessoryView;
@property(nonatomic, unsafe_unretained) Class<XLFTableViewCellInterface> evCellClass;
@property(nonatomic, assign) SEL evAction;
@property(nonatomic, assign) id evTarget;
@property(nonatomic, strong) id evUserInfo;

@property(nonatomic, copy  ) void (^evblcModelCallBack)(XLFNormalCellModel* model);

@property(nonatomic, assign, readonly) BOOL evIsEnableAction;

- (void)efPerformAction;

- (id)initWithTitle:(NSString *)title;

- (id)initWithTitle:(NSString *)title
           subTitle:(NSString *)subTitle;

- (id)initWithTitle:(NSString *)title
         detailText:(NSString *)detailText;

- (id)initWithTitle:(NSString *)title
           subTitle:(NSString *)subTitle
              style:(UITableViewCellStyle)style;

- (id)initWithTitle:(NSString *)title
           subTitle:(NSString *)subTitle
              style:(UITableViewCellStyle)style
      modelCallBack:(void (^)(XLFNormalCellModel* etModel))modelCallBack;

- (id)initWithTitle:(NSString *)title
           subTitle:(NSString *)subTitle
              style:(UITableViewCellStyle)style
             target:(id)target
             action:(SEL)action;

@end

@interface XLFTextCellModel : XLFNormalCellModel

@end

@interface XLFEditableCellModel : XLFNormalCellModel

@property(nonatomic,copy)   NSAttributedString     *evAttributedText;
@property(nonatomic,retain) UIColor                *evTextColor;
@property(nonatomic,retain) UIFont                 *evFont;
@property(nonatomic)        NSTextAlignment         evTextAlignment;
@property(nonatomic)        UITextBorderStyle       evBorderStyle;
@property(nonatomic,copy)   NSString               *evPlaceholder;
@property(nonatomic,copy)   NSAttributedString     *evAttributedPlaceholder;
@property(nonatomic)        BOOL                    evClearsOnBeginEditing;
@property(nonatomic)        BOOL                    evAdjustsFontSizeToFitWidth;
@property(nonatomic)        CGFloat                 evMinimumFontSize;
@property(nonatomic,retain) UIImage                *evBackground;
@property(nonatomic,retain) UIImage                *evDisabledBackground;
@property(nonatomic)        UITextFieldViewMode  evClearButtonMode;
@property(nonatomic,retain) UIView              *evLeftView;
@property(nonatomic)        UITextFieldViewMode  evLeftViewMode;
@property(nonatomic,retain) UIView              *evRightView;
@property(nonatomic)        UITextFieldViewMode  evRightViewMode;
@property(nonatomic) UITextAutocapitalizationType evAutocapitalizationType;
@property(nonatomic) UITextAutocorrectionType evAutocorrectionType;
@property(nonatomic) UITextSpellCheckingType evSpellCheckingType;
@property(nonatomic) UIKeyboardType evKeyboardType;
@property(nonatomic) UIKeyboardAppearance evKeyboardAppearance;
@property(nonatomic) UIReturnKeyType evReturnKeyType;

- (id)initWithTitle:(NSString *)title
           subTitle:(NSString *)subTitle
        placeholder:(NSString *)placeholder
              style:(UITableViewCellStyle)style
             target:(id)target
             action:(SEL)action;

@end

@class XLFNormalSectionModel;

@protocol XLFNormalSectionViewInterface <NSObject>

+ (id)alloc;
- (id)initWithFrame:(CGRect)frame;

@property(nonatomic, strong) XLFNormalSectionModel *evSectionModel;

@end

@interface XLFNormalSectionModel : NSObject

@property(nonatomic, strong) IBOutletCollection(XLFNormalCellModel) NSArray *evCellModels;

@property(nonatomic, copy  ) NSString *evHeaderTitle;
@property(nonatomic, copy  ) NSString *evHeaderSubTitle;
@property(nonatomic, strong) UIColor *evHeaderBackgroundColor;

@property(nonatomic, copy  ) NSString *evFooterTitle;
@property(nonatomic, copy  ) NSString *evFooterSubTitle;
@property(nonatomic, strong) UIColor *evFooterBackgroundColor;

@property(nonatomic, strong) Class<XLFNormalSectionViewInterface> evHeaderViewClass;

@property(nonatomic, strong) Class<XLFNormalSectionViewInterface> evFooterViewClass;

@property(nonatomic, assign) CGFloat evHeaderViewHeight;

@property(nonatomic, assign) CGFloat evFooterViewHeight;

@property(nonatomic, assign) id evUserInfo;

- (id)initWithCellModels:(NSArray *)cellModels;

@end

@interface UITableViewCell (NormalCellModel)

@property(nonatomic, strong) XLFNormalCellModel *evModel;

@end


@interface XLFNormalCell : UITableViewCell<XLFModelViewInterface>

@property(nonatomic, strong) XLFNormalCellModel *evModel;

@end


@interface XLFTextCell : XLFNormalCell<XLFModelViewInterface>

@end

@interface XLFEditableCell : UITableViewCell<XLFModelViewInterface>

@property(nonatomic, strong, readonly) XLFLimitTextField *evtxfDetailTextField;

@property(nonatomic, strong) XLFEditableCellModel *evModel;

@end

@interface XLFSwitchCell : XLFNormalCell

@end

@interface XLFNormalSectionView : UITableViewHeaderFooterView<XLFNormalSectionViewInterface>

@property(nonatomic, strong) XLFNormalSectionModel *evSectionModel;

@end

@interface XLFStaticTableView : UIView

@property(nonatomic, strong) id<UITableViewDelegate, UITableViewDataSource> evDelegate;

@property(nonatomic, strong, readonly) UITableView *evtbvContent;

@property(nonatomic, strong) NSArray *evCellSectionModels;

- (instancetype)initWithStyle:(UITableViewStyle)style;

- (instancetype)initWithStyle:(UITableViewStyle)style defaultCellModels:(NSArray *)defaultCellModels;

- (instancetype)initWithStyle:(UITableViewStyle)style defaultCellSections:(NSArray *)defaultCellSections;

- (void)efReloadData;

- (void)efRemoveAll;

- (XLFNormalSectionModel *)efAddTitleSection:(NSString *)sectionTitle;
- (XLFNormalSectionModel *)efInsertTitleSection:(NSString *)sectionTitle atSectionIndex:(NSInteger)atSectionIndex;

- (XLFNormalCellModel *)efAddCellWithTitle:(NSString *)title inSection:(NSInteger)inSection;
- (XLFNormalCellModel *)efAddCellWithTitle:(NSString *)title detailText:(NSString *)detailText image:(UIImage *)image style:(UITableViewCellStyle)style inSection:(NSInteger)inSection;
- (XLFNormalCellModel *)efInsertCellWithTitle:(NSString *)title atIndexPath:(NSIndexPath *)atIndexPath;
- (XLFNormalCellModel *)efInsertCellWithTitle:(NSString *)title detailText:(NSString *)detailText image:(UIImage *)image style:(UITableViewCellStyle)style atIndexPath:(NSIndexPath *)atIndexPath;

- (void)efAddSection:(XLFNormalSectionModel *)sectionModel;
- (void)efInsertSection:(XLFNormalSectionModel *)sectionModel atSectionIndex:(NSInteger)atSectionIndex;
- (void)efDeleteSection:(XLFNormalSectionModel *)sectionModel;
- (void)efDeleteSectionAtIndex:(NSInteger)atSectionIndex;

- (void)efAddCell:(XLFNormalCellModel *)cellModel inSection:(NSInteger)inSection;
- (void)efInsertCell:(XLFNormalCellModel *)cellModel atIndexPath:(NSIndexPath *)atIndexPath;
- (void)efDeleteCell:(XLFNormalCellModel *)cellModel;
- (void)efDeleteCell:(XLFNormalCellModel *)cellModel inSection:(NSInteger)inSection;
- (void)efDeleteCellAtIndexPath:(NSIndexPath *)atIndexPath;

- (void)efReloadCellAtIndexPaths:(NSArray *)atIndexPaths;

- (void)efReloadSectionAtSections:(NSIndexSet *)atSections;

@end
