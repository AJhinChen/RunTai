//
//  SettingTextCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_SettingText @"SettingTextCell"

#import <UIKit/UIKit.h>

@interface SettingTextCell : UITableViewCell
@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) NSString *textValue;
@property (copy, nonatomic) void(^textChangeBlock)(NSString *textValue);

- (void)setTextValue:(NSString *)textValue andTextChangeBlock:(void(^)(NSString *textValue))block;

@end
