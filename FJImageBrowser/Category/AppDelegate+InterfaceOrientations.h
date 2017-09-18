//
//  AppDelegate+InterfaceOrientations.h
//  fjTestProject
//
//  Created by fjf on 2017/9/13.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import "AppDelegate.h"


typedef NS_ENUM(NSInteger, FJViewControllerRotateType) {
    FJViewControllerRotateTypeOfPortrait = 0,
    FJViewControllerRotateTypeOfPortraitAndLandscape,
    FJViewControllerRotateTypeOfAll,
};


@interface AppDelegate (InterfaceOrientations)
// viewController rotate tyep
@property (nonatomic,assign) FJViewControllerRotateType viewControllerRotateType;
@end
