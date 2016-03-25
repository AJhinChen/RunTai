//
//  LoggingPhotosView.m
//  RunTai
//
//  Created by Joel Chen on 16/3/17.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "LoggingPhotosView.h"
#import "LoggingPhotoView.h"
#import "MJPhotoBrowser.h"
#import "Photo.h"

#define StatusPhotosMaxCount 9
#define StatusPhotosMaxCols(photosCount) ((photosCount == 4) ? 2 :3)
#define StatusPhotosW (kScreen_Width - 2*StatusPhotosMargin - 8*2)/3
#define StatusPhotosH StatusPhotosW
#define StatusPhotosMargin 5

@interface LoggingPhotosView()
//配图
@property (nonatomic ,weak) LoggingPhotoView *photoView;


@end

@implementation LoggingPhotosView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        //能与用户交互
        self.userInteractionEnabled = YES;
        //预先创建9个图片控件
        for (int i = 0; i < StatusPhotosMaxCount; i++){
            LoggingPhotoView *photoView = [[LoggingPhotoView alloc] init];
            photoView.tag = i;
            [self addSubview:photoView];
            
            //添加手势
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(statusPhotoOnTap:)];
            [photoView addGestureRecognizer:gestureRecognizer];
        }
    }
    
    
    return self;
    
}

- (void)statusPhotoOnTap:(UITapGestureRecognizer *)recognizer {
    // 1.创建图片浏览器
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    
    // 2.设置图片浏览器显示的所有图片
    NSMutableArray *photos = [NSMutableArray array];
    int count = (int)self.picUrls.count;
    for (int i = 0; i <count; i++){
        Photo *pic = [[Photo alloc] init];
        pic.original_pic = self.picUrls[i];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:pic.original_pic];
        //设置来源于哪一个UIImageView
        photo.srcImageView = self.subviews[i];
        
        [photos addObject:photo];
    }
    
    browser.photos = photos;
    
    // 3.设置默认显示的图片索引
    browser.currentPhotoIndex = recognizer.view.tag;
    
    // 4.显示浏览器
    [browser show];
}

- (void)setPicUrls:(NSArray *)picUrls {
    
    _picUrls = picUrls;
    
    for (int i = 0; i < StatusPhotosMaxCount; i++){
        
        LoggingPhotoView *photoView = self.subviews[i];
        
        if (i < picUrls.count){
            photoView.photo = picUrls[i];
            photoView.hidden = NO;
        }else{
            photoView.hidden = YES;
        }
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    int count = (int)self.picUrls.count;
    int maxCols = StatusPhotosMaxCols(count);
    
    for (int i = 0; i < count; i++){
        LoggingPhotoView *photoView = self.subviews[i];
        photoView.width = StatusPhotosW;
        photoView.height = StatusPhotosH;
        
        photoView.x = (i % maxCols) * (StatusPhotosW + StatusPhotosMargin);
        photoView.y = (i / maxCols) * (StatusPhotosW + StatusPhotosMargin);
        
    }
}


+ (CGSize)sizeWithPhotosCount:(int)photosCount {
    
    int maxCols = StatusPhotosMaxCols(photosCount);
    
    // 总列数
    int totalCols = photosCount >= maxCols ? maxCols : photosCount;
    
    // 总行数
    int totalRows = (photosCount + maxCols - 1) / maxCols;
    
    // 计算尺寸
    CGFloat photosW = totalCols * StatusPhotosW + (totalCols - 1) * StatusPhotosMargin;
    CGFloat photosH = totalRows * StatusPhotosH + (totalRows - 1) * StatusPhotosMargin;
    
    return CGSizeMake(photosW, photosH);
    
    
}

@end
