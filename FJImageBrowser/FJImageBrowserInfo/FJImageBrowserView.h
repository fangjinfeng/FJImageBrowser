//
//  FJImageBrowserView.h
//  FJImageBrowser
//
//  Created by fjf on 2017/5/18.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJImageBrowserMacro.h"

@class FJImageModel;
@class FJImageBrowserView;



@protocol FJViewControllerRotateProtocol <NSObject>

@end

@protocol FJImageBrowserViewDelegate <NSObject>

@optional

/**
 获取占位图 起始 位置
 
 @param browser FJPhotosView
 @param index 第几张图
 @return 占位小图 起始位置
 */
- (CGRect)photoBrowser:(FJImageBrowserView *_Nullable)browser targetRectForIndex:(NSInteger)index;

/**
 返回 占位 小图
 
 @param browser FJPhotosView
 @param index 第几张图
 @return 占位 小图
 */
- (UIImageView *_Nullable)photoBrowser:(FJImageBrowserView *_Nullable)browser placeholderImageForIndex:(NSInteger)index;

@end


@interface FJImageBrowserView : UIViewController<FJViewControllerRotateProtocol>

/**
 选中第几张(必传)
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 是否需要隐藏原始的imageView
 */
@property (nonatomic, assign) BOOL isHidesOriginal;

/**
 是否禁止 滑动手势
 */
@property (nonatomic, assign) BOOL isBanPanGesture;

/**
 是否显示页码
 */
@property (nonatomic, assign) BOOL isShowPageControl;

/**
 是否禁止横屏
 */
@property (nonatomic, assign) BOOL isForbidLandscape;

/**
 图片数据源（需要自己实现代理）
 */
@property (nonatomic, copy, nonnull) NSArray  *photoDataArray;

/**
 视图模型数据源(不需要自己 实现代理,如果实现,代理优先级高)
 */
@property (nonatomic, copy, nonnull) NSMutableArray  <FJImageModel *>*photoModeArray;

/**
 浏览 显示 模式
 */
@property (nonatomic, assign) FJPhotoViewShowType photoBrowserType;

/**
 委托
 */
@property (nonatomic, weak) _Nullable id  <FJImageBrowserViewDelegate> photoBrowserDelegate;


/**
 *  显示图片浏览器
 */
- (void)showPhotoBrowser;

/**
 *  判断 是否 左右 滚动
 */
- (BOOL)isHorizontalScrolling;

/**
 *  浏览器 拖曳 手势 enable 状态
 */
- (BOOL)isPanGestureRecognizerEnable;

/**
 *  设置 左右 是否 正在 滚动
 */
- (void)setHorizontalScrolling:(BOOL)isScrolling;

/**
 *  设置 浏览器 拖曳 手势
 */
- (void)setPanGestureRecognizerEnable:(BOOL)isEnable;

/**
 *  是否 退出 当前 界面
 */
- (void)setIsQuitCurrentView:(BOOL)isQuitCurrentView;

/**
 *  浏览器 拖曳 手势
 */
- (UIPanGestureRecognizer *_Nullable)panGestureRecognizer;

/**
 *  设置 状态栏 隐藏 属性
 */
- (void)setStatusBarHiddenStatus:(BOOL)statusBarHiddenStatus;
@end
