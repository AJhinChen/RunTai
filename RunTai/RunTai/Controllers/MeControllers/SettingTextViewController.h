//
//  SettingTextViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, SettingType)
{
    SettingTypeOnlyText = 0,
    SettingTypeUserName,
    SettingTypeAddressName
};

@interface SettingTextViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *textValue, *placeholderStr;
@property (copy, nonatomic) void(^doneBlock)(NSString *textValue);
@property (assign, nonatomic) SettingType settingType;

+ (instancetype)settingTextVCWithTitle:(NSString *)title textValue:(NSString *)textValue doneBlock:(void(^)(NSString *textValue))block;

@end
