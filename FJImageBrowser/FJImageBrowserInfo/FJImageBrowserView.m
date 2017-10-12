//
//  FJImageBrowserView.m
//  FJImageBrowser
//
//  Created by fjf on 2017/5/18.
//  Copyright © 2017年 fjf. All rights reserved.
//


#import "FJImageModel.h"
#import "UIView+FJExtension.h"
#import "FJImageBrowserView.h"
#import "TMMuiLazyScrollView.h"
#import "FJImageBrowserPhotoView.h"
#import "UIViewController+FJCurrentViewController.h"


@interface FJImageBrowserView()<TMMuiLazyScrollViewDataSource, UIScrollViewDelegate>

// 是否 为 第一次 显示
@property (nonatomic, assign) BOOL isFirstShowBrowser;

// 页码 pageControl
@property (nonatomic, strong) UIPageControl *pageControl;

// 是否 正在 左右 滚动
@property (nonatomic, assign) BOOL isHorizontalScrolling;

// 是否 退出 当前 界面
@property (nonatomic, assign) BOOL isQuitCurrentView;

// 原先 状态栏 状态
@property (nonatomic, assign) BOOL isHiddenStatusBar;

// 浏览器 scrollView
@property (nonatomic, strong) TMMuiLazyScrollView *photoBrowserScrollView;
@end

@implementation FJImageBrowserView

#pragma mark --- life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupControls];
    
    [self addOrientationNotiObserver];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setStatusBarHiddenStatus:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self photoBrowserAppear];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}



#pragma mark --- private method
// 添加 屏幕 旋转 通知
- (void)addOrientationNotiObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

// 设置 子控件
- (void)setupControls {
    // 2. 添加 浏览器 collectionView
    [self.view addSubview:self.photoBrowserScrollView];
    // 3. 添加 页码 pageControl
    [self.view addSubview:self.pageControl];
    // 4. 设置 背景色
    self.view.backgroundColor = [UIColor blackColor];
    // 5. 状态栏 隐藏 状态
    self.isHiddenStatusBar = [UIApplication sharedApplication].isStatusBarHidden;
}




#pragma mark --- public method

// 显示 浏览器
- (void)showPhotoBrowser {
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:self animated:NO completion:nil];
}

//  呈现 浏览器
- (void)photoBrowserAppear {
    self.isQuitCurrentView = NO;
    self.isHorizontalScrolling = NO;
    self.pageControl.currentPage = self.selectedIndex;
    self.pageControl.numberOfPages = self.photoModeArray.count;
    self.isFirstShowBrowser = YES;
    [self.photoBrowserScrollView setContentOffset:CGPointMake(_selectedIndex* self.photoBrowserScrollView.frame.size.width, 0) animated:NO];
    [self.photoBrowserScrollView reloadData];
    self.isFirstShowBrowser = NO;
    
}


// 判断 是否 左右 滚动
- (BOOL)isHorizontalScrolling {
    return _isHorizontalScrolling;
}


// 浏览器 拖曳 手势
- (BOOL)isPanGestureRecognizerEnable {
    
    return self.photoBrowserScrollView.panGestureRecognizer.enabled;
}

// 是否 退出 当前 界面
- (void)setIsQuitCurrentView:(BOOL)isQuitCurrentView {
    _isQuitCurrentView = isQuitCurrentView;
}

// 设置 浏览器 拖曳 手势
- (void)setPanGestureRecognizerEnable:(BOOL)isEnable {
    
    self.photoBrowserScrollView.panGestureRecognizer.enabled = isEnable;
}

// 浏览器 拖曳 手势
- (UIPanGestureRecognizer *)panGestureRecognizer {
    
    return self.photoBrowserScrollView.panGestureRecognizer;
}

// 设置 左右 是否 正在 滚动
- (void)setHorizontalScrolling:(BOOL)isScrolling {
    self.isHorizontalScrolling = isScrolling;
}

// 设置 状态栏 属性
- (void)setStatusBarHiddenStatus:(BOOL)statusBarHiddenStatus {
    if (statusBarHiddenStatus) {
        [[UIApplication sharedApplication] setStatusBarHidden:statusBarHiddenStatus withAnimation:UIStatusBarAnimationFade];
    }
    else {
        [UIApplication sharedApplication].statusBarHidden = self.isHiddenStatusBar;
    }
}


#pragma mark --- custom delegate


/************************** UICollectionView Delegate *****************************/

- (NSUInteger)numberOfItemInScrollView:(TMMuiLazyScrollView *)scrollView
{

    return self.photoModeArray.count;
}

- (TMMuiRectModel *)scrollView:(TMMuiLazyScrollView *)scrollView rectModelAtIndex:(NSUInteger)index
{
    TMMuiRectModel *rectModel = [[TMMuiRectModel alloc]init];
    rectModel.absoluteRect = CGRectMake(index * self.photoBrowserScrollView.width, 0, self.photoBrowserScrollView.width, self.view.frame.size.height);
    rectModel.muiID = [NSString stringWithFormat:@"%ld",index];
    return rectModel;
}


- (nullable UIView *)scrollView:(nonnull TMMuiLazyScrollView *)scrollView itemByMuiID:(nonnull NSString *)muiID;
{
   
    FJImageBrowserPhotoView *cell = (FJImageBrowserPhotoView *)[scrollView dequeueReusableItemWithIdentifier:@"FJImageBrowserPhotoView"];
    NSInteger index = [muiID integerValue];
    if (!cell) {
        cell = [[FJImageBrowserPhotoView alloc] init];

    }
    cell.frame = CGRectMake(index * self.photoBrowserScrollView.width, 0, self.view.width, self.view.frame.size.height);
    

    cell.parentPhotosView = self;
    [cell setParamsWithPhotoModel:self.photoModeArray[index] currentIndex:index photoViewShowType:self.photoBrowserType isFirstShowBrowser:self.isFirstShowBrowser];
    
    
    [scrollView addSubview:cell];
    
    return cell;
}


