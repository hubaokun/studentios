//
//  AccountManagerViewController.m
//  guangda_student
//
//  Created by guok on 15/6/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AccountManagerViewController.h"
#import "LoginViewController.h"

@interface AccountManagerViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)clickForSubmit:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *inpputViewBg;

@property (strong, nonatomic) IBOutlet UITextField *accountInputView;

@property (strong, nonatomic) IBOutlet UIButton *clearAccountButton;
- (IBAction)clickForClearAccount:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *closeKeyBoard;
- (IBAction)clickForCloseKeyBoard:(id)sender;

@end

@implementation AccountManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inpputViewBg.layer.cornerRadius = 5;
    self.inpputViewBg.layer.borderWidth = 1;
    self.inpputViewBg.layer.borderColor = [RGB(199, 199, 199) CGColor];
    
    
    //提交按钮默认不可以点击
    [self.submitButton setTitleColor:RGB(183, 183, 183) forState:UIControlStateNormal];
    self.submitButton.enabled = NO;
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *aliaccount = user_info[@"alipay_account"];
    
    if(![CommonUtil isEmpty:aliaccount]){
        self.accountInputView.text = aliaccount;
    }
    
    UIImage *image1 = [[UIImage imageNamed:@"btn_red"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *image2 = [[UIImage imageNamed:@"btn_red_h"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.clearAccountButton setBackgroundImage:image1 forState:UIControlStateNormal];;
    [self.clearAccountButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    
    //注册监听，防止键盘遮挡视图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.closeKeyBoard.hidden = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.closeKeyBoard.hidden = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *aliaccount = user_info[@"alipay_account"];
    
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *input = [toBeString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(![CommonUtil isEmpty:input] && ![input isEqualToString:aliaccount]){
        [self.submitButton setTitleColor:RGB(80, 203, 140) forState:UIControlStateNormal];
        self.submitButton.enabled = YES;
    }else{
        [self.submitButton setTitleColor:RGB(183, 183, 183) forState:UIControlStateNormal];
        self.submitButton.enabled = NO;
    }
    return  YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickForSubmit:(id)sender {
    NSString *aliaccount = [self.accountInputView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    NSString *uri = @"/cmy?action=ChangeAliAccount";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"studentid"] forKey:@"userid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    [paramDic setObject:@"2" forKey:@"type"];
    [paramDic setObject:aliaccount forKey:@"aliaccount"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"提交成功"];
            
            //更新用户的支付宝账户设置
            NSString *account = responseObject[@"aliacount"];
            NSMutableDictionary *user_info = [[CommonUtil getObjectFromUD:@"UserInfo"] mutableCopy];
            [user_info setObject:account forKey:@"alipay_account"];
            [CommonUtil saveObjectToUD:user_info key:@"UserInfo"];
            
            [self.navigationController popViewControllerAnimated:YES];
            
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
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

- (IBAction)clickForClearAccount:(id)sender{
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    NSString *uri = @"/cmy?action=DelAliAccount";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"studentid"] forKey:@"userid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    [paramDic setObject:@"2" forKey:@"type"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"清除支付宝账号成功"];
            
            //更新用户的支付宝账户设置
            NSMutableDictionary *user_info = [[CommonUtil getObjectFromUD:@"UserInfo"] mutableCopy];
            [user_info setObject:@"" forKey:@"alipay_account"];
            [CommonUtil saveObjectToUD:user_info key:@"UserInfo"];
            self.accountInputView.text = @"";
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
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}
- (IBAction)clickForCloseKeyBoard:(id)sender {
    [self.accountInputView resignFirstResponder];
}
@end
