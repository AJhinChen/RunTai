//
//  Home_RootViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Home_RootViewController.h"
#import "PopFliterMenu.h"
#import "MJRefresh.h"
#import "NotesCell.h"
#import "NoteViewController.h"
#import "RegisterViewController.h"
#import "MJRefresh.h"
#import "RunTai_NetAPIManager.h"
#import "ProjectCount.h"
#import "TweetSendViewController.h"

@interface Home_RootViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,SWTableViewCellDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableDictionary *myProjectsDict;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *searchedArray;

@property (nonatomic, strong) PopFliterMenu *myFliterMenu;
@property (nonatomic,assign) NSInteger selectNum;  //筛选状态
@property (nonatomic,strong) UIButton *leftNavBtn;
@property (nonatomic,strong) UIButton *orderBtn;

@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *loadedObjects;

@property (strong, nonatomic) ProjectCount *pCount;

@property (assign, nonatomic) NSIndexPath *cellIndexPath;

@end

@implementation Home_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.myProjects) {
        self.myProjects = [[Projects alloc]init];
        self.myProjects.type = ProjectsTypeAll;
    }
    switch (self.myProjects.type) {
        case ProjectsTypeAll:
            self.title = @"全部笔录";
            [self setupNavBtn];
            break;
        case ProjectsTypeCreated:
            self.title = @"我的订单";
            break;
        case ProjectsTypeWatched:
            self.title = @"我收藏的";
            break;
        default:
            self.title = @"全部笔录";
            [self setupNavBtn];
            break;
    }
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    if (!_loadedObjects) {
        _loadedObjects = [[NSMutableArray alloc] initWithCapacity:2];
    }
    [self configSegmentItems];
    
    _selectNum=0;
    _myProjectsDict = [[NSMutableDictionary alloc] initWithCapacity:_segmentItems.count];
    // Do any additional setup after loading the view.
    
    _searchedArray = [NSMutableArray array];
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = GlobleTableViewBackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[NotesCell class] forCellReuseIdentifier:kCellIdentifier_Notes];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = [UIColor colorWithHexString:@"0x666666"];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _mySearchBar = ({
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"业主名/楼盘小区"];
        searchBar;
    });
    _myTableView.tableHeaderView = _mySearchBar;
    
    //初始化过滤目录
    _myFliterMenu = [[PopFliterMenu alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-64) items:nil];
    __weak typeof(self) weakSelf = self;
    _myFliterMenu.clickBlock = ^(NSInteger pageIndex){
        [weakSelf fliterBtnClose:TRUE];
        if (![Login isLogin]) {
            [NSObject showHudTipStr:@"登录后才能查看哦!"];
            return;
        }
        if (pageIndex%2 != 0 || pageIndex == weakSelf.selectNum) {
            return;
        }else{
            weakSelf.selectNum=pageIndex;
            weakSelf.myProjects.type = weakSelf.selectNum/2;
            [weakSelf myFliterMenuAction];
        }
    };
    
    _myFliterMenu.closeBlock=^(){
        [weakSelf closeFliter];
    };
    
    [self setupOrderBtn];
    [self setupRefresh];
    [_myFliterMenu refreshMenuDate:^(ProjectCount *pCount){
        self.pCount = pCount;
        [self myFliterMenuAction];
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openWithWeixin:) name:@"Weixin" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_myFliterMenu.showStatus) {
        [self fliterBtnClose:TRUE];
        [_myFliterMenu dismissMenu];
    }
}

- (void)configSegmentItems{
    _segmentItems = @[@"全部笔录",@"我的订单",@"我的收藏"];
}

- (void)openWithWeixin:(NSNotification *)sender{
    NoteViewController *vc = [[NoteViewController alloc] init];
    vc.curPro = sender.object;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - nav item
- (void)setupNavBtn{
    
    self.navigationItem.leftBarButtonItem = [self BarButtonItemWithBackgroudImageName:@"filtertBtn_normal_Nav" highBackgroudImageName:@"filterBtn_selected_Nav" target:self action:@selector(fliterClicked:)];
}

- (UIBarButtonItem *)BarButtonItemWithBackgroudImageName:(NSString *)backgroudImage highBackgroudImageName:(NSString *)highBackgroudImageName target:(id)target action:(SEL)action
{
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageWithName:backgroudImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithName:highBackgroudImageName] forState:UIControlStateHighlighted];
    
    // 设置按钮的尺寸为背景图片的尺寸
    button.size = button.currentBackgroundImage.size;
    
    // 监听按钮点击
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)setupOrderBtn{
    CGFloat buttonHeight = kScaleFrom_iPhone5_Desgin(45);
    _orderBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(orderClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [button setImage:[UIImage imageNamed:@"tabbar_compose_idea"] forState:UIControlStateNormal];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonHeight/2;
        button;
    });
    [self.view addSubview:_orderBtn];
    
    [_orderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonHeight, buttonHeight));
        make.right.equalTo(self.view.mas_right).offset(-11);
        make.bottom.equalTo(self.view).offset(-60);
    }];
}

