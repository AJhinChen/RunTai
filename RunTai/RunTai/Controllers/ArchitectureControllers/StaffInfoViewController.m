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

@interface StaffInfoViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) EaseUserHeaderView *headerView;

@end

@implementation StaffInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"业务员1号";
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.contentInset=UIEdgeInsetsMake(190, 0, 0, 0);
        [tableView registerClass:[UserInfoTextCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoTextCell];
        [tableView registerClass:[DirectorCell class] forCellReuseIdentifier:kCellIdentifier_Director];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    __weak typeof(self) weakSelf = self;
    User *user = [User new];
    user.phone = @"12312";
    user.name = @"业务员1号";
    user.gender = [NSNumber numberWithInt:0];
    _headerView = [EaseUserHeaderView userHeaderViewWithUser:user image:[UIImage imageNamed:@"MIDAUTUMNIMAGE.jpg"]];
    _headerView.userIconClicked = ^(){
        [weakSelf userIconClicked];
    };
    _headerView.fansCountBtnClicked = ^(){
        [weakSelf fansCountBtnClicked];
    };
    _headerView.followsCountBtnClicked = ^(){
        [weakSelf followsCountBtnClicked];
    };
    [_myTableView addParallaxWithView:_headerView andHeight:CGRectGetHeight(_headerView.frame)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
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
        row = 14;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        UserInfoTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoTextCell forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                [cell setTitle:@"所在地" value:@"南京"];
                break;
            case 1:
                [cell setTitle:@"职称" value:@"部门经理"];
                break;
            default:
                [cell setTitle:@"联系方式" value:@"15919161012"];
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }else{
        DirectorCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Director forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setTitle:@"楼盘业主:[南京 金城丽景]蒋先生" subtitle:@"户型报价:130㎡/三居/北欧简约/16.7万" value:@"avatar_default_big"];
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
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark Btn Clicked
- (void)fansCountBtnClicked{
    
}
- (void)followsCountBtnClicked{
    
}

- (void)userIconClicked{
    //        显示大图
    MJPhoto *photo = [[MJPhoto alloc] init];
//    photo.url = [_curUser.avatar urlWithCodePath];
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0;
    browser.photos = [NSArray arrayWithObject:photo];
    [browser show];
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
