//
//  Project.h
//  RunTai
//
//  Created by Joel Chen on 16/3/24.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"

typedef NS_ENUM(NSInteger, ProjectType)
{
    ProjectTypeReviewing = 0,
    ProjectTypeReady,
    ProjectTypeDismantle,
    ProjectTypeHydropower,
    ProjectTypeCement,
    ProjectTypePaint,
    ProjectTypeComplete,
    ProjectTypeCustom,
    ProjectTypeCheckin
};

@interface Project : NSObject
@property (readwrite, nonatomic, strong) NSString *objectId, *background, *name, *full_name, *description_mine;
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *done, *stared, *processing, *watch_count, *type;
@property (assign, nonatomic) BOOL isStaring, isWatching, isLoadingMember, isLoadingDetail;

@property (strong, nonatomic) User *owner;

@property (strong, nonatomic) User *responsible;

@property (readwrite, nonatomic, strong) NSMutableArray *list;

@property (nonatomic , strong) NSMutableArray *buylist;

@property (strong, nonatomic) NSDate *created_at,*updated_at;

@property (assign, nonatomic) ProjectType proType;

+(NSString*)getProcessingName:(int)num;

- (Project *)configWithObjects:(NSArray *)objects type:(ProjectType)type;

@end
