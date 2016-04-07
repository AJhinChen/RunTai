//
//  LoadingView.m
//  TVBPushDemo
//
//  Created by Joel Chen on 15/12/15.
//  Copyright © 2015年 Joel Chen. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView()

@property (strong, nonatomic) UIView  * bgView;
@property (strong, nonatomic) UIView * contentView;
@property (strong, nonatomic) CAShapeLayer *indefiniteAnimatedLayer;
@property (strong, nonatomic) UILabel * lbTitle;

@end

@implementation LoadingView


- (instancetype)initFullScreen:(NSString *) title{
    self=[super init];
    if(self){
        self.frame=[UIApplication sharedApplication].keyWindow.bounds;
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows){
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self];
                break;
            }
        }
        self.bgView=[[UIView alloc] initWithFrame:self.bounds];
        self.bgView.backgroundColor=[UIColor blackColor];
        self.bgView.alpha=0.4;
        [self addSubview:self.bgView];
        
        if([title isEqualToString:@""]){
            title=@"加載中...";
        }
        
        CGRect size=[title boundingRectWithSize:CGSizeMake(120, INT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
        
        self.contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 140 , 90+size.size.height)];
        self.contentView.backgroundColor=[UIColor whiteColor];
        self.contentView.center=self.center;
        self.contentView.layer.cornerRadius=10;
        [self addSubview:self.contentView];
        
        self.lbTitle=[[UILabel alloc] initWithFrame:CGRectMake(10, 70, 120, size.size.height)];
        self.lbTitle.textColor=[UIColor blackColor];
        self.lbTitle.numberOfLines=0;
        self.lbTitle.textAlignment=NSTextAlignmentCenter;
        self.lbTitle.font=[UIFont systemFontOfSize:15];
        self.lbTitle.text=title;
        [self.contentView addSubview:self.lbTitle];
        
        CGPoint arcCenter = CGPointMake(30, 30);
        CGRect rect = CGRectMake(0.0f, 0.0f, 60, 60);
        
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:20
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        
        self.indefiniteAnimatedLayer = [CAShapeLayer layer];
        self.indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
        self.indefiniteAnimatedLayer.frame = rect;
        self.indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
        self.indefiniteAnimatedLayer.strokeColor = [UIColor blackColor].CGColor;
        self.indefiniteAnimatedLayer.lineWidth = 2.0;
        self.indefiniteAnimatedLayer.lineCap = kCALineCapRound;
        self.indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel;
        self.indefiniteAnimatedLayer.path = smoothedPath.CGPath;
        [self.contentView.layer addSublayer:self.indefiniteAnimatedLayer];
        self.indefiniteAnimatedLayer.position = CGPointMake(self.contentView.bounds.size.width/2.0, 40);
        
        CALayer *maskLayer = [CALayer layer];
        
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask.png"] CGImage];;
        maskLayer.frame = self.indefiniteAnimatedLayer.bounds;
        self.indefiniteAnimatedLayer.mask = maskLayer;
        
        NSTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = 0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [self.indefiniteAnimatedLayer.mask addAnimation:animation forKey:@"rotate"];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame :(NSString *) title{
    self=[super initWithFrame:frame];
    if(self){
        self.contentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width ,self.bounds.size.height)];
        self.contentView.backgroundColor=[UIColor whiteColor];
        [self addSubview:self.contentView];
        
        if([title isEqualToString:@""]){
            title=@"載入中...";
        }
        
        CGRect size=[title boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width-60, INT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
        
        self.lbTitle=[[UILabel alloc] initWithFrame:CGRectMake(30, self.contentView.bounds.size.height/2.0+5, self.contentView.bounds.size.width-60, size.size.height)];
        self.lbTitle.textColor=[UIColor blackColor];
        self.lbTitle.numberOfLines=0;
        self.lbTitle.textAlignment=NSTextAlignmentCenter;
        self.lbTitle.font=[UIFont systemFontOfSize:15];
        self.lbTitle.text=title;
        [self.contentView addSubview:self.lbTitle];

        
        CGPoint arcCenter = CGPointMake(30, 30);
        CGRect rect = CGRectMake(0.0f, 0.0f, 60, 60);
        
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:20
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        
        self.indefiniteAnimatedLayer = [CAShapeLayer layer];
        self.indefiniteAnimatedLayer.contentsScale = [[UIScreen mainScreen] scale];
        self.indefiniteAnimatedLayer.frame = rect;
        self.indefiniteAnimatedLayer.fillColor = [UIColor clearColor].CGColor;
        self.indefiniteAnimatedLayer.strokeColor = [UIColor blackColor].CGColor;
        self.indefiniteAnimatedLayer.lineWidth = 2.0;
        self.indefiniteAnimatedLayer.lineCap = kCALineCapRound;
        self.indefiniteAnimatedLayer.lineJoin = kCALineJoinBevel;
        self.indefiniteAnimatedLayer.path = smoothedPath.CGPath;
        [self.contentView.layer addSublayer:self.indefiniteAnimatedLayer];
        self.indefiniteAnimatedLayer.position = CGPointMake(self.contentView.bounds.size.width/2.0, self.contentView.bounds.size.height/2.0-25);
        
        CALayer *maskLayer = [CALayer layer];
        
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask.png"] CGImage];;
        maskLayer.frame = self.indefiniteAnimatedLayer.bounds;
        self.indefiniteAnimatedLayer.mask = maskLayer;
        
        NSTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.fromValue = 0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        animation.repeatCount = INFINITY;
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [self.indefiniteAnimatedLayer.mask addAnimation:animation forKey:@"rotate"];
    }
    return self;
}

-(void) setTitle:(NSString *)title{
    
}


-(void) dismiss{
    [self removeFromSuperview];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay{
    [self performSelector:@selector(dismiss) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
