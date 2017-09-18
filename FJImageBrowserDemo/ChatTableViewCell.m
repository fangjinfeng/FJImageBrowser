//
//  ChatTableViewCell.m
//  JKPhotoBrowser
//
//  Created by 蒋鹏 on 17/2/20.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import "ChatTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface ChatTableViewCell ()

@property (nonatomic, strong, ) NSIndexPath * indexPath;

@property (nonatomic, copy) NSString *imageUrl;
@end

@implementation ChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.userInteractionEnabled = YES;
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        _imgView = imageView;
    }return self;
}


- (void)configueCellWithImageUrl:(NSString *)imageUrl indexPath:(NSIndexPath *)indexPath {
    self.imageUrl = imageUrl;
    self.indexPath = indexPath;
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    CGSize size = CGSizeMake(100, 100);
    CGFloat scale = size.width / size.height;
    CGFloat width = 200;
    CGFloat height = 200;
    if (scale > 1.0) {
        height = width / scale;
    } else {
        width = height * scale;
    }
    
    
    CGFloat x = indexPath.row % 2 ? 10 : [UIScreen mainScreen].bounds.size.width - 10 - width;
    self.imgView.frame = CGRectMake(x, 10, width, height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
