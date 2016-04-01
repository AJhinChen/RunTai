//
//  Case.m
//  RunTai
//
//  Created by Joel Chen on 16/3/30.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Case.h"

@implementation Case
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.images = [NSArray array];
    }
    return self;
}

-(id)copyWithZone:(NSZone*)zone {
    Case *cases = [[[self class] allocWithZone:zone] init];
    cases.title = [_title copy];
    cases.thumbnail = [_thumbnail copy];
    cases.type = [_type copy];
    cases.style = [_style copy];
    cases.id = [_id copy];
    cases.address = [_address copy];
    return cases;
}

+ (NSArray *)configWithObjects:(NSArray *)objects{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *model1 = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *model2 = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *model3 = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *model4 = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in objects) {
        Case * model = [[Case alloc]init];
        model.id = dict[@"id"];
        model.title = dict[@"title"];
        model.thumbnail = dict[@"thumbnail"];
        model.type = dict[@"type"];
        model.style = dict[@"style"];
        model.address = dict[@"address"];
        model.images = dict[@"images"];
        if ([model.id isEqualToString:@"公寓案例"]) {
            [model1 addObject:model];
        }else if ([model.id isEqualToString:@"复式案例"]) {
            [model2 addObject:model];
        }else if ([model.id isEqualToString:@"别墅案例"]) {
            [model3 addObject:model];
        }
        [model4 addObject:model];
    }
    [result addObjectsFromArray:@[model4,model2,model3,model1]];
    return result;
}

@end
