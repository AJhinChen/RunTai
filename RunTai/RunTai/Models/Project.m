//
//  Project.m
//  RunTai
//
//  Created by Joel Chen on 16/3/24.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Project.h"
#import "Login.h"

@implementation Project
- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!self.list) {
            self.list = [[NSMutableArray alloc] initWithCapacity:2];
        }
    }
    return self;
}

-(id)copyWithZone:(NSZone*)zone {
    Project *project = [[[self class] allocWithZone:zone] init];
    project.objectId = [_objectId copy];
    project.background = [_background copy];
    project.name = [_name copy];
    project.full_name = [_full_name copy];
    project.description_mine = [_description_mine copy];
    project.id = [_id copy];
    project.owner_id = [_owner_id copy];
    project.done = [_done copy];
    project.processing = [_processing copy];
    project.stared = [_stared copy];
    project.watch_count = [_watch_count copy];
    project.isStaring = _isStaring;
    project.isWatching = _isWatching;
    project.isLoadingMember = _isLoadingMember;
    project.created_at = [_created_at copy];
    project.updated_at = [_updated_at copy];
    project.owner=[_owner copy];
    project.responsible = [_responsible copy];
    return project;
}

+(NSString*)getProcessingName:(int)num{
    switch (num) {
        case 0:
            return @"审核中";
            break;
        case 1:
            return @"准备中";
            break;
        case 2:
            return @"拆改中";
            break;
        case 3:
            return @"水电中";
            break;
        case 4:
            return @"泥木中";
            break;
        case 5:
            return @"油漆中";
            break;
        case 6:
            return @"竣工中";
            break;
        case 7:
            return @"软装中";
            break;
        case 8:
            return @"入住中";
            break;
        default:
            return @"上门服务";
            break;
    }
}

- (Project *)configWithObjects:(NSArray *)objects type:(ProjectType)type{
    Project *pro = [[Project alloc]init];
    pro.proType = type;
    for (AVObject *object in objects) {
        Note *note = [[Note alloc]init];
        note.objectId = object.objectId;
        note.text = [object objectForKey:@"text"];
        
        NSArray *picFiles = [object objectForKey:@"pic_urls"];
        
        NSMutableArray *picUrls = [NSMutableArray array];
        
        for (AVFile *file in picFiles) {
            
            [picUrls addObject:file.url];
            
        }
        note.pic_urls = picUrls;
        note.updatedAt = [object objectForKey:@"updatedAt"];
        NSString *type = [object objectForKey:@"type"];
        note.noteType = type.integerValue;
        [pro.list addObject:note];
    }
    return pro;
}

@end
