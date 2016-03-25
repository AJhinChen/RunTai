//
//  UserDescriptionCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/17.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_UserDescriptionCell @"UserDescriptionCell"

#import <UIKit/UIKit.h>

@interface UserDescriptionCell : UITableViewCell

@property (nonatomic,copy) NSString *descriptionStr;

- (void)setDescriptionStr:(NSString *)descriptionStr;

//+ (CGFloat)cellHeightWithObj:(id)obj;
+ (CGFloat)cellHeight;

@end
