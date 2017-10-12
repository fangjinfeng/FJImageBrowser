
//
//  FJPhotoBrowserCollectionCell.m
//  FJImageBrowser
//
//  Created by fjf on 2017/5/18.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import "FJImageBrowser.h"
#import "UIView+FJExtension.h"
#import "FJShapeCircleView.h"
#import "UIImageView+WebCache.h"
#import "FJImageBrowserPhotoView.h"


// 默认 动画 时间
static CGFloat const kFJDefaultAnimationTime = 0.3f;

// 最大 放大 倍数
static CGFloat const kFJPhotoBrowserCellZoomMaxScale = 2.0f;

// 最小 缩小 倍数
static CGFloat const kFJPhotoBrowserCellZoomMinScale = 0.2f;


@interface FJImageBrowserPhotoView()<UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>


// 图片下载成功 YES 否则 NO
@property (nonatomic, assign) BOOL isLoadedImage;

//当前图片index
@property (nonatomic, assign) NSInteger currentIndex;

// scrollView 用于缩放图片
@property (nonatomic, strong) UIScrollView *scrollView;

// presentImageView 当前展示图
@property(nonatomic, strong)  UIImageView *presentImageView;

// placeHoldImageView 占位图
@property (nonatomic, strong) UIImageView *placeHoldImageView;

// 图片 模型
@property (nonatomic, strong) FJImageModel *photoModel;

// progressLayer 下载进度条
@property (nonatomic, strong) FJShapeCircleView *progressLayer;

// 显示 方式
@property (nonatomic, assign) FJPhotoViewShowType photoViewShowType;

// doubleTap 双击
@property (nonatomic,strong) UITapGestureRecognizer *doubleTapGesture;

// singleTap 单击
@property (nonatomic,strong) UITapGestureRecognizer *singleTapGesture;

// longPressGesture 长按
@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGesture;

// 拖拽手势，实现偏移、缩放、背景渐变
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

//  原始坐标的中心点，用来还原坐标
@property (nonatomic, assign) CGPoint imageViewOriginalCenter;

// 长按手势的初始坐标，用来坐标偏移大小和方法
@property (nonatomic, assign) CGPoint panGestureBeginPoint;

// 拖拽手势上一次的触屏点location坐标点
@property (nonatomic, assign) CGFloat panGestureLocationY;

// 向下则隐藏图片，向上则缩放到到1.0比例
@property (nonatomic, assign) BOOL isPanGestureDirectionDown;

// 水平 是否 滚动
@property (nonatomic, assign) BOOL isScrollHorizontal;

@end

@implementation FJImageBrowserPhotoView

#pragma mark --- init method

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {

        [self setupSubviews];
        
        [self addOrientationNotiObserver];
    }
    return self;
}



#pragma mark --- private method

// 设置 子控件
- (void)setupSubviews {
    // 添加 scrollView
    [self addSubview:self.scrollView];
    
    // 添加 当前 展示图
    [self.scrollView addGestureRecognizer:self.singleTapGesture];
    [self.scrollView addGestureRecognizer:self.doubleTapGesture];
    [self.scrollView addGestureRecognizer:self.longPressGesture];
    [self.scrollView addSubview:self.presentImageView];
    
    // 添加 下载 进度条
    [self.scrollView addSubview:self.progressLayer];
}


// 添加 屏幕 旋转 通知
- (void)addOrientationNotiObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

// 显示 下载进入和 下载完成 展现 动画
- (void)showDownloadingProgerssWithImageUrl:(NSString *)imageUrl isAnimation:(BOOL)isAnimation{
    //变换完动画 从网络开始加载图
    NSString *imageUrlStr = [[imageUrl stringByReplacingOccurrencesOfString:@"\\" withString:@""] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
     __weak typeof(self) weakSelf = self;

    [self.presentImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:self.presentImageView.image options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        __strong typeof (self) strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.progressLayer.hidden = NO;
            });
        }
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        __strong typeof (self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.progressLayer.hidden = YES;
            if (isAnimation) {
                [UIView animateWithDuration:kFJDefaultAnimationTime animations:^{
                    [strongSelf directAmplifyPresentImageView];
                }];
            }
            else {
                [strongSelf directAmplifyPresentImageView];
            }
            strongSelf.isLoadedImage = YES;
        }
    }];
}

