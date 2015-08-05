//
//  SignUpViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/13.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SignUpViewController.h"
#import "SelfServiceSignUpViewController.h"
#import "UserBaseInfoViewController.h"
@interface SignUpViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumField;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UIView *signUpView;
@property (strong, nonatomic) IBOutlet UIView *nameUnderLine;
@property (strong, nonatomic) IBOutlet UIView *phoneNumUnderLine;
@property (strong, nonatomic) IBOutlet UILabel *footLabel;

//弹框
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UIView *alertBoxView;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

- (IBAction)clickForSelfService:(id)sender;
- (IBAction)clickForSignUp:(id)sender;
- (IBAction)clickForClose:(id)sender;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.nameField.delegate = self;
    self.phoneNumField.delegate = self;
    
    self.signUpButton.layer.cornerRadius = 4;
    self.signUpButton.layer.masksToBounds = YES;
    
    //圆角
    self.alertBoxView.layer.cornerRadius = 4;
    self.alertBoxView.layer.masksToBounds = YES;
    
    self.sureBtn.layer.cornerRadius = 4;
    self.sureBtn.layer.masksToBounds = YES;
    
    
    self.mainView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64);
    [self.mainScrollView addSubview:self.mainView];
    self.mainScrollView.contentSize = CGSizeMake(0, self.mainView.bounds.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewConfig];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

//#pragma mark - 输入框代理
//// 点击返回按钮
//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    [textField resignFirstResponder];
//    return YES;
//}
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
////    self.nowTextField = textField;
//    
//    // 修改下划线的颜色
//    if (textField == self.nameField) {
//        self.nameUnderLine.backgroundColor = [UIColor redColor];
//    }
//    if (textField == self.phoneNumField) {
//        self.phoneNumUnderLine.backgroundColor = [UIColor redColor];
//    }
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    if (textField == self.nameField) {
//        if (self.nameField.text.length == 0) {
//            self.nameUnderLine.backgroundColor = RGB(206, 206, 206);
//        }else{
//            self.nameUnderLine.backgroundColor = [UIColor redColor];
//        }
//    }else if (textField == self.phoneNumField) {
//        
//        if (self.phoneNumField.text.length == 0) {
//            self.phoneNumUnderLine.backgroundColor = RGB(206, 206, 206);
//        }else{
//            self.phoneNumUnderLine.backgroundColor = [UIColor redColor];
//        }
//    }
//    return YES;
//}

#pragma mark - 页面设置
- (void)viewConfig {
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *phoneNum = [user_info[@"phone"] description];
    NSString *realName = [user_info[@"realname"] description];
    
    if (![CommonUtil isEmpty:realName] && ![CommonUtil isEmpty:phoneNum]) { // 未设置姓名或手机号
        self.nameField.text = realName;
        self.phoneNumField.text = phoneNum;
    }
    else {
        // 提示用户去设置姓名或手机号
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请前往设置您的真实姓名与手机号。" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (buttonIndex == 1) {
        UserBaseInfoViewController *nextVC = [[UserBaseInfoViewController alloc] initWithNibName:@"UserBaseInfoViewController" bundle:nil];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

#pragma mark - 接口方法
// 提交用户信息一键报名
- (void)changePsw {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    NSString *uri = @"/suser?action=ENROLL";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            NSLog(@"message ===== %@", responseObject[@"message"]);
            self.alertView.frame = self.view.frame;
            [self.view addSubview:self.alertView];
//            [self.navigationController popViewControllerAnimated:YES];
            self.signUpButton.enabled = NO;
            self.signUpButton.alpha = 0.4;
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
    
}

#pragma mark - action
- (IBAction)hideKeyboardClick:(id)sender {
    [self.nameField resignFirstResponder];
    [self.phoneNumField resignFirstResponder];
}

- (IBAction)clickForClose:(id)sender
{
    [self.alertView removeFromSuperview];
}

- (IBAction)clickForSelfService:(id)sender {
    SelfServiceSignUpViewController *nextController = [[SelfServiceSignUpViewController alloc] initWithNibName:@"SelfServiceSignUpViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}

- (IBAction)clickForSignUp:(id)sender {
    if ([CommonUtil isEmpty:self.phoneNumField.text] && [CommonUtil isEmpty:self.nameField.text] ) {
        [self makeToast:@"请填写您的真实姓名和联系电话"];
    }else{
        [self changePsw];
    }
}

@end
