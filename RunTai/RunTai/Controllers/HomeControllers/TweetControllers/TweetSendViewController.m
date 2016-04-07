//
//  TweetSendViewController.m
//  WeiBo
//
//  Created by Joel Chen on 16/1/29.
//  Copyright © 2016年 Joel Chen. All rights reserved.
//

#import "TweetSendViewController.h"
#import <TPKeyboardAvoiding/TPKeyboardAvoidingTableView.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Helper.h"
#import "JKImagePickerController.h"
#import "TweetSendTextCell.h"
#import "TweetSendImagesCell.h"
#import "JKAssets.h"
#import "RunTai_NetAPIManager.h"
#import "ActionSheetStringPicker.h"
#import "TitleValueMoreCell.h"

@interface TweetSendViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, JKImagePickerControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UITableView *myTableView;

@property (readwrite, nonatomic, strong) NSMutableArray *selectedAssetArray;

@end

@implementation TweetSendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!_curTweet) {
        _curTweet = [Note tweetForSend];
    }else{
        NSMutableArray *pic_urls = [NSMutableArray arrayWithCapacity:9];
        for (NSString *url in _curTweet.pic_urls) {
            TweetImage *photo = [[TweetImage alloc]init];
            photo.assetURL = [NSURL URLWithString:url];
            photo.image = [UIImage imageWithData:[NSData
                                                  dataWithContentsOfURL:[NSURL URLWithString:url]]];
            photo.thumbnailImage = photo.image;
            [pic_urls addObject:photo];
        }
        [_curTweet.pic_urls removeAllObjects];
        [_curTweet.pic_urls addObjectsFromArray:pic_urls];
    }
    
    //设置导航标题
    [self setupNavigationItem];
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetSendTextCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendText];
        [tableView registerClass:[TweetSendImagesCell class] forCellReuseIdentifier:kCellIdentifier_TweetSendImages];
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValue];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self inputViewBecomeFirstResponder];
}

- (BOOL)inputViewBecomeFirstResponder{
    TweetSendTextCell *cell = (TweetSendTextCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell respondsToSelector:@selector(becomeFirstResponder)]) {
        [cell becomeFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationItem {
    NSString *prefix = @"更新笔录";
    NSString *text = [NSString stringWithFormat:@"%@",prefix];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    
    [string addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:[text rangeOfString:prefix]];
    
    
    //创建label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.attributedText = string;
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.width = 100;
    titleLabel.height = 44;
    self.navigationItem.titleView = titleLabel;
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClicked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendTweet)];
    
    
    @weakify(self);
    RAC(self.navigationItem.rightBarButtonItem, enabled) =
    [RACSignal combineLatest:@[RACObserve(self, curTweet.text),
                               RACObserve(self, curTweet.pic_urls)] reduce:^id (NSString *mdStr){
                                   @strongify(self);
                                   return @(![self isEmptyTweet]);
                               }];
    
}

#pragma mark - JKImagePickerControllerDelegate
- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAsset:(JKAssets *)asset isSource:(BOOL)source
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(JKImagePickerController *)imagePicker didSelectAssets:(NSArray *)assets isSource:(BOOL)source
{
    NSMutableArray *selectedAssetArray = [NSMutableArray new];
    [imagePicker.selectedAssetArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [selectedAssetArray addObject:obj];
    }];
    self.selectedAssetArray = selectedAssetArray;
    
    NSMutableArray *selectedAssetURLs = [NSMutableArray new];
    for (JKAssets  *asset in selectedAssetArray) {
        if (asset.assetPropertyURL) {
            [selectedAssetURLs addObject:asset.assetPropertyURL];
        }
    }
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.curTweet.selectedAssetURLs = selectedAssetURLs;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        });
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *pickerImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary writeImageToSavedPhotosAlbum:[pickerImage CGImage] orientation:(ALAssetOrientation)pickerImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        [self.curTweet addASelectedAssetURL:assetURL];
        [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(JKImagePickerController *)imagePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIActionSheet M

- (void)showActionForPhoto{
    [self.view endEditing:YES];
    @weakify(self);
    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"拍照", @"从相册选择"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        @strongify(self);
        [self photoActionSheet:sheet DismissWithButtonIndex:index];
    }] showInView:self.view];
}