// 微信 模式 还没下载完成 显示在中间
- (void)showPresentImageViewInMiddle {
    //设置空image时的情况
    //ImageView.image的大小
    CGFloat   imageH;
    CGFloat   imageW;
    
    imageH = self.presentImageView.height;
    imageW = self.presentImageView.width;
    
    if (!self.presentImageView.image) {
        
        self.presentImageView.image = [UIImage imageNamed:KFJPhotoBrowserDefaultImage];
    }
    
    self.presentImageView.size = CGSizeMake(imageW, imageH);
    
    if (imageW < 0.5 || imageH < 0.5) {
        imageH = [[UIScreen mainScreen] bounds].size.height / 2.5;
        imageW = [[UIScreen mainScreen] bounds].size.width / 2.5;
    }
    CGFloat imageX = ([[UIScreen mainScreen] bounds].size.width/2.0) - (imageW/2.0);
    CGFloat imageY = ([[UIScreen mainScreen] bounds].size.height/2.0) - (imageH/2.0);
    
    self.presentImageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
}

// 获取 图片 大小
- (CGSize)presentImageViewSize {
    //ImageView.image的大小
    CGFloat   imageH;
    CGFloat   imageW;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (self.presentImageView.image) {
        //设置主图片
        imageW  = self.presentImageView.image.size.width;
        imageH = self.presentImageView.image.size.height;
        
        if (screenWidth < screenHeight) {
            CGFloat ratio = screenWidth / imageW;
            imageH = imageH*ratio;
            imageW = screenWidth;
        }
        else {
            CGFloat ratio = imageW / imageH;
            if (ratio > (screenHeight / screenWidth)) {
                
                if (imageH <= imageW/2) {
                    imageH = screenHeight - 80.0f;
                }
                else {
                    imageH = screenHeight;
                }
                imageW = imageH * ratio;
                if (imageW > screenWidth) {
                    imageW = screenWidth;
                }
            }
            else {
                imageH = imageH * (screenHeight / imageW);
                imageW = screenHeight;
            }
        }
    }
    else {
        imageH = screenHeight;
        imageW = screenWidth;
        self.presentImageView.image = [UIImage imageNamed:KFJPhotoBrowserDefaultImage];
    }
    return CGSizeMake(imageW, imageH);
}

// 微博 模式 直接 放大
-(void)directAmplifyPresentImageView {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.presentImageView.frame = CGRectMake(0, 0, [self presentImageViewSize].width, [self presentImageViewSize].height);
    self.scrollView.contentSize = self.presentImageView.frame.size;
    self.presentImageView.center = [self centerOfScrollViewContent:self.scrollView];
    
    CGFloat maxScale = screenHeight / self.presentImageView.height;
    maxScale = screenWidth / self.presentImageView.width > maxScale ? (screenWidth / self.presentImageView.width):maxScale;
    maxScale = maxScale > kFJPhotoBrowserCellZoomMaxScale? maxScale : kFJPhotoBrowserCellZoomMaxScale;
    
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.zoomScale = 1.0f;
    
    if (self.presentImageView.height > self.scrollView.height) {
        [self.presentImageView removeGestureRecognizer:self.panGesture];
    }
    else {
        [self.presentImageView addGestureRecognizer:self.panGesture];
    }
    
    /// 保存原始frame的中心坐标
    self.imageViewOriginalCenter = CGPointMake(screenWidth / 2.0, screenHeight / 2.0);
    
}

// 显示 直接 放大 图片 动画
- (void)directAmplifyImageViewWithVariable:(id)variable isFirstShowBrowser:(BOOL)isFirstShowBrowser {
    
    
    if (isFirstShowBrowser == NO) {
        [self directAmplifyPresentImageView];
        [self updatePresentImageViewWithVariable:variable];
    }
    else {
        
        [self.parentPhotosView setHorizontalScrolling:NO];
        [UIView animateWithDuration:kFJDefaultAnimationTime animations:^{
            
            [self directAmplifyPresentImageView];
            
        } completion:^(BOOL finished) {
            
            [self updatePresentImageViewWithVariable:variable];
        }];
    }

}

// 更新 大图
- (void)updatePresentImageViewWithVariable:(id)variable {
    
    self.scrollView.userInteractionEnabled = YES ;
    // 网络 图片
    if ([self isImageUrl:variable]) {
        
        [self showDownloadingProgerssWithImageUrl:(NSString *)variable isAnimation:NO];
    }
    // 本地 图片
    else {
        //变换完动画 从网络开始加载图
        self.presentImageView.image = [self localImage:variable];
        [self directAmplifyPresentImageView];//设置最新的网络下载后的图的frame大小
    }
}

// 判断 是否 为 网络 图片
- (BOOL)isImageUrl:(id)variable {
    BOOL isImageUrl = NO;
    // NSString 类型
    if ([variable isKindOfClass:[NSString class]]) {
        NSString *tmpStr = (NSString *)variable;
        isImageUrl = [self isHttpUrl:tmpStr];
        
    }
    return isImageUrl;
}


