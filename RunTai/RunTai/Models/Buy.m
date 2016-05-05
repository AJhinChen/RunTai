//
//  Buy.m
//  RunTai
//
//  Created by Joel Chen on 16/4/22.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Buy.h"

@implementation Buy
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(id)copyWithZone:(NSZone*)zone {
    Buy *buy = [[[self class] allocWithZone:zone] init];
    buy.objectId = [_objectId copy];
    buy.title = [_title copy];
    buy.price = [_price copy];
    buy.subtitle=[NSArray array];
    return buy;
}

@end
