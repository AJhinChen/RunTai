//
//  Login.m
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Login.h"
#import "AppDelegate.h"

#define kLoginUserInfo @"user_info"
#define kLoginStatus @"login_status"
#define kLoginPreUserPhone @"pre_user_phone"
#define kLoginUserIcon @"user_icon"

#define UserFilepath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"account.arch"]

static User *curLoginUser;

@implementation Login
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.remember_me = [NSNumber numberWithBool:YES];
        self.phone = @"";
        self.password = @"";
    }
    return self;
}

+ (void)setPreUserPhone:(NSString *)phoneStr{
    if (phoneStr.length <= 0) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:phoneStr forKey:kLoginPreUserPhone];
    [defaults synchronize];
}

+ (NSString *)preUserPhone{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLoginPreUserPhone];
}

+ (NSString *)preUserIcon{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLoginUserIcon];
}

+ (BOOL)isLogin{
    NSNumber *loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
    if (loginStatus.boolValue && [Login curLoginUser]) {
        User *loginUser = [Login curLoginUser];
        if (loginUser.status && loginUser.status.integerValue == 0) {
            return NO;
        }
        return YES;
    }else{
        return NO;
    }
}

+ (User *)curLoginUser{
    if (!curLoginUser) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserInfo];
        curLoginUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return curLoginUser;
}

+(BOOL)isLoginUserGlobalKey:(NSString *)global_key{
    if (global_key.length <= 0) {
        return NO;
    }
    return [[self curLoginUser].global_key isEqualToString:global_key];
}

+ (void)doLogin:(AVUser *)user{
    if (user) {
        curLoginUser = [Login transfer:user];
        curLoginUser.status = @"1";
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:curLoginUser];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kLoginStatus];
        [defaults setObject:data forKey:kLoginUserInfo];
        [defaults setObject:curLoginUser.avatar forKey:kLoginUserIcon];
        [defaults synchronize];
    }else{
        [Login doLogout];
    }
}

+ (User *)transfer:(AVUser *)user{
    
    User *curUser = [[User alloc] init];
    
    if (user != nil) {
        
        curUser.name = [user objectForKey:@"name"];
        
        curUser.global_key = [user objectForKey:@"name"];
        
        curUser.phone = user.mobilePhoneNumber;
        
        curUser.gender = [user objectForKey:@"gender"];
        
        AVFile *avatarFile = [user objectForKey:@"avatar"];
        
        curUser.avatar = avatarFile.url;
        
        curUser.location = [user objectForKey:@"location"];
        
        curUser.address = [user objectForKey:@"address"];
        
        curUser.objectId = user.objectId;
        
        curUser.introduction = [user objectForKey:@"introduction"];
        
        curUser.id = [NSNumber numberWithInt:user.objectId.intValue];
        
        curUser.tweets_count = [user objectForKey:@"tweets_count"];
        
        curUser.is_phone_validated = [NSNumber numberWithBool:user.mobilePhoneVerified];
        
        curUser.watched = [user objectForKey:@"watched"];
        
        curUser.professional = [user objectForKey:@"professional"];
        
    }
    
    return curUser;
}

+ (void)doLogout{
    [AVUser logOut];
    User *loginUser = [Login curLoginUser];
    loginUser.status = @"0";
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:kLoginStatus];
    [defaults synchronize];
}



@end