// 判断是否是 https
- (BOOL)isHttpUrl:(NSString *)httpUrl {
    BOOL isHttp = NO;
    if ([httpUrl containsString:@"http://"] || [httpUrl containsString:@"https://"]) {
        isHttp = YES;
    }
    return isHttp;
}

// 是否存在该图片
- (BOOL)isExitWithImageUrl:(NSString *)imageUrl {
    
    UIImage *exsitImage = [SDWebImageManager.sharedManager.imageCache imageFromDiskCacheForKey:[SDWebImageManager.sharedManager cacheKeyForURL:[NSURL URLWithString:imageUrl]]];
    if (exsitImage) {
        return YES;
    }
    return NO;
}


// 获取 本地 图片
- (UIImage *)localImage:(id)variable {
    UIImage *tmpImage = nil;
    if ([self isImageUrl:variable] == NO) {
        if ([variable isKindOfClass:[NSString class]]) {
            tmpImage = [UIImage imageNamed:(NSString *)variable];
            if (tmpImage == nil) {
                tmpImage =  [UIImage imageWithContentsOfFile:(NSString *)variable];
            }
        }
        else if([variable isKindOfClass:[UIImage class]]){
            tmpImage = (UIImage *)variable;
        }
    }
    if (tmpImage == nil) {
        tmpImage = [UIImage imageNamed:KFJPhotoBrowserDefaultImage];
    }
    return tmpImage;
}


// 保存 图片
- (void)saveImageToAlbum {
    
    UIImageWriteToSavedPhotosAlbum(self.presentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}


// 保存 图片 回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error == nil) {
        NSLog(@"图片保存成功");
    } else {
        NSLog(@"图片保存失败");
    }
}

// 恢复 原先 位置
- (void)restorePresentImageViewOriginalPosition {
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.zoomScale = 1.0;
        self.parentPhotosView.view.backgroundColor = [UIColor blackColor];
        self.presentImageView.center = self.imageViewOriginalCenter;
    } completion:^(BOOL finished) {
        [self showOriginImageView];
    }];
    
    [self.parentPhotosView setStatusBarHiddenStatus:YES];
}


// 获取占位图
- (UIImageView *)placeholderImageForIndex:(NSInteger)index {
    UIImageView *tmpImageView = nil;
    if ([self.parentPhotosView.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        tmpImageView = [self.parentPhotosView.photoBrowserDelegate photoBrowser:self.parentPhotosView placeholderImageForIndex:index];
    }
    else {
       tmpImageView =  self.photoModel.imageView;
    }
    return tmpImageView;
}



// 获取原图位置
- (CGRect)targetRectForIndex:(NSInteger)index {
    
    if ([self.parentPhotosView.photoBrowserDelegate respondsToSelector:@selector(photoBrowser:targetRectForIndex:)]) {
        return [self.parentPhotosView.photoBrowserDelegate photoBrowser:self.parentPhotosView targetRectForIndex:index];
    }
    else {
        // 获取 原图位置
        CGRect sourceRect;
        UIView *toCovertView = self.parentPhotosView.view;
        if (self.scrollView.contentSize.height > self.scrollView.height) {
            toCovertView = self.presentImageView;
        }
        float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (systemVersion >= 8.0 && systemVersion < 9.0) {
            sourceRect = [self.photoModel.imageView.superview convertRect:self.photoModel.imageView.frame toCoordinateSpace:toCovertView];
        } else {
            sourceRect = [self.photoModel.imageView.superview convertRect:self.photoModel.imageView.frame toView:toCovertView];
        }

        CGRect newOriginalRect = [self.photoModel.imageView.superview convertRect:self.photoModel.imageView.superview.bounds toView:self.parentPhotosView.view];
        
        if (newOriginalRect.origin.y > self.parentPhotosView.view.height) {
            sourceRect = CGRectZero;
        }
        
        return sourceRect;
    }
}

// 获取 scrollView center
- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}


// 恢复 竖直 屏幕
- (void)restoreScreenVerticalStatus {
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        [self changeDeviceOrientation:UIInterfaceOrientationPortrait];
    }
}

