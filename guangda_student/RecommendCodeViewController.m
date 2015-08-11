//
//  RecommendCodeViewController.m
//  guangda
//
//  Created by Ray on 15/7/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "RecommendCodeViewController.h"
#import "LoginViewController.h"
#import "LearnDriveInfoViewController.h"
#import "AppDelegate.h"
@interface RecommendCodeViewController ()

@property (strong, nonatomic) IBOutlet UITextField *inviteCode;
@property (strong, nonatomic) IBOutlet UIView *inviteCodeView;
@property (strong, nonatomic) IBOutlet UIButton *sureButton;

@end

@implementation RecommendCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //圆角
    self.sureButton.layer.cornerRadius = 4;
    self.sureButton.layer.masksToBounds = YES;
    
    self.inviteCodeView.layer.borderWidth = 1;
    self.inviteCodeView.layer.borderColor = RGB(222, 222, 222).CGColor;
    
}

- (void) getRecommendRecordList{
    [DejalBezelActivityView activityViewForView:self.view];
    NSString *uri = @"/recomm?action=CHEAKINVITECODE";
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.inviteCode.text forKey:@"InviteCode"];
    [paramDic setObject:user_info[@"studentid"] forKey:@"InvitedPeopleid"];
    [paramDic setObject:@"2" forKey:@"type"]; //教练推荐教练：1  教练推荐学员：2
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [DejalBezelActivityView removeViewAnimated:YES];
            LearnDriveInfoViewController *nextController = [[LearnDriveInfoViewController alloc] initWithNibName:@"LearnDriveInfoViewController" bundle:nil];
            nextController.isSkip = @"1";
            [self.navigationController pushViewController:nextController animated:YES];
        }else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(backLogin)
                                           userInfo:nil
                                            repeats:NO];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [self makeToast:ERR_NETWORK];
    }];
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

//发送邀请码
- (IBAction)clickForSure:(id)sender {
    if (self.inviteCode.text.length != 8 || [self.inviteCode.text isEqualToString:@"请输入推荐码"]) {
        [self makeToast:@"请输入8位的推荐码"];
    }else{
        [self getRecommendRecordList];
    }
}

- (IBAction)clickForPop:(id)sender {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([app.isregister isEqualToString:@"1"]) {
        LearnDriveInfoViewController *nextController = [[LearnDriveInfoViewController alloc] initWithNibName:@"LearnDriveInfoViewController" bundle:nil];
        nextController.isSkip = @"1";
        [self.navigationController pushViewController:nextController animated:YES];
        app.isregister = @"0";
        app.isInvited = @"0";

    }else{
        app.isInvited = @"0";
        app.isregister = @"0";
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
