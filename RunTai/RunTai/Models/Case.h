//
//  Case.h
//  RunTai
//
//  Created by Joel Chen on 16/3/30.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Case : NSObject

@property (readwrite, nonatomic, copy) NSString *thumbnail, *title, *id, *style, *type, *address;

@property (strong, nonatomic) NSArray *images;

+ (NSArray *)configWithObjects:(NSArray *)objects;

@end
