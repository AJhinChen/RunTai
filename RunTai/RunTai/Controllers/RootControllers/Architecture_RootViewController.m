//
//  Architecture_RootViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/16.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Architecture_RootViewController.h"
#import "DirectorCell.h"
#import "StaffInfoViewController.h"
#import "RunTai_NetAPIManager.h"
#import "Login.h"

@interface Architecture_RootViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *myTableView;

@property (assign, nonatomic) NSInteger type;/**< segment */

@property (strong, nonatomic) NSMutableArray *dataList;

@end

@implementation Architecture_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = GlobleTableViewBackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[DirectorCell class] forCellReuseIdentifier:kCellIdentifier_Director];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = [UIColor colorWithHexString:@"0x666666"];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    [self setNav];
    [self loadStaffs];
    _type = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNav{
    NSArray *segmentArray = [[NSArray alloc] initWithObjects:@"上海",@"南京", nil];
    UISegmentedControl *segmentCtr = [[UISegmentedControl alloc] initWithItems:segmentArray];
    segmentCtr.frame = CGRectMake(0, 0, 120, 30);
    segmentCtr.selectedSegmentIndex = 0;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:NavigationFont,NSFontAttributeName,[UIColor darkGrayColor], NSForegroundColorAttributeName, nil];
    [segmentCtr setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [segmentCtr setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    segmentCtr.tintColor = [UIColor colorWithHexString:@"0xb0271d"];
    [segmentCtr addTarget:self action:@selector(OnTapSegmentCtr:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentCtr;
}

- (void)loadStaffs{
    [NSObject showLoadingView:@"加载中.."];
    typeof(self) __weak weakSelf= self;
    [[RunTai_NetAPIManager sharedManager] request_LoadStaffs:_type?@"上海":@"南京" :^(NSArray *objects, NSError *error) {
        [NSObject hideLoadingView];
        if ([objects count]>0) {
            for (AVUser *user in objects) {
                [weakSelf.dataList addObject:[Login transfer:user]];
            }
            [weakSelf.myTableView reloadData];
        }
    }];
}

//响应事件
-(void)OnTapSegmentCtr:(UISegmentedControl *)seg{
    NSInteger index = seg.selectedSegmentIndex;
    if (index == 0) {
        _type = 0;
    }else{
        _type = 1;
    }
    [self.dataList removeAllObjects];
    [self loadStaffs];
}

#pragma mark Table M

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DirectorCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Director forIndexPath:indexPath];
    User *curUser = self.dataList[indexPath.section];
    [cell setTitle:[NSString stringWithFormat:@"监察:%@",curUser.name] subtitle:[NSString stringWithFormat:@"职称:%@",curUser.professional] value:curUser.avatar];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [DirectorCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kPaddingLeftWidth;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]init];
//    if (section >= 2) {
//        header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 45.0)];
//        
//        UIView *body = [[UIView alloc]initWithFrame:CGRectMake(0, 1, kScreen_Width, 44.0)];
//        body.backgroundColor = [UIColor whiteColor];
//        
//        UILabel *intro = [[UILabel alloc]initWithFrame:CGRectMake(kPaddingLeftWidth, kPaddingLeftWidth, 70, 44-kPaddingLeftWidth*2)];
//        
//        intro.text=@"前期设计";
//        intro.textColor = [UIColor whiteColor];
//        intro.font = NotesIntroFont;
//        intro.textAlignment=NSTextAlignmentCenter;
//        intro.backgroundColor=[UIColor colorWithHexString:@"0x3bbc79"];
//        
//        [body addSubview:intro];
//        
//        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(kPaddingLeftWidth*2+80, kPaddingLeftWidth, kScreen_Width-(kPaddingLeftWidth*2+80)*2, 44-kPaddingLeftWidth*2)];
//        
//        title.text=@"2016年2月14日";
//        title.textColor = [UIColor colorWithHexString:@"0x222222"];
//        title.font = NotesIntroFont;
//        title.textAlignment=NSTextAlignmentCenter;
//        title.backgroundColor=[UIColor clearColor];
//        
//        [body addSubview:title];
//        [header addSubview:body];
//    }
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc]init];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.frame = CGRectMake(-320, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    [UIView animateWithDuration:0.4 animations:^{
        cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    StaffInfoViewController *vc = [[StaffInfoViewController alloc]init];
    vc.responsible = self.dataList[indexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
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
