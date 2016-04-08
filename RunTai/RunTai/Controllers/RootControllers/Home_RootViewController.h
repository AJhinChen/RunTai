//
//  Home_RootViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BaseViewController.h"
#import "Projects.h"
#import "ProjectCount.h"
@interface Home_RootViewController : BaseViewController

@property (nonatomic, strong) Projects *myProjects;

@property (strong, nonatomic) ProjectCount *pCount;

@end
