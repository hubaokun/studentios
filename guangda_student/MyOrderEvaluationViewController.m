//
//  MyOrderEvaluationViewController.m
//  guangda_student
//
//  Created by duanjycc on 15/3/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyOrderEvaluationViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "TQStarRatingView.h"
#import "GuangdaCoach.h"
#import "GuangdaOrder.h"
#import "LoginViewController.h"

@interface MyOrderEvaluationViewController () <UITextViewDelegate, StarRatingViewDelegate>
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UITextView *evaluationTextView;
@property (strong, nonatomic) IBOutlet UILabel *evaluationPlaceholderLabel;

@property (strong, nonatomic) TQStarRatingView *teachMannerStarView;
@property (strong, nonatomic) TQStarRatingView *teachQualityStarView;
@property (strong, nonatomic) TQStarRatingView *carQualityStarView;

@property (strong, nonatomic) GuangdaOrder *order;          // 订单
@property (strong, nonatomic) GuangdaCoach *coach;          // 订单信息
@property (strong, nonatomic) NSDictionary *orderInfoDic;       // 订单信息

- (IBAction)clickForCommit:(id)sender;
@end

@implementation MyOrderEvaluationViewController

- (void)viewDidLoad {
    [self.mainScrollView contentSizeToFit];
    [super viewDidLoad];
    [self settingView];
    [self postGetOrderDetail];
}

#pragma mark - 页面设置
- (void)settingView {
    // 教学态度
    self.teachMannerStarView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(89, 0, 93, 17) numberOfStar:5];
    self.teachMannerStarView.couldClick = YES;
    self.teachMannerStarView.delegate = self;
    [self.teachMannerView addSubview:self.teachMannerStarView];
    _teachMannerScoreStr = [NSString stringWithFormat:@"%0.1f", 5.0];
    
    // 教学质量
    self.teachQualityStarView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(89, 0, 93, 17) numberOfStar:5];
    self.teachQualityStarView.couldClick = YES;
    self.teachQualityStarView.delegate = self;
    [self.teachQualityView addSubview:self.teachQualityStarView];
    _teachQualityScoreStr = [NSString stringWithFormat:@"%0.1f", 5.0];
    
    // 车容车貌
    self.carQualityStarView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(89, 0, 93, 17) numberOfStar:5];
    self.carQualityStarView.couldClick = YES;
    self.carQualityStarView.delegate = self;
    [self.carQualityView addSubview:self.carQualityStarView];
    _carQualityScoreStr = [NSString stringWithFormat:@"%0.1f", 5.0];
    
    [self keyboardHiddenFun];
}

- (void)showData {
    // orderInfo
    self.orderCreateDateLabel.text = self.order.creatTime;
    self.coachNameLabel.text = [NSString stringWithFormat:@"%@ 教练", self.coach.realName];
    self.orderAddrLabel.text = self.order.detailAddr;
    self.costLabel.text = [NSString stringWithFormat:@"%@元", self.order.cost];
    
    NSArray *startTimeArray = [self.order.startTime componentsSeparatedByString:@" "];
    NSString *startDateStr = startTimeArray[0];
    NSString *startTimeStr = [startTimeArray[1] substringToIndex:5];
    NSArray *endTimeArray = [self.order.endTime componentsSeparatedByString:@" "];
    NSString *endTimeStr = [endTimeArray[1] substringToIndex:5];
    if ([endTimeStr isEqualToString:@"00:00"]) {
        endTimeStr = @"24:00";
    }
    self.orderTimeLabel.text = [NSString stringWithFormat:@"%@ %@~%@", startDateStr, startTimeStr, endTimeStr];
    
    // 计算预约地址文字高度
    CGFloat addrStrHeight =  [CommonUtil sizeWithString:self.order.detailAddr fontSize:13 sizewidth:_screenWidth - 105 sizeheight:MAXFLOAT].height;
    self.orderAddrLabelHeightCon.constant = addrStrHeight;
}

#pragma mark - 网络请求
// test
- (void)printDic:(NSDictionary *)responseObject withTitle:(NSString *)title {
    NSLog(@"%@", [NSString stringWithFormat:@"**************%@**************", title]);
    NSLog(@"response ===== %@", responseObject);
    NSLog(@"code = %@",  responseObject[@"code"]);
    NSLog(@"message = %@", responseObject[@"message"]);
}

// 订单详细
- (void)postGetOrderDetail {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:_orderid forKey:@"orderid"];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    
    NSString *uri = @"/sorder?action=GetOrderDetail";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self printDic:responseObject withTitle:@"订单评价-订单详细"];
            _orderInfoDic =[responseObject objectForKey:@"orderinfo"];
            [self loadData];
            [self showData];
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
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

// 提交评价
- (void)postEvaluationTask {
    [self catchInputData];
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"userid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:@"2" forKey:@"type"];
    [paramDic setObject:_orderid forKey:@"orderid"];
    [paramDic setObject:_teachMannerScoreStr forKey:@"score1"];
    [paramDic setObject:_teachQualityScoreStr forKey:@"score2"];
    [paramDic setObject:_carQualityScoreStr forKey:@"score3"];
    if (![CommonUtil isEmpty:self.evaluationTextView.text]) {
        [paramDic setObject:self.evaluationTextView.text forKey:@"content"];
    }
    
    NSString *uri = @"/ctask?action=EvaluationTask";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self printDic:responseObject withTitle:@"评论订单"];
            [self makeToast:@"提交成功"];
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
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
    
}

#pragma mark - 页面特性
// 点击背景退出键盘
- (void)keyboardHiddenFun {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}
-(void)backupgroupTap:(id)sender {
    [self.evaluationTextView resignFirstResponder];
}

// 评分回调
-(void)starRatingView:(TQStarRatingView *)view score:(float)score {
    if ([view isEqual:self.teachMannerStarView]) {
        _teachMannerScoreStr = [NSString stringWithFormat:@"%0.1f", score * 5];
        self.teachMannerScoreLabel.text = [NSString stringWithFormat:@"%@分", _teachMannerScoreStr];
    }
    if ([view isEqual:self.teachQualityStarView]) {
        _teachQualityScoreStr = [NSString stringWithFormat:@"%0.1f", score * 5];
        self.teachQualityScoreLabel.text = [NSString stringWithFormat:@"%@分", _teachQualityScoreStr];
    }
    if ([view isEqual:self.carQualityStarView]) {
        _carQualityScoreStr = [NSString stringWithFormat:@"%0.1f", score * 5];
        self.carQualityScoreLabel.text = [NSString stringWithFormat:@"%@分", _carQualityScoreStr];
    }
}

// 模拟placeholder
-(void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.evaluationPlaceholderLabel.hidden = NO;
    }else{
        self.evaluationPlaceholderLabel.hidden = YES;
    }
}

#pragma mark - 数据处理
// 取得输入数据
- (void)catchInputData {
}

- (void)loadData {
    self.order = [GuangdaOrder orderWithDict:_orderInfoDic];
    self.coach = self.order.coach;
}

#pragma mark - 点击事件
- (IBAction)clickForCommit:(id)sender {
//    if ([CommonUtil isEmpty:self.evaluationTextView.text]) {
//        [self makeToast:@"请输入评论"];
//        return;
//    }
    [self postEvaluationTask];
}
@end
