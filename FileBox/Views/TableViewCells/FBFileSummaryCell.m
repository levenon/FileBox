//
//  FBFileSummaryCell.m
//  FileBox
//
//  Created by Marike Jave on 16/4/13.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import "FBFileSummaryCell.h"
#import "FBFileManager.h"

@implementation NSString (PathExtension)

- (NSString *)defaultPathExtension{
    
    NSString *etPathExtension = [self pathExtension];
    if (![etPathExtension length]) {
        etPathExtension = @"Unknown";
    }
    return [etPathExtension uppercaseString];
}

@end

@interface FBFileSummaryCell ()<XLFViewInterface>

@property(nonatomic, strong)UILabel *evlbFileType;
@property(nonatomic, strong)UIImageView *evimgvFileType;
@property(nonatomic, strong)UILabel *evlbFileName;

@end

@implementation FBFileSummaryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        
        [self epCreateSubViews];
        [self epConfigSubViewsDefault];
        [self epInstallConstraints];
    }
    return self;
}

- (void)epCreateSubViews{
    
    [self setEvlbFileType:[UILabel emptyFrameView]];
    [self setEvlbFileName:[UILabel emptyFrameView]];
    [self setEvimgvFileType:[UIImageView emptyFrameView]];
    
    [[self contentView] addSubview:[self evlbFileType]];
    [[self contentView] addSubview:[self evimgvFileType]];
    [[self contentView] addSubview:[self evlbFileName]];
}

- (void)epConfigSubViewsDefault{
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [[self evlbFileName] setTextColor:[UIColor darkTextColor]];
    [[self evlbFileName] setFont:[UIFont systemFontOfSize:13]];
    
    UIColor *etRandomColor = [UIColor colorWithHexRGB:arc4random()% 0x999999];
    [[self evlbFileType] setFont:[UIFont systemFontOfSize:16]];
    [[self evlbFileType] setTextAlignment:NSTextAlignmentCenter];
    [[self evlbFileType] setTextColor:etRandomColor];
    
    [[[self evlbFileType] layer] setCornerRadius:10];
    [[[self evlbFileType] layer] setBorderWidth:0.5];
    [[[self evlbFileType] layer] setBorderColor:[etRandomColor CGColor]];
    
    [[[self evimgvFileType] layer] setCornerRadius:10];
    [[[self evimgvFileType] layer] setBorderWidth:0.3];
    [[[self evimgvFileType] layer] setBorderColor:[etRandomColor CGColor]];
}

- (void)epInstallConstraints{
    
    @weakify(self);
    [[self evlbFileType] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.left.equalTo(self.contentView.mas_leftMargin).offset(0);
        make.centerY.equalTo(self.contentView.mas_centerY).offset(0);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    [[self evimgvFileType] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.left.equalTo(self.contentView.mas_leftMargin).offset(0);
        make.centerY.equalTo(self.contentView.mas_centerY).offset(0);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    [[self evlbFileName] mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        
        make.left.equalTo(self.evlbFileType.mas_right).offset(10);
        make.top.equalTo(self.contentView.mas_topMargin).offset(0);
        make.bottom.equalTo(self.contentView.mas_bottomMargin).offset(0);
        make.right.equalTo(self.contentView.mas_rightMargin).offset(0);
    }];
}

- (void)epConfigSubViews{
    
    [[self evlbFileName] setText:[[self evFilePath] lastPathComponent]];
    [[self evlbFileType] setText:[[[self evFilePath] defaultPathExtension] substringToIndex:1]];
    
    UIImage *etFileTypeImage = [FBFileManager efIconWithFilePath:[self evFilePath]];
    
    [[self evimgvFileType] setImage:etFileTypeImage];
    [[self evimgvFileType] setHidden:!etFileTypeImage];
    
    [[self evlbFileType] setHidden:etFileTypeImage];
}

- (void)setEvFilePath:(NSString *)evFilePath{
    
    if (evFilePath != _evFilePath) {
        
        _evFilePath = [evFilePath copy];
    }
    [self epConfigSubViews];
}

@end