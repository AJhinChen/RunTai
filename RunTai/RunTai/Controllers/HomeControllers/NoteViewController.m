//
//  NoteViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/16.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "NoteViewController.h"
#import "DirectorCell.h"
#import "LoggingCell.h"
#import "ListsCell.h"
#import "WXApiRequestHandler.h"
#import "WXApiManager.h"
#import "PopMenu.h"
#import "StaffInfoViewController.h"
#import "RunTai_NetAPIManager.h"
#import "Note.h"
#import "Login.h"
#import "BuyListViewController.h"


#define ORIGINAL_MAX_WIDTH 640.0f
const CGFloat BackGroupHeight = 250;

@interface NoteViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,WXApiManagerDelegate>
{
    
    UITableView *myTableView;
    
    UIImageView *imageBG;
    UIView *BGView;
    
    UILabel *nameLabel;
    UILabel *titleLabel;
    
    UILabel *introLabel;
    UIButton *collectBtn;
}
@property (nonatomic) enum WXScene currentScene;
@property (nonatomic, strong) PopMenu *myPopMenu;
@property (nonatomic, strong) Project *myProject;

@property (strong, nonatomic) NSMutableArray *dataList;

@end

@implementation NoteViewController

@synthesize currentScene = _currentScene;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] initWithCapacity:2];
    }
    if (!_myProject){
        _myProject = [[Project alloc]init];
    }
    //    添加myTableView
    myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate=self;
        tableView.dataSource=self;
        tableView.backgroundColor = GlobleTableViewBackgroundColor;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[DirectorCell class] forCellReuseIdentifier:kCellIdentifier_Director];
        [tableView registerClass:[ListsCell class] forCellReuseIdentifier:kCellIdentifier_ListsCell];
        [tableView registerClass:[LoggingCell class] forCellReuseIdentifier:kCellIdentifier_LoggingCell];
        tableView.contentInset=UIEdgeInsetsMake(BackGroupHeight, 0, 0, 0);
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    //初始化弹出菜单
    __weak typeof(self) weakSelf = self;
    NSArray *menuItems = @[
                           [MenuItem itemWithTitle:@"微信" iconName:@"share_btn_wxsession" index:0],
                           [MenuItem itemWithTitle:@"朋友圈" iconName:@"share_btn_wxtimeline" index:1],
                           ];
    if (!_myPopMenu) {
        _myPopMenu = [[PopMenu alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-0) items:menuItems];
        _myPopMenu.perRowItemCount = 2;
        _myPopMenu.menuAnimationType = kPopMenuAnimationTypeSina;
    }
    @weakify(self);
    _myPopMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem){
        [weakSelf.myPopMenu.realTimeBlurFooter disMiss];
        @strongify(self);
        if (!selectedItem) return;
        switch (selectedItem.index) {
            case 0:
                [self shareToWeChatMsg];
                break;
            case 1:
                [self shareToWeChatFriends];
                break;
            default:
                NSLog(@"%@",selectedItem.title);
                break;
        }
    };
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [self loadNewNote];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[[UIColor colorWithHexString:@"0xffffff"]colorWithAlphaComponent:0.9]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    titleLabel.textColor=[UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[[UIColor colorWithHexString:@"0xffffff"]colorWithAlphaComponent:0.1]] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self closeMenu];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xffffff"]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

