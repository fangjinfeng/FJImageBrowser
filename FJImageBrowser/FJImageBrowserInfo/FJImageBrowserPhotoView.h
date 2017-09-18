//
//  FJPhotoBrowserCollectionCell.h
//  FJImageBrowser
//
//  Created by fjf on 2017/5/18.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FJImageBrowserPhotoView : UIView

// 父控件
@property (nonatomic, weak) FJImageBrowserView *parentPhotosView;

/**
 * @brief 设置所需的参数
 * @param photoModel        图片模型
 * @param currentIndex      当前索引
 * @param photoViewShowType 显示 类型
 * param isFirstTouchImage  是否 为 第一张 需要 放大 图片
 */
// 设置所需的参数
- (void)setParamsWithPhotoModel:(FJImageModel *)photoModel currentIndex:(NSInteger)currentIndex photoViewShowType:(FJPhotoViewShowType)photoViewShowType isFirstShowBrowser:(BOOL)isFirstShowBrowser;

@end