- (void)myFliterMenuAction{
    switch (self.myProjects.type) {
        case ProjectsTypeAll:
            self.title = @"全部笔录";
            if (!self.myTableView.tableHeaderView) {
                self.myTableView.tableHeaderView = self.mySearchBar;
            }
            self.myTableView.mj_header.hidden = NO;
            self.myTableView.mj_footer.hidden = NO;
            [self.dataList removeAllObjects];
            [self.loadedObjects removeAllObjects];
            [self.myTableView reloadData];
            [self.myTableView.mj_header beginRefreshing];
            return;
            break;
        case ProjectsTypeCreated:
            self.title = @"我的订单";
            [self.myTableView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
            self.myTableView.tableHeaderView = nil;
            if (self.pCount.created.intValue == 0) {
                self.myTableView.mj_header.hidden = YES;
                self.myTableView.mj_footer.hidden = YES;
                [self.dataList removeAllObjects];
                [self.loadedObjects removeAllObjects];
                [self.myTableView reloadData];
                return;
            }
            break;
        case ProjectsTypeWatched:
            self.title = @"我收藏的";
            [self.myTableView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
            self.myTableView.tableHeaderView = nil;
            //                    if (!self.myTableView.tableHeaderView) {
            //                        self.myTableView.tableHeaderView = self.mySearchBar;
            //                    }
            if (self.pCount.watched.intValue == 0) {
                self.myTableView.mj_header.hidden = YES;
                self.myTableView.mj_footer.hidden = YES;
                [self.dataList removeAllObjects];
                [self.loadedObjects removeAllObjects];
                [self.myTableView reloadData];
                return;
            }
            break;
        default:
            self.title = @"全部笔录";
            break;
    }
    __weak typeof(self) weakSelf = self;
    [[RunTai_NetAPIManager sharedManager]request_Projects_WithType:self.myProjects.type block:^(NSArray *objects, NSError *error) {
        weakSelf.myTableView.mj_header.hidden = YES;
        weakSelf.myTableView.mj_footer.hidden = YES;
        [weakSelf.dataList removeAllObjects];
        [weakSelf.loadedObjects removeAllObjects];
        if ([objects count]>0) {
            weakSelf.myProjects = [weakSelf.myProjects configWithObjects:objects type:weakSelf.myProjects.type];
            // 将新数据插入到旧数据的最后边
            [weakSelf.dataList addObjectsFromArray:weakSelf.myProjects.list];
            [weakSelf.loadedObjects addObjectsFromArray:weakSelf.myProjects.loadedObjectIDs];
            [weakSelf.myTableView reloadData];
        }else{
            [weakSelf.myTableView reloadData];
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                default:
                    [NSObject showHudTipStr:@"获取笔录失败，请重试"];
                    break;
            }
        }
    }];
}

- (void)setupRefresh {
    
    // 1.添加下拉刷新
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewProjects)];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 设置文字
    [header setTitle:@"下拉获取最新笔录" forState:MJRefreshStateIdle];
    [header setTitle:@"释放更新最新笔录" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:13];
    // 设置颜色
    header.stateLabel.textColor = Color(113, 113, 113);
    // 设置header
    self.myTableView.mj_header = header;
    
    // 5.添加上拉加载更多控件
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreProjects)];
    // 设置文字
    [footer setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"全部加载完毕" forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:13];
    
    // 设置颜色
    footer.stateLabel.textColor = Color(113, 113, 113);
    self.myTableView.mj_footer = footer;
}

-(void)orderClicked{
    RegisterViewController *vc = [[RegisterViewController alloc]init];
    vc.methodType = RegisterMethodOrder;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)fliterClicked:(id)sender{
    if (_myFliterMenu.showStatus) {
        [self fliterBtnClose:TRUE];
        [_myFliterMenu dismissMenu];
    }else
    {
        [self fliterBtnClose:FALSE];
        _myFliterMenu.selectNum=_selectNum;
        UIView *presentView=[[[UIApplication sharedApplication].keyWindow rootViewController] view];
        [_myFliterMenu showMenuAtView:presentView];
    }
}

-(void)closeFliter{
    if ([_myFliterMenu showStatus]) {
        [_myFliterMenu dismissMenu];
        [self fliterBtnClose:TRUE];
    }
}

