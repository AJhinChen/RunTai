//
//  Case_RootViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/3/30.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BaseViewController.h"

@interface Case_RootViewController : BaseViewController;

@property (weak,nonatomic) UIViewController *currentViewController;
@property (copy, nonatomic) NSString *currentSegueIdentifier;
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UIView *menu;
@property (strong, nonatomic) UIButton *menuButton;
@property (strong, nonatomic) UILabel *titleLabel;

- (void) displayGestureForTapRecognizer:(UITapGestureRecognizer *) recognizer;
- (void) menuButtonAction: (UIButton *) sender;
- (void) listButtonAction: (UIButton *) sender;

- (void) setTrianglePlacement: (float) trianglePlacementVal;
- (void) setFadeAmountWithAlpha:(float) alphaVal;
- (void) setFadeTintWithColor:(UIColor *) color;
- (void) dropShapeShouldShowWhenOpen:(BOOL)shouldShow;
- (void) toggleMenu;
- (void) showMenu;
- (void) hideMenu;

@end
