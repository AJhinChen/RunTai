//
//  ServiceTermsViewController.m
//  RunTai
//
//  Created by Joel Chen on 16/8/1.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "ServiceTermsViewController.h"

@interface ServiceTermsViewController ()

@end

@implementation ServiceTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, kScreen_Width, 24)];
    titleLabel.text = @"服务条款";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.numberOfLines = 1;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [backView addSubview:titleLabel];
    
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 44+8, kScreen_Width, kScreen_Height-44-16-8-45-16)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"txt"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSString *text = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    textView.text = text;
    textView.editable = NO;
    textView.selectable = NO;
    textView.textColor = [UIColor blackColor];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.font = [UIFont boldSystemFontOfSize:15.0f];
    [backView addSubview:textView];
    
    UIButton *agreeBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"同意" andFrame:CGRectMake(kLoginPaddingLeftWidth, kScreen_Height-45-16, kScreen_Width-kLoginPaddingLeftWidth*2, 45) target:self action:@selector(sendAgree)];
    [backView addSubview:agreeBtn];
    
}

- (void)sendAgree{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