-(void)fliterBtnClose:(BOOL)status{
    [_leftNavBtn setImage:status?[UIImage imageNamed:@"filtertBtn_normal_Nav"]:[UIImage imageNamed:@"filterBtn_selected_Nav"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 加载数据
/**
 *  加载最新的数据
 */
- (void)loadNewProjects{
    
    typeof(self) __weak weakSelf= self;
    [[RunTai_NetAPIManager sharedManager] request_Projects_WithLoadMore:self.loadedObjects block:^(NSArray *objects, NSError *error) {
        if ([objects count]>0) {
            [self.myTableView.mj_header endRefreshing];
            //UITableView开始滚动到的位置（这样一开始headerView是不显示的）
            [self.myTableView setContentOffset:CGPointMake(0.0, 38.0) animated:YES];
            _myProjects = [weakSelf.myProjects configWithObjects:objects type:self.myProjects.type];
            // 将新数据插入到旧数据的最后边
            [self.dataList addObjectsFromArray:_myProjects.list];
            [self.loadedObjects addObjectsFromArray:_myProjects.loadedObjectIDs];
            [weakSelf.myTableView reloadData];
        }else{
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                default:
                    [NSObject showHudTipStr:@"没有更多笔录"];
                    break;
            }
            [self.myTableView.mj_header endRefreshing];
        }
    }];
}

- (void)loadMoreProjects{
    
    typeof(self) __weak weakSelf= self;
    [[RunTai_NetAPIManager sharedManager] request_Projects_WithLoadMore:self.loadedObjects block:^(NSArray *objects, NSError *error) {
        if ([objects count]>0) {
            [self.myTableView.mj_footer endRefreshing];
            _myProjects = [weakSelf.myProjects configWithObjects:objects type:self.myProjects.type];
            // 将新数据插入到旧数据的最后边
            [self.dataList addObjectsFromArray:_myProjects.list];
            [self.loadedObjects addObjectsFromArray:_myProjects.loadedObjectIDs];
            [weakSelf.myTableView reloadData];
        }else{
            // 变为没有更多数据的状态
            [self.myTableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

//按需加载 - 如果目标行与当前行相差超过指定行数，只在目标滚动范围的前后指定3行加载。
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSIndexPath *ip = [self.myTableView indexPathForRowAtPoint:CGPointMake(0, targetContentOffset->y)];
    NSIndexPath *cip = [[self.myTableView indexPathsForVisibleRows] firstObject];
    NSInteger skipCount = 8;
    if (labs(cip.row-ip.row)>skipCount) {
        NSArray *temp = [self.myTableView indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y, self.myTableView.width, self.myTableView.height)];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:temp];
        if (velocity.y<0) {
            NSIndexPath *indexPath = [temp lastObject];
            if (indexPath.row+3<self.dataList.count) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+2 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row+3 inSection:0]];
            }
        } else {
            NSIndexPath *indexPath = [temp firstObject];
            if (indexPath.row>3) {
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-3 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-2 inSection:0]];
                [arr addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
            }
        }
        [_dataList addObjectsFromArray:arr];
    }
}

#pragma mark Table M

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.searchedArray count]>0) {
        return _searchedArray.count;
    }
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotesCell *cell = [NotesCell cellWithTableView:tableView];
    Project *curPro = [[Project alloc]init];
    if ([_searchedArray count]>0) {
        curPro = _searchedArray[indexPath.section];
    }else{
        curPro = self.dataList[indexPath.section];
    }
    cell.curPro = curPro;
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    AVUser *curUser = [AVUser currentUser];
    if (curPro.processing.intValue==0 && [[curUser objectForKey:@"authority"] isEqualToString:@"9"]) {
        cell.rightUtilityButtons = [self rightButtons];
    }
    return cell;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"ios7-telephone"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"compose"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"cross.png"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"list.png"]];
    
    return leftUtilityButtons;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithHexString:@"0x3bbc79"]
//                                                title:@"抢单"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"删除"];
    
    return rightUtilityButtons;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [NotesCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_mySearchBar resignFirstResponder];
    NoteViewController *vc = [[NoteViewController alloc] init];
    Project *curPro = [[Project alloc]init];
    
    if ([_searchedArray count]>0) {
        curPro = _searchedArray[indexPath.section];
//        [self createNotes:_searchedArray[indexPath.section]];
    }else{
        curPro = self.dataList[indexPath.section];
//        [self createNotes:self.dataList[indexPath.section]];
    }
    if (curPro.processing.intValue==0) {
        return;
    }
    vc.curPro = curPro;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kPaddingLeftWidth;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]init];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==self.dataList.count-1) {
        return kPaddingLeftWidth;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc]init];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
}

