//
//  BuyListViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/4/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BuyListViewController.h"
#import "BuyListCell.h"
#import "Buy.h"
#import "RunTai_NetAPIManager.h"

@interface BuyListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *myTableView;

@property (strong, nonatomic) NSMutableArray *list;

@end

@implementation BuyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitle = @"购物清单";
    if (!_list) {
        _list = [[NSMutableArray alloc] initWithCapacity:2];
    }
    // Do any additional setup after loading the view.
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height-64) style:UITableViewStylePlain];
        tableView.backgroundColor = GlobleTableViewBackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [tableView registerClass:[BuyListCell class] forCellReuseIdentifier:kCellIdentifier_BuyList];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = [UIColor colorWithHexString:@"0x666666"];
        [self.view addSubview:tableView];
        UIView *footer = [[UIView alloc]init];
        footer.backgroundColor = [UIColor clearColor];
        [tableView setTableFooterView:footer];
//        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
        tableView;
    });
    NavBarButtonItem *leftButtonBack = [NavBarButtonItem buttonWithImageNormal:[UIImage imageNamed:@"navigationbar_back_withtext"]
                                                                 imageSelected:[UIImage imageNamed:@"navigationbar_back_withtext"]]; //添加图标按钮（分别添加图标未点击和点击状态的两张图片）
    
    [leftButtonBack addTarget:self
                       action:@selector(buttonBackToLastView)
             forControlEvents:UIControlEventTouchUpInside]; //按钮添加点击事件
    
    self.navigationLeftButton = leftButtonBack; //添加导航栏左侧按钮集合
    [self loadData];
}

#pragma mark - BarButtonItem method
- (void)buttonBackToLastView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)loadData{
    [NSObject showLoadingView:@""];
    __weak typeof(self) weakSelf = self;
    [[RunTai_NetAPIManager sharedManager]request_BuyList_WithArray:self.dataList block:^(NSArray *objects, NSError *error) {
        [NSObject hideLoadingView];
        if ([objects count]>0) {
            [weakSelf.list removeAllObjects];
            weakSelf.list = [objects mutableCopy];
            [weakSelf.myTableView reloadData];
        }else{
            [weakSelf.myTableView reloadData];
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                default:
                    [NSObject showHudTipStr:@"获取失败，请重试"];
                    break;
            }
        }
    }];
}

-(void)viewDidLayoutSubviews
{
    if ([self.myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.myTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.myTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (!self.list) {
        return 0;
    }
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BuyListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_BuyList forIndexPath:indexPath];
    Buy *buy = self.list[indexPath.row];
    NSString *value = @"";
    if (buy.price && ![buy.price isEqualToString:@""]) {
        value = [NSString stringWithFormat:@"¥%@",buy.price];
    }
    [cell setTitle:[NSString stringWithFormat:@"名称：%@",buy.title] subtitle:buy.subtitle value:value];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [BuyListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
    self.myTableView = nil;
    self.dataList = nil;
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