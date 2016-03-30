//
//  Note.m
//  RunTai
//
//  Created by Joel Chen on 16/3/28.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Note.h"

@implementation Note
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(id)copyWithZone:(NSZone*)zone {
    Note *note = [[[self class] allocWithZone:zone] init];
    note.objectId = [_objectId copy];
    note.updatedAt = [_updatedAt copy];
    note.text=[_text copy];
    note.pic_urls=[NSArray array];
    return note;
}

@end
