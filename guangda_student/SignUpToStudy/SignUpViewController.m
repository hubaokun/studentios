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
#import "XBExame.h"
#import "XBExameCity.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthV2Info.h"

#define CITY_OUT ([self.curExameCity.cityID isEqualToString:self.cityID] && (self.cityInclude == NO))

@interface SignUpViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phonelabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseCityBtn;
@property (weak, nonatomic) IBOutlet UIButton *chooseExameBtn;


@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;

// 报名记录
@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *payedPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

// 选择器
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;
@property (assign, nonatomic) int pickerType; // 选择器类型 1:城市 2:驾考类型
@property (strong, nonatomic) XBExameCity *curExameCity;
@property (strong, nonatomic) XBExame *curExame;
@property (copy, nonatomic) NSString *selectCity;

//弹框
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UIView *alertBoxView;
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

// 页面数据
@property (strong, nonatomic) NSMutableArray *cityArray;
@property (strong, nonatomic) NSMutableArray *exameArray;
@property (assign, nonatomic) BOOL cityInclude; // 自己设置的城市是否包含在开通城市内
@property (strong, nonatomic) NSDictionary *exameState;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewConfig];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self postGetExameState];
}

#pragma mark - 页面设置
- (void)viewConfig {
    self.mainView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.mainScrollView addSubview:self.mainView];
    self.selectView.frame = [UIScreen mainScreen].bounds;
    self.signUpBtn.layer.cornerRadius = 3;
    
    //圆角
    self.alertBoxView.layer.cornerRadius = 3;
    self.alertBoxView.layer.masksToBounds = YES;
    
    self.sureBtn.layer.cornerRadius = 3;
    self.sureBtn.layer.masksToBounds = YES;
    
    NSDictionary *userDict = USERDICT;
    self.nameLabel.text = userDict[@"realname"];
    self.phonelabel.text = userDict[@"phone"];
    
    self.mainScrollView.contentSize = CGSizeMake(0, self.mainView.height);
}

// 按钮配置
- (void)signUpBtnConfig {
    if (CITY_OUT) { // 选中自己设置的城市，且不在开通城市内
        [self.signUpBtn setTitle:@"我要报名" forState:UIControlStateNormal];
    }
    else {
        [self.signUpBtn setTitle:@"报名并支付" forState:UIControlStateNormal];
    }
}

// 学驾价格配置
- (void)priceLabelConfig {
    if (CITY_OUT) { // 选中自己设置的城市，且不在开通城市内
        self.priceLabel.hidden = YES;
    }
    else {
        self.priceLabel.hidden = NO;
        self.priceLabel.attributedText = [self priceStrCreateByMarketPrice:self.curExame.marketPrice xbPrice:self.curExame.xbPrice];
    }
    [self signUpBtnConfig];
}

- (NSMutableAttributedString *)priceStrCreateByMarketPrice:(NSString *)mPrice xbPrice:(NSString*)xbPrice {
    NSString *str1 = @"小巴一口价 ";
    NSString *str2 = xbPrice;
    NSString *str3 = @"元   ";
    NSString *str4 = [NSString stringWithFormat:@"市场价：%@元", mPrice];
    NSString *priceText = [NSString stringWithFormat:@"%@%@%@%@", str1, str2, str3, str4];
    NSMutableAttributedString *priceStr = [[NSMutableAttributedString alloc] initWithString:priceText];
    NSUInteger loc = 0;
    [priceStr addAttribute:NSForegroundColorAttributeName value:RGB(170, 170, 170) range:NSMakeRange(loc,str1.length)];
    [priceStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(loc, str1.length)];
    loc += str1.length;
    [priceStr addAttribute:NSForegroundColorAttributeName value:RGB(247, 100, 92) range:NSMakeRange(loc, str2.length)];
    [priceStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(loc, str2.length)];
    loc += str2.length;
    [priceStr addAttribute:NSForegroundColorAttributeName value:RGB(247, 100, 92) range:NSMakeRange(loc, str3.length)];
    [priceStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(loc, str3.length)];
    loc += str3.length;
    [priceStr addAttribute:NSForegroundColorAttributeName value:RGB(170, 170, 170) range:NSMakeRange(loc, str4.length)];
    [priceStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(loc, str4.length)];
    [priceStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(loc, str4.length)];
    return priceStr;
}

