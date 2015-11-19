//
//  LoginViewController.h
//  guangda_student
//
//  Created by 吴筠秋 on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
//#import "TencentOAuthObject.h"
#import "JKCountDownButton.h"

@interface LoginViewController : GreyTopViewController
/* input */
@property (copy, nonatomic) void (^afterLoginBlock)();

//@protocol TencentSessionDelegate;
@property (strong, nonatomic) IBOutlet JKCountDownButton *vcodeButton;
- (IBAction)clickForVcodeButton:(id)sender;

@property (assign, nonatomic) int comeFrom; // 1:从报名页面跳转来

@end
