//
//  StaffInfoViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/22.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "StaffInfoViewController.h"
#import "EaseUserHeaderView.h"
#import "UserInfoTextCell.h"
#import "DirectorCell.h"
#import <APParallaxHeader/UIScrollView+APParallaxHeader.h>
#import "MJPhotoBrowser.h"
#import "NoteViewController.h"
#import "RunTai_NetAPIManager.h"
#import "Projects.h"
#import "MJRefresh.h"

@interface StaffInfoViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) EaseUserHeaderView *headerView;

@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *loadedObjects;
@property (nonatomic, strong) Projects *myProjects;

@end

@implementation StaffInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitle = self.responsible.name;
    if (!self.myProjects) {
        self.myProjects = [[Projects alloc]init];
    }
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    if (!_loadedObjects) {
        _loadedObjects = [[NSMutableArray alloc] initWithCapacity:2];
    }
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-64) style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.contentInset=UIEdgeInsetsMake(190, 0, 0, 0);
        [tableView registerClass:[UserInfoTextCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoTextCell];
        [tableView registerClass:[DirectorCell class] forCellReuseIdentifier:kCellIdentifier_Director];
        [self.view addSubview:tableView];
//        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
        tableView;
    });
    __weak typeof(self) weakSelf = self;
    _headerView = [EaseUserHeaderView userHeaderViewWithUser:self.responsible image:[UIImage imageNamed:@"MIDAUTUMNIMAGE"]];
    _headerView.userIconClicked = ^(){
        [weakSelf userIconClicked];
    };
    _headerView.callBtnClicked = ^(){
        [weakSelf callBtnClicked];
    };
    [_myTableView addParallaxWithView:_headerView andHeight:CGRectGetHeight(_headerView.frame)];
    
    [self setupRefresh];
    [self.view bringSubviewToFront:self.navigationView];
    NavBarButtonItem *leftButtonBack = [NavBarButtonItem buttonWithImageNormal:[UIImage imageNamed:@"navigationbar_back_withtext"]
                                                                 imageSelected:[UIImage imageNamed:@"navigationbar_back_withtext"]]; //添加图标按钮（分别添加图标未点击和点击状态的两张图片）
    
    [leftButtonBack addTarget:self
                       action:@selector(buttonBackToLastView)
             forControlEvents:UIControlEventTouchUpInside]; //按钮添加点击事件
    
    self.navigationLeftButton = leftButtonBack; //添加导航栏左侧按钮集合
}

#pragma mark - BarButtonItem method
- (void)buttonBackToLastView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView = nil;
    self.headerView = nil;
    self.dataList = nil;
    self.loadedObjects = nil;
    self.myProjects = nil;
}

- (void)setupRefresh {
    
    // 5.添加上拉加载更多控件
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreProjects)];
    // 设置文字
    [footer setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"全部加载完毕" forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:13];
    
    // 设置颜色
    footer.stateLabel.textColor = Color(113, 113, 113);
    self.myTableView.mj_footer = footer;
    // 马上进入刷新状态
    [self.myTableView.mj_footer beginRefreshing];
}

#pragma mark Table M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (section == 0) {
        row = 3;
    }else{
        row = [self.dataList count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        UserInfoTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoTextCell forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                [cell setTitle:@"所在地" value:self.responsible.location];
                break;
            case 1:
                [cell setTitle:@"职称" value:self.responsible.professional];
                break;
            default:
                [cell setTitle:@"联系方式" value:self.responsible.phone];
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        DirectorCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Director forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        Project *curPro = [[Project alloc]init];
        if ([self.dataList count]>0) {
            curPro = self.dataList[indexPath.row];
        }
//        NSArray *components = [curPro.full_name componentsSeparatedByString:@" "];
//        NSString *address = @"";
//        switch ([components count]) {
//            case 1:
//                address = components[0];
//                break;
//            case 2:
//                address = components[1];
//                break;
//            case 3:
//                address = components[2];
//                break;
//                
//            default:
//                break;
//        }
        [cell setTitle:[NSString stringWithFormat:@"楼盘业主:%@%@",curPro.owner.name,curPro.owner.gender] subtitle:[NSString stringWithFormat:@"户型报价:%@",curPro.name] value:curPro.owner.avatar];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = [UserInfoTextCell cellHeight];
    }else{
        cellHeight = [DirectorCell cellHeight];
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == [self numberOfSectionsInTableView:self.myTableView] -1) {
        return 0.5;
    }
    return 20.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 45.0;
    }
    return 0.5;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]init];
    if (section == 1) {
        header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 45.0)];
        
        UIView *body = [[UIView alloc]initWithFrame:CGRectMake(0, 1, kScreen_Width, 44.0)];
        body.backgroundColor = [UIColor whiteColor];
        
        UILabel *intro = [[UILabel alloc]initWithFrame:CGRectMake(kPaddingLeftWidth, kPaddingLeftWidth, 70, 44-kPaddingLeftWidth*2)];
        
        intro.text=@"Ta的项目";
        intro.textColor = [UIColor whiteColor];
        intro.font = NotesIntroFont;
        intro.textAlignment=NSTextAlignmentCenter;
        intro.backgroundColor=[UIColor colorWithHexString:@"0x3bbc79"];
        
        [body addSubview:intro];
        [header addSubview:body];
    }
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    footerView.backgroundColor = kColorTableSectionBg;
    return footerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1) {
        NoteViewController *vc = [[NoteViewController alloc] init];
        vc.curPro = self.dataList[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark Btn Clicked
- (void)callBtnClicked{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[self.responsible.phone stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
}

- (void)userIconClicked{
    //        显示大图
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.url = [NSURL URLWithString:self.responsible.avatar];
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0;
    browser.photos = [NSArray arrayWithObject:photo];
    [browser show];
}

- (void)loadMoreProjects{
    
    typeof(self) __weak weakSelf= self;
    [[RunTai_NetAPIManager sharedManager] request_Projects_WithUser:self.responsible loaded:self.loadedObjects block:^(NSArray *objects, NSError *error) {
        [self.myTableView.mj_footer endRefreshing];
        if ([objects count]>0) {
            _myProjects = [weakSelf.myProjects configWithObjects:objects type:self.myProjects.type];
            // 将新数据插入到旧数据的最后边
            [self.dataList addObjectsFromArray:_myProjects.list];
            [self.loadedObjects addObjectsFromArray:_myProjects.loadedObjectIDs];
            [weakSelf.myTableView reloadData];
        }else{
            // 变为没有更多数据的状态
            [self.myTableView.mj_footer endRefreshingWithNoMoreData];
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                default:
//                    [NSObject showHudTipStr:@"没有更多笔录"];
                    break;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
