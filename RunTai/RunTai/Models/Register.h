//
//  Register.h
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Register : NSObject
//请求
@property (readwrite, nonatomic, strong) NSString *professional, *location, *gender, *global_key, *phone, *code, *password, *confirm_password;

@end
