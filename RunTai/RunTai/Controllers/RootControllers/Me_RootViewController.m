//
//  Me_RootViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Me_RootViewController.h"
#import "ListsCell.h"
#import "UserInfoCell.h"
#import "UserDescriptionCell.h"
#import "SettingMineInfoViewController.h"
#import "LoginViewController.h"
#import "Login.h"
#import "User.h"

@interface Me_RootViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;

@property (nonatomic, strong) User *curUser;

@end

@implementation Me_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我";
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.contentInset=UIEdgeInsetsMake(kPaddingLeftWidth, 0, 0, 0);
        [tableView registerClass:[ListsCell class] forCellReuseIdentifier:kCellIdentifier_ListsCell];
        [tableView registerClass:[UserInfoCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoCell];
        [tableView registerClass:[UserDescriptionCell class] forCellReuseIdentifier:kCellIdentifier_UserDescriptionCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([Login isLogin]) {
        self.curUser = [Login curLoginUser];
    }
    [self.myTableView reloadData];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

//footer
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section < 2) {
        UIView *footerView = [UIView new];
        footerView.backgroundColor = kColorTableSectionBg;
        return footerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat footerHeight = section < 2? 20: 0.5;
    return footerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section > 0) {
        UIView *headerView = [UIView new];
        headerView.backgroundColor = kColorTableSectionBg;
        return headerView;
    }else{
        return nil;
    }
}

//data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0 || section == 2) {
        row = 2;
    }else if (section == 1){
        row = 4;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoCell forIndexPath:indexPath];
            cell.curUser = self.curUser;
            if (!self.curUser) {
                [cell setLoginBtnClckedBlock:^(UIButton *btn) {
                    [weakSelf loginBtnClicked:btn];
                }];
            }
            return cell;
        }else{
            UserDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserDescriptionCell forIndexPath:indexPath];
            [cell setDescriptionStr:@"客服联系方式: 400-996-2538"];
            return cell;
        }
    }else{
        ListsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ListsCell forIndexPath:indexPath];
        if (indexPath.section == 1){
            switch (indexPath.row) {
                case 0:
                    [cell setImageStr:@"find_people" andTitle:@"我的订单"];
                    break;
                case 1:
                    [cell setImageStr:@"game_center" andTitle:@"我的收藏"];
                    break;
                case 2:
                    [cell setImageStr:@"cast" andTitle:@"推荐润泰"];
                    break;
                case 3:
                    [cell setImageStr:@"more" andTitle:@"关于润泰"];
                    break;
                default:
                    [cell setImageStr:@"cast" andTitle:@"推荐润泰"];
                    break;
            }
        }else if (indexPath.section == 2){
            switch (indexPath.row) {
                case 0:
                    [cell setImageStr:@"app" andTitle:@"使用协议"];
                    break;
                default:
                    [cell setImageStr:@"hot_status" andTitle:@"帮助手册"];
                    break;
            }
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = indexPath.row == 0? [UserInfoCell cellHeight]: [UserDescriptionCell cellHeight];
    }else{
        cellHeight = [ListsCell cellHeight];
    }
    return cellHeight;
}

//selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0 && self.curUser) {
        SettingMineInfoViewController *vc = [[SettingMineInfoViewController alloc]init];
        vc.curUser = self.curUser;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)loginBtnClicked:(UIButton *)btn{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.showDismissButton = YES;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
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
