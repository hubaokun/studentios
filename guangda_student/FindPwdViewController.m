//
//  FindPwdViewController.m
//  guangda_student
//
//  Created by guok on 15/5/18.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "FindPwdViewController.h"

@interface FindPwdViewController ()
@property (strong, nonatomic) IBOutlet UITextField *pwdField;


@end

@implementation FindPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.pwdField resignFirstResponder];
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}

-(void)backupgroupTap:(id)sender{
    [self.pwdField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 提交新密码
- (void)commitNewPwd {
    [DejalBezelActivityView activityViewForView:self.view];
    NSString *pwdStr = self.pwdField.text;
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:_phoneNum forKey:@"phone"];
    [paramDic setObject:[CommonUtil md5:pwdStr] forKey:@"newpassword"];
    
    NSString *uri = @"/suser?action=FindPsw";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            [self makeToast:@"修改密码成功"];
            NSInteger index = self.navigationController.viewControllers.count - 3;
            [self.navigationController popToViewController:self.navigationController.viewControllers[index] animated:YES];
            
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

- (IBAction)clickForCommit:(id)sender {
    if ([CommonUtil isEmpty:self.pwdField.text]) {
        [self makeToast:@"请输入新密码"];
        return;
    }
    [self commitNewPwd];
}

@end
