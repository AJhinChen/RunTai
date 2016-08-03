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
    [curUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            [AVUser changeCurrentUser:curUser save:YES];
            [Login doLogin:curUser];
        }
        block(succeeded,error);
    }];
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

- (void)request_CreateProject_WithUser:(Register *)myRegister block:(AVBooleanResultBlock)block{
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    [query whereKey:@"owner" equalTo:[AVUser currentUser]];
    [query whereKey:@"processing" equalTo:@0];
    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
        if (!error) {
            // 查询成功，输出计数
            if (number>0) {
                error = [NSError errorWithDomain:@"" code:999 userInfo:[NSDictionary dictionaryWithObject:@"999" forKey:@"code"]];
                block(NO,error);
            }else{
                AVObject *project = [AVObject objectWithClassName:@"Project"];
                AVUser *curUser = [AVUser currentUser];
                if (!curUser) {
                    block(NO,nil);
                    return;
                }
                [project setObject:curUser forKey:@"owner"];
                [project setObject:[NSString stringWithFormat:@"[%@]",myRegister.location] forKey:@"full_name"];
                [project setObject:[NSNumber numberWithInt:0] forKey:@"processing"];
                [project setObject:[NSNumber numberWithInt:0] forKey:@"watch_count"];
                [project saveInBackgroundWithBlock:block];
            }
        } else {
            // 查询失败
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢,请重试"];
                    return;
                    break;
                default:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢,请重试"];
                    break;
            }
            block(NO,error);
        }
    }];
}

- (void)request_Projects_WithUser:(User *)user loaded:(NSArray *)loaded block:(AVArrayResultBlock)block{
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    AVUser *curUser = [AVQuery getUserObjectWithId:user.objectId];
    if (!curUser) {
        block(nil,nil);
        return;
    }
    [query whereKey:@"responsible" equalTo:curUser];
    [query orderByDescending:@"updatedAt"];
    [query whereKey:@"objectId" notContainedIn:loaded];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query includeKey:@"owner"];
    [query includeKey:@"responsible"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:block];
}

- (void)request_Projects_WithRefresh:(AVArrayResultBlock)block{
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query whereKey:@"watch_count" greaterThanOrEqualTo:@100];
    [query includeKey:@"owner"];
    [query includeKey:@"responsible"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:block];
}

- (void)request_ProjectsLoadMoreWithType:(ProjectsType)type :(NSArray *)loaded block:(AVArrayResultBlock)block{
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    [query whereKey:@"objectId" notContainedIn:loaded];
    switch (type) {
        case ProjectsTypeHot:
            [query whereKey:@"watch_count" greaterThanOrEqualTo:@100];
            break;
        case ProjectsTypeFresh:
            [query orderByDescending:@"updatedAt"];
            break;
            
        default:
            break;
    }
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query includeKey:@"owner"];
    [query includeKey:@"responsible"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:block];
}

