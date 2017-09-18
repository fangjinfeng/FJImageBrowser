
//
//  FJShapeCircleView.m
//  FJBezierPathDemo
//
//  Created by fjf on 2017/6/2.
//  Copyright © 2017年 fjf. All rights reserved.
//

#import "FJShapeCircleView.h"

// 设置 十六 进制 RGB 颜色 和 透明度
#define kColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]


@interface FJShapeCircleView()

@property (nonatomic, strong) UIBezierPath *trackPath;

@property (nonatomic, strong) CAShapeLayer *trackLayer;

@property (nonatomic, strong) UIBezierPath *progressPath;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

@implementation FJShapeCircleView

#pragma mark --- init method

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 外圆
        self.trackPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:15 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        
        self.trackLayer = [CAShapeLayer new];
        self.trackLayer.fillColor = [UIColor clearColor].CGColor;
        self.trackLayer.strokeColor = kColorFromRGBA(0x000000, 0.7).CGColor;
        self.trackLayer.path = self.trackPath.CGPath;
        self.trackLayer.lineWidth = 4.0;
        self.trackLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:self.trackLayer];
        
        
        // 内圆
        self.progressPath = [UIBezierPath bezierPathWithArcCenter:self.center radius:15 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        self.progressPath.lineCapStyle = kCGLineCapRound;
        self.progressLayer = [CAShapeLayer new];
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.progressLayer.path = self.progressPath.CGPath;
        self.progressLayer.lineWidth = 3.0f;
        self.progressLayer.lineCap = kCALineCapRound;
        self.progressLayer.strokeStart = 0;
        self.progressLayer.strokeEnd = 0.40;
        self.progressLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self.layer addSublayer:self.progressLayer];
        [self startLoading:self.progressLayer];
        
        
    }
    return self;
}

#pragma mark --- private method

// 动画
- (void)startLoading:(CAShapeLayer *)rotateView{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2.0);
    rotationAnimation.duration = 0.7f;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [rotateView addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
}

@end
