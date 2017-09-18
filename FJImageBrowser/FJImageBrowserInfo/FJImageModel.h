//
//  FJImageModel.h
//  FJPhotoBrowserDemo
//
//  Created by fjf on 2017/6/8.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJImageModel : NSObject
// 图片url / 图片image
@property (nonatomic, weak) id imageInfo;
// 原图
@property (nonatomic, weak) UIImageView *imageView;
@end
