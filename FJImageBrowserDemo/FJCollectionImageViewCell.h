//
//  FJCollectionImageViewCell.h
//  FJImageBrowser
//
//  Created by fjf on 16/7/1.
//  Copyright © 2016年 fjf. All rights reserved.
//

#import "FJImageBrowserMacro.h"
#import <UIKit/UIKit.h>

// 间距
#define  FJ_COLLECTION_IMAGE_VIEW_CELL_SPACING 6

// 每行个数
#define  FJ_COLLECTION_IMAGE_VIEW_CELL_ROW_COUNT 3

// 宽
#define  FJ_COLLECTION_IMAGE_VIEW_WIDTH (([UIScreen mainScreen].bounds.size.width - ((FJ_COLLECTION_IMAGE_VIEW_CELL_ROW_COUNT + 1) * FJ_COLLECTION_IMAGE_VIEW_CELL_SPACING)) / FJ_COLLECTION_IMAGE_VIEW_CELL_ROW_COUNT)
// 高
#define FJ_COLLECTION_IMAGE_VIEW_HEIGHT  FJ_COLLECTION_IMAGE_VIEW_WIDTH

static NSString *kFJCollectionImageViewCellId = @"FJCollectionImageViewCellId";

@interface FJCollectionImageViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;
@end
