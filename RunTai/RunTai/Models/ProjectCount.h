//
//  ProjectCount.h
//  Coding_iOS
//
//  Created by jwill on 15/11/10.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectCount : NSObject

@property (strong, nonatomic) NSNumber *all, *reviewing, *watched, *created;

- (void)configWithProjects:(ProjectCount *)ProjectCount;


@end
