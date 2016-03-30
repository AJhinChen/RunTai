//
//  User.h
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject<NSCoding>
@property (readwrite, nonatomic, strong) NSString *avatar, *gender, *name, *status, *global_key, *location, *address, *objectId, *professional;
@property (readwrite, nonatomic, strong) NSString *curPassword, *resetPassword, *resetPasswordConfirm, *phone, *introduction;
@property (readwrite, nonatomic, strong) NSMutableArray *watched;

@property (readwrite, nonatomic, strong) NSNumber *id, *tweets_count, *is_phone_validated;

+ (User *)userWithGlobalKey:(NSString *)global_key;

+ (NSString *)makeUsername;

@end
