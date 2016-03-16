//
//  UIImage+Extension.h
//  WeiBo
//
//  Created by Joel Chen on 16/1/7.
//  Copyright © 2016年 Joel Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
+ (UIImage *) imageWithName:(NSString *) imageName;
+ (UIImage *) resizableImageWithName:(NSString *)imageName;
- (UIImage*) scaleImageWithSize:(CGSize)size;

@end
