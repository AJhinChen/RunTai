//
//  TweetSendViewController.h
//  WeiBo
//
//  Created by Joel Chen on 16/1/29.
//  Copyright © 2016年 Joel Chen. All rights reserved.
//

#import "BaseViewController.h"
#import "Note.h"
#import "Project.h"


@interface TweetSendViewController : BaseViewController

@property (strong, nonatomic) Note *curTweet;
@property (copy, nonatomic) Project *curPro;

@end
