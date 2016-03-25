//
//  UserInfoTextCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/22.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_UserInfoTextCell @"UserInfoTextCell"

#import <UIKit/UIKit.h>

@interface UserInfoTextCell : UITableViewCell

- (void)setTitle:(NSString *)title value:(NSString *)value;
+ (CGFloat)cellHeight;
@end
