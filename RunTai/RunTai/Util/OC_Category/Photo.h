//
//  Photo.h
//  WeiBo
//
//  Created by Joel Chen on 16/1/8.
//  Copyright © 2016年 Joel Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

//缩略图
@property (nonatomic , copy) NSString *thumbnail_pic;

//中等尺寸图片地址，没有时返回此字段
@property (nonatomic , copy) NSString *bmiddle_pic;

//原图地址，没有时不返回此字段
@property (nonatomic , copy) NSString *original_pic;

@end
