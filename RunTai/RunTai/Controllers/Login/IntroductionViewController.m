//
//  IntroductionViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "IntroductionViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"

#import "SMPageControl.h"
#import <NYXImagesKit/NYXImagesKit.h>

@interface IntroductionViewController ()
@property (strong, nonatomic) UIButton *registerBtn ,*loginBtn ,*gohomeBtn;
@property (strong, nonatomic) SMPageControl *pageControl;

@property (strong, nonatomic) NSMutableDictionary *iconsDict, *tipsDict;

@end

@implementation IntroductionViewController

- (instancetype)init
{
    if ((self = [super init])) {
        self.numberOfPages = 4;
        
        
        _iconsDict = [@{
                        @"0_image" : @"intro_icon_0",
                        @"1_image" : @"intro_icon_1",
                        @"2_image" : @"intro_icon_2",
                        @"3_image" : @"intro_icon_3",
                        } mutableCopy];
        _tipsDict = [@{
                       @"0_image" : @"intro_tip_0",
                       @"1_image" : @"intro_tip_1",
                       @"2_image" : @"intro_tip_2",
                       @"3_image" : @"intro_tip_3",
                       } mutableCopy];
        
//        _iconsDict = [NSMutableDictionary new];
//        _tipsDict = [NSMutableDictionary new];
//        for (int i = 0; i < self.numberOfPages; i++) {
//            NSString *imageKey = [self imageKeyForIndex:i];
//            [_iconsDict setObject:[NSString stringWithFormat:@"intro_icon_%d", i] forKey:imageKey];
//            [_tipsDict setObject:[NSString stringWithFormat:@"intro_tip_%d", i] forKey:imageKey];
//        }
    }
    
    return self;
}

- (NSString *)imageKeyForIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%ld_image", (long)index];
}

- (NSString *)viewKeyForIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%ld_view", (long)index];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
    
    [self configureViews];
    [self configureAnimations];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)dealloc{
    self.registerBtn = nil;
    self.loginBtn = nil;
    self.gohomeBtn = nil;
    self.pageControl = nil;
    self.iconsDict = nil;
    self.tipsDict = nil;
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)forceChangeToOrientation:(UIInterfaceOrientation)interfaceOrientation{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:interfaceOrientation] forKey:@"orientation"];
}

#pragma mark Super
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self animateCurrentFrame];
    NSInteger nearestPage = floorf(self.pageOffset + 0.5);
    self.pageControl.currentPage = nearestPage;
}

#pragma Views
- (void)configureViews{
    [self configureButtonsAndPageControl];

    CGFloat scaleFactor = 1.0;
    CGFloat desginHeight = 667.0;//iPhone6 的设计尺寸
    if (!kDevice_Is_iPhone6 && !kDevice_Is_iPhone6Plus) {
        scaleFactor = kScreen_Height/desginHeight;
    }

    for (int i = 0; i < self.numberOfPages; i++) {
        NSString *imageKey = [self imageKeyForIndex:i];
        NSString *viewKey = [self viewKeyForIndex:i];
        NSString *iconImageName = [self.iconsDict objectForKey:imageKey];
        NSString *tipImageName = [self.tipsDict objectForKey:imageKey];
        
        if (iconImageName) {
            UIImage *iconImage = [UIImage imageNamed:iconImageName];
            if (iconImage) {
                iconImage = scaleFactor != 1.0? [iconImage scaleByFactor:scaleFactor] : iconImage;
                UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
                [self.contentView addSubview:iconView];
                [self.iconsDict setObject:iconView forKey:viewKey];
            }
        }
        
        if (tipImageName) {
            UIImage *tipImage = [UIImage imageNamed:tipImageName];
            if (tipImage) {
                tipImage = scaleFactor != 1.0? [tipImage scaleByFactor:scaleFactor]: tipImage;
                UIImageView *tipView = [[UIImageView alloc] initWithImage:tipImage];
                [self.contentView addSubview:tipView];
                [self.tipsDict setObject:tipView forKey:viewKey];
            }
        }
    }
}

