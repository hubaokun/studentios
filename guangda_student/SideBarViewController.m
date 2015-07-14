//
//  SideBarViewController.m
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SideBarViewController.h"
#import "MyOrderViewController.h"
#import "AccountListViewController.h"
#import "SystemMessageViewController.h"
#import "ComplaintViewController.h"
#import "SettingViewController.h"
#import "UserInfoHomeViewController.h"
#import "LoginViewController.h"
#import "UIImageView+WebCache.h"
#import "CouponListViewController.h"
#import "OnlineTestViewController.h"
#import "SignUpViewController.h"
@interface SideBarViewController ()

@property (nonatomic, strong) UIView *redPoint;
@property (strong, nonatomic) IBOutlet UIView *systemMessageView;
@property (strong, nonatomic) IBOutlet UIImageView *messageIcon;
@property (strong, nonatomic) IBOutlet UIImageView *messageRed;

@end

@implementation SideBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //登陆监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStart:) name:@"needlogin" object:nil];
//    [[CommonUtil currentUtil] isLogin];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showName) name:@"autologincomplete" object:nil];

    self.userLogo.layer.cornerRadius = self.userLogo.bounds.size.width/2;
    self.userLogo.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo) name:@"loginSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRedPoint) name:@"haveMessageNoRead" object:nil];
}

- (void)showRedPoint
{
    
    if([[CommonUtil currentUtil] isLogin]){
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
        NSString *studentid = userInfo[@"studentid"];
        if([CommonUtil isEmpty:studentid])
            return;
        [params setObject:studentid forKey:@"studentid"];
        
        NSString *uri = @"/sset?action=GetMessageCount";
        NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            int code = [responseObject[@"code"] intValue];
            if(code == 1){
                int messagecount = [responseObject[@"noticecount"] intValue];
                if(messagecount == 0){
                    self.messageRed.hidden = YES;
                }else{
                    self.messageRed.hidden = NO;
                }
            }else{
                self.messageRed.hidden = YES;
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.messageRed.hidden = YES;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *userName = [userInfo objectForKey:@"realname"];
    NSString *phoneNum = [userInfo objectForKey:@"phone"];
    NSString *avatarUrlStr = [userInfo[@"avatarurl"] description];
    if ([[CommonUtil currentUtil] isLogin:NO]) {
        if(![CommonUtil isEmpty:userName]){
            self.userNameLabel.text = userName;
        }else{
            self.userNameLabel.text = @"未设置";
        }
        
        self.phoneNumLabel.text = phoneNum;
        [self.userLogo sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"login_icon"]];
    } else {
        self.userNameLabel.text = @"账号未登录";
        self.phoneNumLabel.text = @"";
        [self.userLogo setImage:[UIImage imageNamed:@"login_icon"]];
    }
}

- (void)refreshUserInfo
{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *userName = [userInfo objectForKey:@"realname"];
    NSString *phoneNum = [userInfo objectForKey:@"phone"];
    NSString *avatarUrlStr = [userInfo[@"avatarurl"] description];
    if ([[CommonUtil currentUtil] isLogin:NO]) {
        self.userNameLabel.text = userName;
        self.phoneNumLabel.text = phoneNum;
        [self.userLogo sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"login_icon"]];
    } else {
        self.userNameLabel.text = @"账号未登录";
        self.phoneNumLabel.text = @"";
        [self.userLogo setImage:[UIImage imageNamed:@"login_icon"]];
    }
}

- (void)showName {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *userName = [userInfo objectForKey:@"realname"];
    NSString *phoneNum = [userInfo objectForKey:@"phone"];
    NSString *avatarUrlStr = [userInfo[@"avatarurl"] description];
    if(![CommonUtil isEmpty:userName]){
        self.userNameLabel.text = userName;
    }else{
        self.userNameLabel.text = @"未设置";
    }
    self.phoneNumLabel.text = phoneNum;
    [self.userLogo sd_setImageWithURL:[NSURL URLWithString:avatarUrlStr] placeholderImage:[UIImage imageNamed:@"login_icon"]];
}

#pragma mark - private
- (void)loginStart:(NSNotification *)notification {
    LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:NO];
}

// 个人信息
- (IBAction)userInfo:(id)sender
{
    if ([[CommonUtil currentUtil] isLogin]) {
        UserInfoHomeViewController *viewController = [[UserInfoHomeViewController alloc] initWithNibName:@"UserInfoHomeViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

// 我的订单
- (IBAction)myOrderClick:(id)sender
{
    if ([[CommonUtil currentUtil] isLogin]) {
        MyOrderViewController *viewController = [[MyOrderViewController alloc] initWithNibName:@"MyOrderViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

// 账户
- (IBAction)accountClick:(id)sender
{
    if ([[CommonUtil currentUtil] isLogin]) {
        AccountListViewController *viewController = [[AccountListViewController alloc] initWithNibName:@"AccountListViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

//学车报名
- (IBAction)clickForSignUp:(id)sender{
    if ([[CommonUtil currentUtil] isLogin]) {
        SignUpViewController *nextViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
        
    }
}

// 系统消息
- (IBAction)messageClick:(id)sender
{
    if ([[CommonUtil currentUtil] isLogin]) {
        SystemMessageViewController *viewController = [[SystemMessageViewController alloc] initWithNibName:@"SystemMessageViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


//在线约考
- (IBAction)onlineSignUp:(id)sender {
    OnlineTestViewController *viewController = [[OnlineTestViewController alloc] initWithNibName:@"OnlineTestViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}


// 设置
- (IBAction)settingClick:(id)sender
{
    SettingViewController *viewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}



@end
