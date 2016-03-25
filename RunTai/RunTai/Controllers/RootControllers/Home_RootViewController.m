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

@interface Home_RootViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) Projects *myProjects;
@property (strong, nonatomic) NSMutableDictionary *myProjectsDict;
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *queryingArray, *addedArray, *searchedArray;

@property (nonatomic, strong) PopFliterMenu *myFliterMenu;
@property (nonatomic,assign) NSInteger selectNum;  //筛选状态
@property (nonatomic,strong) UIButton *leftNavBtn;
@property (nonatomic,strong) UIButton *orderBtn;

@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *loadedObjects;

@property (strong, nonatomic) ProjectCount *pCount;

@end

@implementation Home_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.myProjects.type) {
        self.myProjects = [[Projects alloc]init];
        self.myProjects.type = ProjectsTypeAll;
    }
    switch (self.myProjects.type) {
        case ProjectsTypeAll:
            self.title = @"全部笔录";
            break;
        case ProjectsTypeCreated:
            self.title = @"我的订单";
            break;
        case ProjectsTypeWatched:
            self.title = @"我收藏的";
            break;
        default:
            self.title = @"全部笔录";
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
    
    _queryingArray = [NSMutableArray array];
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
        if (pageIndex%2 != 0 || pageIndex == weakSelf.selectNum) {
            return;
        }else{
            weakSelf.selectNum=pageIndex;
            weakSelf.myProjects.type = weakSelf.selectNum/2;
            switch (weakSelf.myProjects.type) {
                case ProjectsTypeAll:
                    weakSelf.title = @"全部笔录";
                    weakSelf.myTableView.mj_header.hidden = NO;
                    weakSelf.myTableView.mj_footer.hidden = NO;
                    [weakSelf.dataList removeAllObjects];
                    [weakSelf.loadedObjects removeAllObjects];
                    [weakSelf.myTableView reloadData];
                    [weakSelf.myTableView.mj_header beginRefreshing];
                    return;
                    break;
                case ProjectsTypeCreated:
                    weakSelf.title = @"我的订单";
                    if (weakSelf.pCount.created.intValue == 0) {
                        weakSelf.myTableView.mj_header.hidden = YES;
                        weakSelf.myTableView.mj_footer.hidden = YES;
                        [weakSelf.dataList removeAllObjects];
                        [weakSelf.loadedObjects removeAllObjects];
                        [weakSelf.myTableView reloadData];
                        return;
                    }
                    break;
                case ProjectsTypeWatched:
                    weakSelf.title = @"我收藏的";
                    if (weakSelf.pCount.watched.intValue == 0) {
                        weakSelf.myTableView.mj_header.hidden = YES;
                        weakSelf.myTableView.mj_footer.hidden = YES;
                        [weakSelf.dataList removeAllObjects];
                        [weakSelf.loadedObjects removeAllObjects];
                        [weakSelf.myTableView reloadData];
                        return;
                    }
                    break;
                default:
                    weakSelf.title = @"全部笔录";
                    break;
            }
            [[RunTai_NetAPIManager sharedManager]request_Projects_WithType:weakSelf.myProjects.type block:^(NSArray *objects, NSError *error) {
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
    };
    
    _myFliterMenu.closeBlock=^(){
        [weakSelf closeFliter];
    };
    
    [self setupNavBtn];
    
    [self setupOrderBtn];
    
    [self setupRefresh];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_myFliterMenu refreshMenuDate:^(ProjectCount *pCount){
        self.pCount = pCount;
    }];
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
    // 马上进入刷新状态
    [self.myTableView.mj_header beginRefreshing];
    
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
                    [NSObject showHudTipStr:@"没有最新笔录"];
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
    
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotesCell *cell = [NotesCell cellWithTableView:tableView];
    cell.curPro = self.dataList[indexPath.section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [NotesCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self goToUserInfo:[_searchedArray objectAtIndex:indexPath.row]];
    NoteViewController *vc = [[NoteViewController alloc] init];
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
        
    }else{
        [_searchedArray removeAllObjects];
        [_myTableView reloadData];
    }
    
}


- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
    _mySearchBar.delegate = nil;
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
