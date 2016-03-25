//
//  DirectorCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/16.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_Director @"DirectorCell"

@interface DirectorCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tablView;

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle value:(NSString *)value;

+ (CGFloat)cellHeight;

@end
