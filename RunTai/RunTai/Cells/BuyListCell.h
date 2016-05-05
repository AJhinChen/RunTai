//
//  BuyListCell.h
//  RunTai
//
//  Created by Joel Chen on 16/4/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_BuyList @"BuyListCell"

@interface BuyListCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tablView;

- (void)setTitle:(NSString *)title subtitle:(NSArray *)subtitle value:(NSString *)value;

+ (CGFloat)cellHeight;

@end
