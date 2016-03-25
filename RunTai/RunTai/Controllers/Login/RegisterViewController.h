//
//  RegisterViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/3/14.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, RegisterMethodType) {
    RegisterMethodLogin = 0,
    RegisterMethodOrder
};

@interface RegisterViewController : BaseViewController

@property (assign, nonatomic) RegisterMethodType methodType;

@end
