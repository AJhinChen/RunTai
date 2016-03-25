//
//  UserInfoCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/17.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_UserInfoCell @"UserInfoCell"

#import <UIKit/UIKit.h>
@class User;
@interface UserInfoCell : UITableViewCell

@property (strong, nonatomic) User *curUser;

@property (strong, nonatomic) UIButton *loginBtn;

@property (nonatomic,copy) void(^loginBtnClckedBlock)(UIButton *btn);

+ (CGFloat)cellHeight;

@end
