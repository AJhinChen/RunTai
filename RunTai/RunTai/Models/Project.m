//
//  Project.m
//  RunTai
//
//  Created by Joel Chen on 16/3/24.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Project.h"

@implementation Project
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isStaring = _isWatching = _isLoadingMember = _isLoadingDetail = NO;
    }
    return self;
}

-(id)copyWithZone:(NSZone*)zone {
    Project *project = [[[self class] allocWithZone:zone] init];
    project.background = [_background copy];
    project.name = [_name copy];
    project.responsible = [_responsible copy];
    project.full_name = [_full_name copy];
    project.description_mine = [_description_mine copy];
    project.id = [_id copy];
    project.owner_id = [_owner_id copy];
    project.done = [_done copy];
    project.processing = [_processing copy];
    project.stared = [_stared copy];
    project.watch_count = [_watch_count copy];
    project.watched = [_watched copy];
    project.isStaring = _isStaring;
    project.isWatching = _isWatching;
    project.isLoadingMember = _isLoadingMember;
    project.created_at = [_created_at copy];
    project.updated_at = [_updated_at copy];
    project.owner=[_owner copy];
    return project;
}


- (void)setFull_name:(NSString *)full_name{
    _full_name = full_name;
    NSArray *components = [_full_name componentsSeparatedByString:@"/"];
    if (components.count == 2) {
        if (!_responsible) {
            _responsible = components[0];
        }
        if (_name) {
            _name = components[1];
        }
    }
}

+(Project *)project_All{
    Project *pro = [[Project alloc] init];
    pro.id = [NSNumber numberWithInteger:-1];
    return pro;
}

+(NSString*)getProcessingName:(int)num{
    switch (num) {
        case 0:
            return @"审核中..";
            break;
        case 1:
            return @"准备阶段";
            break;
        case 2:
            return @"拆改阶段";
            break;
        case 3:
            return @"水电阶段";
            break;
        case 4:
            return @"泥木阶段";
            break;
        case 5:
            return @"油漆阶段";
            break;
        case 6:
            return @"竣工阶段";
            break;
        case 7:
            return @"软装阶段";
            break;
        case 8:
            return @"入住阶段";
            break;
        default:
            return @"上门服务";
            break;
    }
}

@end
