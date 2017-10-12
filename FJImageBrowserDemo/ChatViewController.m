//
//  ChatViewController.m
//  JKPhotoBrowser
//
//  Created by 蒋鹏 on 17/2/20.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import "FJImageModel.h"
#import "UIView+FJExtension.h"
#import "FJImageBrowserView.h"
#import "ChatViewController.h"
#import "ChatTableViewCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, FJImageBrowserViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *bigImageArray;

@end

@implementation ChatViewController

#pragma mark --- life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupControls];

}



#pragma mark --- private mthod

// 设置 子控件
- (void)setupControls {
    self.title = @"UITableView";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    [self.view addSubview:self.tableView];
}



#pragma mark --- system delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bigImageArray.count;
}


NSString * const JKChatCellKey = @"JKChatCellKey";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JKChatCellKey];
    if (cell == nil) {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JKChatCellKey];
    }
    [cell configueCellWithImageUrl:self.bigImageArray[indexPath.row] indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 200 + 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FJImageBrowserView *photosView = [[FJImageBrowserView alloc] init];
    photosView.photoDataArray = self.bigImageArray;
    photosView.selectedIndex = indexPath.row;
    photosView.photoBrowserDelegate = self;
    [photosView showPhotoBrowser];

}


/************************************* PhotosViewDelegate ***************************************/
// 返回图片占位小图
- (UIImageView *)photoBrowser:(FJImageBrowserView *)browser placeholderImageForIndex:(NSInteger)index {
    ChatTableViewCell *cell = (ChatTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.imgView;
}

// 返回原图片位置
- (CGRect)photoBrowser:(FJImageBrowserView *)browser targetRectForIndex:(NSInteger)index {
    
    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
     ChatTableViewCell *cell = (ChatTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:tmpIndexPath];
      CGRect newImageViewFrame = [cell.imgView convertRect:cell.imgView.bounds toView:self.view];
    
    // 先计算cell的位置,再转化到view中的位置.
    CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:tmpIndexPath];
    
    CGRect rectInSuperView = [self.tableView convertRect:rectInTableView toView:[UIApplication sharedApplication].keyWindow];
    newImageViewFrame.origin = CGPointMake(newImageViewFrame.origin.x, rectInSuperView.origin.y + 10);

    if (newImageViewFrame.origin.y > self.view.height) {
        newImageViewFrame = CGRectZero;
    }
    return newImageViewFrame;
}


#pragma mark --- getter method

// tableView
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 49.0f - 64.0f) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:JKChatCellKey];

    }
    return _tableView;
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
                           @"http://7xqyre.com2.z0.glb.qiniucdn.com/images/98B0BB13A85FE520CFC3039368C036E3dpMomentThumbImageName8.png?w=1280&h=960"];
    }
    return _bigImageArray;
}


@end
