//
//  RegisterViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/14.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "RegisterViewController.h"
#import "Input_OnlyText_Cell.h"
#import "Register.h"
#import "Login.h"
#import "User.h"
#import "AppDelegate.h"
//#import "UIUnderlinedButton.h"
#import "TPKeyboardAvoidingTableView.h"
#import "WebViewController.h"
//#import "CannotLoginViewController.h"
#import "EaseInputTipsView.h"
#import "RunTai_NetAPIManager.h"

@interface RegisterViewController ()<UITableViewDataSource, UITableViewDelegate,TTTAttributedLabelDelegate>

@property (nonatomic, strong) Register *myRegister;

@property (nonatomic, strong) User *curUser;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) EaseInputTipsView *inputTipsView;

@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;

@property (assign, nonatomic) int row;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    if (_methodType == RegisterMethodLogin) {
        self.title = @"注册";
    }else{
        self.title = @"申请免费设计";
    }
    if (!_myRegister) {
        self.myRegister = [Register new];
    }
    if ([Login isLogin]) {
        self.curUser = [Login curLoginUser];
        if (self.curUser) {
            self.row = 2;
            self.myRegister.phone = self.curUser.phone;
            self.myRegister.global_key = self.curUser.global_key;
            self.myRegister.gender = self.curUser.gender;
            self.myRegister.code = @"1111";
            self.myRegister.password = @"pass";
        }else{
            self.row = 4;
        }
    }else{
        self.row = 4;
    }
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Password];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Gender];
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
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:_methodType == RegisterMethodLogin?@"注册":@"免费申请" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.global_key),
                                                              RACObserve(self, myRegister.phone),
                                                              RACObserve(self, myRegister.gender),
                                                              RACObserve(self, myRegister.password),
                                                              RACObserve(self, myRegister.code)]
                                                     reduce:^id(NSString *global_key,
                                                                NSString *phone,
                                                                NSString *gender,
                                                                NSString *password,
                                                                NSString *code){
                                                         BOOL enabled = (global_key.length > 0 &&
                                                                         password.length > 0 && phone.length > 0 && code.length > 0);
                                                         return @(enabled);
                                                     }];
    //label
    UITTTAttributedLabel *lineLabel = ({
        UITTTAttributedLabel *label = [[UITTTAttributedLabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"0x999999"];
        label.numberOfLines = 0;
        label.linkAttributes = kLinkAttributes;
        label.activeLinkAttributes = kLinkAttributesActive;
        label.delegate = self;
        label;
    });
    NSString *tipStr = @"注册 润泰账号 表示您已同意《润泰装饰 服务条款》";
    if (_methodType == RegisterMethodOrder) {
        tipStr = @"*温馨提示：申请前请确保‘我的订单’中没有订单正在‘审核中’，否则将会无法申请！\n*您的信息将被严格保密，资料提交后客服将在24小时内联系您\n*申请免费设计表示您已同意《润泰装饰 服务条款》";
    }
    lineLabel.text = tipStr;
    [lineLabel addLinkToTransitInformation:@{@"actionStr" : @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《润泰装饰 服务条款》"]];
    CGRect footerBtnFrame = _footerBtn.frame;
    lineLabel.frame = CGRectMake(CGRectGetMinX(footerBtnFrame), CGRectGetMaxY(footerBtnFrame) +12, CGRectGetWidth(footerBtnFrame), 65);
    [footerV addSubview:lineLabel];
    
    return footerV;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = indexPath.row == 3? self.phoneCodeCellIdentifier: indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Password: indexPath.row == 1? kCellIdentifier_Input_OnlyText_Cell_Text : kCellIdentifier_Input_OnlyText_Cell_Gender;
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
        [cell setPlaceholder:@" 设置登录密码" value:self.myRegister.password];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.password = valueStr;
        };
    }else if (indexPath.row == 3){
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 手机验证码" value:self.myRegister.code];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.code = valueStr;
        };
        cell.phoneCodeBtnClckedBlock = ^(PhoneCodeButton *btn){
            [weakSelf phoneCodeBtnClicked:btn];
        };
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    [self gotoServiceTermsVC];
}
#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender{
    [self.view endEditing:YES];
    if (![_myRegister.global_key isGK]) {
        [NSObject showHudTipStr:@"称呼字数不能超过6个汉字或英文字母"];
        return;
    }
    if (![_myRegister.phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    if ([_myRegister.password length]<6 || [_myRegister.password length]>16) {
        [NSObject showHudTipStr:@"密码需要6到16位"];
        return;
    }
    sender.enabled = NO;
    //注册
    AVUser *user = [AVUser user];
    user.username = [User makeUsername];
    user.password = _myRegister.password;
    user.mobilePhoneNumber = _myRegister.phone;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        }else{
            // 发送失败可以查看 error 里面提供的信息
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                case 214:{
                    if (_methodType == RegisterMethodOrder) {
                        [AVUser requestMobilePhoneVerify:_myRegister.phone withBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                [NSObject showHudTipStr:@"验证码发送成功"];
                                [sender startUpTimer];
                            }else{
                                // 发送失败可以查看 error 里面提供的信息
                                NSString * errorCode = error.userInfo[@"code"];
                                switch (errorCode.intValue) {
                                    case 28:
                                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                                        break;
                                        
                                    default:
                                        [NSObject showHudTipStr:@"验证码发送失败"];
                                        break;
                                }
                                [sender invalidateTimer];
                            }
                        }];
                    }else{
                        [NSObject showHudTipStr:@"该手机号已注册"];
                        [sender invalidateTimer];
                    }
                }
                    break;
                    
                default:
                    [NSObject showHudTipStr:@"验证码发送失败"];
                    [sender invalidateTimer];
                    break;
            }
        }
    }];
}

