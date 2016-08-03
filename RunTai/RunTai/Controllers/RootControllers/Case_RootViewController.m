//
//  Case_RootViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/30.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#import "Case_RootViewController.h"
#import "DropdownMenuSegue.h"
#import "CaseImageCell.h"
#import "Case.h"

@interface Case_RootViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSTimer *_timer;
    BOOL _isDown1;
    BOOL _isDown2;
}

@property (nonatomic, readonly) CGFloat offset;

@property (nonatomic,strong) UITableView *contentTable1;
@property (nonatomic,strong) UITableView *contentTable2;

@property (nonatomic,strong) NSMutableArray *dataArray1;
@property (nonatomic,strong) NSMutableArray *dataArray2;
@property (nonatomic,strong) NSArray *dataArrs;
@property (nonatomic,strong) NSArray *dataArr;

- (void)iOS6_hideMenuCompleted;

@end

@implementation Case_RootViewController {
    bool shouldDisplayDropShape;
    float fadeAlpha;
    float trianglePlacement;
}

CAShapeLayer *openMenuShape;
CAShapeLayer *closedMenuShape;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitle = @"全部案例";
    shouldDisplayDropShape = YES;
    fadeAlpha = 0.5f;
    trianglePlacement = 0.87f;
    _isDown1                    = NO;
    _isDown2                    = NO;
    self.currentViewController = self;
    
    // Draw the shapes for the open and close menu triangle.
    [self drawOpenLayer];
    [self drawClosedLayer];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self initContentTableView];//初始化两个tableView
    [self initDataArray];//将原数据分组
    [self initNav];
}
- (void)initContentTableView
{
    self.contentTable1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width/2, kScreen_Height - 109)];
    self.contentTable1.delegate =self;
    self.contentTable1.dataSource = self;
    self.contentTable1.backgroundColor = GlobleTableViewBackgroundColor;
    self.contentTable1.separatorColor= [UIColor clearColor];
    self.contentTable1.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTable1.showsVerticalScrollIndicator = NO;
    [self.contentTable1 registerClass:[CaseImageCell class] forCellReuseIdentifier:kCellIdentifier_CaseImageCell];
    [self.view addSubview:self.contentTable1];
    
    self.contentTable2 = [[UITableView alloc] initWithFrame:CGRectMake(kScreen_Width/2, 64, kScreen_Width/2, kScreen_Height - 109)];
    self.contentTable2.delegate = self;
    self.contentTable2.dataSource = self;
    self.contentTable2.backgroundColor = GlobleTableViewBackgroundColor;
    self.contentTable2.separatorColor= [UIColor clearColor];
    self.contentTable2.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.contentTable2.showsVerticalScrollIndicator = NO;
    [self.contentTable2 registerClass:[CaseImageCell class] forCellReuseIdentifier:kCellIdentifier_CaseImageCell];
    [self.view addSubview:self.contentTable2];
    
}
- (void)initDataArray
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"case" ofType:@"json"];
    NSError *error = nil;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
    if (jsonObject) {
        self.dataArrs = [Case configWithObjects:jsonObject];
    }
    [self loadDataWithType:0];
    
}

- (void)loadDataWithType:(int)type{
    switch (type) {
        case 0:
            self.labelTitle.text = @"全部案例";
            break;
        case 1:
            self.labelTitle.text = @"复式案例";
            break;
        case 2:
            self.labelTitle.text = @"别墅案例";
            break;
        case 3:
            self.labelTitle.text = @"公寓案例";
            break;
            
        default:
            break;
    }
    self.tabBarItem.title = @"图库";
    self.dataArr = self.dataArrs[type];
    self.dataArray1 = [[NSMutableArray alloc] initWithCapacity:0];
    self.dataArray2 = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i = 0; i < self.dataArr.count; i ++)
    {
        if (i % 2 == 0)
        {
            [self.dataArray1 addObject:self.dataArr[i]];
        }
        else if (i % 2 != 0)
        {
            [self.dataArray2 addObject:self.dataArr[i]];
        }
    }
    [self.contentTable1 reloadData];
    [self.contentTable2 reloadData];
    [_timer invalidate];
    if ([self.dataArr count]>8) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    }
}

