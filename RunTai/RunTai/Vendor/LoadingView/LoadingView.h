//
//  LoadingView.h
//  TVBPushDemo
//
//  Created by Joel Chen on 15/12/15.
//  Copyright © 2015年 Joel Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

- (instancetype)initFullScreen:(NSString *) title;
-(void) setTitle:(NSString *)title;

- (instancetype)initWithFrame:(CGRect)frame :(NSString *) title;

-(void) dismiss;

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@end