- (void)configureButtonsAndPageControl{
//    Button
    UIColor *darkColor = [UIColor whiteColor];
    CGFloat buttonWidth = kScreen_Width * 0.8;
    CGFloat buttonHeight = kScaleFrom_iPhone5_Desgin(38);
    CGFloat paddingToLeft = kScaleFrom_iPhone5_Desgin(30);
    CGFloat paddingToBottom = kScaleFrom_iPhone5_Desgin(85);
    
    self.loginBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = [UIColor colorWithHexString:@"0x3bbc79"];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [button setTitleColor:darkColor forState:UIControlStateNormal];
        [button setTitle:@"登  录" forState:UIControlStateNormal];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonHeight/2;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = darkColor.CGColor;
        button;
    });
    
    self.registerBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(registerBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"注册新账号" forState:UIControlStateNormal];
        button;
    });
    
    self.gohomeBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(gohomeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"直接进首页" forState:UIControlStateNormal];
        button;
    });
    
    [self.view addSubview:self.gohomeBtn];
    [self.view addSubview:self.registerBtn];
    [self.view addSubview:self.loginBtn];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
        make.left.equalTo(self.view.mas_left).offset(paddingToLeft);
        make.bottom.equalTo(self.view).offset(-paddingToBottom);
    }];
    
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWidth/3, buttonHeight));
        make.left.equalTo(self.loginBtn.mas_left);
        make.top.equalTo(self.loginBtn.mas_bottom).offset(kScaleFrom_iPhone5_Desgin(15));
    }];
    
    [self.gohomeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWidth/3, buttonHeight));
        make.right.equalTo(self.loginBtn.mas_right);
        make.top.equalTo(self.loginBtn.mas_bottom).offset(kScaleFrom_iPhone5_Desgin(15));
    }];
    
//    PageControl
    UIImage *pageIndicatorImage = [UIImage imageNamed:@"intro_dot_unselected"];
    UIImage *currentPageIndicatorImage = [UIImage imageNamed:@"intro_dot_selected"];

    if (!kDevice_Is_iPhone6 && !kDevice_Is_iPhone6Plus) {
        CGFloat desginWidth = 375.0;//iPhone6 的设计尺寸
        CGFloat scaleFactor = kScreen_Width/desginWidth;
        pageIndicatorImage = [pageIndicatorImage scaleByFactor:scaleFactor];
        currentPageIndicatorImage = [currentPageIndicatorImage scaleByFactor:scaleFactor];
    }
    
    self.pageControl = ({
        SMPageControl *pageControl = [[SMPageControl alloc] init];
        pageControl.numberOfPages = self.numberOfPages;
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorImage = pageIndicatorImage;
        pageControl.currentPageIndicatorImage = currentPageIndicatorImage;
        [pageControl sizeToFit];
        pageControl.currentPage = 0;
        pageControl;
    });
    
    [self.view addSubview:self.pageControl];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, kScaleFrom_iPhone5_Desgin(20)));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.loginBtn.mas_top).offset(-kScaleFrom_iPhone5_Desgin(15));
    }];
}


#pragma mark Animations
- (void)configureAnimations{
    [self configureTipAndTitleViewAnimations];
}

- (void)configureTipAndTitleViewAnimations{
    for (int index = 0; index < self.numberOfPages; index++) {
        NSString *viewKey = [self viewKeyForIndex:index];
        UIView *iconView = [self.iconsDict objectForKey:viewKey];
        UIView *tipView = [self.tipsDict objectForKey:viewKey];
        if (iconView) {
            [self keepView:iconView onPage:index];
            
            [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(-kScreen_Height/5);
            }];
            IFTTTAlphaAnimation *iconAlphaAnimation = [IFTTTAlphaAnimation animationWithView:iconView];
            [iconAlphaAnimation addKeyframeForTime:index -0.5 alpha:0.f];
            [iconAlphaAnimation addKeyframeForTime:index alpha:1.f];
            [iconAlphaAnimation addKeyframeForTime:index +0.5 alpha:0.f];
            [self.animator addAnimation:iconAlphaAnimation];
        }
        if (tipView) {
            [self keepView:tipView onPages:@[@(index +1), @(index), @(index-1)] atTimes:@[@(index - 1), @(index), @(index +1)]];

            IFTTTAlphaAnimation *tipAlphaAnimation = [IFTTTAlphaAnimation animationWithView:tipView];
            [tipAlphaAnimation addKeyframeForTime:index -0.5 alpha:0.f];
            [tipAlphaAnimation addKeyframeForTime:index alpha:1.f];
            [tipAlphaAnimation addKeyframeForTime:index +0.5 alpha:0.f];
            [self.animator addAnimation:tipAlphaAnimation];
            
            [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(iconView.mas_bottom).offset(kScaleFrom_iPhone5_Desgin(15));
            }];
        }
    }
}


#pragma mark Action
- (void)registerBtnClicked{
    RegisterViewController *vc = [[RegisterViewController alloc]init];
    vc.methodType = RegisterMethodLogin;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)loginBtnClicked{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.showDismissButton = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)gohomeBtnClicked{
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
}

@end