- (void)initNav{
    
    self.container = ({
        UIView *container = [[UIView alloc] init];
        container.backgroundColor = [UIColor clearColor];
        container.userInteractionEnabled = YES;
        //添加手势
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerOnTap)];
        [container addGestureRecognizer:gestureRecognizer];
        container.hidden = YES;
        container;
    });
    [self.view addSubview:self.container];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.menu = ({
        UIView *menu = [[UIView alloc] initWithFrame:CGRectMake(0, -200, kScreen_Width, 200)];
        menu.hidden = YES;
        menu.userInteractionEnabled = YES;
        menu.backgroundColor = [UIColor whiteColor];
        menu;
    });
    [self.view addSubview:self.menu];
    
    for (int i = 0; i<4; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 50*i, kScreen_Width, 50)];
        [btn setImage:[UIImage imageNamed:@"ios7-pricetag-outline"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"ios7-pricetag"] forState:UIControlStateHighlighted];
        btn.tag = i;
        [btn setTitleColor:[UIColor colorWithHexString:@"0x222222"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"0xb0271d"] forState:UIControlStateHighlighted];
        [btn setTintColor:[UIColor colorWithHexString:@"0x222222"]];
//        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 50);
//        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 100, 0, -50);
        [btn addTarget:self action:@selector(menuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        switch (btn.tag) {
            case 0:
                [btn setTitle:@"全部案例" forState:UIControlStateNormal];
                break;
            case 1:
                [btn setTitle:@"复式案例" forState:UIControlStateNormal];
                break;
            case 2:
                [btn setTitle:@"别墅案例" forState:UIControlStateNormal];
                break;
            case 3:
                [btn setTitle:@"公寓案例" forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        [self.menu addSubview:btn];
    }
    //创建导航栏按钮的方法（左右两侧最多可以各添加两个按钮）
    NavBarButtonItem *rightButtonMenu = [NavBarButtonItem buttonWithImageNormal:[UIImage imageNamed:@"navicon"]
                                                                   imageSelected:[UIImage imageNamed:@"navicon"]];
    //添加图标按钮（分别添加图标未点击和点击状态的两张图片）
    
    [rightButtonMenu addTarget:self
                         action:@selector(toggleMenu)
               forControlEvents:UIControlEventTouchUpInside]; //按钮添加点击事件
    
    self.navigationRightButton = rightButtonMenu; //添加导航栏左侧按钮集合
    [self.view bringSubviewToFront:self.navigationView];
}

- (void)containerOnTap{
    [self toggleMenu];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.contentTable1)
    {
        return self.dataArray1.count;
    }
    else
    {
        return self.dataArray2.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CaseImageCell *cell = [CaseImageCell cellWithTableView:tableView];
    if (tableView == self.contentTable1)
    {
        cell.curCase = self.dataArray1[indexPath.row];
    }
    if (tableView == self.contentTable2)
    {
        cell.curCase = self.dataArray2[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [CaseImageCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kPaddingLeftWidth;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]init];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return kPaddingLeftWidth;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer = [[UIView alloc]init];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
}

#pragma mark - autoScrolling
- (void)autoScroll
{
    CGFloat cellWidth = kScreen_Width/2 - 10;
    CGFloat rowHigh = cellWidth*0.6+53;
    CGFloat tableHigh = rowHigh*_dataArray1.count;
    if (!_isDown1)//向下位移 y轴增加
    {
        CGFloat upOffset        = _contentTable1.contentOffset.y + rowHigh/20;
        [_contentTable1 setContentOffset:CGPointMake(0,upOffset) animated:YES];
        if (tableHigh - _contentTable1.contentOffset.y - _contentTable1.frame.size.height + 30     <= rowHigh)
        {
            CGFloat offset  = tableHigh - _contentTable1.contentOffset.y - _contentTable1.frame.size.height + 30;
            [_contentTable1 setContentOffset:CGPointMake(0,_contentTable1.contentOffset.y + offset) animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isDown1    = YES;
            });
        }
    }
    if (!_isDown2)
    {
        CGFloat upOffset1 = _contentTable2.contentOffset.y + rowHigh/20;
        [_contentTable2 setContentOffset:CGPointMake(0,upOffset1) animated:YES];
        
        if (tableHigh - _contentTable2.contentOffset.y - _contentTable2.frame.size.height + 30 <= rowHigh)
        {
            CGFloat offset = tableHigh - _contentTable2.contentOffset.y - _contentTable2.frame.size.height + 30;
            [_contentTable2 setContentOffset:CGPointMake(0,_contentTable2.contentOffset.y + offset) animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isDown2 = YES;
            });
        }
    }
    if (_isDown1)//向上位移 y轴减
    {
        CGFloat downOffset = _contentTable1.contentOffset.y - rowHigh/20;
        
        [_contentTable1 setContentOffset:CGPointMake(0, downOffset) animated:YES];
        if (_contentTable1.contentOffset.y <= rowHigh)
        {
            [_contentTable1 setContentOffset:CGPointMake(0, 0) animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isDown1 = NO;
            });
        }
    }
    if (_isDown2)
    {
        CGFloat downOffset = _contentTable2.contentOffset.y - rowHigh/20;
        [_contentTable2 setContentOffset:CGPointMake(0, downOffset) animated:YES];
        if (_contentTable2.contentOffset.y <= rowHigh)
        {
            [_contentTable2 setContentOffset:CGPointMake(0, 0) animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isDown2 = NO;
            });
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@">>页面消失<<");
    [_timer invalidate];
}




