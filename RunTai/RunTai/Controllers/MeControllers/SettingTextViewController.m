//
//  SettingTextViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "SettingTextViewController.h"
#import "SettingTextCell.h"

@interface SettingTextViewController ()
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSString *myTextValue;
@end

@implementation SettingTextViewController
+ (instancetype)settingTextVCWithTitle:(NSString *)title textValue:(NSString *)textValue doneBlock:(void(^)(NSString *textValue))block{
    SettingTextViewController *vc = [[SettingTextViewController alloc] init];
    vc.title = title;
    vc.textValue = textValue? textValue : @"";
    vc.doneBlock = block;
    vc.settingType = SettingTypeOnlyText;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myTextValue = [_textValue mutableCopy];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem itemWithBtnTitle:@"完成" target:self action:@selector(doneBtnClicked:)] animated:YES];
    @weakify(self);
    RAC(self.navigationItem.rightBarButtonItem, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, myTextValue)] reduce:^id (NSString *newTextValue){
        @strongify(self);
        if ([self.textValue isEqualToString:newTextValue]) {
            return @(NO);
        }else if (self.settingType != SettingTypeOnlyText && newTextValue.length <= 0){
            return @(NO);
        }
        return @(YES);
    }];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[SettingTextCell class] forCellReuseIdentifier:kCellIdentifier_SettingText];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark doneBtn
- (void)doneBtnClicked:(id)sender{
    [self.view endEditing:YES];
    if (self.settingType == SettingTypeUserName) {
        if (![_myTextValue isGK]) {
            [NSObject showHudTipStr:@"称呼字数不能超过6个汉字或英文字母"];
            return;
        }
        if (self.doneBlock) {
            self.doneBlock(_myTextValue);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.settingType == SettingTypeAddressName){
        if ([_myTextValue length]>10) {
            [NSObject showHudTipStr:@"称呼字数不能超过10个汉字或英文字母"];
            return;
        }
        if (self.doneBlock) {
            self.doneBlock(_myTextValue);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark Table M
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    SettingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_SettingText forIndexPath:indexPath];
    [cell setTextValue:_textValue andTextChangeBlock:^(NSString *textValue) {
        weakSelf.myTextValue = textValue;
    }];
    cell.textField.placeholder = self.placeholderStr ?: @"未填写";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    headerView.backgroundColor = kColorTableSectionBg;
    [headerView setHeight:30.0];
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

@end
