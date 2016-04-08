//
//  AddStaffViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/4/8.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "AddStaffViewController.h"
#import "Input_OnlyText_Cell.h"
#import "RunTai_NetAPIManager.h"
#import "Register.h"

@interface AddStaffViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;

@property (nonatomic, strong) Register *myRegister;

@end

@implementation AddStaffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加业务员";
    if (!_myRegister) {
        self.myRegister = [Register new];
    }
    // Do any additional setup after loading the view.//    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Gender];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    [self setupNav];
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

#pragma mark - Nav
- (void)setupNav{
    if (self.navigationController.childViewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(dismissSelf)];
    }
}

- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.2*kScreen_Height)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.2*kScreen_Height)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"润泰装饰设计，完美家居生活！";
    [headerLabel setCenter:headerV.center];
    [headerV addSubview:headerLabel];
    return headerV;
}

- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150)];
    //button
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"添加" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.global_key),
                                                              RACObserve(self, myRegister.phone),
                                                              RACObserve(self, myRegister.gender),
                                                              RACObserve(self, myRegister.professional)]
                                                     reduce:^id(NSString *global_key,
                                                                NSString *phone,
                                                                NSString *gender,
                                                                NSString *professional){
                                                         BOOL enabled = (global_key.length > 0 &&
                                                                         phone.length > 0 &&
                                                                         professional.length > 0);
                                                         return @(enabled);
                                                     }];
    return footerV;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = indexPath.row == 0? kCellIdentifier_Input_OnlyText_Cell_Gender : kCellIdentifier_Input_OnlyText_Cell_Text;
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        [cell setPlaceholder:@" 您的称呼" value:self.myRegister.global_key];
        [cell setGenderValue:self.myRegister.gender];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.global_key = valueStr;
        };
        cell.genderBtnClckedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.gender = valueStr;
        };
    }else if (indexPath.row == 1){
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 手机号" value:self.myRegister.phone];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.phone = valueStr;
        };
    }else if (indexPath.row == 2){
        [cell setPlaceholder:@" 职称" value:self.myRegister.professional];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.professional = valueStr;
        };
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

- (void)sendRegister{
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    if (![_myRegister.global_key isGK]) {
        [NSObject showHudTipStr:@"称呼字数不能超过6个汉字或英文字母"];
        return;
    }
    if (![_myRegister.phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    //注册
    [self.footerBtn startQueryAnimate];
    AVUser *user = [AVUser user];
    user.username = [User makeUsername];
    user.password = @"88888888";
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [weakSelf.footerBtn stopQueryAnimate];
        if (succeeded) {
            [self dismissSelf];
            [user setObject:_myRegister.global_key forKey:@"name"];
            [user setObject:_myRegister.gender forKey:@"gender"];
            [user setObject:_myRegister.professional forKey:@"professional"];
            [user setObject:@"1" forKey:@"authority"];
            user.mobilePhoneNumber = _myRegister.phone;
            [NSObject showHudTipStr:@"添加业务员成功"];
        }else{
            // 发送失败可以查看 error 里面提供的信息
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                default:
                    [NSObject showHudTipStr:@"添加业务员失败"];
                    break;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView = nil;
    self.myRegister = nil;
    self.footerBtn = nil;
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
