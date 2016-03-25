//
//  User.m
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "User.h"

@implementation User

-(void)encodeWithCoder:(NSCoder *)encoder{
    
    [encoder encodeObject:self.avatar forKey:@"avatar"];
    
    [encoder encodeObject:self.name forKey:@"name"];
    
    [encoder encodeObject:self.global_key forKey:@"global_key"];
    
    [encoder encodeObject:self.location forKey:@"location"];
    
    [encoder encodeObject:self.address forKey:@"address"];
    
    [encoder encodeObject:self.objectId forKey:@"objectId"];
    
    [encoder encodeObject:self.curPassword forKey:@"curPassword"];
    
    [encoder encodeObject:self.resetPassword forKey:@"resetPassword"];
    
    [encoder encodeObject:self.resetPasswordConfirm forKey:@"resetPasswordConfirm"];
    
    [encoder encodeObject:self.phone forKey:@"phone"];
    
    [encoder encodeObject:self.introduction forKey:@"introduction"];
    
    [encoder encodeObject:self.id forKey:@"id"];
    
    [encoder encodeObject:self.gender forKey:@"gender"];
    
    [encoder encodeObject:self.tweets_count forKey:@"tweets_count"];
    
    [encoder encodeObject:self.is_phone_validated forKey:@"is_phone_validated"];
    
//    [encoder encodeObject:self.watched forKey:@"watched"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        
        self.avatar = [decoder decodeObjectForKey:@"avatar"];
        
        self.name =[decoder decodeObjectForKey:@"name"];
        
        self.global_key = [decoder decodeObjectForKey:@"global_key"];
        
        self.location = [decoder decodeObjectForKey:@"location"];
        
        self.address = [decoder decodeObjectForKey:@"address"];
        
        self.objectId =[decoder decodeObjectForKey:@"objectId"];
        
        self.curPassword = [decoder decodeObjectForKey:@"curPassword"];
        
        self.resetPassword = [decoder decodeObjectForKey:@"resetPassword"];
        
        self.resetPasswordConfirm =[decoder decodeObjectForKey:@"resetPasswordConfirm"];
        
        self.phone = [decoder decodeObjectForKey:@"phone"];
        
        self.introduction = [decoder decodeObjectForKey:@"introduction"];
        
        self.id =[decoder decodeObjectForKey:@"id"];
        
        self.gender = [decoder decodeObjectForKey:@"gender"];
        
        self.tweets_count = [decoder decodeObjectForKey:@"tweets_count"];
        
        self.is_phone_validated =[decoder decodeObjectForKey:@"is_phone_validated"];
        
//        self.watched =[decoder decodeObjectForKey:@"watched"];
        
    }
    
    return self;
    
}

-(id)copyWithZone:(NSZone*)zone {
    User *user = [[[self class] allocWithZone:zone] init];
    user.avatar = [_avatar copy];
    user.name = [_name copy];
    user.global_key = [_global_key copy];
    user.location = [_location copy];
    user.address = [_address copy];
    user.objectId = [_objectId copy];
    user.curPassword = [_curPassword copy];
    user.resetPassword = [_resetPassword copy];
    user.resetPasswordConfirm = [_resetPasswordConfirm copy];
    user.phone = [_phone copy];
    user.introduction = [_introduction copy];
    user.id = [_id copy];
    user.gender = [_gender copy];
    user.tweets_count = [_tweets_count copy];
    user.is_phone_validated = [_is_phone_validated copy];
    user.watched = [NSMutableArray array];
    return user;
}

+ (User *)userWithGlobalKey:(NSString *)global_key{
    User *curUser = [[User alloc] init];
    curUser.global_key = global_key;
    return curUser;
}

+ (NSString *)makeUsername{
    NSString *temp = @"U";
    temp = [temp stringByAppendingString:[NSString stringWithFormat:@"%@",[NSDate stringFromDate:[NSDate date] withFormat:@"yymmdd"]]];
    temp = [temp stringByAppendingString:[NSString stringWithFormat:@"%d",arc4random_uniform(1000)]];
    return temp;
}

@end