-(void)setupUI
{
    
    //
    imageBG=[[UIImageView alloc]init];
    imageBG.frame=CGRectMake(0, -BackGroupHeight, kScreen_Width, BackGroupHeight);
    [imageBG sd_setImageWithURL:[_curPro.background urlImageWithCodePathResizeToView:imageBG] placeholderImage:kPlaceholderBackground];
    imageBG.contentMode = UIViewContentModeScaleToFill;
    
    [myTableView addSubview:imageBG];
    //
    BGView=[[UIView alloc]init];
    BGView.backgroundColor=[UIColor clearColor];
    BGView.frame=CGRectMake(0, -BackGroupHeight, kScreen_Width, BackGroupHeight);
    
    [myTableView addSubview:BGView];
    
    //
    
    CGFloat paddingWidth = kScreen_Width - kPaddingLeftWidth*2;
    CGFloat paddingToLeft = 9;
    CGFloat paddingToBottom = 20;
    
    nameLabel = ({
        UILabel *title = [[UILabel alloc] init];
        title.text = self.curPro.full_name;//@"[南京 金城丽景] 品质北欧简约风";
        title.textColor = [UIColor whiteColor];
        title.font = NotesTitleFont;
        title.textAlignment=NSTextAlignmentLeft;
        title.backgroundColor=[UIColor clearColor];
        
        title;
    });
    
    [BGView addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(paddingWidth, 20));
        make.left.equalTo(BGView.mas_left).offset(paddingToBottom);
        make.bottom.equalTo(BGView.mas_bottom).offset(-paddingToBottom*2);
    }];
    
    
    //introLabel
    
    introLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.text=self.curPro.name;
        intro.textColor = [UIColor whiteColor];
        intro.font = NotesIntroFont;
        intro.textAlignment=NSTextAlignmentLeft;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [BGView addSubview:introLabel];
    
    [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(paddingWidth, 20));
        make.left.equalTo(BGView.mas_left).offset(paddingToBottom);
        make.top.equalTo(nameLabel.mas_bottom).offset(paddingToLeft);
    }];
    
    titleLabel=[[UILabel alloc]init];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.text=self.curPro.owner.name;
    titleLabel.font=NavigationFont;
    titleLabel.textAlignment=NSTextAlignmentCenter;
    CGFloat titleWidth = [titleLabel.text getWidthWithFont:NavigationFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, 25)];
    titleLabel.frame = CGRectMake(0, 0, titleWidth, 25);
    
    self.navigationItem.titleView=titleLabel;
    titleLabel.alpha=0;
    
    collectBtn = [[UIButton alloc]init];
    [collectBtn setBackgroundImage:[UIImage imageWithName:@"composer_rating_icon"] forState:UIControlStateNormal];
    [collectBtn setBackgroundImage:[UIImage imageWithName:@"composer_rating_icon_highlighted"] forState:UIControlStateSelected];
    [collectBtn addTarget:self action:@selector(collectClicked:) forControlEvents:UIControlEventTouchUpInside];
    collectBtn.size = collectBtn.currentBackgroundImage.size;
    UIBarButtonItem *collect = [[UIBarButtonItem alloc] initWithCustomView:collectBtn];
    
    
    
    self.navigationItem.rightBarButtonItems = @[[self BarButtonItemWithBackgroudImageName:@"share_Nav" highBackgroudImageName:@"share_Nav" target:self action:@selector(shareClicked)],collect];
}

- (UIBarButtonItem *)BarButtonItemWithBackgroudImageName:(NSString *)backgroudImage highBackgroudImageName:(NSString *)highBackgroudImageName target:(id)target action:(SEL)action
{
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageWithName:backgroudImage] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithName:highBackgroudImageName] forState:UIControlStateHighlighted];
    
    // 设置按钮的尺寸为背景图片的尺寸
    button.size = button.currentBackgroundImage.size;
    
    // 监听按钮点击
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}



-(void)shareClicked
{
    [_myPopMenu showMenuAtView:kKeyWindow startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100)];
}

-(void)closeMenu{
    if ([_myPopMenu isShowed]) {
        [_myPopMenu dismissMenu];
    }
}

-(void)collectClicked:(UIButton *)btn
{
    if (![Login isLogin]) {
        [NSObject showHudTipStr:@"登录后才能收藏哦!"];
    }else{
        btn.selected = !btn.selected;
        if (btn.selected) {
            [NSObject showLoadingView:@"收藏中.."];
        }else{
            [NSObject showLoadingView:@"取消收藏中.."];
        }
        [[RunTai_NetAPIManager sharedManager]request_CollectNote_WithProject:_curPro.objectId block:^(BOOL succeeded, NSError *error) {
            [NSObject hideLoadingView];
            if (succeeded) {
                if (btn.selected) {
                    [NSObject showHudTipStr:@"收藏成功"];
                }else{
                    [NSObject showHudTipStr:@"取消收藏成功"];
                }
            }else{
                if (btn.selected) {
                    [NSObject showHudTipStr:@"收藏失败"];
                }else{
                    [NSObject showHudTipStr:@"取消收藏失败"];
                }
                btn.selected = !btn.selected;
            }
        }];
    }
}


-(void)rightBtnAction
{
    NSLog(@"rightClick");
}

-(void)shareToWeChatFriends{
    self.currentScene = WXSceneTimeline;
    [self sendAppContent];
}

