//
//  NotesCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

#define kCellIdentifier_Notes @"NotesCell"

@interface NotesCell : UITableViewCell

@property (nonatomic, strong) Project *curPro;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

+ (CGFloat)cellHeight;

@end
