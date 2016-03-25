//
//  ListsCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/16.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_ListsCell @"ListsCell"

#import <UIKit/UIKit.h>

@interface ListsCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;

- (void)setImageStr:(NSString *)imgStr andTitle:(NSString *)title;

+ (CGFloat)cellHeight;

@end
