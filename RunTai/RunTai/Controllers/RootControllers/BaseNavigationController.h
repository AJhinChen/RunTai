//
//  BaseNavigationController.h
//  Coding_iOS
//
//  Created by Ease on 15/2/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PushTransitionAnimation.h"
#import "PopTransitionAnimation.h"
#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, InteractivePopGestureRecognizerType) {
    InteractivePopGestureRecognizerNone, //没有返回手势
    InteractivePopGestureRecognizerEdge, //边缘返回手势
    InteractivePopGestureRecognizerFullScreen //全屏返回手势
};

@interface BaseNavigationController : UINavigationController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *percentDrivenInteractiveTransition;

//选择返回手势方式（边缘触发/全屏触发）
@property (nonatomic, assign) InteractivePopGestureRecognizerType interactivePopGestureRecognizerType;

@end