//Enables/Disables the 'drop' triangle from displaying when down
- (void) dropShapeShouldShowWhenOpen:(BOOL)shouldShow {
    shouldDisplayDropShape = shouldShow;
}

//Sets the color that background content will fade to when the menu is open
- (void) setFadeTintWithColor:(UIColor *) color {
    self.view.backgroundColor = color;
}

//Sets the amount of fade that should be applied to background content when menu is open
- (void) setFadeAmountWithAlpha:(float) alphaVal {
    fadeAlpha = alphaVal;
}

- (void) setTrianglePlacement: (float) trianglePlacementVal {
    trianglePlacement = trianglePlacementVal;
}

- (void) menuButtonAction: (UIButton *) sender {
    [self loadDataWithType:(int)sender.tag];
    [self toggleMenu];
}

- (void) listButtonAction: (UIButton *) sender {
    [self hideMenu];
}

- (void) toggleMenu {
    if(self.menu.hidden) {
        [self showMenu];
    } else {
        [self hideMenu];
    }
}

- (void) showMenu {
    self.container.hidden = NO;
    self.menu.hidden = NO;
    self.menu.translatesAutoresizingMaskIntoConstraints = YES;
    
    [closedMenuShape removeFromSuperlayer];
    
    if (shouldDisplayDropShape)
    {
        [[[self view] layer] addSublayer:openMenuShape];
    }
    
    // Set new origin of menu
    CGRect menuFrame = self.menu.frame;
    menuFrame.origin.y = 64-self.offset;
    
    // Set new alpha of Container View (to get fade effect)
    float containerAlpha = fadeAlpha;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.menu.frame = menuFrame;
        [self.container setAlpha:containerAlpha];
    } else {
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:4.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.menu.frame = menuFrame;
                             [self.container setAlpha: containerAlpha];
                         }
                         completion:^(BOOL finished){
                         }];
    }
    
    [UIView commitAnimations];
    
}

- (void) hideMenu {
    self.container.hidden = YES;
    // Set the border layer to hidden menu state
    [openMenuShape removeFromSuperlayer];
    [[[self view] layer] addSublayer:closedMenuShape];
    
    // Set new origin of menu
    CGRect menuFrame = self.menu.frame;
    menuFrame.origin.y = 64-menuFrame.size.height;
    
    // Set new alpha of Container View (to get fade effect)
    float containerAlpha = 1.0f;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(iOS6_hideMenuCompleted)];
        
        self.menu.frame = menuFrame;
        [self.container setAlpha:containerAlpha];
    } else {
        [UIView animateWithDuration:0.3f
                              delay:0.05f
             usingSpringWithDamping:1.0
              initialSpringVelocity:4.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.menu.frame = menuFrame;
                             [self.container setAlpha: containerAlpha];
                         }
                         completion:^(BOOL finished){
                             self.menu.hidden = YES;
                         }];
    }
    
    [UIView commitAnimations];
    
}

- (void)iOS6_hideMenuCompleted {
    self.menu.hidden = YES;
}


-(CGFloat)offset {
    UIInterfaceOrientation interfaceOrientation;
    
    // Check if we are running an iOS version that support `interfaceOrientation`
    // Otherwise, use statusBarOrientation.
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        interfaceOrientation = self.interfaceOrientation;
    } else {
        interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation) ? 20.0f : 0.0f;
}


