//
//  UserInfoIconCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/22.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_UserInfoIconCell @"UserInfoIconCell"

#import <UIKit/UIKit.h>

@interface UserInfoIconCell : UITableViewCell
- (void)setTitle:(NSString *)title icon:(NSString *)iconName;
+ (CGFloat)cellHeight;
@end