- (void)sendRegister{
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [self.footerBtn startQueryAnimate];
    if (self.curUser) {
        [[RunTai_NetAPIManager sharedManager] request_CreateProject_WithUser:self.curUser block:^(BOOL succeeded, NSError *error) {
            [weakSelf.footerBtn stopQueryAnimate];
            if (succeeded) {
                [weakSelf dismissSelf];
                [NSObject showHudTipStr:@"免费申请设计成功"];
            }else{
                NSString * errorCode = error.userInfo[@"code"];
                switch (errorCode.intValue) {
                    case 28:
                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢,请重试"];
                        break;
                    case 999:
                        [NSObject showHudTipStr:@"申请失败，请确认您是否有订单正在审核中"];
                        break;
                    default:
                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢,请重试"];
                        break;
                }
            }
        }];
    }else{
        [AVUser verifyMobilePhone:_myRegister.code withBlock:^(BOOL succeeded, NSError *error) {
            //验证结果
            if (succeeded) {
                AVUser *user = [AVUser currentUser];
                [user setObject:_myRegister.gender forKey:@"gender"];
                [user setObject:_myRegister.global_key forKey:@"name"];
                [user saveInBackground];
                [Login doLogin:user];
                [Login setPreUserPhone:self.myRegister.phone];//记住登录账号
                if (_methodType == RegisterMethodLogin) {
                    [weakSelf.footerBtn stopQueryAnimate];
                    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabViewController];
                    [NSObject showHudTipStr:@"注册成功"];
                }else{
                    [[RunTai_NetAPIManager sharedManager] request_CreateProject_WithUser:self.curUser block:^(BOOL succeeded, NSError *error) {
                        [weakSelf.footerBtn stopQueryAnimate];
                        if (succeeded) {
                            [weakSelf dismissSelf];
                            [NSObject showHudTipStr:@"免费申请设计成功"];
                        }else{
                            NSString * errorCode = error.userInfo[@"code"];
                            switch (errorCode.intValue) {
                                case 28:
                                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                                    break;
                                case 999:
                                    [NSObject showHudTipStr:@"申请失败，请确认您是否有订单正在审核中"];
                                    break;
                                default:
                                    [NSObject showHudTipStr:@"免费申请设计失败,请重试或拨打客服热线!"];
                                    break;
                            }
                        }
                    }];
                }
            }else{
                [weakSelf.footerBtn stopQueryAnimate];
                NSString * errorCode = error.userInfo[@"code"];
                switch (errorCode.intValue) {
                    case 28:
                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                        break;
                    case 603:
                        [NSObject showHudTipStr:@"验证码错误"];
                        break;
                    default:{
                        if (_methodType == RegisterMethodLogin) {
                            [NSObject showHudTipStr:@"注册失败"];
                        }else{
                            [NSObject showHudTipStr:@"免费申请设计失败,请重试或拨打客服热线!"];
                        }
                    }
                        break;
                }
            }
        }];
    }
}

#pragma mark VC
- (void)gotoServiceTermsVC{
    NSString *pathForServiceterms = [[NSBundle mainBundle] pathForResource:@"service_terms" ofType:@"html"];
    WebViewController *vc = [WebViewController webVCWithUrlStr:pathForServiceterms];
    [self.navigationController pushViewController:vc animated:YES];
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
    self.curUser = nil;
    self.footerBtn = nil;
    self.phoneCodeCellIdentifier = nil;
    self.inputTipsView = nil;
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
