//
//  TypeinNumberViewController.m
//  guangda_student
//
//  Created by Dino on 15/4/2.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "TypeinNumberViewController.h"
#import "AppDelegate.h"

#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthV2Info.h"
#import "LoginViewController.h"

@interface TypeinNumberViewController ()

@property (strong, nonatomic) IBOutlet UIView *typeInView;
@property (strong, nonatomic) IBOutlet UITextField *texttView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation TypeinNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.typeInView.layer.cornerRadius = 5;
    self.typeInView.layer.borderWidth = 1;
    self.typeInView.layer.borderColor = [RGB(199, 199, 199) CGColor];
    
    if ([_status isEqualToString:@"2"]) {
        self.titleLabel.text = @"请输入提现金额";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 充值
- (void)requestRechareInterface
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *studentId = delegate.userid;
    NSString *moneyNum = self.texttView.text;
    if (!studentId) {
        [self makeToast:@"用户未登录"];
        return;
    }
    if (moneyNum.length == 0 ||
        [moneyNum floatValue] <= 0) {
        [self makeToast:@"请输入大于0的金额"];
        return;
    }
    
    NSString *uri = @"/suser?action=Recharge";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:moneyNum forKey:@"amount"];
    [paramDic setObject:@"0" forKey:@"resource"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            
            if (responseObject && [responseObject count] != 0) {
                [self requestAlipayWithRechargeInfo:responseObject];
            }
            
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

#pragma mark 提现
- (void)requestApplyCashInterface
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *studentId = delegate.userid;
    NSString *moneyNum = self.texttView.text;
    if (!studentId) {
        [self makeToast:@"用户未登录"];
        return;
    }
    if (moneyNum.length == 0 ||
        [moneyNum floatValue] <= 0) {
        [self makeToast:@"请输入大于0的金额"];
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

#pragma mark 提交按钮
- (IBAction)submitBtnClick:(id)sender {
    [self.texttView resignFirstResponder];
    
    int stats = [self.status intValue];
    switch (stats) {
        case 1:
            // chongzhi
            [self requestRechareInterface];
            break;
        case 2:
            // 提现
            [self requestApplyCashInterface];
            break;

        default:
            break;
    }
}

#pragma mark 请求支付宝
- (void)requestAlipayWithRechargeInfo:(NSDictionary *)rechargeInfo
{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    
    // 服务器获取
    NSString *partner = [rechargeInfo[@"partner"] description];
    NSString *seller = [rechargeInfo[@"seller_id"] description];
    NSString *privateKey = [rechargeInfo[@"private_key"] description];
    
    NSString *tradeNO = [rechargeInfo[@"out_trade_no"] description];       //订单ID（由商家自行制定）
    NSString *productName = [rechargeInfo[@"subject"] description];        // 商品标题
    NSString *productDescription = [rechargeInfo[@"body"] description];    //商品描述
    NSString *amount = [rechargeInfo[@"total_fee"] description];           //商品价格
    NSString *notifyURL = [rechargeInfo[@"notify_url"] description];                 //回调URL
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    
    // 接口返回的参数设置
    order.tradeNO = tradeNO; //订单ID（由商家自行制定）
    order.productName = productName; //商品标题
    order.productDescription = productDescription; //商品描述
    order.amount = amount; //商品价格
    order.notifyURL = notifyURL; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"guangdastudent";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            
            NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
            NSString *success = [resultDic objectForKey:@"success"];
            
            if ([resultStatus isEqualToString:@"9000"] ||
                [success isEqualToString:@"true"]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"alipaySuccessStudent" object:nil];
                [self makeToast:@"充值成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self makeToast:@"充值失败"];
            }
//            NSLog(@"post alipaySuccessStudent");
            
        }];
    }

}


@end
