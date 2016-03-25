//
//  LoggingPhotosView.h
//  RunTai
//
//  Created by Joel Chen on 16/3/17.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoggingPhotosView : UIImageView

@property(nonatomic , strong) NSArray *picUrls;

//根据图片个数计算尺寸
+ (CGSize)sizeWithPhotosCount:(int)photosCount;

@end
