//
//  Input_OnlyText_Cell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_Input_OnlyText_Cell_Text @"Input_OnlyText_Cell_Text"
#define kCellIdentifier_Input_OnlyText_Cell_Password @"Input_OnlyText_Cell_Password"
#define kCellIdentifier_Input_OnlyText_Cell_Gender @"Input_OnlyText_Cell_Gender"

#import <UIKit/UIKit.h>
#import "UITapImageView.h"
#import "PhoneCodeButton.h"
#import "GenderButton.h"
#import "ActionSheetStringPicker.h"

@interface Input_OnlyText_Cell : UITableViewCell
@property (strong, nonatomic, readonly) UITextField *textField;
@property (strong, nonatomic, readonly) PhoneCodeButton *verify_codeBtn;
@property (strong, nonatomic, readonly) GenderButton *genderBtn;

@property (assign, nonatomic) BOOL isForLoginVC;

@property (nonatomic,copy) void(^textValueChangedBlock)(NSString *);
@property (nonatomic,copy) void(^editDidBeginBlock)(NSString *);
@property (nonatomic,copy) void(^editDidEndBlock)(NSString *);
@property (nonatomic,copy) void(^phoneCodeBtnClckedBlock)(PhoneCodeButton *);
@property (nonatomic,copy) void(^genderBtnClckedBlock)(NSString *);
@property (nonatomic,copy) void(^pwdBtnClckedBlock)(UIButton *);

- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr;
- (void)setGenderValue:(NSString *)valueStr;
+ (NSString *)randomCellIdentifierOfPhoneCodeType;

@end
