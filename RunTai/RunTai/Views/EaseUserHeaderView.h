//
//  EaseUserHeaderView.h
//  RunTai
//
//  Created by Joel Chen on 16/3/22.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface EaseUserHeaderView : UITapImageView
@property (strong, nonatomic) User *curUser;
@property (strong, nonatomic) UIImage *bgImage;

@property (nonatomic, copy) void (^userIconClicked)();
@property (nonatomic, copy) void (^fansCountBtnClicked)();
@property (nonatomic, copy) void (^followsCountBtnClicked)();
@property (nonatomic, copy) void (^followBtnClicked)();
@property (nonatomic, copy) void (^callBtnClicked)();

+ (id)userHeaderViewWithUser:(User *)user image:(UIImage *)image;
- (void)updateData;

@end
