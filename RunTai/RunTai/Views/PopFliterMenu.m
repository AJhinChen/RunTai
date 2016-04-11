//
//  PopFliterMenu.m
//  Coding_iOS
//
//  Created by jwill on 15/11/10.
//  Copyright © 2015年 Coding. All rights reserved.
//
#define kfirstRowNum 3

#import "PopFliterMenu.h"
#import "XHRealTimeBlur.h"
#import "pop.h"
#import "RunTai_NetAPIManager.h"
#import "Login.h"

@interface PopFliterMenu()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) XHRealTimeBlur *realTimeBlur;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) ProjectCount *pCount;
@end

@implementation PopFliterMenu

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.items = @[@{@"all":@""},@{@"aaa":@"0"},@{@"reviewing":@""},@{@"aaa":@"0"},@{@"created":@""},@{@"aaa":@"0"},@{@"watched":@""}].mutableCopy;
        self.pCount=[ProjectCount new];
        self.showStatus=FALSE;
        [self setup];
    }
    return self;
}

- (void)refreshMenuDate:(void (^)(ProjectCount *pCount))block
{
    __weak typeof(self) weakSelf = self;
    if ([Login isLogin]) {
        [[RunTai_NetAPIManager sharedManager] request_ProjectsCatergoryAndCounts_WithAll:^(ProjectCount *data, NSError *error){
            if (!error) {
                [weakSelf.pCount configWithProjects:data];
                [weakSelf updateDateSource:weakSelf.pCount];
                [weakSelf.tableview reloadData];
                block(data);
            }else{
                NSString * errorCode = error.userInfo[@"code"];
                switch (errorCode.intValue) {
                    case 28:
                        [NSObject showHudTipStr:@"请求超时，网络信号不好噢"];
                        break;
                    default:
                        [NSObject showHudTipStr:@"获取笔录总数失败,请重试!"];
                        break;
                }
            }
        }];
    }else{
        block(nil);
    }
}

// 设置属性
- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    _realTimeBlur = [[XHRealTimeBlur alloc] initWithFrame:self.bounds];
    _realTimeBlur.blurStyle = XHBlurStyleTranslucentWhite;
    _realTimeBlur.showDuration = 0.1;
    _realTimeBlur.disMissDuration = 0.2;
    typeof(self) __weak weakSelf = self;

    _realTimeBlur.willShowBlurViewcomplted = ^(void) {
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.fromValue = @0.0;
        alphaAnimation.toValue = @1.0;
        alphaAnimation.duration = 0.3f;
        [weakSelf.tableview pop_addAnimation:alphaAnimation forKey:@"alphaAnimationS"];
    };
    
    _realTimeBlur.willDismissBlurViewCompleted = ^(void) {
        POPBasicAnimation *alphaAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        alphaAnimation.fromValue = @1.0;
        alphaAnimation.toValue = @0.0;
        alphaAnimation.duration = 0.2f;
        [weakSelf.tableview pop_addAnimation:alphaAnimation forKey:@"alphaAnimationE"];
    };
    
    _realTimeBlur.didDismissBlurViewCompleted = ^(BOOL finished) {
        [weakSelf removeFromSuperview];
    };

    
    _realTimeBlur.hasTapGestureEnable = YES;
    
    _tableview = ({
        UITableView *tableview=[[UITableView alloc] initWithFrame:self.bounds];
        tableview.backgroundColor=[UIColor clearColor];
        tableview.delegate=self;
        tableview.dataSource=self;
        [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        tableview.tableFooterView=[UIView new];
        tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
        tableview;
    });
    [self addSubview:_tableview];
    _tableview.contentInset=UIEdgeInsetsMake(15, 0,0,0);
    
    
    int contentHeight=320;
    if ((kScreen_Height-64)>contentHeight) {
        UIView *contentView=[[UIView alloc] initWithFrame:CGRectMake(0,64+contentHeight , kScreen_Width, kScreen_Height-64-contentHeight)];
        contentView.backgroundColor=[UIColor clearColor];
        [self addSubview:contentView];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
        [contentView addGestureRecognizer:tapGestureRecognizer];
    }
}

