//
//  AppDelegate+InterfaceOrientations.m
//  fjTestProject
//
//  Created by fjf on 2017/9/13.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import <objc/runtime.h>
#import "AppDelegate+InterfaceOrientations.h"

static int FJViewControllerRotateTypeKey;

@implementation AppDelegate (InterfaceOrientations)

+ (void)load {
    //只执行一次这个方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *tmpRemoveStr = @"application:supportedInterfaceOrientationsForWindow:";
        NSString *tmpSafeRemoveStr = @"aop_application:supportedInterfaceOrientationsForWindow:";
        
        [self exchangeImplementationWithClassStr:@"AppDelegate" originalMethodStr:tmpRemoveStr newMethodStr:tmpSafeRemoveStr];
    });
    
}

// 获取 method
+ (Method)methodOfClassStr:(NSString *)classStr selector:(SEL)selector {
    return class_getInstanceMethod(NSClassFromString(classStr),selector);
}

// 添加 新方法 / 新方法 替换 原来 方法
+ (void)exchangeImplementationWithClassStr:(NSString *)classStr originalMethodStr:(NSString *)originalMethodStr newMethodStr:(NSString *)newMethodStr {
    
    SEL originalSelector = NSSelectorFromString(originalMethodStr);
    SEL swizzledSelector = NSSelectorFromString(newMethodStr);
    
    Method originalMethod = [AppDelegate methodOfClassStr:classStr selector:NSSelectorFromString(originalMethodStr)];
    Method swizzledMethod = [AppDelegate methodOfClassStr:classStr selector:NSSelectorFromString(newMethodStr)];
    
    BOOL didAddMethod =
    class_addMethod(NSClassFromString(classStr),
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(NSClassFromString(classStr),
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark --- implement method


- (UIInterfaceOrientationMask)aop_application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {

    switch (self.viewControllerRotateType) {
        case FJViewControllerRotateTypeOfPortrait:
            return UIInterfaceOrientationMaskPortrait;
            break;
        case FJViewControllerRotateTypeOfPortraitAndLandscape:
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
            break;
        case FJViewControllerRotateTypeOfAll:
            return UIInterfaceOrientationMaskAll;
            break;
            
        default:
            break;
    }
     return UIInterfaceOrientationMaskPortrait;
}

#pragma mark --- setter method

- (void)setViewControllerRotateType:(FJViewControllerRotateType)viewControllerRotateType {
    objc_setAssociatedObject(self, &FJViewControllerRotateTypeKey, [NSNumber numberWithInt:viewControllerRotateType], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark --- getter method
- (FJViewControllerRotateType)viewControllerRotateType {
    NSNumber *rotateTypeNum = objc_getAssociatedObject(self, &FJViewControllerRotateTypeKey);
    return rotateTypeNum.integerValue;
}
@end
