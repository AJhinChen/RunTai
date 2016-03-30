//
//  Home_RootViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BaseViewController.h"
#import "Projects.h"
@interface Home_RootViewController : BaseViewController

@property (strong, nonatomic) NSArray *segmentItems;
@property (nonatomic, strong) Projects *myProjects;

@end
