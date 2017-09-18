//
//  ViewController.m
//  FJImageBrowser
//
//  Created by fjf on 16/6/25.
//  Copyright © 2016年 fjf. All rights reserved.
//


#import "FJImageBrowser.h"
#import "ViewController.h"
#import "UIView+Extension.h"
#import "UIImageView+WebCache.h"
#import "FJCollectionImageViewCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,FJImageBrowserViewDelegate>
// 大图数组
@property (nonatomic, strong)   NSArray *bigImageArray;
// 小图数组
@property (nonatomic, strong)   NSArray *smallImageArray;
// 清理缓存按键
@property (nonatomic, strong)   UIButton *clearCacheBtn;
// 切换模式按键
@property (nonatomic, strong)   UIButton *switchShowBtn;
// 图片模型 数组
@property (nonatomic, strong)   NSMutableArray * imageModels;
// collectionView
@property (nonatomic, strong)   UICollectionView *collectionView;
@end

@implementation ViewController

#pragma mark --- life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置 导航栏
    [self initNavigationBar];
    
    self.imageModels = [NSMutableArray array];
    
    // *************************绑定JKPhotoModel*********************************
    
    [self.bigImageArray enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger idx, BOOL * _Nonnull stop) {
        
        FJImageModel * photoModel = [[FJImageModel alloc] init];
        photoModel.imageInfo = imageUrl;
        [self.imageModels addObject:photoModel];
    }];

    
    // 清理 缓存 按键
    [self.view addSubview:self.clearCacheBtn];
    
    // 显示 模式 切换
    [self.view addSubview:self.switchShowBtn];
    
    // UICollectionView
    [self.view addSubview:self.collectionView];
    
}

#pragma mark --- private method

// 初始化导航栏
- (void)initNavigationBar{
    self.title = @"UICollectionView";
}


#pragma mark --- event response
- (void)clearCache:(UIButton *)sender {
    [[SDImageCache sharedImageCache]clearMemory];
    [[SDImageCache sharedImageCache]clearDiskOnCompletion:^{
        [_collectionView reloadData];
    }];
}

// 切换 显示 模式
- (void)switchPhotoShowType:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setTitle:@"微信模式" forState:UIControlStateNormal];
    }else {
        [sender setTitle:@"微博模式" forState:UIControlStateNormal];
        
    }
}

#pragma mark --- custom delegate

/************************************* UICollectionViewDelegate ***************************************/

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.smallImageArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FJCollectionImageViewCell *cell = [FJCollectionImageViewCell cellWithCollectionView:collectionView atIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.smallImageArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"default_avatar_geren_134.png"]];
    
    // *************************绑定cell和imageView*********************************
    
    FJImageModel * photoModel = self.imageModels[indexPath.row];
    photoModel.imageView = cell.imageView;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FJImageBrowserView *photosView = [[FJImageBrowserView alloc] init];
    photosView.photoBrowserType = self.switchShowBtn.selected;
    photosView.photoModeArray = self.imageModels;
    photosView.selectedIndex = indexPath.row;
    photosView.isHidesOriginal = YES;
    [photosView showPhotoBrowser];
}



#pragma mark --- getter method
// 清空缓存 按键
- (UIButton *)clearCacheBtn {
    if (!_clearCacheBtn) {
        
        _clearCacheBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _clearCacheBtn.frame = CGRectMake(10, 70, 100, 45);
        _clearCacheBtn.backgroundColor = [UIColor blackColor];
        [_clearCacheBtn addTarget:self action:@selector(clearCache:) forControlEvents:UIControlEventTouchUpInside];
        [_clearCacheBtn setTitle:@"清空缓存" forState:UIControlStateNormal];
    }
    return _clearCacheBtn;
}

// 切换显示模式
- (UIButton *)switchShowBtn {
    if (!_switchShowBtn) {
        
        _switchShowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchShowBtn.frame = CGRectMake(CGRectGetMaxX(_clearCacheBtn.frame) + 50, 70, 100, 45);
        _switchShowBtn.backgroundColor = [UIColor blackColor];
        [_switchShowBtn addTarget:self action:@selector(switchPhotoShowType:) forControlEvents:UIControlEventTouchUpInside];
        [_switchShowBtn setTitle:@"微博模式" forState:UIControlStateNormal];
    }
    return _switchShowBtn;
}

