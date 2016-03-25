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

static NSString *kAPPContentTitle = @"[润泰装饰]我的装修笔录";
static NSString *kAPPContentDescription = @"前边我虽然说过，要是还没有拿到手，很多事情还不能确定和准备。不过设计这个事情还是可以提前准备的！哈哈！\n刚好有个朋友就是在装修公司做室内设计的，就是麻烦他了！\n特别喜欢它们给我设计的餐厅的部分！卡座！不多说了上图！";
static NSString *kAppContentExInfo = @"<xml>extend info</xml>";
static NSString *kAppContnetExURL = @"http://www.njruntai.com";
static NSString *kAppMessageExt = @"这是第三方带的测试字段";
static NSString *kAppMessageAction = @"<action>dotaliTest</action>";

const CGFloat BackGroupHeight = 250;

@interface NoteViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,WXApiManagerDelegate>
{
    
    UITableView *myTableView;
    
    UIImageView *imageBG;
    UIView *BGView;
    
    UILabel *nameLabel;
    UILabel *titleLabel;
    
    UILabel *introLabel;
}
@property (nonatomic) enum WXScene currentScene;
@property (nonatomic, strong) PopMenu *myPopMenu;

@end

@implementation NoteViewController

@synthesize currentScene = _currentScene;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
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
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[[UIColor colorWithHexString:@"0xffffff"]colorWithAlphaComponent:0]] forBarMetrics:UIBarMetricsDefault];
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
    imageBG.image=[UIImage imageNamed:@"IMG_NotesDemo"];
    
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
        title.text=@"[南京 金城丽景] 品质北欧简约风";
        title.textColor = [UIColor whiteColor];
        title.font = NotesTitleFont;
        title.textAlignment=NSTextAlignmentCenter;
        title.backgroundColor=[UIColor clearColor];
        
        title;
    });
    
    [BGView addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(paddingWidth, 20));
        make.left.equalTo(BGView.mas_left).offset(paddingToLeft);
        make.top.equalTo(BGView.mas_top).offset(BackGroupHeight/2);
    }];
    
    
    //introLabel
    
    introLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.text=@"130㎡/三居/北欧简约/报价:16.7万";
        intro.textColor = [UIColor whiteColor];
        intro.font = NotesIntroFont;
        intro.textAlignment=NSTextAlignmentCenter;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [BGView addSubview:introLabel];
    
    [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(paddingWidth, 20));
        make.left.equalTo(BGView.mas_left).offset(paddingToLeft);
        make.top.equalTo(nameLabel.mas_bottom).offset(paddingToBottom);
    }];
    
    
    titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
    titleLabel.textColor=[UIColor blackColor];
    titleLabel.text=@"[南京 金城丽景]蒋先生";
    titleLabel.textAlignment=NSTextAlignmentCenter;
    
    self.navigationItem.titleView=titleLabel;
    titleLabel.alpha=0;
    
    self.navigationItem.rightBarButtonItems = @[[self BarButtonItemWithBackgroudImageName:@"share_Nav" highBackgroudImageName:@"share_Nav" target:self action:@selector(shareClicked)],[self BarButtonItemWithBackgroudImageName:@"composer_rating_icon" highBackgroudImageName:@"composer_rating_icon_highlighted" target:self action:@selector(collectClicked)]];
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

-(void)collectClicked
{
    
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

- (void)sendAppContent {
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    UIImage *thumbImage = [UIImage imageNamed:@"AppIcon"];
    [WXApiRequestHandler sendAppContentData:data
                                    ExtInfo:kAppContentExInfo
                                     ExtURL:kAppContnetExURL
                                      Title:kAPPContentTitle
                                Description:kAPPContentDescription
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
    
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 6-3;
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
        [cell setTitle:@"监察:业务员1号" subtitle:@"职称:资深项目组成员" value:@"avatar_default_big"];
        return cell;
    }else if (indexPath.section == 1){
        ListsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ListsCell forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                [cell setImageStr:@"list_icon_pre" andTitle:@"报价清单: 23.7万"];
                break;
            case 1:
                [cell setImageStr:@"list_icon_end" andTitle:@"实际清单: 16.7万"];
                cell.titleLabel.textColor = [UIColor colorWithHexString:@"0xb0271d"];
                break;
            default:
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:50];
        return cell;
    }else{
        LoggingCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LoggingCell forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return [DirectorCell cellHeight];
    }else if(indexPath.section==1){
        return 44.0;
    }else{
        return [LoggingCell cellHeight];
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
        header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 45.0)];
        
        UIView *body = [[UIView alloc]initWithFrame:CGRectMake(0, 1, kScreen_Width, 44.0)];
        body.backgroundColor = [UIColor whiteColor];
        
        UILabel *intro = [[UILabel alloc]initWithFrame:CGRectMake(kPaddingLeftWidth, kPaddingLeftWidth, 70, 44-kPaddingLeftWidth*2)];
        
        intro.text=@"前期设计";
        intro.textColor = [UIColor whiteColor];
        intro.font = NotesIntroFont;
        intro.textAlignment=NSTextAlignmentCenter;
        intro.backgroundColor=[UIColor colorWithHexString:@"0x3bbc79"];
        
        [body addSubview:intro];
        
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(kPaddingLeftWidth*2+80, kPaddingLeftWidth, kScreen_Width-(kPaddingLeftWidth*2+80)*2, 44-kPaddingLeftWidth*2)];
        
        title.text=@"2016年2月14日";
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
    if (section==5) {
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
    if (indexPath.section==0) {
        StaffInfoViewController *vc = [[StaffInfoViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
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
    
    CGFloat alpha = (yOffset+BackGroupHeight)/(BackGroupHeight-60);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    myTableView.delegate = nil;
    myTableView.dataSource = nil;
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
