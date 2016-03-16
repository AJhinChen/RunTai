//
//  RootTabViewController.m
//  WeiBo
//
//  Created by Joel Chen on 16/1/26.
//  Copyright © 2016年 Joel Chen. All rights reserved.
//

#import "RootTabViewController.h"
#import "Home_RootViewController.h"
#import "Gallery_RootViewController.h"
#import "Me_RootViewController.h"
#import "RDVTabBarItem.h"
#import "BaseNavigationController.h"

@interface RootTabViewController ()

@end

@implementation RootTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [self setupViewControllers];
    
    //1.添加所有的自控制器
    [self addAllChildVcs];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Private_M
- (void)addAllChildVcs
{
    
    Home_RootViewController *home = [[Home_RootViewController alloc] init];
    [self addOneChildVc:home title:@"首页" imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected"];
    
    Gallery_RootViewController *message = [[Gallery_RootViewController alloc] init];
    [self addOneChildVc:message title:@"图库" imageName:@"tabbar_photo" selectedImageName:@"tabbar_photo_selected"];
    
    Me_RootViewController *profile = [[Me_RootViewController alloc] init];
    [self addOneChildVc:profile title:@"我" imageName:@"tabbar_profile" selectedImageName:@"tabbar_profile_selected"];
}

/**
 *  添加一个子控制器
 *
 *  @param childVc           子控制器对象
 *  @param title             标题
 *  @param imageName         图标
 *  @param selectedImageName 选中的图标
 */

- (void)addOneChildVc:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    
    //    childVc.view.backgroundColor = RandomColor;
    
    //设置标题
    childVc.title = title;
    if ([childVc class] == [Home_RootViewController class]){
        childVc.navigationItem.title = @"装修笔录";
    }
    if ([childVc class] == [Gallery_RootViewController class]){
        childVc.navigationItem.title = @"设计师的仓库";
    }
    
    //设置图标
    childVc.tabBarItem.image = [UIImage imageNamed:imageName];
    childVc.tabBarItem.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    childVc.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    
    //设置tabbar字体
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor], NSForegroundColorAttributeName,[UIFont systemFontOfSize:12],NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    //设置选中图标
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    if (iOS7) {
        //声明这张图用原图
        selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    childVc.tabBarItem.selectedImage = selectedImage;
    
    //添加导航控制器
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
}

@end
