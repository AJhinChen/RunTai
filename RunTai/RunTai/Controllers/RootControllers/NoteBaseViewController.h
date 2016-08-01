//
//  NoteBaseViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/7/6.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  这个枚举设置头图动画滑动的速度等级
 */
typedef enum {
    YHBaseHeaderAnimatedLevelSlow,
    YHBaseHeaderAnimatedLevelNormal,
    YHBaseHeaderAnimatedLevelFast
}YHBaseHeaderAnimatedLevel;

@interface NoteBaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView * tableView;
/**
 *  设置动画头图图片
 */
@property(nonatomic,strong)UIView * animatedHeaderView;
/**
 *  设置TableView的头视图
 *
 *  注意：设置tableView的头视图不能够在使用tableHeatherView方法 要使用这个属性设置
 *
 */
@property(nonatomic,strong)UIView * tableHeaderView;
/**
 *  设置动画头图高度
 *
 *  这个属性如果不设置或者设置为0 则默认会使用设置的image图片比例
 *
 */
@property(nonatomic,assign)CGFloat headerHeight;
/**
 *
 *  设置动画滑动速率
 */
@property(nonatomic,assign)YHBaseHeaderAnimatedLevel animatedlevel;
/**
 *
 *  设置头图可方法的最大scrollView偏移量 默认为40
 *
 */
@property(nonatomic,assign)CGFloat maxScrollOffset;
/**
 *  设置是否带渐隐效果
 *
 */
@property(nonatomic,assign)BOOL alphaAnimated;
/**
 *  设置最小渐变到的alpha渐隐值 <0 >1之间 默认为0.5
 *
 */
@property(nonatomic,assign)CGFloat minAlpha;
/**
 *
 *  是否显示毛玻璃模糊效果
 *
 */
@property(nonatomic,assign)BOOL bluerAnimated;
/**
 *
 *  设置最大小模糊度 默认为1
 *
 */
@property(nonatomic,assign)CGFloat maxBluer;
/**
 *  这个方法在修改了头图相关属性后 需要调用刷新
 *
 *  注意：如果重新设置了TableView的tableheaderView属性 也需要调用这个方法刷新
 *
 */
-(void)reloadAnimatedView;

@end
