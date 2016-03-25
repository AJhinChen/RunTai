//
//  RunTai_NetAPIManager.m
//  RunTai
//
//  Created by Joel Chen on 16/3/23.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "RunTai_NetAPIManager.h"

@implementation RunTai_NetAPIManager

+ (instancetype)sharedManager {
    static RunTai_NetAPIManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

#pragma mark Login

- (void)request_UpdateUserInfo_WithParam:(NSString *)param value:(id)value block:(AVBooleanResultBlock)block{
    AVUser *curUser = [AVUser currentUser];
    [curUser setObject:value forKey:param];
    [curUser saveInBackgroundWithBlock:block];
    [AVUser changeCurrentUser:curUser save:YES];
    [Login doLogin:curUser];
}

- (void)request_DeleteOriginalFile_WithUrl:(NSString *)url{
    AVQuery *query = [AVQuery queryWithClassName:@"_File"];
    [query setCachePolicy:kAVCachePolicyNetworkOnly];
    [query whereKey:@"url" equalTo:url];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            AVFile *originalFile = [objects firstObject];
            if (originalFile) {
                [originalFile deleteInBackground];
            }
        }
    }];
}

- (void)request_CreateProject_WithUser:(User *)user block:(AVBooleanResultBlock)block{
    AVObject *project = [AVObject objectWithClassName:@"Project"];
    AVUser *curUser = [AVQuery getUserObjectWithId:user.objectId];
    [project setObject:curUser forKey:@"owner"];
    [project setObject:[NSString stringWithFormat:@"[%@ %@]",user.location,user.address] forKey:@"full_name"];
    [project setObject:[NSNumber numberWithInt:0] forKey:@"processing"];
    [project setObject:[NSNumber numberWithInt:0] forKey:@"watch_count"];
    [project saveInBackgroundWithBlock:block];
}

- (void)request_Projects_WithStart:(AVArrayResultBlock)block{
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query includeKey:@"owner"];
    [query includeKey:@"responsible"];
    [query addDescendingOrder:@"watch_count"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:block];
}

- (void)request_Projects_WithLoadMore:(NSArray *)loaded block:(AVArrayResultBlock)block{
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    [query whereKey:@"objectId" notContainedIn:loaded];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query includeKey:@"owner"];
    [query includeKey:@"responsible"];
    [query addDescendingOrder:@"watch_count"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:block];
}

- (void)request_ProjectsCatergoryAndCounts_WithAll:(void (^)(ProjectCount *data, NSError *error))block{
    ProjectCount *pCount = [[ProjectCount alloc]init];
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
        if (!error) {
            // 查询成功，输出计数
            pCount.all = [NSNumber numberWithInteger:number?number:0];
            AVQuery *query = [AVQuery queryWithClassName:@"Project"];
            [query whereKey:@"owner" equalTo:[AVUser currentUser]];
            [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
                if (!error) {
                    // 查询成功，输出计数
                    NSInteger watched = [((User *)[Login curLoginUser]).watched count];
                    pCount.created = [NSNumber numberWithInteger:number?number:0];
                    pCount.watched = [NSNumber numberWithInteger:watched?watched:0];
                    block(pCount,nil);
                } else {
                    // 查询失败
                    NSString * errorCode = error.userInfo[@"code"];
                    switch (errorCode.intValue) {
                        case 28:
                            [NSObject showHudTipStr:@"请求超时，网络信号不好噢,请切换页面重试"];
                            break;
                        default:
                            [NSObject showHudTipStr:@"获取我的订单数量失败,请切换页面重试"];
                            break;
                    }
                }
            }];
        } else {
            // 查询失败
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢,请切换页面重试"];
                    break;
                default:
                    [NSObject showHudTipStr:@"获取全部笔录数量失败,请切换页面重试"];
                    break;
            }
        }
    }];
}

- (void)request_Projects_WithType:(ProjectsType)type block:(AVArrayResultBlock)block{
    NSMutableArray *querysArr = [NSMutableArray array];
    User *curUser = [Login curLoginUser];
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    switch (type) {
        case ProjectsTypeAll:
            [query addDescendingOrder:@"watch_count"];
            [querysArr addObject:query];
            break;
        case ProjectsTypeCreated:
            [query whereKey:@"owner" equalTo:[AVUser currentUser]];
            [query orderByDescending:@"updatedAt"];
            [querysArr addObject:query];
            break;
        case ProjectsTypeWatched:{
            for (AVObject* object in curUser.watched) {
                AVQuery *watched = [AVQuery queryWithClassName:@"Project"];
                [watched whereKey:@"objectId" equalTo:object.objectId];
                [querysArr addObject:watched];
            }
        }
            break;
        default:
            break;
    }
    AVQuery *querys = [AVQuery orQueryWithSubqueries:querysArr];
    [querys setCachePolicy:kAVCachePolicyNetworkOnly];
    [querys includeKey:@"owner"];
    [querys includeKey:@"responsible"];
    [querys findObjectsInBackgroundWithBlock:block];
}




- (void)request_Projects_WithType:(ProjectsType)type :(NSArray *)loaded block:(AVArrayResultBlock)block{
    NSMutableArray *querys = [NSMutableArray array];
    AVQuery *Query = [AVQuery queryWithClassName:@"Project"];
//    switch (type) {
//        case ProjectsTypeAll:
//        case ProjectsTypeCreated:
//            
//            break;
//        case ProjectsTypeWatched:
//            
//            break;
//        default:
//            [Query orderByAscending:@"watch_count"];
//            [querys addObject:Query];
//            break;
//    }
    AVQuery *loadedQuery = [AVQuery queryWithClassName:@"Project"];
    [loadedQuery whereKey:@"objectId" notContainedIn:loaded];
    [querys addObject:loadedQuery];
    [Query whereKey:@"watch_count" greaterThan:@1000];
    [Query addDescendingOrder:@"watch_count"];
    [querys addObject:Query];
    AVQuery *query = [AVQuery andQueryWithSubqueries:querys];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query includeKey:@"owner"];
    [query includeKey:@"responsible"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:block];
}



@end
