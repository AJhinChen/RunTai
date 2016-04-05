//
//  LoggingCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/16.
//  Copyright © 2016年 AJhin. All rights reserved.
//
#define kCellIdentifier_LoggingCell @"LoggingCell"

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "Note.h"

@interface LoggingCell : SWTableViewCell

@property (strong, nonatomic) Note *note;

+ (CGFloat)cellHeightWithObj:(Note *)obj;

@end