-(void)shareToWeChatMsg{
    self.currentScene = WXSceneSession;
    [self sendAppContent];
}

static NSString *kAPPContentTitle = @"[润泰装饰]我的装修笔录";
static NSString *kAPPContentDescription = @"前边我虽然说过，要是还没有拿到手，很多事情还不能确定和准备。不过设计这个事情还是可以提前准备的！哈哈！\n刚好有个朋友就是在装修公司做室内设计的，就是麻烦他了！\n特别喜欢它们给我设计的餐厅的部分！卡座！不多说了上图！";
static NSString *kAppContentExInfo = @"http://www.njruntai.com";
static NSString *kAppContnetExURL = @"http://fir.im/runtai";
static NSString *kAppMessageExt = @"http://fir.im/runtai";
static NSString *kAppMessageAction = @"http://fir.im/runtai";

- (void)sendAppContent {
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    UIImage *thumbImage = [self imageByScalingAndCroppingForSourceImage:imageBG.image targetSize:CGSizeMake(180, 180)];
    [WXApiRequestHandler sendAppContentData:data
                                    ExtInfo:self.curPro.objectId
                                     ExtURL:kAppContnetExURL
                                      Title:[NSString stringWithFormat:@"[润泰装饰]%@的装修笔录",self.curPro.owner.name]
                                Description:[NSString stringWithFormat:@"%@%@,点击查看更多详情!",self.curPro.full_name,self.curPro.name]
                                 MessageExt:kAppMessageExt
                              MessageAction:kAppMessageAction
                                 ThumbImage:thumbImage
                                    InScene:_currentScene];
}

- (void)applicationWillEnterBackground{
    myTableView.contentInset=UIEdgeInsetsMake(BackGroupHeight, 0, 0, 0);
    [myTableView setContentOffset:CGPointMake(0.0, -BackGroupHeight) animated:NO];
}



