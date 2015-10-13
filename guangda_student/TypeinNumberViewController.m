//
//  TypeinNumberViewController.m
//  guangda_student
//
//  Created by Dino on 15/4/2.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "TypeinNumberViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "PayViewController.h"

@interface TypeinNumberViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *typeInView;
@property (strong, nonatomic) IBOutlet UITextField *inputField;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cashExplainLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextStepBtn;

@end

@implementation TypeinNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.inputField addTarget:self action:@selector(fieldTextChanged:) forControlEvents:UIControlEventAllEditingEvents];
    [self viewConfig];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputField resignFirstResponder];
}

#pragma mark 页面配置
- (void)viewConfig {
    self.typeInView.layer.borderWidth = 1;
    self.typeInView.layer.borderColor = [RGB(170, 170, 170) CGColor];
    
    self.nextStepBtn.layer.cornerRadius = 3;
    self.nextStepBtn.enabled = NO;
    
    // 提现
    if ([_status isEqualToString:@"2"]) {
        self.titleLabel.text = @"请输入提现金额";
        self.inputField.placeholder = [NSString stringWithFormat:@"账户余额%@元", self.balance];
        [self.nextStepBtn setTitle:@"提交" forState:UIControlStateNormal];
        [self requestCashExplainText];
    }
}

#pragma mark - 网络请求
// 提现
- (void)requestApplyCashInterface
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *studentId = delegate.userid;
    NSString *moneyNum = self.inputField.text;
    if (!studentId) {
        [self makeToast:@"用户未登录"];
        return;
    }
    if ([moneyNum floatValue] <= 0) {
        [self makeToast:@"请输入大于0的金额"];
        return;
    }
    if ([moneyNum floatValue] > [self.balance floatValue]) {
        [self makeToast:@"余额不足"];
        return;
    }
    
    NSString *uri = @"/suser?action=ApplyCash";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:moneyNum forKey:@"count"];
    [paramDic setObject:@"0" forKey:@"resource"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"提现成功"];
            NSLog(@"message = %@", responseObject[@"message"]);
            
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
            
            NSLog(@"code = %@",  responseObject[@"code"]);
            NSLog(@"message = %@", responseObject[@"message"]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

// 提现解释文字
- (void)requestCashExplainText
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *studentId = delegate.userid;
    if (!studentId) {
        [self makeToast:@"用户未登录"];
        return;
    }
    
    NSString *uri = @"/cmy?action=CASHEXPLAIN";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            self.cashExplainLabel.text = [responseObject[@"cashexplain"] description];
            
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
            
            NSLog(@"code = %@",  responseObject[@"code"]);
            NSLog(@"message = %@", responseObject[@"message"]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

#pragma mark - Custom
- (void)fieldTextChanged:(UITextField *)field {
    if ([CommonUtil isEmpty:field.text]) {
        self.nextStepBtn.enabled = NO;
        self.nextStepBtn.backgroundColor = RGB(170, 170, 170);
    } else {
        self.nextStepBtn.enabled = YES;
        self.nextStepBtn.backgroundColor = RGB(80, 203, 140);
    }
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - Action
- (IBAction)nextStepClick:(id)sender {
    [self.inputField resignFirstResponder];
    
    int stats = [self.status intValue];
    switch (stats) {
        case 1: { // 充值
            PayViewController *nextVC = [[PayViewController alloc] initWithNibName:@"PayViewController" bundle:nil];
            nextVC.cashNum = self.inputField.text;
            nextVC.purpose = 0;
            [self.navigationController pushViewController:nextVC animated:YES];
            break;
        }
            
        case 2: // 提现
            [self requestApplyCashInterface];
            break;
            
        default:
            break;
    }
    
}

@end
