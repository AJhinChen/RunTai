//
//  NavBarButtonItem.h
//  RunTai
//
//  Created by Joel Chen on 16/7/5.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavBarButtonItem : UIButton

//创建文字按钮
+ (instancetype)buttonWithTitle:(NSString *)buttonTitle;

//创建图标按钮
+ (instancetype)buttonWithImageNormal:(UIImage *)imageNormal imageSelected:(UIImage *)imageSelected;

@end