#pragma mark -- event & action
- (void)showMenuAtView:(UIView *)containerView {
    _showStatus=TRUE;
    [containerView addSubview:self];
    [_realTimeBlur showBlurViewAtView:self];
    [_tableview reloadData];
}

- (void)dismissMenu
{
    UIView *presentView=[[[UIApplication sharedApplication].keyWindow rootViewController] view];
    if ([[presentView.subviews firstObject] isMemberOfClass:NSClassFromString(@"RDVTabBar")]) {
        [presentView bringSubviewToFront:[presentView.subviews firstObject]];
    }
    _showStatus=FALSE;
    [_realTimeBlur disMiss];
//    [self removeFromSuperview];
}

//组装cell标题
- (NSString*)formatTitleStr:(NSDictionary*)aDic
{
    NSString *keyStr=[[aDic allKeys] firstObject];
    NSMutableString *convertStr=[NSMutableString new];
    if ([keyStr isEqualToString:@"all"]) {
        [convertStr appendString:@"全部笔录"];
    }else if ([keyStr isEqualToString:@"reviewing"]) {
        [convertStr appendString:@"申请中的"];
    }else if ([keyStr isEqualToString:@"created"]) {
        [convertStr appendString:@"我负责的"];
    }else if ([keyStr isEqualToString:@"watched"]) {
        [convertStr appendString:@"我收藏的"];
    }else
    {
        NSLog(@"-------------error type:%@",keyStr);
    }
    if ([[aDic objectForKey:keyStr] length]>0) {
        [convertStr appendString:[NSString stringWithFormat:@" (%@)",[aDic objectForKey:keyStr]]];
    }
    return [convertStr copy];
}

//更新数据源
-(void)updateDateSource:(ProjectCount*)pCount
{
    _items = @[@{@"all":[pCount.all stringValue]},@{@"aaa":@"0"},@{@"reviewing":[pCount.reviewing stringValue]},@{@"aaa":@"0"},@{@"created":[pCount.created stringValue]},@{@"aaa":@"0"},@{@"watched":[pCount.watched stringValue]}].mutableCopy;
}


//转化为Projects类对应类型
//-(NSInteger)convertToProjectType
//{
//    switch (_selectNum) {
//        case 0:
//            return ProjectsTypeAll;
//            break;
//        case 1:
//            return ProjectsTypeCreated;
//            break;
//        case 2:
//            return ProjectsTypeJoined;
//            break;
//        case 3:
//            return ProjectsTypeWatched;
//            break;
//        case 4:
//            return ProjectsTypeStared;
//            break;
//        default:
//            NSLog(@"type error");
//            return ProjectsTypeAll;
//            break;
//    }
//}


#pragma mark -- uitableviewdelegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.backgroundColor=[UIColor clearColor];
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
    titleLab.font=[UIFont systemFontOfSize:15];
    [cell.contentView addSubview:titleLab];
    if (indexPath.section%2==0) {
        titleLab.textColor=(indexPath.section==_selectNum)?[UIColor colorWithHexString:@"0xb0271d"]:[UIColor colorWithHexString:@"0x222222"];
        titleLab.text=[self formatTitleStr:[_items objectAtIndex:indexPath.section]];
    }else{
        [titleLab removeFromSuperview];
        UIView *seperatorLine=[[UIView alloc] initWithFrame:CGRectMake(20, 15, self.bounds.size.width-40, 0.5)];
        seperatorLine.backgroundColor=[UIColor colorWithHexString:@"0xcccccc"];
        [cell.contentView addSubview:seperatorLine];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((indexPath.section%2)?30.5:50);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectNum=indexPath.section;
    [self dismissMenu];
    _clickBlock(_selectNum);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didClickedContentView:(UIGestureRecognizer *)sender {
    _closeBlock();
}


@end