// collectionView
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.sectionInset = UIEdgeInsetsMake(3, 6, 3, 6);
        flowLayout.itemSize = CGSizeMake(FJ_COLLECTION_IMAGE_VIEW_WIDTH, FJ_COLLECTION_IMAGE_VIEW_HEIGHT);
        flowLayout.minimumLineSpacing = FJ_COLLECTION_IMAGE_VIEW_CELL_SPACING;
        flowLayout.minimumInteritemSpacing = 3;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, self.clearCacheBtn.bottom + 15, [UIScreen mainScreen].bounds.size.width, [[UIScreen mainScreen] bounds].size.height - self.clearCacheBtn.bottom - 65.0f) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        //cell注册
        [_collectionView registerNib:[UINib nibWithNibName:@"FJCollectionImageViewCell" bundle:nil] forCellWithReuseIdentifier:kFJCollectionImageViewCellId];
    }
    return _collectionView;
}

// 小图数组
- (NSArray *)smallImageArray {
    if (!_smallImageArray) {
        _smallImageArray = @[@"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg",
                             @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/5143FDE23D34A31DBB7C1D40C49C88F3dpMomentThumbImageName1.png?imageView2/1/w/163/h/107",
                             @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/703419A3ADBF064B21473EB5EF117D41dpMomentThumbImageName2.png?imageView2/1/w/163/h/121",
                             @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/74B92B777F9CF8F2C7C64393A14FF681dpMomentThumbImageName3.png?imageView2/1/w/163/h/116",
                             @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/4E7C8C0AF66D4F6F8811FBB5832C3780dpMomentThumbImageName4.png?imageView2/1/w/163/h/108",
                             @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/5A6884F666D7A7EDFCA85E65303004DDdpMomentThumbImageName5.png?imageView2/1/w/163/h/108",
                             @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/81C79FC2446D297A6728F3CAA06F693FdpMomentThumbImageName6.png?imageView2/1/w/163/h/79",
                             @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/3CF39EFE8ABAB75554471159C239E1B7dpMomentThumbImageName7.png?imageView2/1/w/163/h/122",
                             @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/98B0BB13A85FE520CFC3039368C036E3dpMomentThumbImageName8.png?imageView2/1/w/163/h/122",
                             @"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg",
                             @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1f01hkxyjhej20u00jzacj.jpg",
                             @"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f01hhs2omoj20u00jzwh9.jpg",
                             @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1ey1oyiyut7j20u00mi0vb.jpg",
                             @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1exkkw984e3j20u00miacm.jpg",
                             @"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1ezvdc5dt1pj20ku0kujt7.jpg",
                             @"http://ww3.sinaimg.cn/bmiddle/a15bd3a5jw1ew68tajal7j20u011iacr.jpg",
                             @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1eupveeuzajj20hs0hs75d.jpg",
                             @"http://ww2.sinaimg.cn/bmiddle/d8937438gw1fb69b0hf5fj20hu13fjxj.jpg"];
    }
    return _smallImageArray;
}

// 大图数组
- (NSArray *)bigImageArray {
    if (!_bigImageArray) {
        _bigImageArray = @[
                           @"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg",
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/5143FDE23D34A31DBB7C1D40C49C88F3dpMomentThumbImageName1.png?w=1280&h=848",
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/703419A3ADBF064B21473EB5EF117D41dpMomentThumbImageName2.png?w=1280&h=953",
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/74B92B777F9CF8F2C7C64393A14FF681dpMomentThumbImageName3.png?w=1280&h=911",
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/4E7C8C0AF66D4F6F8811FBB5832C3780dpMomentThumbImageName4.png?w=1280&h=854",
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/5A6884F666D7A7EDFCA85E65303004DDdpMomentThumbImageName5.png?w=1280&h=854",
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/81C79FC2446D297A6728F3CAA06F693FdpMomentThumbImageName6.png?w=1024&h=494",
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/3CF39EFE8ABAB75554471159C239E1B7dpMomentThumbImageName7.png?w=1280&h=960",
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/98B0BB13A85FE520CFC3039368C036E3dpMomentThumbImageName8.png?w=1280&h=960",
                           @"http://ww4.sinaimg.cn/bmiddle/677febf5gw1erma1g5xd0j20k0esa7wj.jpg",
                           @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1f01hkxyjhej20u00jzacj.jpg",
                           @"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1f01hhs2omoj20u00jzwh9.jpg",
                           @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1ey1oyiyut7j20u00mi0vb.jpg",
                           @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1exkkw984e3j20u00miacm.jpg",
                           @"http://ww4.sinaimg.cn/bmiddle/a15bd3a5jw1ezvdc5dt1pj20ku0kujt7.jpg",
                           @"http://ww3.sinaimg.cn/bmiddle/a15bd3a5jw1ew68tajal7j20u011iacr.jpg",
                           @"http://ww2.sinaimg.cn/bmiddle/a15bd3a5jw1eupveeuzajj20hs0hs75d.jpg",
                           @"http://ww2.sinaimg.cn/bmiddle/d8937438gw1fb69b0hf5fj20hu13fjxj.jpg"];
    }
    return _bigImageArray;
}

@end