- (void)request_ProjectsCatergoryAndCounts_WithAll:(void (^)(ProjectCount *data, NSError *error))block{
    ProjectCount *pCount = [[ProjectCount alloc]init];
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
        if (!error) {
            // 查询成功，输出计数
            pCount.fresh = [NSNumber numberWithInteger:number?number:0];
            AVQuery *query = [AVQuery queryWithClassName:@"Project"];
            [query whereKey:@"watch_count" greaterThanOrEqualTo:@100];
            [query countObjectsInBackgroundWithBlock:^(NSInteger number, NSError *error) {
                if (!error) {
                    pCount.hot = [NSNumber numberWithInteger:number?number:0];
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
    AVQuery *query = [AVQuery queryWithClassName:@"Project"];
    switch (type) {
        case ProjectsTypeFresh:
            [query includeKey:@"owner"];
            [query includeKey:@"responsible"];
            [query orderByDescending:@"updatedAt"];
            query.limit = 10;
            [query setCachePolicy:kAVCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:block];
            return;
            break;
        case ProjectsTypeCreated:{
            User *curUser = [Login curLoginUser];
            if (!curUser) {
                block(nil,nil);
                return;
            }
            [query whereKey:@"owner" equalTo:[AVUser currentUser]];
            [query orderByDescending:@"createdAt"];
            [query includeKey:@"owner"];
            [query includeKey:@"responsible"];
            [query setCachePolicy:kAVCachePolicyNetworkOnly];
            [query findObjectsInBackgroundWithBlock:block];
            return;
        }
            break;
        case ProjectsTypeWatched:{
            User *curUser = [Login curLoginUser];
            if (!curUser) {
                block(nil,nil);
                return;
            }
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

- (void)request_BuyList_WithArray:(NSArray *)list block:(AVArrayResultBlock)block{
    NSMutableArray *buylist = [NSMutableArray array];
    for (AVObject *object in list) {
        AVObject *obj = [AVQuery getObjectOfClass:@"Buy" objectId:object.objectId];
        Buy *buy = [[Buy alloc]init];
        buy.objectId = [obj objectForKey:@"objectId"];
        buy.title = [obj objectForKey:@"title"];
        buy.subtitle = [obj objectForKey:@"subtitle"];
        buy.price = [obj objectForKey:@"price"];
        [buylist addObject:buy];
    }
    block(buylist,nil);
}

- (void)request_SearchProjectOrUser_WithString:(NSString *)string block:(AVArrayResultBlock)block{
    NSMutableArray *querysArr = [NSMutableArray array];
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"name" containsString:string];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count]>0) {
            for (AVUser *user in objects) {
                AVQuery *name = [AVQuery queryWithClassName:@"Project"];
                [name whereKey:@"owner" equalTo:user];
                [querysArr addObject:name];
            }
            AVQuery *address = [AVQuery queryWithClassName:@"Project"];
            [address whereKey:@"full_name" containsString:string];
            [querysArr addObject:address];
            AVQuery *querys = [AVQuery orQueryWithSubqueries:querysArr];
            [querys setCachePolicy:kAVCachePolicyNetworkOnly];
            [querys orderByDescending:@"updatedAt"];
            [querys includeKey:@"owner"];
            [querys includeKey:@"responsible"];
            [querys findObjectsInBackgroundWithBlock:block];
        }else{
            AVQuery *address = [AVQuery queryWithClassName:@"Project"];
            [address whereKey:@"full_name" containsString:string];
            [address setCachePolicy:kAVCachePolicyNetworkOnly];
            [address orderByDescending:@"updatedAt"];
            [address includeKey:@"owner"];
            [address includeKey:@"responsible"];
            [address findObjectsInBackgroundWithBlock:block];
        }
    }];
}



#pragma mark - Note

- (void)request_Notes_WithNotes:(NSArray *)notes block:(AVArrayResultBlock)block{
    NSMutableArray *querysArr = [NSMutableArray array];
    for (AVObject *object in notes) {
        AVQuery *note = [AVQuery queryWithClassName:@"Note"];
        [note whereKey:@"objectId" equalTo:object.objectId];
        [querysArr addObject:note];
    }
    AVQuery *querys = [AVQuery orQueryWithSubqueries:querysArr];
    [querys includeKey:@"pic_urls"];
    [querys setCachePolicy:kAVCachePolicyNetworkOnly];
    [querys findObjectsInBackgroundWithBlock:block];
}

- (void)request_WatchNote_WithProject:(NSString *)projectId block:(AVObjectResultBlock)block{
    AVObject *object = [AVQuery getObjectOfClass:@"Project" objectId:projectId];
    NSString *count = [object objectForKey:@"watch_count"];
    [object setObject:[NSNumber numberWithInt:count.intValue+1] forKey:@"watch_count"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        block(object,error);
    }];
    
}

- (void)request_CollectNote_WithProject:(NSString *)projectId block:(AVBooleanResultBlock)block{
    AVUser *user = [AVUser currentUser];
    NSMutableArray *digPros = [user objectForKey:@"watched"];
    AVObject *object = [AVQuery getObjectOfClass:@"Project" objectId:projectId];
    if (!object) {
        block(NO,nil);
        return;
    }
    if ( [digPros containsObject:object]){
        [user removeObject:object forKey:@"watched"];
        
    }else{
        [user addObject:object forKey:@"watched"];
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            [AVUser changeCurrentUser:user save:YES];
            [Login doLogin:user];
        }
        block(succeeded,error);
    }];
}


#pragma mark - Arch

- (void)request_LoadStaffs:(NSString *)location :(AVArrayResultBlock)block{
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"authority" notEqualTo:@"0"];
    [query whereKey:@"location" containsString:location];
    [query orderByAscending:@"createdAt"];
    [query setCachePolicy:kAVCachePolicyNetworkElseCache];
    [query findObjectsInBackgroundWithBlock:block];
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
