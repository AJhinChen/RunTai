//
//  Me_RootViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Me_RootViewController.h"

const CGFloat BackGroupHeight = 200;
const CGFloat HeadImageHeight= 80;

@interface Me_RootViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    
    UITableView *demoTableView;
    
    UIImageView *imageBG;
    UIView *BGView;
    
    UIImageView *headImageView;
    UILabel *nameLabel;
    UILabel *titleLabel;
    
    UILabel *followersLabel;
    UILabel *introLabel;
    
    UIImage *iconImage;
}

@end

@implementation Me_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets=NO;
    //    添加myTableView
    demoTableView = ({
        UITableView *tableView=[[UITableView alloc]init];
        tableView.backgroundColor = GlobleTableViewBackgroundColor;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        tableView.frame=[UIScreen mainScreen].bounds;
        tableView.contentInset=UIEdgeInsetsMake(BackGroupHeight, 0, 0, 0);
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    // Do any additional setup after loading the view.
    [self setupUI];
}

-(void)setupUI
{
    
    //
    imageBG=[[UIImageView alloc]init];
    imageBG.frame=CGRectMake(0, -BackGroupHeight, kScreen_Width, BackGroupHeight);
    imageBG.image=[UIImage imageNamed:@"new_feature2"];
    
    [demoTableView addSubview:imageBG];
    //
    BGView=[[UIView alloc]init];
    BGView.backgroundColor=[UIColor clearColor];
    BGView.frame=CGRectMake(0, -BackGroupHeight, kScreen_Width, BackGroupHeight);
    
    [demoTableView addSubview:BGView];
    
    //
    headImageView=[[UIImageView alloc]init];
//    [headImageView sd_setImageWithURL:[_curUser.avatarUrl urlImageWithCodePathResizeToView:headImageView] placeholderImage:kPlaceholderMonkeyRoundView(headImageView)];
    headImageView.frame=CGRectMake((kScreen_Width-HeadImageHeight)/2, 70, HeadImageHeight, HeadImageHeight);
    
    headImageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0].CGColor;
    headImageView.layer.borderWidth = 2.0f;
    headImageView.autoresizingMask = UIViewAutoresizingNone;
    [headImageView doCircleFrame];
    //添加手势
    
//    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewOnTap)];
//    gestureRecognizer.numberOfTapsRequired = 1;
//    headImageView.userInteractionEnabled=YES;
//    [headImageView addGestureRecognizer:gestureRecognizer];
    
    [BGView addSubview:headImageView];
    
    //
    
    nameLabel=[[UILabel alloc]init];
//    nameLabel.text=_curUser.username;
    nameLabel.textAlignment=NSTextAlignmentCenter;
    nameLabel.frame=CGRectMake(HeadImageHeight/2, CGRectGetMaxY(headImageView.frame)+8, kScreen_Width-HeadImageHeight, 20);
    nameLabel.backgroundColor=[UIColor clearColor];
    [BGView addSubview:nameLabel];
    
    followersLabel=[[UILabel alloc]init];
//    followersLabel.text=[NSString stringWithFormat:@"关注  %d  ｜  粉丝  %d",_curUser.follows_count,_curUser.fans_count];
    followersLabel.textAlignment=NSTextAlignmentCenter;
    followersLabel.frame=CGRectMake(HeadImageHeight/2, CGRectGetMaxY(nameLabel.frame)+8, kScreen_Width-HeadImageHeight, 20);
    followersLabel.backgroundColor=[UIColor clearColor];
    [BGView addSubview:followersLabel];
    
    introLabel=[[UILabel alloc]init];
//    NSString *intro = _curUser.extra;
//    if (_curUser.extra == nil || [_curUser.extra isEqualToString:@""]) {
//        intro = @"暂无简介";
//    }
//    introLabel.text=[NSString stringWithFormat:@"简介:%@",intro];
    introLabel.textAlignment=NSTextAlignmentCenter;
    introLabel.frame=CGRectMake(HeadImageHeight/2, CGRectGetMaxY(followersLabel.frame)+8, kScreen_Width-HeadImageHeight, 20);
    introLabel.backgroundColor=[UIColor clearColor];
    [BGView addSubview:introLabel];
    
    
    titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(HeadImageHeight/2, 0, kScreen_Width-HeadImageHeight, 30)];
    titleLabel.textColor=[UIColor blackColor];
//    titleLabel.text=_curUser.username;
    
    titleLabel.textAlignment=NSTextAlignmentCenter;
    
    self.navigationItem.titleView=titleLabel;
    titleLabel.alpha=0;
    
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem BarButtonItemWithBackgroudImageName:@"navigationbar_more" highBackgroudImageName:@"navigationbar_more_highlighted" target:self action:@selector(rightBtnAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - tableViewDelegate&DataSource


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc]init];
    }
    
    return cell;
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
