//
//  BaseViewController.m
//  WeiBo
//
//  Created by Joel Chen on 16/1/26.
//  Copyright © 2016年 Joel Chen. All rights reserved.
//

#import "BaseViewController.h"
#import "RootTabViewController.h"
#import "AppDelegate.h"
#import "Login.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //边缘不留白
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //初始化navigationView并添加
    self.navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
    
    //这里设置导航栏的全局颜色
    self.navigationView.backgroundColor = [UIColor colorWithHexString:@"0xffffff"];
    
    
    [self.view addSubview:self.navigationView];
    [self.view bringSubviewToFront:self.navigationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 改变导航栏背景透明度
- (void)setNavigationAlpha:(CGFloat)navigationAlpha{
    self.navigationView.backgroundColor = [self.navigationView.backgroundColor colorWithAlphaComponent:navigationAlpha];
}

#pragma mark - 改变导航栏颜色
- (void)setNavigationBackgroundColor:(UIColor *)navigationBackgroundColor{
    self.navigationView.backgroundColor = navigationBackgroundColor;
}

#pragma mark - 设置导航栏标题
- (void)setNavigationTitle:(NSString *)navigationTitle{
    //    根据文本计算宽度
    CGSize labelSize = [navigationTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f]}];
    
    //初始化labelTitle并调整位置
    if (labelSize.width > kScreen_Width) {
        labelSize.width = kScreen_Width;
    }
    self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 42)];
    CGPoint center = self.navigationView.center;
    center.y = center.y + 8;
    self.labelTitle.center = center;
    
    //文字基本设置
    self.labelTitle.textColor = [UIColor blackColor];
    self.labelTitle.numberOfLines = 1;
    self.labelTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.labelTitle.textAlignment = NSTextAlignmentCenter;
    self.labelTitle.font = [UIFont boldSystemFontOfSize:18.0f];
    self.labelTitle.text = navigationTitle;
    [self.navigationView addSubview:self.labelTitle];
}

#pragma mark - 自定义导航栏标题位置视图
- (void)setNavigationTitleView:(UIControl *)navigationTitleView{
    CGPoint titleView;
    titleView.x = kScreen_Width / 2;
    titleView.y = self.navigationView.frame.size.height / 2 + 7;
    navigationTitleView.center = titleView;
    
    [self.navigationView addSubview:navigationTitleView];
}

#pragma mark - 添加导航栏左侧按钮
- (void)setNavigationLeftButton:(UIButton *)navigationLeftButton{
    //判断是文字按钮还是图片按钮，两者坐标稍有不同
    CGFloat leftButtonWidth = navigationLeftButton.frame.size.width;
    CGFloat leftButtonHeight = navigationLeftButton.frame.size.height;
    
    navigationLeftButton.frame = CGRectMake(10, self.navigationView.frame.size.height / 2 - 8, leftButtonWidth, leftButtonHeight);
    
    [self.navigationView addSubview:navigationLeftButton];
}

#pragma mark - 添加导航栏右侧按钮
- (void)setNavigationRightButton:(UIButton *)navigationRightButton{
    //同上
    CGFloat rightButtonWidth = navigationRightButton.frame.size.width;
    CGFloat rightButtonHeight = navigationRightButton.frame.size.height;
    
    navigationRightButton.frame = CGRectMake(kScreen_Width - navigationRightButton.frame.size.width - 10, self.navigationView.frame.size.height / 2 - 8, rightButtonWidth, rightButtonHeight);
    
    [self.navigationView addSubview:navigationRightButton];
}

#pragma mark - 添加导航栏左侧按钮集合
- (void)setNavigationLeftButtons:(NSArray<UIButton *> *)navigationLeftButtons{
    CGFloat firstLeftButtonWidth = navigationLeftButtons[0].frame.size.width;
    CGFloat firstLeftButtonHeight = navigationLeftButtons[0].frame.size.height;
    
    CGFloat secondLeftButtonWidth = navigationLeftButtons[1].frame.size.width;
    CGFloat secondLeftButtonHeight = navigationLeftButtons[1].frame.size.height;
    
    navigationLeftButtons[0].frame = CGRectMake(10, self.navigationView.frame.size.height / 2 - 8, firstLeftButtonWidth, firstLeftButtonHeight);
    navigationLeftButtons[1].frame = CGRectMake(10 + firstLeftButtonWidth + 8, self.navigationView.frame.size.height / 2 - 8, secondLeftButtonWidth, secondLeftButtonHeight);
    //8为两个按钮之间的间隔
    
    [self.navigationView addSubview:navigationLeftButtons[0]];
    [self.navigationView addSubview:navigationLeftButtons[1]];
}

#pragma mark - 添加导航栏右侧按钮集合
- (void)setNavigationRightButtons:(NSArray<UIButton *> *)navigationRightButtons{
    CGFloat firstRightButtonWidth = navigationRightButtons[0].frame.size.width;
    CGFloat firstRightButtonHeight = navigationRightButtons[0].frame.size.height;
    
    CGFloat secondRightButtonWidth = navigationRightButtons[1].frame.size.width;
    CGFloat secondRightButtonHeight = navigationRightButtons[1].frame.size.height;
    
    navigationRightButtons[0].frame = CGRectMake(kScreen_Width - 10 - firstRightButtonWidth, self.navigationView.frame.size.height / 2 - 8, firstRightButtonWidth, firstRightButtonHeight);
    navigationRightButtons[1].frame = CGRectMake(kScreen_Width - 10 - firstRightButtonWidth - 8 - secondRightButtonWidth, self.navigationView.frame.size.height / 2 - 8, secondRightButtonWidth, secondRightButtonHeight);
    //8为两个按钮之间的间隔
    
    [self.navigationView addSubview:navigationRightButtons[0]];
    [self.navigationView addSubview:navigationRightButtons[1]];
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
//
//+ (UIViewController *)presentingVC{
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    if (window.windowLevel != UIWindowLevelNormal)
//    {
//        NSArray *windows = [[UIApplication sharedApplication] windows];
//        for(UIWindow * tmpWin in windows)
//        {
//            if (tmpWin.windowLevel == UIWindowLevelNormal)
//            {
//                window = tmpWin;
//                break;
//            }
//        }
//    }
//    UIViewController *result = window.rootViewController;
//    while (result.presentedViewController) {
//        result = result.presentedViewController;
//    }
//    if ([result isKindOfClass:[RootTabViewController class]]) {
//        result = [(RootTabViewController *)result selectedViewController];
//    }
//    if ([result isKindOfClass:[BaseNavigationController class]]) {
//        result = [(BaseNavigationController *)result topViewController];
//    }
//    return result;
//}
//
//+ (void)presentVC:(UIViewController *)viewController{
//    if (!viewController) {
//        return;
//    }
//    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:viewController];
//    if (!viewController.navigationItem.leftBarButtonItem) {
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissModalViewControllerAnimated:)];
//    }
//    [[self presentingVC] presentViewController:nav animated:YES completion:nil];
//}

#pragma mark Login
- (void)loginOutToLoginVC{
    [Login doLogout];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupIntroductionViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
