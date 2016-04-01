//
//  CaseImageCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/30.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_CaseImageCell @"CaseImageCell"

#import <UIKit/UIKit.h>
#import "Case.h"

@interface CaseImageCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

+ (CGFloat)cellHeight;

@property (strong, nonatomic) Case *curCase;

@end
