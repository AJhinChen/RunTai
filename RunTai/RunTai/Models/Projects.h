//
//  Projects.h
//  RunTai
//
//  Created by Joel Chen on 16/3/24.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef NS_ENUM(NSInteger, ProjectsType)
{
    ProjectsTypeAll = 0,
    ProjectsTypeCreated,
    ProjectsTypeWatched,
    ProjectsTypeAllPublic,
};

@interface Projects : NSObject
@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) ProjectsType type;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (readwrite, nonatomic, strong) NSMutableArray *loadedObjectIDs;

+ (Projects *)projectsWithType:(ProjectsType)type andUser:(User *)user;
- (Projects *)configWithObjects:(NSArray *)objects type:(ProjectsType)type;

@end