/************************** UIScrollView Delegate *****************************/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.isHorizontalScrolling = YES;
    NSInteger index = (NSInteger)roundf(scrollView.contentOffset.x / self.photoBrowserScrollView.width);
    self.pageControl.currentPage = index;

}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    self.isHorizontalScrolling = NO;
}


#pragma mark --- noti method


// 屏幕 旋转 通知
- (void)didChangeStatusBarOrientationNotification: (NSNotification*)notify {

    self.isHorizontalScrolling = NO;
    CGFloat itemSizeHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat itemSizeWidth = [UIScreen mainScreen].bounds.size.width;

    //收到的消息是上一个InterfaceOrientation的值
    UIInterfaceOrientation currInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    //计算旋转角度
    CGFloat tmpAngle = -M_PI_2;
    if (currInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        tmpAngle = M_PI_2;
    }
    else if(currInterfaceOrientation == UIInterfaceOrientationPortrait) {
        tmpAngle = 0;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(tmpAngle);
    [[UIViewController fj_navigationTopViewController].tabBarController.view setTransform:transform];
    [UIViewController fj_navigationTopViewController].tabBarController.view.frame = CGRectMake(0, 0, itemSizeWidth, itemSizeHeight);
    

    CGFloat currentPageIndex = self.pageControl.currentPage;
    self.photoBrowserScrollView.frame = CGRectMake(0, 0, itemSizeWidth+ [self getCellSpacing], itemSizeHeight);
    self.photoBrowserScrollView.contentSize = CGSizeMake(self.photoBrowserScrollView.width * self.photoModeArray.count, self.view.frame.size.height);
    self.pageControl.frame = CGRectMake(0, itemSizeHeight -40, itemSizeWidth, 40);
    [self.photoBrowserScrollView setContentOffset:CGPointMake(currentPageIndex* self.photoBrowserScrollView.frame.size.width, 0) animated:NO];
    
    [self.photoBrowserScrollView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isHorizontalScrolling = NO;
    });
}



#pragma mark --- response event

// 页码 点击 事件
- (void)handlePageControlTapAction {
    [self.photoBrowserScrollView setContentOffset:CGPointMake(self.pageControl.currentPage * self.photoBrowserScrollView.bounds.size.width, 0) animated:YES];
}


#pragma mark --- setter method

// 图片 数据 数组
- (void)setPhotoDataArray:(NSArray *)photoDataArray {
    _photoDataArray = photoDataArray;
    if (_photoDataArray.count > 0) {
        self.photoModeArray = [NSMutableArray array];
        [_photoDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FJImageModel *photoModel = [[FJImageModel alloc] init];
            photoModel.imageInfo = obj;
            [self.photoModeArray addObject:photoModel];
        }];
        self.photoBrowserScrollView.contentSize = CGSizeMake(self.photoBrowserScrollView.width * self.photoModeArray.count, self.view.frame.size.height);
    }
}

// 视图 模型 数据源
- (void)setPhotoModeArray:(NSMutableArray<FJImageModel *> *)photoModeArray {
    _photoModeArray = photoModeArray;
    if (_photoModeArray.count > 0) {
        self.photoBrowserScrollView.contentSize = CGSizeMake(self.photoBrowserScrollView.width * _photoModeArray.count, self.view.frame.size.height);
    }
}
// 设置 是否 显示 页码
- (void)setIsShowPageControl:(BOOL)isShowPageControl {
    self.pageControl.hidden = !isShowPageControl;
}

#pragma mark --- getter method

// 获取 cell 间隔
- (CGFloat)getCellSpacing {
    return kFJPhotoBrowserCellHorizotolSpacing;
}


// 页码 pageControl
- (UIPageControl *)pageControl {
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.numberOfPages = 1;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height -40, [[UIScreen mainScreen] bounds].size.width, 40);
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.pageIndicatorTintColor = kFJPageControlIndicatorTintColor;
        _pageControl.currentPageIndicatorTintColor = kFJPageControlCurrentPageIndicatorTintColor;
        _pageControl.userInteractionEnabled = YES;
        [_pageControl addTarget:self action:@selector(handlePageControlTapAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pageControl;
}


// 浏览器 scrollView
- (TMMuiLazyScrollView *)photoBrowserScrollView {
    if (!_photoBrowserScrollView) {
        _photoBrowserScrollView = [[TMMuiLazyScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width + [self getCellSpacing], [[UIScreen mainScreen] bounds].size.height)];
        _photoBrowserScrollView.pagingEnabled = YES;
        _photoBrowserScrollView.showsVerticalScrollIndicator = NO;
        _photoBrowserScrollView.showsHorizontalScrollIndicator = NO;
        _photoBrowserScrollView.dataSource = self;
        _photoBrowserScrollView.delegate = self;
    }
    return _photoBrowserScrollView;
}


/**
 用KVC取statusBar
 
 @return statusBar
 */
- (UIView *)statusBar {

    return [[UIApplication sharedApplication] valueForKey:@"statusBar"];
}

/**
 遍历取window
 
 @return keyWindow
 */
- (UIWindow *)jk_keyWindow {
    NSArray * windows = [UIApplication sharedApplication].windows;
    for (id window in windows) {
        if ([window isKindOfClass:[UIWindow class]]) {
            if (((UIWindow *)window).hidden == NO) {
                return (UIWindow *)window;
            }
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}


#pragma mark --- dealloc method
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
