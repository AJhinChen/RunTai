//
//  CannotLoginViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, CannotLoginMethodType) {
    CannotLoginMethodLogin = 0,
    CannotLoginMethodSetting
};

@interface CannotLoginViewController : BaseViewController

@property (assign, nonatomic) CannotLoginMethodType methodType;

@end