#pragma mark - tableViewDelegate&DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [self.dataList count]+2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DirectorCell *cell = [DirectorCell cellWithTableView:tableView];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setTitle:[NSString stringWithFormat:@"监察:%@",self.curPro.responsible.name] subtitle:[NSString stringWithFormat:@"职称:%@",self.curPro.responsible.professional] value:@"avatar_default_big"];
        return cell;
    }else if (indexPath.section == 1){
        ListsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ListsCell forIndexPath:indexPath];
        NSArray *components = [self.curPro.name componentsSeparatedByString:@"/"];
        switch (indexPath.row) {
            case 0:
                [cell setImageStr:@"list_icon_end" andTitle:[NSString stringWithFormat:@"购物清单: %@",components[0]]];
                break;
            case 1:
                [cell setImageStr:@"list_icon_pre" andTitle:@"实际清单: 16.7万"];
                cell.titleLabel.textColor = [UIColor colorWithHexString:@"0xb0271d"];
                break;
            default:
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }else{
        LoggingCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LoggingCell forIndexPath:indexPath];
        if ([self.dataList count]>0) {
            cell.note = self.dataList[indexPath.section-2];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return [DirectorCell cellHeight];
    }else if(indexPath.section==1){
        return 44.0;
    }else{
        if ([self.dataList count]>0) {
            return [LoggingCell cellHeightWithObj:self.dataList[indexPath.section-2]];
        }else{
            return 44;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section<2) {
        return kPaddingLeftWidth;
    }
    return 45.0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]init];
    if (section >= 2) {
        Note *note = self.dataList[section-2];
        header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 45.0)];
        
        UIView *body = [[UIView alloc]initWithFrame:CGRectMake(0, 1, kScreen_Width, 44.0)];
        body.backgroundColor = [UIColor whiteColor];
        
        UILabel *intro = [[UILabel alloc]initWithFrame:CGRectMake(kPaddingLeftWidth, kPaddingLeftWidth, 70, 44-kPaddingLeftWidth*2)];
        
        intro.text=[Project getProcessingName:note.noteType];
        intro.textColor = [UIColor whiteColor];
        intro.font = NotesIntroFont;
        intro.textAlignment=NSTextAlignmentCenter;
        intro.backgroundColor=[UIColor colorWithHexString:@"0x3bbc79"];
        
        [body addSubview:intro];
        
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(kPaddingLeftWidth*2+80, kPaddingLeftWidth, kScreen_Width-(kPaddingLeftWidth*2+80)*2, 44-kPaddingLeftWidth*2)];
        
        title.text=[NSDate stringFromDate:note.updatedAt];
        title.textColor = [UIColor colorWithHexString:@"0x222222"];
        title.font = NotesIntroFont;
        title.textAlignment=NSTextAlignmentCenter;
        title.backgroundColor=[UIColor clearColor];
        
        [body addSubview:title];
        [header addSubview:body];
    }
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==1) {
        return kPaddingLeftWidth;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc]init];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{
            StaffInfoViewController *vc = [[StaffInfoViewController alloc]init];
            vc.responsible = self.curPro.responsible;
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
        case 1:{
            BuyListViewController *vc = [[BuyListViewController alloc]init];
            vc.dataList = [self.curPro.buylist mutableCopy];
            [self.navigationController pushViewController:vc animated:YES];
        }
        break;
        
        default:
        break;
    }
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset  = scrollView.contentOffset.y;
    CGFloat xOffset = (yOffset + BackGroupHeight)/2;
    
    //修改myTableView.contentInset的高度
    if (-BackGroupHeight<=yOffset && yOffset<-60) {
        myTableView.contentInset=UIEdgeInsetsMake(-yOffset, 0, 0, 0);
        titleLabel.alpha=0;
    }else if(yOffset>=-60){
        myTableView.contentInset=UIEdgeInsetsMake(60, 0, 0, 0);
    }else if (yOffset>=0){
        myTableView.contentInset=UIEdgeInsetsZero;
    }
    
    if (yOffset < -BackGroupHeight) {
        
        CGRect rect = imageBG.frame;
        rect.origin.y = yOffset;
        rect.size.height =  -yOffset ;
        rect.origin.x = xOffset;
        rect.size.width = kScreen_Width + fabs(xOffset)*2;
        
        imageBG.frame = rect;
    }
    
    CGFloat alpha = (yOffset+BackGroupHeight)/(BackGroupHeight-60)+0.1;
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[[UIColor colorWithHexString:@"0xffffff"]colorWithAlphaComponent:alpha]] forBarMetrics:UIBarMetricsDefault];
    titleLabel.textColor=[UIColor blackColor];
    if (alpha >= 0.98) {
        [self.navigationController.navigationBar setShadowImage:nil];
        titleLabel.alpha=1;
    }else{
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
        titleLabel.alpha=0;
    }
    alpha=fabs(alpha);
    alpha=fabs(1-alpha);
    
    alpha=alpha<0.2? 0:alpha-0.2;
    
}


- (UIImage *)imageWithColor:(UIColor *)color
{
    // 描述矩形
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return theImage;
}

#pragma mark image scale utility

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 加载数据
/**
 *  加载最新的数据
 */
- (void)loadNewNote{
    if ([Login isLogin]) {
        User *curUser = [Login curLoginUser];
        if ([curUser.watched containsObject:[AVQuery getObjectOfClass:@"Project" objectId:_curPro.objectId]]) {
            collectBtn.selected = YES;
        }
    }
    
    typeof(self) __weak weakSelf= self;
    [[RunTai_NetAPIManager sharedManager] request_Notes_WithNotes:_curPro.list block:^(NSArray *objects, NSError *error) {
        if ([objects count]>0) {
            _myProject = [weakSelf.myProject configWithObjects:objects type:self.curPro.processing.integerValue];
            // 将新数据插入到旧数据的最后边
            [weakSelf.dataList addObjectsFromArray:_myProject.list];
            [myTableView reloadData];
        }else{
            NSString * errorCode = error.userInfo[@"code"];
            switch (errorCode.intValue) {
                case 28:
                    [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                    break;
                default:
                    [NSObject showHudTipStr:@"没有相关笔录"];
                    break;
            }
        }
    }];
    [[RunTai_NetAPIManager sharedManager] request_WatchNote_WithProject:_curPro.objectId block:^(AVObject *object, NSError *error) {
        if (!error) {
            _curPro.watch_count = [object objectForKey:@"watch_count"];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    myTableView.delegate = nil;
    myTableView.dataSource = nil;
    self.myPopMenu = nil;
    self.myProject = nil;
    myTableView = nil;
    imageBG = nil;
    BGView = nil;
    nameLabel = nil;
    titleLabel = nil;
    introLabel = nil;
    collectBtn = nil;
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
