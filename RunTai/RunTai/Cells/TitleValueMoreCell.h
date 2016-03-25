//
//  TitleValueMoreCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_TitleValueMore @"TitleValueMoreCell"
#define kCellIdentifier_TitleValue @"TitleValue"

#import <UIKit/UIKit.h>

@interface TitleValueMoreCell : UITableViewCell
- (void)setTitleStr:(NSString *)title valueStr:(NSString *)value;
+ (CGFloat)cellHeight;
@end
