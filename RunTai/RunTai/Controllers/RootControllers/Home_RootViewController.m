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

@interface Home_RootViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *queryingArray, *addedArray, *searchedArray;

@property (nonatomic, strong) PopFliterMenu *myFliterMenu;
@property (nonatomic,assign) NSInteger selectNum;  //筛选状态
@property (nonatomic,strong)UIButton *leftNavBtn;

@end

@implementation Home_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
        //UITableView开始滚动到的位置（这样一开始headerView是不显示的）
        [tableView setContentOffset:CGPointMake(0.0, 34.0) animated:NO];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _mySearchBar = ({
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"项目编号/楼盘小区"];
        searchBar;
    });
    _myTableView.tableHeaderView = _mySearchBar;
    
    //初始化过滤目录
    _myFliterMenu = [[PopFliterMenu alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-64) items:nil];
    __weak typeof(self) weakSelf = self;
    _myFliterMenu.clickBlock = ^(NSInteger pageIndex){
        if (pageIndex==1000) {
//            [weakSelf goToProjectSquareVC];
        }else
        {
            [weakSelf fliterBtnClose:TRUE];
//            [weakCarousel scrollToItemAtIndex:pageIndex animated:NO];
            weakSelf.selectNum=pageIndex;
        }
    };
    
    _myFliterMenu.closeBlock=^(){
        [weakSelf closeFliter];
    };
    
    [self setupNavBtn];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_myFliterMenu.showStatus) {
        [self fliterBtnClose:TRUE];
        [_myFliterMenu dismissMenu];
    }
}

#pragma mark - nav item
- (void)setupNavBtn{
    
    self.navigationItem.leftBarButtonItem = [self BarButtonItemWithBackgroudImageName:@"filtertBtn_normal_Nav" highBackgroudImageName:@"filtertBtn_normal_Nav_highlighted" target:self action:@selector(fliterClicked:)];
    
    self.navigationItem.rightBarButtonItem = [self BarButtonItemWithBackgroudImageName:@"navigationbar_compose" highBackgroudImageName:@"navigationbar_compose_highlighted" target:self action:@selector(orderClicked:)];
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

-(void)orderClicked:(id)sender{
    
}

-(void)fliterClicked:(id)sender{
    if (_myFliterMenu.showStatus) {
        [self fliterBtnClose:TRUE];
        [_myFliterMenu dismissMenu];
    }else
    {
        [self fliterBtnClose:FALSE];
        _myFliterMenu.selectNum=_selectNum>=3?_selectNum+1:_selectNum;
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

#pragma mark Table M

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotesCell *cell = [NotesCell cellWithTableView:tableView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [NotesCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self goToUserInfo:[_searchedArray objectAtIndex:indexPath.row]];
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
    if (section==3) {
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
