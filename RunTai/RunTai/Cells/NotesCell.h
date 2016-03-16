//
//  NotesCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCellIdentifier_Notes @"NotesCell"


@interface NotesCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tablView;

+ (CGFloat)cellHeight;

@end
