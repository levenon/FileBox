//
//  UIViewController+ImagesPicker.h
//  UiComponentDemo
//
//  Created by Marike Jave 14-2-18.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define  MaximumNumberOfSelectionDefaultValue  10 //默认最多选择10张图片

typedef void (^XLFImagesPickerFinishBlock)(NSArray* imagesAssetsArray);
typedef void (^XLFSingleImagePickerFinishBlock)(UIImage* image);

@interface UIViewController (ImagesPicker)

/*!
 *@abstract 多图片选择
 *@param    imagesPickerFinishBlock 选择完成之后响应的Block，必须传递有效的Block
 *@param    maximumNumberOfSelection 最大选中数，默认为MaximumNumberOfSelectionDefaultValue； 如果传递的参数小于等于0，则改值未默认值
 */
- (void)efGetImagesWithPickerFinishBlock:(XLFImagesPickerFinishBlock)imagesPickerFinishBlock
                maximumNumberOfSelection:(NSInteger)maximumNumberOfSelection;
/**
 *  选择一张图片
 *
 *  @param imagePickerFinishBlock
 */
- (void)efGetSingleImageWithPickerFinishBlock:(XLFSingleImagePickerFinishBlock)imagePickerFinishBlock
                                  allowsEdit:(BOOL)isAllowsEdit;
@end
