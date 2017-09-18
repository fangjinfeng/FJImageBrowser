
//
//  FJCollectionImageViewCell.m
//  FJImageBrowser
//
//  Created by fjf on 16/7/1.
//  Copyright © 2016年 fjf. All rights reserved.
//

#import "FJCollectionImageViewCell.h"

@interface FJCollectionImageViewCell()

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation FJCollectionImageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.userInteractionEnabled = YES;
//    [self.imageView addGestureRecognizer:tap];
}


+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    //collectionView查询可重用Cell
    FJCollectionImageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFJCollectionImageViewCellId forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FJCollectionImageViewCell" owner:self options:nil] lastObject];
    }
    cell.indexPath = indexPath;
    return cell;
}
@end