- (void) drawOpenLayer {
    [openMenuShape removeFromSuperlayer];
    openMenuShape = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    int height = 0;
    int width = kScreen_Width;
    int triangleDirection = 1; // 1 for down, -1 for up.
    int triangleSize =  8;
    int trianglePosition = trianglePlacement*width;
    
    // The path for the triangle (showing that the menu is open).
    UIBezierPath *triangleShape = [[UIBezierPath alloc] init];
    [triangleShape moveToPoint:CGPointMake(trianglePosition, height)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition+triangleSize, height+triangleDirection*triangleSize)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition+2*triangleSize, height)];
    [triangleShape addLineToPoint:CGPointMake(trianglePosition, height)];
    
    [openMenuShape setPath:triangleShape.CGPath];
    [openMenuShape setFillColor:[[UIColor colorWithHexString:@"0xffffff"] CGColor]];
    //[openMenuShape setFillColor:[self.menu.backgroundColor CGColor]];
    UIBezierPath *borderPath = [[UIBezierPath alloc] init];
    [borderPath moveToPoint:CGPointMake(0, height)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition, height)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition+triangleSize, height+triangleDirection*triangleSize)];
    [borderPath addLineToPoint:CGPointMake(trianglePosition+2*triangleSize, height)];
    [borderPath addLineToPoint:CGPointMake(width, height)];
    
    [openMenuShape setPath:borderPath.CGPath];
    [openMenuShape setStrokeColor:[[UIColor colorWithHexString:@"0xffffff"] CGColor]];
    
    [openMenuShape setBounds:CGRectMake(0.0f, 0.0f, height+triangleSize, width)];
    [openMenuShape setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [openMenuShape setPosition:CGPointMake(0.0f, -self.offset)];
}

- (void) drawClosedLayer {
    [closedMenuShape removeFromSuperlayer];
    closedMenuShape = [CAShapeLayer layer];
    
    // Constants to ease drawing the border and the stroke.
    int height = 0;
    int width = kScreen_Width;
    
    // The path for the border (just a straight line)
    UIBezierPath *borderPath = [[UIBezierPath alloc] init];
    [borderPath moveToPoint:CGPointMake(0, height)];
    [borderPath addLineToPoint:CGPointMake(width, height)];
    
    [closedMenuShape setPath:borderPath.CGPath];
    [closedMenuShape setStrokeColor:[[UIColor clearColor] CGColor]];
    
    [closedMenuShape setBounds:CGRectMake(0.0f, 0.0f, height, width)];
    [closedMenuShape setAnchorPoint:CGPointMake(0.0f, 0.0f)];
    [closedMenuShape setPosition:CGPointMake(0.0f, -self.offset)];
}

- (void)displayGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer {
    // Get the location of the gesture
    CGPoint tapLocation = [recognizer locationInView:self.view];
    // NSLog(@"Tap location X:%1.0f, Y:%1.0f", tapLocation.x, tapLocation.y);
    
    // If menu is open, and the tap is outside of the menu, close it.
    if (!CGRectContainsPoint(self.menu.frame, tapLocation) && !self.menu.hidden) {
        [self hideMenu];
    }
}

#pragma mark - Rotation

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect menuFrame = self.menu.frame;
    menuFrame.origin.y = 60 - self.offset;
    self.menu.frame = menuFrame;
    
    [self drawClosedLayer];
    [self drawOpenLayer];
    
    if (self.menu.hidden) {
        [[[self view] layer] addSublayer:closedMenuShape];
    } else {
        if (shouldDisplayDropShape) {
            [[[self view] layer] addSublayer:openMenuShape];
        }
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [closedMenuShape removeFromSuperlayer];
    [openMenuShape removeFromSuperlayer];
}

#pragma mark - Segue


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.currentSegueIdentifier = segue.identifier;
    [super prepareForSegue:segue sender:sender];
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.currentSegueIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        return NO;
    }
    
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _contentTable1.delegate = nil;
    _contentTable2.delegate = nil;
    _contentTable1.dataSource = nil;
    _contentTable2.dataSource = nil;
    self.dataArray1 = nil;
    self.dataArray2 = nil;
    self.dataArrs = nil;
    self.dataArr = nil;
    [_timer invalidate];
}

@end