//手动设置设备方向，这样就能收到转屏事件
- (void)changeDeviceOrientation:(UIInterfaceOrientation)toOrientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
    {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = toOrientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark --- public method

// 设置所需的参数
- (void)setParamsWithPhotoModel:(FJImageModel *)photoModel currentIndex:(NSInteger)currentIndex photoViewShowType:(FJPhotoViewShowType)photoViewShowType isFirstShowBrowser:(BOOL)isFirstShowBrowser {
    
    self.photoModel = photoModel;
    self.currentIndex = currentIndex;
    
    self.scrollView.frame = self.bounds;
    self.presentImageView.frame = self.bounds;
    self.photoViewShowType = photoViewShowType;
    self.presentImageView.frame = [self targetRectForIndex:currentIndex];
    // 获取 占位图
    self.placeHoldImageView = [self placeholderImageForIndex:currentIndex];
    
    self.presentImageView.image = self.placeHoldImageView.image;
    
    // 放大 图片
    [self amplifyImageViewWithIsFirstShowBrowser:isFirstShowBrowser];
}


//  放大 图片
- (void)amplifyImageViewWithIsFirstShowBrowser:(BOOL)isFirstShowBrowser {
    // 微博 显示 方式 (直接放大)
    if (self.photoViewShowType == FJPhotoViewShowTypeOfWeiBo) {
        
        [self directAmplifyImageViewWithVariable:self.photoModel.imageInfo isFirstShowBrowser:isFirstShowBrowser];
    }
    
    // 微信 显示 方式 (加载完成后 放大)
    else if(self.photoViewShowType == FJPhotoViewShowTypeOfWeiXin && [self isImageUrl:self.photoModel.imageInfo]) {
        // 图片未下载 先显示在 中部
        NSString *tmpImageUrl = (NSString *)self.photoModel.imageInfo;
        
        if ([self isExitWithImageUrl:tmpImageUrl] == NO) {
            [UIView animateWithDuration:kFJDefaultAnimationTime animations:^{
                
                [self showPresentImageViewInMiddle];
                
            } completion:^(BOOL finished) {
                
                [self showDownloadingProgerssWithImageUrl:tmpImageUrl isAnimation:YES];
            }];
        }
        // 图片已下载 直接放大
        else {
            [self directAmplifyImageViewWithVariable:self.photoModel.imageInfo isFirstShowBrowser:isFirstShowBrowser];
        }
    }
}

// 依据 参数 设置 原视图
- (void)hiddenOriginImageView {
    
    self.photoModel.imageView.hidden = self.parentPhotosView.isHidesOriginal;
}

// 显示 原视图
- (void)showOriginImageView {
    self.photoModel.imageView.hidden = NO;
}


#pragma mark --- custom delegate

/************************ UIGestureRecognizer delegate ***************************/

// 让 scrollView 能够 同时 相应 拖动 和 左右滑动 两种手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

/************************ UIScrollView delegate ***************************/

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.presentImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    self.presentImageView.center = [self centerOfScrollViewContent:scrollView];
}

/************************ UIActionSheet delegate ***************************/

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self saveImageToAlbum];
    }
}


#pragma mark --- noti method

// 视频 旋转 通知
- (void)didChangeStatusBarOrientationNotification: (NSNotification*)notify {
    
    self.scrollView.frame = [UIScreen mainScreen].bounds;

    [self directAmplifyPresentImageView];
   
}


#pragma mark --- response event

// 拖曳 手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    // 非滚动图 和 非禁止pan手势
    if (self.parentPhotosView.isBanPanGesture == NO && self.presentImageView.height <= self.scrollView.height) {
        CGPoint location = [recognizer locationInView:self];
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            /// 记录初始点
            self.isScrollHorizontal = NO;
            self.panGestureBeginPoint = location;
        }
        
        else if (recognizer.state == UIGestureRecognizerStateChanged && [self.parentPhotosView isHorizontalScrolling] == NO) {
            
            CGFloat verticalMargin = location.y - self.panGestureBeginPoint.y;
            CGFloat horizontalMargin = location.x - self.panGestureBeginPoint.x;
            
            
            if (fabs(verticalMargin) < fabs(horizontalMargin) && self.isScrollHorizontal == NO) {
                self.isScrollHorizontal = YES;
                return;
            }
            // 上下 移动 禁止 左右 滑动 手势
            if ([self.parentPhotosView isPanGestureRecognizerEnable]) {
                [self.parentPhotosView setPanGestureRecognizerEnable:NO];
            }
            // 向下
            self.isPanGestureDirectionDown = verticalMargin;
            CGFloat height = self.bounds.size.height / 2.0;
            CGFloat zoomScale = 1 - (verticalMargin / height) * 0.6;
            if (zoomScale >= 1) {
                zoomScale = 1.0f;
            }else {
                [self.parentPhotosView setStatusBarHiddenStatus:NO];
            }
            [self hiddenOriginImageView];
            self.scrollView.zoomScale = zoomScale;
            self.parentPhotosView.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:zoomScale];
            self.presentImageView.center = CGPointMake(self.imageViewOriginalCenter.x + horizontalMargin, self.imageViewOriginalCenter.y + verticalMargin);
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded ) {
            
            if ([self.parentPhotosView isPanGestureRecognizerEnable] == NO) {
                [self.parentPhotosView setPanGestureRecognizerEnable:YES];
                /// 最后的手势不是向下，则将imageView还原到1.0比例，并移到原始中心点
                if (self.isPanGestureDirectionDown == NO) {
                    [self restorePresentImageViewOriginalPosition];
                }
                else {
                    if (self.scrollView.zoomScale > 0.6) {
                        [self restorePresentImageViewOriginalPosition];
                    }
                    else {
                        [self handleSingleTap:nil];
                    }
                }
            }
        }
    }
}


