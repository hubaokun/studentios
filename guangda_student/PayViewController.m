//
//  PayViewController.m
//  guangda_student
//
//  Created by 冯彦 on 15/9/28.
//  Copyright © 2015年 daoshun. All rights reserved.
//

#import "PayViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
// 支付宝
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthV2Info.h"
#import "Order.h"
#import "DataSigner.h"
// 微信
#import "WXApi.h"
#import "WXApiObject.h"

typedef NS_ENUM(NSUInteger, PayType) {
    PayTypeWeixin = 0,  // 微信支付
    PayTypeAli          // 支付宝支付
};

@interface PayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *wxBtn;
@property (weak, nonatomic) IBOutlet UIButton *aliBtn;
@property (assign, nonatomic) PayType payType;

@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.countLabel.text = self.cashNum;
    [self aliClick:self.aliBtn];
}

#pragma mark - 网络请求
// 获取订单参数
- (void)requestPayParameters
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *studentId = delegate.userid;
    NSString *moneyNum = self.cashNum;
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
    if (self.payType == PayTypeAli) {
        [paramDic setObject:@"0" forKey:@"resource"];
    }
    else if (self.payType == PayTypeWeixin) {
        [paramDic setObject:@"1" forKey:@"resource"];
        [paramDic setObject:kAppID_Weixin forKey:@"appid"];
        [paramDic setObject:@"trade_type" forKey:@"APP"];
        [paramDic setObject:[self deviceIPAdress] forKey:@"spbill_create_ip"];
        
    }
    
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            
            if (responseObject && [responseObject count] != 0) {
                if (self.payType == PayTypeAli) {
                    [self requestAlipayWithRechargeInfo:responseObject];
                }
                else if (self.payType == PayTypeWeixin) {
                    [self requestWeixinPayWithRechargeInfo:responseObject];
                }
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

#pragma mark 微信支付
- (void)requestWeixinPayWithRechargeInfo:(NSDictionary *)rechargeInfo
{
    NSDictionary *dict = rechargeInfo;
    if(dict != nil){
        NSMutableString *retcode = [dict objectForKey:@"retcode"];
        if (retcode.intValue == 0){
            NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
            
            //调起微信支付
            PayReq* req             = [[PayReq alloc] init];
            req.openID              = [dict objectForKey:@"appid"];
            req.partnerId           = [dict objectForKey:@"partnerid"];
            req.prepayId            = [dict objectForKey:@"prepayid"];
            req.nonceStr            = [dict objectForKey:@"noncestr"];
            req.timeStamp           = stamp.intValue;
            req.package             = [dict objectForKey:@"package"];
            req.sign                = [dict objectForKey:@"sign"];
            [WXApi sendReq:req];
            //日志输出
//            NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
        }else{
            [self alert:@"提示信息" msg:[dict objectForKey:@"retmsg"]];
        }
    }else{
        [self alert:@"提示信息" msg:@"服务器返回错误，未获取到json对象"];
    }
}

//客户端提示信息
- (void)alert:(NSString *)title msg:(NSString *)msg
{
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alter show];
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

#pragma mark - Custom
- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

// 获取手机IP
- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);  
    
//    NSLog(@"手机的IP是：%@", address);
    return address;
}

#pragma mark - Action
- (IBAction)wxClick:(id)sender {
    if (self.wxBtn.selected) return;
    self.wxBtn.selected = YES;
    self.aliBtn.selected = NO;
    self.payType = PayTypeWeixin;
}

- (IBAction)aliClick:(id)sender {
    if (self.aliBtn.selected) return;
    self.aliBtn.selected = YES;
    self.wxBtn.selected = NO;
    self.payType = PayTypeAli;
}

- (IBAction)payClick:(id)sender {
    [self requestPayParameters];
}
@end
