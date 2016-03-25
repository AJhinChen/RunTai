//
//  Login.h
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Login : NSObject
//请求
@property (readwrite, nonatomic, strong) NSString *phone, *password, *j_captcha;
@property (readwrite, nonatomic, strong) NSNumber *remember_me;

+ (NSString *)preUserPhone;
+ (void)setPreUserPhone:(NSString *)phoneStr;
+ (BOOL)isLogin;
+ (User *)curLoginUser;
+(BOOL)isLoginUserGlobalKey:(NSString *)global_key;
+ (User *)transfer:(AVUser *)user;
+ (void)doLogin:(AVUser *)user;
+ (void)doLogout;

@end