// 双击
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    
    //图片加载完之后才能响应双击放大
    if (!self.isLoadedImage) {
        return;
    }
    CGPoint touchPoint = [recognizer locationInView:self];
    if (self.scrollView.zoomScale <= 1.0) {
        //需要放大的图片的X点
        CGFloat scaleX = touchPoint.x + self.scrollView.contentOffset.x;
        //需要放大的图片的Y点
        CGFloat sacleY = touchPoint.y + self.scrollView.contentOffset.y;
        [self.scrollView zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
        
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES]; //还原
    }
}



// 单击
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.parentPhotosView setIsQuitCurrentView:YES];
    [self.parentPhotosView setStatusBarHiddenStatus:NO];
    
    CGRect originalRect = [self targetRectForIndex:_currentIndex];
    
    self.scrollView.userInteractionEnabled = NO;
    self.parentPhotosView.isShowPageControl = NO;
    
    if (self.scrollView.zoomScale > 1.0) {
        self.scrollView.zoomScale = 1.0f;
    }

    [UIView animateWithDuration:kFJDefaultAnimationTime animations:^{
        if (CGRectEqualToRect(originalRect, CGRectZero)) {
            self.alpha = 0;
        }else{
            self.presentImageView.frame = originalRect;
        }
        self.parentPhotosView.view.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self showOriginImageView];
        [self restoreScreenVerticalStatus];
        self.photoModel.imageView.hidden = NO;
        [self.presentImageView removeFromSuperview];
        [self.parentPhotosView dismissViewControllerAnimated:NO completion:nil];
    }];
    
}

// 长按
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片" otherButtonTitles:nil, nil];
        [actionSheet showInView:self];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.center = self.presentImageView.center;
}


#pragma mark --- getter method

// scrollView 用于缩放图片
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.maximumZoomScale = kFJPhotoBrowserCellZoomMaxScale;
        _scrollView.minimumZoomScale = kFJPhotoBrowserCellZoomMinScale;
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
    }
    return _scrollView;
}

// 当前 显示图片
- (UIImageView *)presentImageView {
    if (!_presentImageView) {
        _presentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [_presentImageView setContentMode:UIViewContentModeScaleAspectFill];
        _presentImageView.clipsToBounds = YES;
        _presentImageView.userInteractionEnabled = YES;
    }
    return _presentImageView;
}


// 下载 进度条
- (FJShapeCircleView *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [[FJShapeCircleView alloc] initWithFrame:CGRectMake(0 , 0, 40, 40)];
        _progressLayer.center = self.presentImageView.center;
        _progressLayer.hidden = YES;
    }
    return _progressLayer;
}

// 拖曳 手势
- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delaysTouchesEnded = NO;
        _panGesture.maximumNumberOfTouches = 1;
        _panGesture.delegate = self;
    }
    return _panGesture;
}


// doubleTapGesture 双击
- (UITapGestureRecognizer *)doubleTapGesture {
    
    if (!_doubleTapGesture) {
        _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapGesture.numberOfTapsRequired = 2;
        _doubleTapGesture.numberOfTouchesRequired  =1;
    }
    return _doubleTapGesture;
}


// singleTapGesture 单击
- (UITapGestureRecognizer *)singleTapGesture {
    
    if (!_singleTapGesture) {
        _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTapGesture.numberOfTapsRequired = 1;
        _singleTapGesture.numberOfTouchesRequired = 1;
        //只能有一个手势存在
        [_singleTapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
        
    }
    return _singleTapGesture;
}


// longPressGesture 长按
- (UILongPressGestureRecognizer *)longPressGesture {
    
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    }
    return _longPressGesture;
}

@end
