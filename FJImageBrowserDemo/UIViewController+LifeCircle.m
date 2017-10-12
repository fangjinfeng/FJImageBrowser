//
//  UIViewController+LifeCircle.m
//  FJImageBrowserDemo
//
//  Created by fjf on 2017/10/12.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>
#import "FJImageBrowser.h"
#import "UIViewController+LifeCircle.h"

@implementation UIViewController (LifeCircle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(xxx_viewWillAppear:);
        
        SEL originalSecondSelector = @selector(viewWillDisappear:);
        SEL swizzledSecondSelector = @selector(xxx_viewWillDisappear:);
        
        [self exchangeInstanceMethodWithSelfClass:class originalSelector:originalSelector swizzledSelector:swizzledSelector];
        [self exchangeInstanceMethodWithSelfClass:class originalSelector:originalSecondSelector swizzledSelector:swizzledSecondSelector];
    });
}


+ (void)exchangeInstanceMethodWithSelfClass:(Class)selfClass
                           originalSelector:(SEL)originalSelector
                           swizzledSelector:(SEL)swizzledSelector {
    
    Method originalMethod = class_getInstanceMethod(selfClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(selfClass, swizzledSelector);
    BOOL didAddMethod = class_addMethod(selfClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(selfClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#pragma mark - Method Swizzling

- (void)xxx_viewWillAppear:(BOOL)animated {
    
    if ([self conformsToProtocol:@protocol(FJViewControllerRotateProtocol)]) {
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.viewControllerRotateType = FJViewControllerRotateTypeOfPortraitAndLandscape;
    }
    NSLog(@"viewWillAppear: %@", self);
    [self xxx_viewWillAppear:animated];
}

- (void)xxx_viewWillDisappear:(BOOL)animated {
    if ([self conformsToProtocol:@protocol(FJViewControllerRotateProtocol)]) {
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.viewControllerRotateType = FJViewControllerRotateTypeOfPortrait;
    }
    [self xxx_viewWillDisappear:animated];
}
@end
