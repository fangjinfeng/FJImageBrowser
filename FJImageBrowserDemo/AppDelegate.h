//
//  AppDelegate.h
//  FJImageBrowserDemo
//
//  Created by fjf on 2017/9/18.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FJViewControllerRotateType) {
    FJViewControllerRotateTypeOfDefault,
    FJViewControllerRotateTypeOfAll,
    FJViewControllerRotateTypeOfPortrait,
    FJViewControllerRotateTypeOfPortraitAndLandscape,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,assign) FJViewControllerRotateType viewControllerRotateType;
@end

