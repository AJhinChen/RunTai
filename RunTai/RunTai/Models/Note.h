//
//  Note.h
//  RunTai
//
//  Created by Joel Chen on 16/3/28.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NoteType)
{
    NoteTypeReviewing = 0,
    NoteTypeReady,
    NoteTypeDismantle,
    NoteTypeHydropower,
    NoteTypeCement,
    NoteTypePaint,
    NoteTypeComplete,
    NoteTypeCustom,
    NoteTypeCheckin
};

@interface Note : NSObject

@property (readwrite, nonatomic, strong) NSString *objectId, *text;

//配图
@property (nonatomic , strong) NSArray *pic_urls;

@property (strong, nonatomic) NSDate *updatedAt;

@property (assign, nonatomic) NoteType noteType;

@end
