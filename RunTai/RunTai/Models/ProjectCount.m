//
//  ProjectCount.m
//  Coding_iOS
//
//  Created by jwill on 15/11/10.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ProjectCount.h"

@implementation ProjectCount

- (void)configWithProjects:(ProjectCount *)ProjectCount
{
    self.hot = ProjectCount.hot;
    self.fresh = ProjectCount.fresh;
    self.watched = ProjectCount.watched;
    self.created = ProjectCount.created;
}

@end