// 用户已报名的页面配置
- (void)haveSigedViewConfig {
    self.chooseCityBtn.enabled = NO;
    self.chooseExameBtn.enabled = NO;
    self.signUpBtn.backgroundColor = RGB(200, 200, 200);
    self.signUpBtn.enabled = NO;
    [self.signUpBtn setTitle:@"已报名" forState:UIControlStateNormal];
    
    self.cityLabel.text = self.exameState[@"cityname"];
    self.typeLabel.text = self.exameState[@"model"];
    
    self.priceLabel.hidden = NO;
    NSString *marketPrice = [self.exameState[@"marketprice"] description];
    NSString *xbPrice = [self.exameState[@"xiaobaprice"] description];
    self.priceLabel.attributedText = [self priceStrCreateByMarketPrice:marketPrice xbPrice:xbPrice];
   
    // 显示报名记录
    self.recordView.hidden = NO;
    NSDictionary *userDict = USERDICT;
    self.titleLabel.text = [NSString stringWithFormat:@"%@-%@", userDict[@"realname"], self.exameState[@"model"]];
    self.payedPriceLabel.text = [NSString stringWithFormat:@"%@元", self.exameState[@"xiaobaprice"]];
    self.dateLabel.text = [self.exameState[@"enrolltime"] description];
}

#pragma mark - PickerVIew
- (void)cityDataConfig {
    // 检索自己设置的城市是否在开通城市里
    BOOL include = NO;
    for (XBExameCity *city in self.cityArray) {
        if ([self.cityID isEqualToString:city.cityID]) {
            include = YES;
            break;
        }
    }
    self.cityInclude = include;
    // 如果不包含在内，将设置的城市添加到数组第一位
    if (!include) {
        XBExameCity *myCity = [[XBExameCity alloc] init];
        myCity.cityID = self.cityID;
        myCity.cityName = self.cityName;
        [self.cityArray insertObject:myCity atIndex:0];
    }
    
    self.curExameCity = self.cityArray[0];
    self.cityLabel.text = self.curExameCity.cityName;
    
    
    if (CITY_OUT) { // 如果选中的城市是自己设置的城市且不在开通城市内
        [self exameDataConfig:nil];
    } else {
        [self postGetExamePrice];
    }
}

- (void)exameDataConfig:(NSArray *)array {
    if (array) {
        self.exameArray = [XBExame examesWithArray:array];
    }
    // 数组为nil则手动添加c1/c2
    else {
        XBExame *c1 = [[XBExame alloc] init];
        c1.exameName = @"c1";
        XBExame *c2 = [[XBExame alloc] init];
        c2.exameName = @"c2";
        self.exameArray = [NSMutableArray arrayWithObjects:c1, c2, nil];
    }
    
    self.curExame = self.exameArray[0];
    self.typeLabel.text = self.curExame.exameName;
    [self priceLabelConfig];
}

// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.0;
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // 城市
    if (self.pickerType == 1) {
        return self.cityArray.count;
    }
    // 驾考
    else {
        return self.exameArray.count;
    }
}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 45)];
    myView.font = [UIFont systemFontOfSize:18];         //用label来设置字体大小
    myView.textColor = [UIColor whiteColor];
    myView.backgroundColor = [UIColor clearColor];
    myView.textAlignment = NSTextAlignmentCenter;
    
    // 城市
    if (self.pickerType == 1) {
        XBExameCity *city = self.cityArray[row];
        myView.text = city.cityName;
    }
    // 驾考
    else {
        XBExame *exame = self.exameArray[row];
        myView.text = exame.exameName;
    }
    
    return myView;
}