- (void)photoActionSheet:(UIActionSheet *)sheet DismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //        拍照
        if (![Helper checkCameraAuthorizationStatus]) {
            return;
        }else if (_curTweet.pic_urls.count > 9) {
            kTipAlert(@"最多只可选择9张照片，已经选满了。先去掉一张照片再拍照呗～");
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
    }else if (buttonIndex == 1){
        //        相册
        if (![Helper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        JKImagePickerController *imagePickerController = [[JKImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.showsCancelButton = YES;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.minimumNumberOfSelection = 1;
        imagePickerController.maximumNumberOfSelection = 9;
        
        NSMutableArray *selectedAssetArray = [NSMutableArray new];
        for (NSURL *url in self.curTweet.selectedAssetURLs) {
            for (JKAssets  *asset in self.selectedAssetArray) {
                if (asset.assetPropertyURL == url) {
                    [selectedAssetArray addObject:asset];
                }
            }
        }
        imagePickerController.selectedAssetArray = selectedAssetArray;
        UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark Table M

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        TweetSendTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetSendText forIndexPath:indexPath];
        cell.tweetContentView.text = _curTweet.text;
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.curTweet.text = valueStr;
        };
        cell.photoBtnBlock = ^(){
            [weakSelf showActionForPhoto];
        };
        return cell;
    }else if(indexPath.row == 1){
        TweetSendImagesCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetSendImages forIndexPath:indexPath];
        cell.curTweet = _curTweet;
        cell.addPicturesBlock = ^(){
            [self showActionForPhoto];
        };
        cell.deleteTweetImageBlock = ^(TweetImage *toDelete){
            [weakSelf.curTweet deleteATweetImage:toDelete];
            [weakSelf.myTableView reloadData];
        };
        return cell;
    }else{
        TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValue forIndexPath:indexPath];
        if (_curPro) {
            [cell setTitleStr:@"项目进度" valueStr:[Project getProcessingName:_curPro.processing.intValue]];
        }else{
            [cell setTitleStr:@"项目进度" valueStr:[Project getProcessingName:_curTweet.noteType]];
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [TweetSendTextCell cellHeight];
    }else if(indexPath.row == 1){
        cellHeight = [TweetSendImagesCell cellHeightWithObj:_curTweet];
    }else if(indexPath.row == 2){
        cellHeight = [TitleValueMoreCell cellHeight];
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==2) {
        NSNumber *processing = [NSNumber numberWithInt:0];
        if (_curPro.processing) {
            processing = _curPro.processing;
        }
        if (_curTweet.noteType) {
            processing = [NSNumber numberWithInteger:_curTweet.noteType];
        }
        __weak typeof(self) weakSelf = self;
        [ActionSheetStringPicker showPickerWithTitle:nil rows:@[@[@"上门服务",@"准备阶段", @"拆改阶段",@"水电阶段", @"泥木阶段",@"油漆阶段", @"竣工阶段",@"软装阶段", @"入住阶段"]] initialSelection:@[processing] doneBlock:^(ActionSheetStringPicker *picker, NSArray * selectedIndex, NSArray *selectedValue) {
            if (weakSelf.curPro) {
                weakSelf.curPro.processing = [selectedIndex firstObject];
            }else{
                weakSelf.curTweet.noteType = ((NSNumber *)[selectedIndex firstObject]).integerValue;
            }
            [weakSelf.myTableView reloadData];
        } cancelBlock:nil origin:self.view];
    }
}


#pragma mark Nav Btn M
- (void)cancelBtnClicked:(id)sender{
    [self dismissSelfWithCompletion:nil];
}

- (void)dismissSelfWithCompletion:(void (^)(void))completion{
    [self.view endEditing:YES];
    TweetSendTextCell *cell = (TweetSendTextCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell.footerToolBar) {
        [cell.footerToolBar removeFromSuperview];
    }
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (BOOL)isEmptyTweet{
    BOOL isEmptyTweet = YES;
    if ((_curTweet.text && ![_curTweet.text isEmptyOrListening])//内容不为空
        || _curTweet.pic_urls.count > 0)//有照片
    {
        isEmptyTweet = NO;
    }
    return isEmptyTweet;
}

- (void)sendTweet{
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [NSObject showLoadingView:@"发送中..."];
    if (self.curPro) {
        [[RunTai_NetAPIManager sharedManager]request_CreateNote_WithProject:self.curPro.objectId text:self.curTweet.text photos:self.curTweet.pic_urls type:self.curPro.processing block:^(BOOL succeeded, NSError *error) {
            [NSObject hideLoadingView];
            if (succeeded) {
                [weakSelf cancelBtnClicked:nil];
                [NSObject showHudTipStr:@"添加笔录成功"];
            }else{
                [NSObject showHudTipStr:@"添加笔录失败，请重试"];
            }
        }];
    }else{
        [[RunTai_NetAPIManager sharedManager]request_UpdateNote_WithNoteId:self.curTweet.objectId text:self.curTweet.text photos:self.curTweet.pic_urls type:[NSNumber numberWithInteger:self.curTweet.noteType] block:^(BOOL succeeded, NSError *error) {
            [NSObject hideLoadingView];
            if (succeeded) {
                [weakSelf cancelBtnClicked:nil];
                [NSObject showHudTipStr:@"修改笔录成功"];
            }else{
                [NSObject showHudTipStr:@"修改笔录失败，请重试"];
            }
        }];
    }
}

- (void)enableNavItem:(BOOL)isEnable{
    self.navigationItem.leftBarButtonItem.enabled = isEnable;
    self.navigationItem.rightBarButtonItem.enabled = isEnable;
}

- (void)dealloc
{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
    self.curTweet = nil;
    self.curPro = nil;
    self.selectedAssetArray = nil;
}

#pragma mark
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.myTableView) {
        [self.view endEditing:YES];
    }
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
