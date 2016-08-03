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
#import "Home_RootViewController.h"
#import "Projects.h"
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "PopMenu.h"
#import "WebViewController.h"
#import "RunTai_NetAPIManager.h"
#import "ServiceTermsViewController.h"

@interface Me_RootViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;

@property (nonatomic, strong) User *curUser;
@property (nonatomic, strong) PopMenu *myPopMenu;
@property (nonatomic) enum WXScene currentScene;
@property (nonatomic, strong) ProjectCount *pCount;

@end

@implementation Me_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitle = @"我";
    self.pCount = [[ProjectCount alloc]init];

    // Do any additional setup after loading the view.
//    self.automaticallyAdjustsScrollViewInsets=NO;
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-64-49) style:UITableViewStylePlain];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.contentInset=UIEdgeInsetsMake(kPaddingLeftWidth, 0, kPaddingLeftWidth, 0);
        [tableView registerClass:[ListsCell class] forCellReuseIdentifier:kCellIdentifier_ListsCell];
        [tableView registerClass:[UserInfoCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoCell];
        [tableView registerClass:[UserDescriptionCell class] forCellReuseIdentifier:kCellIdentifier_UserDescriptionCell];
        [self.view addSubview:tableView];
//        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
        tableView;
    });
    //初始化弹出菜单
    __weak typeof(self) weakSelf = self;
    NSArray *menuItems = @[
                           [MenuItem itemWithTitle:@"微信" iconName:@"share_btn_wxsession" index:0],
                           [MenuItem itemWithTitle:@"朋友圈" iconName:@"share_btn_wxtimeline" index:1],
                           ];
    if (!_myPopMenu) {
        _myPopMenu = [[PopMenu alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-0) items:menuItems];
        _myPopMenu.perRowItemCount = 2;
        _myPopMenu.menuAnimationType = kPopMenuAnimationTypeSina;
    }
    @weakify(self);
    _myPopMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem){
        [weakSelf.myPopMenu.realTimeBlurFooter disMiss];
        @strongify(self);
        if (!selectedItem) return;
        switch (selectedItem.index) {
            case 0:
                [self shareToWeChatMsg];
                break;
            case 1:
                [self shareToWeChatFriends];
                break;
            default:
                NSLog(@"%@",selectedItem.title);
                break;
        }
    };
}
- (void)loadProCount{
    __weak typeof(self) weakSelf = self;
    [[RunTai_NetAPIManager sharedManager] request_ProjectsCatergoryAndCounts_WithAll:^(ProjectCount *data, NSError *error){
        if (!error) {
            [weakSelf.pCount configWithProjects:data];
        }else{
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                default:
                    [NSObject showHudTipStr:@"获取笔录总数失败,请重试!"];
                    break;
            }
        }
    }];
}


-(void)shareClicked
{
    [_myPopMenu showMenuAtView:kKeyWindow startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100)];
}

-(void)closeMenu{
    if ([_myPopMenu isShowed]) {
        [_myPopMenu dismissMenu];
    }
}

-(void)shareToWeChatFriends{
    self.currentScene = WXSceneTimeline;
    [self sendAppContent];
}

-(void)shareToWeChatMsg{
    self.currentScene = WXSceneSession;
    [self sendAppContent];
}

static NSString *kAPPContentTitle = @"[润泰装饰]我的装修笔录";
static NSString *kAPPContentDescription = @"前边我虽然说过，要是还没有拿到手，很多事情还不能确定和准备。不过设计这个事情还是可以提前准备的！哈哈！\n刚好有个朋友就是在装修公司做室内设计的，就是麻烦他了！\n特别喜欢它们给我设计的餐厅的部分！卡座！不多说了上图！";
static NSString *kAppContentExInfo = @"http://www.njruntai.com";
static NSString *kAppContnetExURL = @"http://fir.im/runtai";
static NSString *kAppMessageExt = @"http://fir.im/runtai";
static NSString *kAppMessageAction = @"http://fir.im/runtai";

- (void)sendAppContent {
    
    UIImage *thumbImage = [UIImage imageNamed:@"icon"];
    [WXApiRequestHandler sendLinkURL:AppDownloadLink TagName:@"[润泰装饰]" Title:@"[润泰装饰]官方APP下载" Description:@"润泰装饰设计，完美家居生活" ThumbImage:thumbImage InScene:_currentScene];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([Login isLogin]) {
        self.curUser = [Login curLoginUser];
        [self loadProCount];
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
    if (section == 0) {
        row = 2;
    }else if (section == 1){
        row = 4;
    }else{
        row = 1;
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
    }else if (indexPath.section == 1){
        Projects *curPro = [[Projects alloc]init];
        switch (indexPath.row) {
            case 0:{
                if (![Login isLogin]) {
                    [NSObject showHudTipStr:@"登录后才能查看哦!"];
                    return;
                }
                if (_pCount.created.intValue == 0) {
                    [NSObject showHudTipStr:@"没有相关笔录可以查看!"];
                    return;
                }
                Home_RootViewController *vc = [[Home_RootViewController alloc]init];
                curPro.type = ProjectsTypeCreated;
                vc.myProjects = curPro;
                vc.pCount = self.pCount;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:{
                if (![Login isLogin]) {
                    [NSObject showHudTipStr:@"登录后才能查看哦!"];
                    return;
                }
                if (_pCount.watched.intValue == 0) {
                    [NSObject showHudTipStr:@"没有相关笔录可以查看!"];
                    return;
                }
                Home_RootViewController *vc = [[Home_RootViewController alloc]init];
                curPro.type = ProjectsTypeWatched;
                vc.myProjects = curPro;
                vc.pCount = self.pCount;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:{
                [self shareClicked];
            }
                break;
            case 3:{
                WebViewController *vc = [WebViewController webVCWithUrlStr:@"http://www.njruntai.com"];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:nav animated:YES completion:nil];
            }
                break;
                
            default:
                break;
        }
    }else{
        ServiceTermsViewController *vc = [[ServiceTermsViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)loginBtnClicked:(UIButton *)btn{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.showDismissButton = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
    self.curUser = nil;
    self.myPopMenu = nil;
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