#pragma mark - 网络请求
// 获取报名信息
- (void)postGetExameState {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    paramDic[@"studentid"] = studentId;
    NSString *uri = @"suser?action=GETENROLLINFO";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            self.exameState = responseObject;
            int state = [responseObject[@"state"] intValue];
            if (state == 1) { // 已报名
                [self haveSigedViewConfig];
            }
            else if (state == 0) { // 未报名
                [self postGetExameCity];
            }
            
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

// 获取录入的城市列表
- (void)postGetExameCity {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *uri = @"sbook?action=GETOPENMODELPRICE";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            self.cityArray = [XBExameCity citiesWithArray:responseObject[@"opencity"]];
            [self cityDataConfig];
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

// 获取驾考价格
- (void)postGetExamePrice {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic[@"cityid"] = self.curExameCity.cityID;
    NSString *uri = @"sbook?action=GETMODELPRICE";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            [self exameDataConfig:responseObject[@"modelprice"]];
        } else {
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
    
}

// 我要报名
- (void)postSignUp {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    paramDic[@"studentid"] = studentId;
    paramDic[@"model"] = self.curExame.exameName;
    paramDic[@"cityid"] = self.curExameCity.cityID;
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
            self.signUpBtn.enabled = NO;
            self.signUpBtn.alpha = 0.4;
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

// 报名支付
- (void)postSignUpAndPay {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    paramDic[@"studentid"] = studentId;
    paramDic[@"model"] = self.curExame.exameName;
    paramDic[@"cityid"] = self.curExameCity.cityID;
    paramDic[@"amount"] = self.curExame.xbPrice;
    NSString *uri = @"/suser?action=PROMOENROLL";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            if (responseObject && [responseObject count] != 0) {
                [self requestAlipayWithRechargeInfo:responseObject];
            }
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您已报名成功" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }else{
                [self makeToast:@"支付失败"];
            }
            //            NSLog(@"post alipaySuccessStudent");
            
        }];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self viewWillAppear:YES];
}

#pragma mark - action
// 选择城市
- (IBAction)chooseCityClick:(id)sender {
    self.pickerType = 1;
    [self.picker reloadAllComponents];
    [self.view addSubview:self.selectView];
    [self.picker selectRow:0 inComponent:0 animated:NO];
}

// 选择考试项目
- (IBAction)chooseTypeClick:(id)sender {
    if ([CommonUtil isEmpty:self.cityLabel.text]) {
        [self makeToast:@"请先选择报考城市"];
        return;
    }
    self.pickerType = 2;
    [self.picker reloadAllComponents];
    [self.view addSubview:self.selectView];
    [self.picker selectRow:0 inComponent:0 animated:NO];
}

// 关闭选择页面
- (IBAction)closeSelectViewClick:(id)sender {
    [self.selectView removeFromSuperview];
}

// 确定选择结果
- (IBAction)selectDoneClick:(id)sender {
    NSInteger index = [self.picker selectedRowInComponent:0];
    
    // 城市
    if (self.pickerType == 1) {
        self.curExameCity = self.cityArray[index];
        self.cityLabel.text = self.curExameCity.cityName;
        
        // 如果选中的城市是自己设置的城市且不在开通城市内
        if (CITY_OUT) {
            [self exameDataConfig:nil];
        } else {
            [self postGetExamePrice];
        }
    }
    // 驾考
    else {
        self.curExame = self.exameArray[index];
        self.typeLabel.text = self.curExame.exameName;
        [self priceLabelConfig];
    }
    [self.selectView removeFromSuperview];
}

// 报名
- (IBAction)signUpClick:(id)sender {
    if (CITY_OUT) { // 选中自己设置的城市，且不在开通城市内
        [self postSignUp];
    }
    else {
        [self postSignUpAndPay];
    }
}

// 关闭弹窗
- (IBAction)closeAlertViewClick:(id)sender
{
    [self.alertView removeFromSuperview];
}

@end
