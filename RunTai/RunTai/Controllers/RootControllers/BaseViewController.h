//
//  BaseViewController.h
//  WeiBo
//
//  Created by Joel Chen on 16/1/26.
//  Copyright © 2016年 Joel Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

+ (UIViewController *)presentingVC;
+ (void)presentVC:(UIViewController *)viewController;

@end
