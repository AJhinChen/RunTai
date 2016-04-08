//
//  Projects.m
//  RunTai
//
//  Created by Joel Chen on 16/3/24.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Projects.h"
#import "Login.h"
#import "Project.h"

@implementation Projects

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!self.list) {
            self.list = [[NSMutableArray alloc] initWithCapacity:2];
        }
        if (!self.loadedObjectIDs) {
            self.loadedObjectIDs = [[NSMutableArray alloc] initWithCapacity:2];
        }
    }
    return self;
}

+ (Projects *)projectsWithType:(ProjectsType)type andUser:(User *)user{
    Projects *pros = [[Projects alloc] init];
    pros.type = type;
    pros.curUser = user;
    
    return pros;
}

- (NSString *)typeStr{
    NSString *typeStr;
    switch (_type) {
        case  ProjectsTypeHot:
        case  ProjectsTypeCreated:
            typeStr = @"created";
            break;
        case  ProjectsTypeWatched:
            typeStr = @"watched";
            break;
        default:
            typeStr = @"all";
            break;
    }
    return typeStr;
}

- (Projects *)configWithObjects:(NSArray *)objects type:(ProjectsType)type{
    Projects *pros = [[Projects alloc]init];
    pros.type = type;
    for (AVObject *object in objects) {
        Project *project = [[Project alloc]init];
        AVFile *backgroundFile = [object objectForKey:@"background"];
        project.objectId = object.objectId;
        project.background = backgroundFile.url;
        project.name = [object objectForKey:@"name"];
        project.full_name = [object objectForKey:@"full_name"];
        project.description_mine = [object objectForKey:@"description_mine"];
        project.id = [NSNumber numberWithInt:object.objectId.intValue];
        project.owner_id = [object objectForKey:@"owner_id"];
        project.done = [object objectForKey:@"done"];
        project.processing = [object objectForKey:@"processing"];
        project.stared = [object objectForKey:@"stared"];
        project.watch_count = [object objectForKey:@"watch_count"];
        project.isStaring = [object objectForKey:@"isStaring"];
        project.isWatching = [object objectForKey:@"isWatching"];
        project.isLoadingMember = [object objectForKey:@"isLoadingMember"];
        project.created_at = [object objectForKey:@"created_at"];
        project.updated_at = [object objectForKey:@"updated_at"];
        project.owner=[Login transfer:[object objectForKey:@"owner"]];
        project.responsible = [Login transfer:[object objectForKey:@"responsible"]];
        project.list = [object objectForKey:@"notes"];
        [pros.list addObject:project];
        [pros.loadedObjectIDs addObject:object.objectId];
    }
    return pros;
}

@end
