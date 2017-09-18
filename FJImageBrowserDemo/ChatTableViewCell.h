//
//  ChatTableViewCell.h
//  JKPhotoBrowser
//
//  Created by 蒋鹏 on 17/2/20.
//  Copyright © 2017年 溪枫狼. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTableViewCell : UITableViewCell

@property (nonatomic, weak, readonly) UIImageView * imgView;

- (void)configueCellWithImageUrl:(NSString *)imageUrl indexPath:(NSIndexPath *)indexPath ;

@end
