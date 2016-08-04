//
//  EditProInfoViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/4/6.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "EditProInfoViewController.h"
#import "SettingTextViewController.h"
#import "ActionSheetStringPicker.h"
#import "TitleValueMoreCell.h"
#import "RunTai_NetAPIManager.h"
#import "Helper.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface EditProInfoViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIImage *bgImge;

@end

@implementation EditProInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑订单信息";
    
    //设置导航标题
    [self setupNavigationItem];
    
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = GlobleTableViewBackgroundColor;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValue];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myTableView.tableFooterView = [self tableFooterView];
}

- (void)setupNavigationItem{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClicked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(savePro)];
}

#pragma mark Nav Btn M
- (void)cancelBtnClicked:(id)sender{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)savePro{
    [self.view endEditing:YES];
    [NSObject showLoadingView:@"数据保存中.."];
    [[RunTai_NetAPIManager sharedManager]request_UpdateProInfo_WithParam:_curPro.objectId value:_curPro image:self.bgImge block:^(BOOL succeeded, NSError *error) {
        [NSObject hideLoadingView];
        if (succeeded) {
            [self dismissViewControllerAnimated:YES completion:^{
                [NSObject showHudTipStr:@"数据保存成功"];
            }];
        }else{
            [NSObject showHudTipStr:@"数据保存失败，请重试"];
        }
    }];
    
}

#pragma mark TableM

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row;
    switch (section) {
        case 0:
            row = 4;
            break;
        case 1:
            row = 1;
            break;
        default:
            row = 1;
            break;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = indexPath.row == 0? kCellIdentifier_TitleValue: kCellIdentifier_TitleValueMore;
    TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:
                    [cell setTitleStr:@"客户昵称" valueStr:[NSString stringWithFormat:@"%@%@",_curPro.owner.name,_curPro.owner.gender]];
                    break;
                case 1:
                    [cell setTitleStr:@"地址信息" valueStr:_curPro.full_name];
                    break;
                case 2:
                    [cell setTitleStr:@"报价房型" valueStr:_curPro.name];
                    break;
                case 3:
                    [cell setTitleStr:@"项目进度" valueStr:[Project getProcessingName:_curPro.processing.intValue]];
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:{
            [cell setTitleStr:@"背景图片" valueStr:@"请选择"];
        }
            break;
        default:
            break;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight;
    cellHeight = [TitleValueMoreCell cellHeight];
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 1)];
    headerView.backgroundColor = kColorTableSectionBg;
    [headerView setHeight:20.0];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{//客户昵称
                    return;
                    break;
                case 1:{//地址信息
                    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"地址信息" textValue:_curPro.full_name  doneBlock:^(NSString *textValue) {
                        weakSelf.curPro.full_name = textValue;
                        [self.myTableView reloadData];
                    }];
                    vc.settingType = SettingTypeAddressName;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2:{//报价房型
                    SettingTextViewController *vc = [SettingTextViewController settingTextVCWithTitle:@"报价房型" textValue:_curPro.name  doneBlock:^(NSString *textValue) {
                        weakSelf.curPro.name = textValue;
                        [self.myTableView reloadData];
                    }];
                    vc.settingType = SettingTypeAddressName;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3:{//手机号码
                    NSNumber *processing = [NSNumber numberWithInt:0];
                    if (weakSelf.curPro.processing) {
                        processing = weakSelf.curPro.processing;
                    }
                    [ActionSheetStringPicker showPickerWithTitle:nil rows:@[@[@"上门服务",@"准备阶段", @"拆改阶段",@"水电阶段", @"泥木阶段",@"油漆阶段", @"竣工阶段",@"软装阶段", @"入住阶段"]] initialSelection:@[processing] doneBlock:^(ActionSheetStringPicker *picker, NSArray * selectedIndex, NSArray *selectedValue) {
                        weakSelf.curPro.processing = [selectedIndex firstObject];
                        [weakSelf.myTableView reloadData];
                    } cancelBlock:nil origin:self.view];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:{
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更换背景图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
            [actionSheet showInView:self.view];
        }
            break;
        default:
            break;
        }
    }
}

#pragma mark UIActionSheetDelegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    
    if (buttonIndex == 0) {
        //        拍照
        if (![Helper checkCameraAuthorizationStatus]) {
            return;
        }
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if (buttonIndex == 1){
        //        相册
        if (![Helper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        
    }
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
    
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *editedImage, *originalImage;
        editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        self.bgImge = editedImage;
        _myTableView.tableFooterView = [self tableFooterView:editedImage];
        // 保存原图片到相册中
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            UIImageWriteToSavedPhotosAlbum(originalImage, self, nil, NULL);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIView*)tableFooterView{
    UIImageView *footerV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, (kScreen_Height - 64 - 49 - kPaddingLeftWidth*3)/3 - 6)];
    footerV.contentMode = UIViewContentModeScaleAspectFit;
    [footerV sd_setImageWithURL:[_curPro.background urlImageWithCodePathResizeToView:footerV] placeholderImage:kPlaceholderBackground];
    return footerV;
}

- (UIView*)tableFooterView:(UIImage *)img{
    UIImageView *footerV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, (kScreen_Height - 64 - 49 - kPaddingLeftWidth*3)/3 - 6)];
    footerV.contentMode = UIViewContentModeScaleAspectFit;
    footerV.image = img;
    return footerV;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
    self.myTableView = nil;
    self.view = nil;
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
