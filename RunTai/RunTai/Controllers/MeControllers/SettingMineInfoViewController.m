//
//  SettingMineInfoViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "SettingMineInfoViewController.h"
#import "TitleValueMoreCell.h"
#import "TitleRImageMoreCell.h"
#import "SettingTextViewController.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetDatePicker.h"
#import "SettingIconViewController.h"
#import "User.h"
#import "RunTai_NetAPIManager.h"
#import "CannotLoginViewController.h"
#import "AddressManager.h"

@interface SettingMineInfoViewController ()<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation SettingMineInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"个人信息";
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = GlobleTableViewBackgroundColor;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValue];
        [tableView registerClass:[TitleRImageMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleRImageMore];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myTableView.tableFooterView = [self tableFooterView];
}

#pragma mark TableM

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row;
    switch (section) {
        case 0:
            row = 6;
            break;
        case 1:
            row = 1;
            break;
        default:
            row = 1;
            break;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        TitleRImageMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleRImageMore forIndexPath:indexPath];
        cell.curUser = self.curUser;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        NSString *cellIdentifier = indexPath.row == 3? kCellIdentifier_TitleValue: kCellIdentifier_TitleValueMore;
        TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        switch (indexPath.section) {
            case 0:{
                switch (indexPath.row) {
                    case 1:
                        [cell setTitleStr:@"称呼" valueStr:_curUser.name];
                        break;
                    case 2:
                        [cell setTitleStr:@"性别" valueStr:_curUser.gender];
                        break;
                    case 3:
                        [cell setTitleStr:@"手机号码" valueStr:_curUser.phone];
                        break;
                    case 4:
                        [cell setTitleStr:@"所在地" valueStr:_curUser.location];
                        break;
                    default:
                        [cell setTitleStr:@"小区名称" valueStr:_curUser.address];
                        break;
                }
            }
                break;
            case 1:{
                if (indexPath.row == 0) {
                    [cell setTitleStr:@"修改密码" valueStr:@""];
                }else{
                    [cell setTitleStr:@"职位" valueStr:@""];
                }
            }
                break;
            default:
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellHeight = [TitleRImageMoreCell cellHeight];
    }else{
        cellHeight = [TitleValueMoreCell cellHeight];
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    headerView.backgroundColor = kColorTableSectionBg;
    [headerView setHeight:20.0];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{//头像
                    SettingIconViewController *vc = [[SettingIconViewController alloc]init];
                    vc.curUser = _curUser;
                    vc.doneBlock = ^(NSString *url){
                        weakSelf.curUser.avatar = url;
                        [self.myTableView reloadData];
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:{//昵称
                    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"称呼" textValue:_curUser.name  doneBlock:^(NSString *textValue) {
                        NSString *preValue = weakSelf.curUser.name;
                        [NSObject showLoadingView:@"信息修改中.."];
                        [[RunTai_NetAPIManager sharedManager] request_UpdateUserInfo_WithParam:@"name" value:textValue block:^(BOOL succeeded, NSError *error){
                            [NSObject hideLoadingView];
                            if (succeeded) {
                                weakSelf.curUser.name = textValue;
                                [NSObject showHudTipStr:@"更新称呼成功"];
                            }else{
                                NSString * errorCode = error.userInfo[@"code"];
                                switch (errorCode.intValue) {
                                    case 28:
                                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                                        break;
                                        
                                    default:
                                        weakSelf.curUser.name = preValue;
                                        [NSObject showHudTipStr:@"更新称呼失败"];
                                        break;
                                }
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    }];
                    vc.settingType = SettingTypeUserName;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2:{//性别
                    NSNumber *gender = [NSNumber numberWithInt:0];
                    if ([_curUser.gender isEqualToString:@"女士"]) {
                        gender = [NSNumber numberWithInt:1];
                    }
                    [ActionSheetStringPicker showPickerWithTitle:nil rows:@[@[@"先生", @"女士"]] initialSelection:@[gender] doneBlock:^(ActionSheetStringPicker *picker, NSArray * selectedIndex, NSArray *selectedValue) {
                        NSString *preValue = weakSelf.curUser.gender;
                        [NSObject showLoadingView:@"信息修改中.."];
                        [[RunTai_NetAPIManager sharedManager] request_UpdateUserInfo_WithParam:@"gender" value:[selectedValue firstObject] block:^(BOOL succeeded, NSError *error){
                            [NSObject hideLoadingView];
                            if (succeeded) {
                                weakSelf.curUser.gender = [selectedValue firstObject];
                                [NSObject showHudTipStr:@"更新性别成功"];
                            }else{
                                NSString * errorCode = error.userInfo[@"code"];
                                switch (errorCode.intValue) {
                                    case 28:
                                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                                        break;
                                        
                                    default:
                                        weakSelf.curUser.gender = preValue;
                                        [NSObject showHudTipStr:@"更新性别失败"];
                                        break;
                                }
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    } cancelBlock:nil origin:self.view];
                }
                    break;
                case 3:{//手机号码
                    return;
//                    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"手机号码" textValue:_curUser.phone  doneBlock:^(NSString *textValue) {
//                        NSString *preValue = weakSelf.curUser.phone;
//                        [[RunTai_NetAPIManager sharedManager] request_UpdateUserInfo_WithParam:@"mobilePhoneNumber" value:weakSelf.curUser.phone block:^(BOOL succeeded, NSError *error){
//                            if (succeeded) {
//                                weakSelf.curUser.phone = textValue;
//                                [weakSelf.myTableView reloadData];
//                                [NSObject showHudTipStr:@"更新手机号码成功"];
//                            }else{
//                                weakSelf.curUser.phone = preValue;
//                                [NSObject showHudTipStr:@"更新手机号码失败"];
//                            }
//                            [weakSelf.myTableView reloadData];
//                        }];
//                    }];
//                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 4:{//所在地
                    NSNumber *firstLevel = nil, *secondLevel = nil;
                    if (_curUser.location && _curUser.location.length > 0) {
                        NSArray *locationArray = [_curUser.location componentsSeparatedByString:@" "];
                        if (locationArray.count == 2) {
                            firstLevel = [AddressManager indexOfFirst:[locationArray firstObject]];
                            secondLevel = [AddressManager indexOfSecond:[locationArray lastObject] inFirst:[locationArray firstObject]];
                        }
                    }
                    if (!firstLevel) {
                        firstLevel = [NSNumber numberWithInteger:0];
                    }
                    if (!secondLevel) {
                        secondLevel = [NSNumber numberWithInteger:0];
                    }
                    
                    [ActionSheetStringPicker showPickerWithTitle:nil rows:@[[AddressManager firstLevelArray], [AddressManager secondLevelMap]] initialSelection:@[firstLevel, secondLevel] doneBlock:^(ActionSheetStringPicker *picker, NSArray * selectedIndex, NSArray *selectedValue) {
                        NSString *location = [selectedValue componentsJoinedByString:@" "];
                        NSString *preValue = weakSelf.curUser.location;
                        [NSObject showLoadingView:@"信息修改中.."];
                        [[RunTai_NetAPIManager sharedManager] request_UpdateUserInfo_WithParam:@"location" value:location block:^(BOOL succeeded, NSError *error){
                            [NSObject hideLoadingView];
                            if (succeeded) {
                                weakSelf.curUser.location = location;
                                [NSObject showHudTipStr:@"更新所在地成功"];
                            }else{
                                NSString * errorCode = error.userInfo[@"code"];
                                switch (errorCode.intValue) {
                                    case 28:
                                        weakSelf.curUser.location = preValue;
                                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                                        break;
                                        
                                    default:
                                        weakSelf.curUser.location = preValue;
                                        [NSObject showHudTipStr:@"更新所在地失败"];
                                        break;
                                }
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    } cancelBlock:nil origin:self.view];
                }
//                    NSNumber *location = [NSNumber numberWithInt:2];
//                    if ([_curUser.location isEqualToString:@"南京"]) {
//                        location = [NSNumber numberWithInt:1];
//                    }else if ([_curUser.location isEqualToString:@"上海"]){
//                        location = [NSNumber numberWithInt:0];
//                    }
//                    [ActionSheetStringPicker showPickerWithTitle:nil rows:@[@[@"上海", @"南京", @"其他地区"]] initialSelection:@[location] doneBlock:^(ActionSheetStringPicker *picker, NSArray * selectedIndex, NSArray *selectedValue) {
//                            NSString *preValue = weakSelf.curUser.location;
//                        
//                            [NSObject showLoadingView:@"信息修改中.."];
//                        [[RunTai_NetAPIManager sharedManager] request_UpdateUserInfo_WithParam:@"location" value:[selectedValue firstObject] block:^(BOOL succeeded, NSError *error){
//                            [NSObject hideLoadingView];
//                                if (succeeded) {
//                                    weakSelf.curUser.location = [selectedValue firstObject];
//                                    [NSObject showHudTipStr:@"更新所在地成功"];
//                                }else{
//                                    NSString * errorCode = error.userInfo[@"code"];
//                                    switch (errorCode.intValue) {
//                                        case 28:
//                                            [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
//                                            break;
//                                            
//                                        default:
//                                            weakSelf.curUser.location = preValue;
//                                            [NSObject showHudTipStr:@"更新所在地失败"];
//                                            break;
//                                    }
//                                }
//                                [weakSelf.myTableView reloadData];
//                            }];
//                    } cancelBlock:nil origin:self.view];
//                }
                    break;
                default:{//小区名称
                    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"小区名称" textValue:_curUser.address  doneBlock:^(NSString *textValue) {
                        NSString *preValue = weakSelf.curUser.address;
                        [NSObject showLoadingView:@"信息修改中.."];
                        [[RunTai_NetAPIManager sharedManager] request_UpdateUserInfo_WithParam:@"address" value:textValue block:^(BOOL succeeded, NSError *error){
                            [NSObject hideLoadingView];
                            if (succeeded) {
                                weakSelf.curUser.address = textValue;
                                [NSObject showHudTipStr:@"更新小区名称成功"];
                            }else{
                                NSString * errorCode = error.userInfo[@"code"];
                                switch (errorCode.intValue) {
                                    case 28:
                                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                                        break;
                                        
                                    default:
                                        weakSelf.curUser.address = preValue;
                                        [NSObject showHudTipStr:@"更新小区名称失败"];
                                        break;
                                }
                            }
                            [weakSelf.myTableView reloadData];
                        }];
                    }];
                    vc.settingType = SettingTypeAddressName;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
            }
        }
            break;
        case 1:{
            switch (indexPath.row) {
                case 0:{//修改密码
                    CannotLoginViewController *vc = [[CannotLoginViewController alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:{//职位
                    
                }
                    break;
            }
        }
            break;
        default:{//退出登录
            
        }
            break;
    }
}

- (UIView*)tableFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 90)];
    UIButton *loginBtn = [UIButton buttonWithStyle:StrapWarningStyle andTitle:@"退出当前账号" andFrame:CGRectMake(10, 0, kScreen_Width-10*2, 45) target:self action:@selector(loginOutBtnClicked:)];
    [loginBtn setCenter:footerV.center];
    [footerV addSubview:loginBtn];
    return footerV;
}

- (void)loginOutBtnClicked:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定要退出当前账号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定退出" otherButtonTitles: nil];
    [actionSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self loginOutToLoginVC];
    }
}

- (void)dealloc{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.myTableView = nil;
    self.view = nil;
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
