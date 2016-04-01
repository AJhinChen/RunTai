//
//  CannotLoginViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "CannotLoginViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"
#import "AppDelegate.h"
#import "Login.h"

@interface CannotLoginViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@property (copy, nonatomic) NSString *phone, *code, *password, *confirm_password, *phoneCodeCellIdentifier;

@property (assign, nonatomic) int row;

@end

@implementation CannotLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    self.title = @"重置密码";
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Password];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:self.phoneCodeCellIdentifier];
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
    _row = 4;
    self.myTableView.tableFooterView=[self customFooterView];
    self.myTableView.tableHeaderView = [self customHeaderView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view Header Footer
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.15*kScreen_Height)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
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
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"重置密码" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(footerBtnClicked:)];
    [footerV addSubview:_footerBtn];
    
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, phone),
                                                              RACObserve(self, password),
                                                              RACObserve(self, confirm_password),
                                                              RACObserve(self, code)]
                                                     reduce:^id(NSString *phone, NSString *password, NSString *confirm_password, NSString *code){
                                                         return @((phone && phone.length > 0) && (password && password.length > 0) && (confirm_password && confirm_password.length > 0) && (code && code.length > 0));
                                                     }];
    return footerV;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = indexPath.row == (_row==4?3:2) ? self.phoneCodeCellIdentifier : indexPath.row == 1? kCellIdentifier_Input_OnlyText_Cell_Password: kCellIdentifier_Input_OnlyText_Cell_Text;
    
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 手机号码" value:self.phone];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.phone = valueStr;
        };
    }else if (indexPath.row == 1) {
        [cell setPlaceholder:@" 新密码" value:self.password];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.password = valueStr;
        };
        cell.pwdBtnClckedBlock = ^(UIButton *btn){
            if (btn.selected) {
                _row = 3;
                weakSelf.confirm_password = weakSelf.password;
                [self.myTableView reloadData];
            }else{
                _row = 4;
                weakSelf.confirm_password = @"";
                [self.myTableView reloadData];
            }
        };
    }else if (indexPath.row == (_row == 4?3:2)){
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 手机验证码" value:self.code];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.code = valueStr;
        };
        cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
            [weakSelf phoneCodeBtnClicked:btn];
        };
    }else{
        [cell setPlaceholder:@" 确认密码" value:self.confirm_password];
        cell.textField.secureTextEntry = YES;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.confirm_password = valueStr;
        };
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender{
    [self.view endEditing:YES];
    if (![self.phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    [AVUser requestPasswordResetWithPhoneNumber:self.phone block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        } else {
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                case 213:
                    [NSObject showHudTipStr:@"该手机号还未注册"];
                    break;
                    
                default:
                    [NSObject showHudTipStr:@"验证码发送失败"];
                    break;
            }
            [sender invalidateTimer];
        }
    }];
}

- (void)footerBtnClicked:(id)sender{
    NSString *tipStr = nil;
    if (![self.password isEqualToString:self.confirm_password]){
        tipStr = @"两次输入的密码不一致";
    }else if (self.password.length < 6){
        tipStr = @"新密码不能少于6位";
    }else if (self.password.length > 16){
        tipStr = @"新密码不得长于16位";
    }
    if (tipStr) {
        [NSObject showHudTipStr:tipStr];
        return;
    }
    [self.view endEditing:YES];
    
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        CGSize captchaViewSize = _footerBtn.bounds.size;
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(captchaViewSize.width/2, captchaViewSize.height/2)];
        [_footerBtn addSubview:_activityIndicator];
    }
    [_activityIndicator startAnimating];
    
    self.footerBtn.enabled = NO;
    __weak typeof(self) weakSelf = self;
    [AVUser resetPasswordWithSmsCode:self.code newPassword:self.password block:^(BOOL succeeded, NSError *error) {
        weakSelf.footerBtn.enabled = YES;
        [weakSelf.activityIndicator stopAnimating];
        if (succeeded) {
            [Login setPreUserPhone:self.phone];//记住登录账号
            if (_methodType == CannotLoginMethodLogin) {
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupIntroductionViewController];
            }
            [NSObject showHudTipStr:@"重置密码成功"];
        } else {
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                case 213:
                    [NSObject showHudTipStr:@"该手机号还未注册"];
                    break;
                    
                default:
                    [NSObject showHudTipStr:@"重置密码失败"];
                    break;
            }
        }
    }];
}

- (void)dealloc{
    self.myTableView.delegate = nil;
    self.myTableView.dataSource = nil;
    self.myTableView = nil;
    self.footerBtn = nil;
    self.activityIndicator = nil;
    self.footerBtn = nil;
    self.phoneCodeCellIdentifier = nil;
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
