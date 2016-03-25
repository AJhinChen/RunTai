//
//  GalleryRiverCell.h
//  RunTai
//
//  Created by Joel Chen on 16/3/18.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kCellIdentifier_GalleryRiverCell @"GalleryRiverCell"

#import <UIKit/UIKit.h>

@interface GalleryRiverCell : UICollectionViewCell

typedef NS_ENUM(NSInteger, XYZPhotoState) {
    XYZPhotoStateNormal = 0,
    XYZPhotoStateBig = 1,
    XYZPhotoStateDraw = 2,
    XYZPhotoStateTogether = 3
};

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *drawView;
@property (nonatomic) float speed;
@property (nonatomic) CGRect oldFrame;
@property (nonatomic) float oldSpeed;
@property (nonatomic) float oldAlpha;
@property (nonatomic) int state;

- (void)updateImage:(UIImage *)image;
- (void)setImageAlphaAndSpeedAndSize:(float)alpha;

@end
