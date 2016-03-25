//
//  RunTai_NetAPIManager.h
//  RunTai
//
//  Created by Joel Chen on 16/3/23.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Projects.h"
#import "Project.h"
#import "Login.h"
#import "ProjectCount.h"

@interface RunTai_NetAPIManager : NSObject
+ (instancetype)sharedManager;

#pragma mark - UnRead

#pragma mark - Login

- (void)request_UpdateUserInfo_WithParam:(NSString *)param value:(id)value block:(AVBooleanResultBlock)block;

- (void)request_DeleteOriginalFile_WithUrl:(NSString *)url;


#pragma mark - Project

- (void)request_CreateProject_WithUser:(User *)user block:(AVBooleanResultBlock)block;

- (void)request_Projects_WithStart:(AVArrayResultBlock)block;

- (void)request_Projects_WithLoadMore:(NSArray *)loaded block:(AVArrayResultBlock)block;

- (void)request_ProjectsCatergoryAndCounts_WithAll:(void (^)(ProjectCount *data, NSError *error))block;

- (void)request_Projects_WithType:(ProjectsType)type block:(AVArrayResultBlock)block;

- (void)request_Projects_WithType:(ProjectsType)type :(NSArray *)loaded block:(AVArrayResultBlock)block;

@end