#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    self.cellIndexPath = [self.myTableView indexPathForCell:cell];
    switch (index) {
        case 0:{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"电话联系" message:[NSString stringWithFormat:@"您确认要电话联系客户吗？"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
            alertView.tag = 111;
            [alertView show];
        }
            break;
        case 1:{
            TweetSendViewController *vc = [[TweetSendViewController alloc] init];
            Project *curPro = self.dataList[self.cellIndexPath.section];
            vc.curPro = curPro;
            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    self.cellIndexPath = [self.myTableView indexPathForCell:cell];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"订单删除警告" message:[NSString stringWithFormat:@"您确认要删除该订单吗？"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认删除",nil];
    alertView.tag = 999;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 111:
            if(buttonIndex!=alertView.cancelButtonIndex){
                
            }
            break;
        case 999:
            if(buttonIndex!=alertView.cancelButtonIndex){
                [NSObject showLoadingView:@"订单删除中.."];
                Project *curPro = self.dataList[self.cellIndexPath.section];
                [[RunTai_NetAPIManager sharedManager]request_DeleteProject_WithProject:curPro.objectId block:^(BOOL succeeded, NSError *error) {
                    [NSObject hideLoadingView];
                    if (succeeded) {
                        [self.dataList removeObjectAtIndex:self.cellIndexPath.section];
                        [self.myTableView deleteSections:[NSIndexSet indexSetWithIndex:self.cellIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [NSObject showHudTipStr:@"删除成功"];
                    }else{
                        NSString * errorCode = error.userInfo[@"code"];
                        switch (errorCode.intValue) {
                            case 28:
                                [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                                break;
                            default:
                                [NSObject showHudTipStr:@"删除失败"];
                                break;
                        }
                    }
                }];
            }
            break;
            
        default:
            break;
    }
    
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [self.mySearchBar resignFirstResponder];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"textDidChange: %@", searchText);
    [self searchUserWithStr:searchText];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked: %@", searchBar.text);
    [searchBar resignFirstResponder];
    [self searchUserWithStr:searchBar.text];
}

- (void)searchUserWithStr:(NSString *)string{
    NSString *strippedStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strippedStr.length > 0) {
        __weak typeof(self) weakSelf = self;
        switch (self.myProjects.type) {
            case ProjectsTypeAll:{
                [[RunTai_NetAPIManager sharedManager] request_SearchProjectOrUser_WithString:string block:^(NSArray *objects, NSError *error) {
                    if ([objects count]>0) {
                        weakSelf.myProjects = [weakSelf.myProjects configWithObjects:objects type:self.myProjects.type];
                        weakSelf.searchedArray = weakSelf.myProjects.list;
                        [weakSelf.myTableView reloadData];
                    }else{
                        [weakSelf.searchedArray removeAllObjects];
                        [weakSelf.myTableView reloadData];
                    }
                }];
            }
                break;
            case ProjectsTypeWatched:{
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@",string];
                NSArray *filteredArray = [weakSelf.dataList filteredArrayUsingPredicate:predicate];
                if ([filteredArray count]>0) {
                    weakSelf.myProjects = [weakSelf.myProjects configWithObjects:filteredArray type:weakSelf.myProjects.type];
                    weakSelf.searchedArray = weakSelf.myProjects.list;
                    [weakSelf.myTableView reloadData];
                }else{
                    [weakSelf.searchedArray removeAllObjects];
                    [weakSelf.myTableView reloadData];
                }
            }
                break;
                
            default:
                break;
        }
    }else{
        [_searchedArray removeAllObjects];
        [_myTableView reloadData];
    }
    
}

- (void)createNotes:(Project *)curPro{
    [NSObject showLoadingView:@"创建中.."];
    NSMutableArray *pic_urls = [NSMutableArray arrayWithCapacity:9];
    for (int i = 0; i<1; i++) {
        UIImage *pic = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i+2]];
        [pic_urls addObject:pic];
    }
    
    [[RunTai_NetAPIManager sharedManager]request_CreateNote_WithProject:curPro.objectId text:@"我和老公都很喜欢简欧风格，让福圣鑫的设计师按我们的想法出的设计图，第一张是我从网上找出图，背景墙铺设壁纸，第二张是我们让设计师出的图，背景墙铺设磁砖，大家看看哪种效果更好呢？给点意见吧" photos:pic_urls type:[NSNumber numberWithInt:1] block:^(BOOL succeeded, NSError *error) {
        [NSObject hideLoadingView];
        if (succeeded) {
            [NSObject showHudTipStr:@"创建笔录成功"];
        }
    }];
}


- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
    _mySearchBar.delegate = nil;
    self.myFliterMenu = nil;
    self.myProjectsDict = nil;
    self.mySearchBar = nil;
    self.myTableView = nil;
    self.searchedArray = nil;
    self.leftNavBtn = nil;
    self.orderBtn = nil;
    self.dataList = nil;
    self.loadedObjects = nil;
    self.pCount = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
