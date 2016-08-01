//
//  SettingIconViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BaseViewController.h"
@class User;
@interface SettingIconViewController : BaseViewController

@property (strong, nonatomic) User *curUser;

@property (copy, nonatomic) void(^doneBlock)(NSString *url);

@end
