//
//  Project.h
//  RunTai
//
//  Created by Joel Chen on 16/3/24.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ProjectType)
{
    ProjectTypeStart = 0,
    ProjectTypeReviewing,
};

@interface Project : NSObject
@property (readwrite, nonatomic, strong) NSString *background, *name, *full_name, *description_mine;
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *done, *stared, *processing, *watch_count, *watched, *type;
@property (assign, nonatomic) BOOL isStaring, isWatching, isLoadingMember, isLoadingDetail;

@property (strong, nonatomic) User *owner;

@property (strong, nonatomic) User *responsible;
@property (strong, nonatomic) NSDate *created_at,*updated_at;

@property (assign, nonatomic) ProjectType proType;

+ (Project *)project_All;
+(NSString*)getProcessingName:(int)num;

@end
