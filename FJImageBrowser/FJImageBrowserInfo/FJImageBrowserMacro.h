//
//  FJImageBrowserMacro.h
//  FJPhotoBrowserDemo
//
//  Created by fjf on 2017/5/19.
//  Copyright © 2017年 fjf. All rights reserved.
//

#ifndef FJImageBrowserMacro_h
#define FJImageBrowserMacro_h


#import <UIKit/UIKit.h>


// 浏览器 图片 间隔
#define kFJPhotoBrowserCellHorizotolSpacing  20.0f

// 默认 图片
#define KFJPhotoBrowserDefaultImage @"default_avatar_geren_134.png"

// 页码 默认 颜色
#define kFJPageControlIndicatorTintColor [UIColor darkGrayColor]

// 页码 选中 颜色
#define kFJPageControlCurrentPageIndicatorTintColor [UIColor whiteColor]

// 显示 模式
typedef NS_ENUM(NSInteger, FJPhotoViewShowType){
    // 模仿微博显示
    FJPhotoViewShowTypeOfWeiBo = 0,
    // 模仿微信显示
    FJPhotoViewShowTypeOfWeiXin = 1,
};





#endif /* FJImageBrowserMacro_h */
