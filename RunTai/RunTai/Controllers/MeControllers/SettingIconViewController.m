//
//  SettingIconViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "SettingIconViewController.h"
#import "Helper.h"
#import "RunTai_NetAPIManager.h"
#import "User.h"

@interface SettingIconViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImageView *myImageView;

@end

@implementation SettingIconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitle = @"个人头像";
    self.view.backgroundColor = GlobleTableViewBackgroundColor;
    
    _myImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    _myImageView.contentMode = UIViewContentModeScaleAspectFit;
    _myImageView.backgroundColor = [UIColor clearColor];
    [_myImageView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResizeToView:_myImageView] placeholderImage:kPlaceholderUserIcon];
    [self.view addSubview:_myImageView];
    
    NavBarButtonItem *leftButtonBack = [NavBarButtonItem buttonWithImageNormal:[UIImage imageNamed:@"navigationbar_back_withtext"]
                                                                 imageSelected:[UIImage imageNamed:@"navigationbar_back_withtext"]]; //添加图标按钮（分别添加图标未点击和点击状态的两张图片）
    
    [leftButtonBack addTarget:self
                       action:@selector(buttonBackToLastView)
             forControlEvents:UIControlEventTouchUpInside]; //按钮添加点击事件
    
    self.navigationLeftButton = leftButtonBack; //添加导航栏左侧按钮集合
    NavBarButtonItem *rightButtonBack = [NavBarButtonItem buttonWithImageNormal:[UIImage imageNamed:@"navigationbar_more"]
                                                                 imageSelected:[UIImage imageNamed:@"navigationbar_more_highlighted"]]; //添加图标按钮（分别添加图标未点击和点击状态的两张图片）
    
    [rightButtonBack addTarget:self
                       action:@selector(changeIconClicked)
             forControlEvents:UIControlEventTouchUpInside]; //按钮添加点击事件
    
    self.navigationRightButton = rightButtonBack; //添加导航栏左侧按钮集合
}

#pragma mark - BarButtonItem method
- (void)buttonBackToLastView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeIconClicked{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    [actionSheet showInView:self.view];
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
        [NSObject showLoadingView:@"信息修改中.."];
        UIImage *editedImage, *originalImage;
        editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        __weak typeof(self) weakSelf = self;
        NSString *originalUrl = _curUser.avatar;
        AVFile* photoFile=[AVFile fileWithData:UIImagePNGRepresentation(editedImage)];
        [[RunTai_NetAPIManager sharedManager] request_UpdateUserInfo_WithParam:@"avatar" value:photoFile block:^(BOOL succeeded, NSError *error){
            [NSObject hideLoadingView];
            if (succeeded) {
                if (weakSelf.doneBlock) {
                    weakSelf.doneBlock(photoFile.url);
                    AVUser *curUser = [AVUser currentUser];
                    [curUser setObject:photoFile forKey:@"avatar"];
                    [AVUser changeCurrentUser:curUser save:YES];
                    [Login doLogin:curUser];
                    _myImageView.image = editedImage;
                    [NSObject showHudTipStr:@"更新头像成功"];
                    //删除原始头像文件
                    if (originalUrl && ![originalUrl isEqualToString:@""]) {
                        [[RunTai_NetAPIManager sharedManager] request_DeleteOriginalFile_WithUrl:originalUrl];
                    }
                }
            }else{
                NSString * errorCode = error.userInfo[@"code"];
                switch (errorCode.intValue) {
                    case 28:
                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                        break;
                        
                    default:
                        [photoFile deleteInBackground];
                        [NSObject showHudTipStr:@"更新头像失败"];
                        break;
                }
            }
        }];
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.myImageView = nil;
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
