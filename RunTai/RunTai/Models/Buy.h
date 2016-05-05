//
//  Buy.h
//  RunTai
//
//  Created by Joel Chen on 16/4/22.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Buy : NSObject

@property (readwrite, nonatomic, strong) NSString *objectId, *title, *price;

//配图
@property (nonatomic , strong) NSArray *subtitle;

@end
