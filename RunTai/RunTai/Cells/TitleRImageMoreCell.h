//
//  TitleRImageMoreCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//
#define kCellIdentifier_TitleRImageMore @"TitleRImageMoreCell"

#import <UIKit/UIKit.h>
@class User;
@interface TitleRImageMoreCell : UITableViewCell

@property (strong, nonatomic) User *curUser;

+ (CGFloat)cellHeight;
@end