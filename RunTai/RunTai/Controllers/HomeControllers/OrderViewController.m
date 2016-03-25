//
//  OrderViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "OrderViewController.h"
#import "Input_OnlyText_Cell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Register.h"
#import "Login.h"
#import "User.h"
#import "RunTai_NetAPIManager.h"

@interface OrderViewController ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) Register *myRegister;

@property (nonatomic, strong) User *curUser;

@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;

@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;

@property (assign, nonatomic) int row;

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"申请免费设计";
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    if (!_myRegister) {
        self.myRegister = [Register new];
    }
    if ([Login isLogin]) {
        self.curUser = [Login curLoginUser];
        if (self.curUser) {
            self.row = 2;
            self.myRegister.phone = self.curUser.phone;
            self.myRegister.global_key = self.curUser.global_key;
            self.myRegister.code = @"1111";
        }else{
            self.row = 3;
        }
    }else{
        self.row = 3;
    }
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
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
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"免费申请" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendApplication)];
    [footerV addSubview:_footerBtn];
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.global_key),
                                                              RACObserve(self, myRegister.phone),
                                                              RACObserve(self, myRegister.code)]
                                                     reduce:^id(NSString *global_key,
                                                                NSString *phone,
                                                                NSString *code){
                                                         BOOL enabled = (global_key.length > 0 && phone.length > 0 && code.length > 0);
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
    NSString *tipStr = @"*您的信息将被严格保密，资料提交后客服将在24小时内联系您\n*申请免费设计表示您已同意《润泰装饰 服务条款》";
    lineLabel.text = tipStr;
    [lineLabel addLinkToTransitInformation:@{@"actionStr" : @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"《润泰装饰 服务条款》"]];
    CGRect footerBtnFrame = _footerBtn.frame;
    lineLabel.frame = CGRectMake(CGRectGetMinX(footerBtnFrame), CGRectGetMaxY(footerBtnFrame) +12, CGRectGetWidth(footerBtnFrame), 30);
    [footerV addSubview:lineLabel];
    
    return footerV;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = indexPath.row == 2? self.phoneCodeCellIdentifier: indexPath.row == 1? kCellIdentifier_Input_OnlyText_Cell_Text : kCellIdentifier_Input_OnlyText_Cell_Gender;
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        [cell setPlaceholder:@" 您的称呼" value:self.curUser.name];
        [cell setGenderValue:self.curUser.gender];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.global_key = valueStr;
        };
        cell.genderBtnClckedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.gender = valueStr;
        };
    }else if (indexPath.row == 1){
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 手机号" value:self.curUser.phone];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.myRegister.phone = valueStr;
        };
    }else if (indexPath.row == 2){
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

#pragma mark Btn Clicked
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)sender{
    [self.view endEditing:YES];
    if (![_myRegister.global_key isGK]) {
        [NSObject showHudTipStr:@"您的称呼仅支持汉字和英文字母"];
        return;
    }
    if (![_myRegister.phone isPhoneNo]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    sender.enabled = NO;
    [AVUser requestMobilePhoneVerify:_myRegister.phone withBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [sender startUpTimer];
        }else{
            // 发送失败可以查看 error 里面提供的信息
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 214:
                    [NSObject showHudTipStr:@"该手机号已注册"];
                    break;
                    
                default:
                    [NSObject showHudTipStr:@"验证码发送失败"];
                    break;
            }
            [sender invalidateTimer];
        }
    }];
}

- (void)sendApplication{
    [self.view endEditing:YES];
    if (self.curUser) {
        [[RunTai_NetAPIManager sharedManager] request_CreateProject_WithUser:self.curUser block:^(BOOL succeeded, NSError *error) {
            [self dismissSelf];
            [NSObject showHudTipStr:@"免费申请设计成功"];
        }];
    }else{
        __weak typeof(self) weakSelf = self;
        [AVUser verifyMobilePhone:_myRegister.code withBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                //验证成功
                
                [weakSelf dismissSelf];
                [NSObject showHudTipStr:@"免费申请设计成功"];
            }else{
                // 发送失败可以查看 error 里面提供的信息
                NSString * errorCode = error.userInfo[@"code"];
                switch (errorCode.intValue) {
                    case 214:
                        [NSObject showHudTipStr:@"您的申请正在处理中，请留意我的订单.."];
                        break;
                        
                    default:
                        [NSObject showHudTipStr:@"免费申请设计失败"];
                        break;
                }
            }
        }];
    }
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
