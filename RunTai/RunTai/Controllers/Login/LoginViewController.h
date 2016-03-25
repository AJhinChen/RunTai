//
//  LoginViewController.h
//  RunTai
//
//  Created by Joel Chen on 16/3/14.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BaseViewController.h"
#import "Login.h"
#import "TPKeyboardAvoidingTableView.h"

@interface LoginViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) BOOL showDismissButton;

@end
