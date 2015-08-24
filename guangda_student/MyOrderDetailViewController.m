//
//  MyOrderDetailViewController.m
//  guangda_student
//
//  Created by 冯彦 on 15/3/29.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyOrderDetailViewController.h"
#import "MyOrderComplainViewController.h"
#import "MyOrderEvaluationViewController.h"
#import "GuangdaCoach.h"
#import "TQStarRatingView.h"
#import <BaiduMapAPI/BMapKit.h>
#import "AppointCoachViewController.h"
#import "LoginViewController.h"

#define CUSTOM_GREY RGB(60, 60, 60)
#define CUSTOM_GREEN RGB(80, 203, 140)
#define BORDER_WIDTH 0.7

@interface MyOrderDetailViewController () <StarRatingViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKGeneralDelegate, UIAlertViewDelegate> {
    CGFloat strHeight1;
    CGFloat strHeight2;
    BMKLocationService *_locService;
    int _payType; // 支付方式 1.账户余额 2.学时券 3.小巴币
}

// orderinfo
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;      // 订单状态
@property (strong, nonatomic) IBOutlet UIView *orderInfoView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *orderInfoHeightCon;
@property (weak, nonatomic) IBOutlet UILabel *orderIDLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderCreateDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachPhoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderAddrLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *orderAddrLabelHeightCon;
@property (strong, nonatomic) IBOutlet UIView *priceView;
@property (strong, nonatomic) IBOutlet UILabel *costLabel;

// btn
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;        // 右边按钮
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;         // 左边按钮

// 我对教练的评价
@property (strong, nonatomic) IBOutlet UIView *seperateView1;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *seperateView1HeightCon;
@property (strong, nonatomic) IBOutlet UIView *myEvaluationView;
@property (assign, nonatomic) float scoreToCoach;
@property (copy, nonatomic) NSString *myEvaluationStr;
@property (strong, nonatomic) IBOutlet UILabel *myEvaluationLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreToCoachLabel;

// 教练对我的评价
@property (strong, nonatomic) IBOutlet UIView *seperateView2;
@property (strong, nonatomic) IBOutlet UIView *coachEvaluationView;
@property (assign, nonatomic) float scoreToMe;
@property (copy, nonatomic) NSString *evaluationStr;
@property (strong, nonatomic) IBOutlet UILabel *coachEvaluationLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreToMeLabel;

// 提示框
@property (strong, nonatomic) UIAlertView *confirmOnAlert;
@property (strong, nonatomic) UIAlertView *confirmDownAlert;
@property (strong, nonatomic) NSTimer *confirmTimer;

@property (strong, nonatomic) IBOutlet UIView *moreOperationView; // 更多操作
@property (strong, nonatomic) IBOutlet UIView *sureCancelOrderView; // 确认取消订单
@property (strong, nonatomic) IBOutlet UILabel *cancelOrderBannerLabel; // 提示订单正在确认取消中
@property (weak, nonatomic) IBOutlet UIButton *postCancelOrderBtn; // 请教练确认

//@property (strong, nonatomic) TQStarRatingView *coachStarView;
@property (strong, nonatomic) TQStarRatingView *myEvaluationStarView;
@property (strong, nonatomic) TQStarRatingView *coachEvaluationStarView;

@property (strong, nonatomic) GuangdaOrder *order;              // 订单
@property (strong, nonatomic) GuangdaCoach *coach;              // 教练
@property (strong, nonatomic) NSDictionary *orderInfoDic;       // 订单信息
@property (strong, nonatomic) NSDictionary *myEvaluationDic;    // 我对教练的评价
@property (strong, nonatomic) NSDictionary *evaluationDic;      // 教练对我的评价

//用户定位
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (strong, nonatomic) NSString *cityName;//城市
@property (strong, nonatomic) NSString *address;//地址

// 约束
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *myEvaluationLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *myEvaluationViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *coachEvaluationLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *coachEvaluationViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;

@end

@implementation MyOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self postGetOrderDetail];
}

#pragma mark - 页面设置
- (void)settingView {
    // 教练综合评分
//    self.coachStarView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(_screenWidth - 93 - 10, 13, 93, 17) numberOfStar:5];
//    self.coachStarView.couldClick = NO;
//    self.coachStarView.delegate = self;
//    [self.coachStarView changeStarForegroundViewWithPoint:CGPointMake(0, 0)];//设置星级
//    [self.orderInfoView addSubview:self.coachStarView];
    
    // 我给教练的评分
    self.myEvaluationStarView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(_screenWidth - 93 - 10, 53, 93, 17) numberOfStar:5];
    self.myEvaluationStarView.couldClick = NO;
    self.myEvaluationStarView.delegate = self;
    [self.myEvaluationStarView changeStarForegroundViewWithPoint:CGPointMake(0, 0)];//设置星级
    [self.myEvaluationView addSubview:self.myEvaluationStarView];
    
    // 教练给我的评分
    self.coachEvaluationStarView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(_screenWidth - 93 - 10, 13, 93, 17) numberOfStar:5];
    self.coachEvaluationStarView.couldClick = NO;
    self.coachEvaluationStarView.delegate = self;
    [self.coachEvaluationStarView changeStarForegroundViewWithPoint:CGPointMake(0, 0)];//设置星级
    [self.coachEvaluationView addSubview:self.coachEvaluationStarView];

    // 确定取消订单弹框
    [self sureCancelOrderViewConfig];
}

// 订单状态文字配置
- (void)orderStateTextConfig
{
    // 未完成订单
    if (self.order.orderType == OrderTypeUncomplete) {
        int minutes = self.order.minutes;
        if (minutes > 0) {
            if (minutes > 24 * 60) {
                int days = minutes / (24 * 60);
                self.statusLabel.text = [NSString stringWithFormat:@"离学车还有%d天", days];
            } else {
                int hours = minutes / 60;
                int restMinutes = minutes %60;
                self.statusLabel.text = [NSString stringWithFormat:@"离学车还有%d小时%d分", hours, restMinutes];
            }
        }
        else if (minutes == 0) {
            self.statusLabel.text = @"订单即将开始";
        }
        else if (minutes == -1) {
            self.statusLabel.text = @"正在学车中...";
        }
        else if (minutes == -2) {
            self.statusLabel.text = @"等待投诉处理";
        }
        else if (minutes == -3) {
            self.statusLabel.text = @"等待确认上车";
        }
        else if (minutes == -4) {
            self.statusLabel.text = @"等待确认下车";
        }
        
    }
    
    // 待评价订单
    else if (self.order.orderType == OrderTypeWaitEvaluate) {
        self.statusLabel.text = @"学车结束，请评价";
    }
    
    // 已完成订单
    else if (self.order.orderType == OrderTypeComplete) {
        self.statusLabel.text = @"学车完成";
    }
    
    // 投诉中订单
    else if (self.order.orderType == OrderTypeComplained) {
        self.statusLabel.text = @"投诉处理中...";
    }
}

// 确定取消订单弹框
- (void)sureCancelOrderViewConfig {
    self.moreOperationView.frame = [UIScreen mainScreen].bounds;
    
    self.sureCancelOrderView.bounds = CGRectMake(0, 0, 300, 150);
    self.sureCancelOrderView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    self.sureCancelOrderView.layer.borderWidth = 1;
    self.sureCancelOrderView.layer.borderColor = [RGB(204, 204, 204) CGColor];
    self.sureCancelOrderView.layer.cornerRadius = 4;
    
    // 请教练确认
    self.postCancelOrderBtn.layer.borderWidth = 0.8;
    self.postCancelOrderBtn.layer.borderColor = [RGB(204, 204, 204) CGColor];
    self.postCancelOrderBtn.layer.cornerRadius = 3;
}

- (void)showData {
    [self orderInfoViewShowData];

    // myEvaluation
    if (_myEvaluationDic) {
        self.seperateView1.hidden = NO;
        self.myEvaluationView.hidden = NO;
        self.scoreToCoachLabel.text = [NSString stringWithFormat:@"%.1f分", _scoreToCoach];
        self.myEvaluationLabel.text = _myEvaluationStr;
        [self.myEvaluationStarView changeStarForegroundViewWithPoint:CGPointMake(_scoreToCoach / 5 * CGRectGetWidth(self.myEvaluationStarView.frame), 0)];
    } else {
        self.myEvaluationLabel.text = @"暂无评价";
        [self.myEvaluationStarView changeStarForegroundViewWithScore:0];
    }
    
    // evaluation
    if (_evaluationDic) {
        self.seperateView2.hidden = NO;
        self.coachEvaluationView.hidden = NO;
        self.scoreToMeLabel.text = [NSString stringWithFormat:@"%.1f分", _scoreToMe];
        self.coachEvaluationLabel.text = _evaluationStr;
        [self.coachEvaluationStarView changeStarForegroundViewWithPoint:CGPointMake(_scoreToMe / 5 * CGRectGetWidth(self.coachEvaluationStarView.frame), 0)];
    } else {
        self.coachEvaluationLabel.text = @"暂无评价";
        [self.coachEvaluationStarView changeStarForegroundViewWithScore:0];
    }
}

// 显示订单信息
- (void)orderInfoViewShowData {
    // 教练
    self.coachNameLabel.text = [NSString stringWithFormat:@"%@ 教练", self.coach.realName];
    
    // 订单状态
    [self orderStateTextConfig];
    
    // 订单编号
    
    // 下单时间
    self.orderCreateDateLabel.text = self.order.creatTime;
    
    // 学车地址
    NSString *addrStr = self.order.detailAddr;
    CGFloat addrStrHeight = [CommonUtil sizeWithString:addrStr fontSize:13 sizewidth:_screenWidth - 85 sizeheight:MAXFLOAT].height;
    self.orderAddrLabel.text = addrStr;
    self.orderAddrLabelHeightCon.constant = addrStrHeight;
    
    // 学车时间
    NSArray *startTimeArray = [self.order.startTime componentsSeparatedByString:@" "];
    NSString *startDateStr = startTimeArray[0];
    NSString *startTimeStr = [startTimeArray[1] substringToIndex:5];
    NSArray *endTimeArray = [self.order.endTime componentsSeparatedByString:@" "];
    NSString *endTimeStr = [endTimeArray[1] substringToIndex:5];
    if ([endTimeStr isEqualToString:@"00:00"]) {
        endTimeStr = @"24:00";
    }
    self.orderTimeLabel.text = [NSString stringWithFormat:@"%@ %@~%@", startDateStr, startTimeStr, endTimeStr];
    
    // 科目车型
    NSArray *orderHourArray = self.order.hourArray;
    CGFloat priceViewHeight = 13;
    if (orderHourArray) {
        priceViewHeight = [self showPriceList:orderHourArray];
    }
    
    // 教练手机
    self.coachPhoneLabel.text = self.coach.phone;
    
    // 金额
    NSMutableString *costStr = [NSMutableString stringWithFormat:@"%@元", self.order.cost];
    if (_payType == 1) {
        [costStr appendString:@" (余额支付)"];
    }
    if (_payType == 2) { // 学时券支付
        [costStr appendString:@" (学时券支付)"];
    } else if (_payType == 3) {
        [costStr appendString:@" (小巴币支付)"];
    }
    self.costLabel.text = costStr;
    
    // 教练综合评分
//    [self.coachStarView changeStarForegroundViewWithPoint:CGPointMake(self.coach.score / 5 * CGRectGetWidth(self.coachStarView.frame), 0)];
    
    // 教练电话
    if (![CommonUtil isEmpty:self.coachPhoneLabel.text]) {
        UITapGestureRecognizer *telGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickForCallCoachPhone)];
        [self.coachPhoneLabel addGestureRecognizer:telGesture];
    }
    
    // 计算高度
    NSString *myEvaluationStr = [CommonUtil isEmpty:_myEvaluationStr]? @"" : _myEvaluationStr;
    NSString *evaluationStr = [CommonUtil isEmpty:_evaluationStr]? @"" : _evaluationStr;
    strHeight1 = [CommonUtil sizeWithString:myEvaluationStr fontSize:13 sizewidth:(_screenWidth - 20) sizeheight:0].height;
    strHeight2 = [CommonUtil sizeWithString:evaluationStr fontSize:13 sizewidth:(_screenWidth - 20) sizeheight:0].height;
    _myEvaluationLabelHeight.constant = strHeight1;
    _coachEvaluationLabelHeight.constant = strHeight2;
    _myEvaluationViewHeight.constant = _myEvaluationViewHeight.constant - 13 + strHeight1;
    _coachEvaluationViewHeight.constant = _coachEvaluationViewHeight.constant - 13 + strHeight2;
    
    _orderInfoHeightCon.constant = _orderInfoHeightCon.constant - 13 + addrStrHeight - 13 +priceViewHeight;
    _mainViewHeight.constant = _mainViewHeight.constant - 13 + addrStrHeight - 26 + strHeight1 + strHeight2 - 13 + priceViewHeight;
    
    // 按钮配置
    [self operationBtnsConfig];

    // 订单是否正在取消中
    if ((self.order.studentState == 4) && (self.order.coachState != 4)) {
        self.cancelOrderBannerLabel.hidden = NO;
    } else {
        self.cancelOrderBannerLabel.hidden = YES;
    }
}

// 科目车型(需求更改导致)
- (CGFloat)showPriceList:(NSArray *)priceArray {
    CGFloat gap = 10;
    CGFloat y = 0;
    for (int i = 0; i < priceArray.count; i++) {
        // 获取数据
        NSDictionary *hourDict = priceArray[i];
        int hour = [hourDict[@"hour"] intValue];
        NSString *start = [NSString stringWithFormat:@"%d:00", hour];
        NSString *end = [NSString stringWithFormat:@"%d:00", hour +1];
        NSString *time = [NSString stringWithFormat:@"%@~%@", start, end];
        
        // 创建label
        UILabel *label = [[UILabel alloc] init];
        CGFloat labelW = _screenWidth - 85;
        CGFloat labelH = 13;
        CGFloat labelX = 0;
        CGFloat labelY = i * (labelH + gap);
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = RGB(61, 61, 61);
        label.text = time;
        
        [self.priceView addSubview:label];
        y = CGRectGetMaxY(label.frame);
    }
    
//    self.priceViewHeightCon.constant = y;
    return y;
}

// 请求取消订单后的界面设置
- (void)orderConfigAfterRequestCanceled {
    [self clickForCloseMoreOperation:nil];
    self.cancelOrderBannerLabel.hidden = NO;
}

#pragma mark - 按钮样式
- (void)btnConfig:(UIButton *)btn
  withBorderWidth:(CGFloat)borderWidth
      borderColor:(CGColorRef)borderColor
     cornerRadius:(CGFloat)cornerRadius
  backgroundColor:(UIColor *)backgroundColor
            title:(NSString *)title
       titleColor:(UIColor *)titleColor
           action:(SEL)action
{
    btn.layer.borderWidth = borderWidth;
    btn.layer.borderColor = borderColor;
    btn.layer.cornerRadius = cornerRadius;
    btn.backgroundColor = backgroundColor;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

// 取消订单按钮
- (void)cancelOrderBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:BORDER_WIDTH
        borderColor:[CUSTOM_GREY CGColor]
       cornerRadius:4
    backgroundColor:[UIColor whiteColor]
              title:@"取消订单"
         titleColor:CUSTOM_GREY
             action:@selector(clickForMoreOperation:)];
}

// 确认上车按钮
- (void)confirmOnBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:0
        borderColor:[[UIColor clearColor] CGColor]
       cornerRadius:4
    backgroundColor:CUSTOM_GREEN
              title:@"确认上车"
         titleColor:[UIColor whiteColor]
             action:@selector(confirmOnClick)];
}

// 确认下车按钮
- (void)confirmDownBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:0
        borderColor:[[UIColor clearColor] CGColor]
       cornerRadius:4
    backgroundColor:CUSTOM_GREEN
              title:@"确认下车"
         titleColor:[UIColor whiteColor]
             action:@selector(confirmDownClick)];
}

// 投诉按钮
- (void)complainBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:BORDER_WIDTH
        borderColor:[CUSTOM_GREY CGColor]
       cornerRadius:4
    backgroundColor:[UIColor whiteColor]
              title:@"投诉"
         titleColor:[UIColor whiteColor]
             action:@selector(complainClick)];
}

// 评价按钮
- (void)eveluateBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:0
        borderColor:[[UIColor clearColor] CGColor]
       cornerRadius:4
    backgroundColor:CUSTOM_GREEN
              title:@"立即评价"
         titleColor:[UIColor whiteColor]
             action:@selector(eveluateClick)];
}

// 继续预约按钮
- (void)bookMoreBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:BORDER_WIDTH
        borderColor:[CUSTOM_GREEN CGColor]
       cornerRadius:4
    backgroundColor:[UIColor whiteColor]
              title:@"继续预约"
         titleColor:CUSTOM_GREEN
             action:@selector(bookMoreClick)];
}

// 按钮组配置
- (void)operationBtnsConfig
{
    // 未完成订单
    if (self.order.orderType == OrderTypeUncomplete) {
        if (self.order.canCancel) { // 可以取消订单
            self.leftBtn.hidden = YES;
            [self cancelOrderBtnConfig:self.rightBtn];
        }
        
        else {
            if (self.order.canUp) { // 可以确认上车
                self.leftBtn.hidden = YES;
                [self confirmOnBtnConfig:self.rightBtn];
            }
            
            else { // 可以确认下车
                self.leftBtn.hidden = YES;
                [self confirmDownBtnConfig:self.rightBtn];
            }
        }
    }
    
    // 待评价订单
    else if (self.order.orderType == OrderTypeWaitEvaluate) {
        // 投诉
        [self complainBtnConfig:self.leftBtn];
        // 评价
        [self eveluateBtnConfig:self.rightBtn];
    }
    
    // 已完成订单
    else if (self.order.orderType == OrderTypeComplete) {
        self.leftBtn.hidden = YES;
        // 继续预约
        [self bookMoreBtnConfig:self.rightBtn];
    }
    
    // 投诉中订单
    else if (self.order.orderType == OrderTypeComplained) {
        self.rightBtn.hidden = YES;
        self.leftBtn.hidden = YES;
    }
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
            [self printDic:responseObject withTitle:@"订单详细"];
            _orderInfoDic =[responseObject objectForKey:@"orderinfo"];
            [self loadData];
            [self showData];
            
            NSMutableDictionary *dict = [_orderInfoDic[@"cuserinfo"] mutableCopy];
            NSString *detail = [_orderInfoDic[@"detail"] description];
            [dict setObject:detail forKey:@"detail"];
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

// 取消订单
- (void)postCancelOrder {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:_orderid forKey:@"orderid"];
    
    NSString *uri = @"/sorder?action=CancelOrder";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self printDic:responseObject withTitle:@"订单详细-取消订单"];
//            [self makeToast:@"订单已取消"];
//            if ([self.isSkip isEqualToString:@"1"]) {
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            } else {
//                [self.navigationController popViewControllerAnimated:YES];
//            }
            [self orderConfigAfterRequestCanceled];
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

// 取消投诉
- (void)postCancelComplaint {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:_orderid forKey:@"orderid"];
    
    NSString *uri = @"/sorder?action=CancelComplaint";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self printDic:responseObject withTitle:@"订单详细-取消投诉"];
            [self makeToast:@"已取消投诉"];
            [self viewWillAppear:YES];
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

// 确认上车
- (void)postConfirmOn {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    // 经度
    NSString *lat = [NSString stringWithFormat:@"%f", self.userCoordinate.latitude];
    // 纬度
    NSString *lon = [NSString stringWithFormat:@"%f", self.userCoordinate.latitude];
    // 详细地址
    NSString *detailAddr = self.address;
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:self.orderid forKey:@"orderid"];
    if (![CommonUtil isEmpty:lat]) [paramDic setObject:lat forKey:@"lat"];
    if (![CommonUtil isEmpty:lon]) [paramDic setObject:lon forKey:@"lon"];
    if (![CommonUtil isEmpty:detailAddr]) [paramDic setObject:detailAddr forKey:@"detail"];
    
    NSString *uri = @"/sorder?action=ConfirmOn";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"确认上车成功"];
            [self viewWillAppear:YES];
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

// 确认下车
- (void)postConfirmDown {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    // 经度
    NSString *lat = [NSString stringWithFormat:@"%f", self.userCoordinate.latitude];
    // 纬度
    NSString *lon = [NSString stringWithFormat:@"%f", self.userCoordinate.latitude];
    // 详细地址
    NSString *detailAddr = self.address;
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:self.orderid forKey:@"orderid"];
    if (![CommonUtil isEmpty:lat]) [paramDic setObject:lat forKey:@"lat"];
    if (![CommonUtil isEmpty:lon]) [paramDic setObject:lon forKey:@"lon"];
    if (![CommonUtil isEmpty:detailAddr]) [paramDic setObject:detailAddr forKey:@"detail"];
    
    NSString *uri = @"/sorder?action=ConfirmDown";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"确认下车成功"];
            [self viewWillAppear:YES];
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

#pragma mark - 定位 BMKLocationServiceDelegate
- (void)startLocation {
    //定位 初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
}

/**
 *用户位置更新后，会调用此函数(无法调用这个方法，可能更新的百度地图.a文件有关)
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation {
    _userCoordinate = userLocation.location.coordinate;
    if (_userCoordinate.latitude == 0 || _userCoordinate.longitude == 0) {
        NSLog(@"位置不正确");
        return;
    } else  {
        [_locService stopUserLocationService];
    }
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = _userCoordinate;
    
    BMKGeoCodeSearch *_geoSearcher = [[BMKGeoCodeSearch alloc] init];
    _geoSearcher.delegate = self;
    BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if (flag) {
        NSLog(@"地理编码检索");
    } else {
        NSLog(@"地理编码检索失败");
    }
}

/**
 *用户位置更新后，会调用此函数(调用这个方法，可能更新的百度地图.a文件有关)
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateBMKUserLocation lat %f,long %f, sutitle: %@",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude, userLocation.subtitle);
    _userCoordinate = userLocation.location.coordinate;
    if (_userCoordinate.latitude == 0 || _userCoordinate.longitude == 0) {
        NSLog(@"位置不正确");
        return;
    } else  {
        [_locService stopUserLocationService];
    }
    
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = _userCoordinate;
    
    BMKGeoCodeSearch *_geoSearcher = [[BMKGeoCodeSearch alloc] init];
    _geoSearcher.delegate = self;
    BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if (flag) {
        NSLog(@"地理编码检索");
    } else {
        NSLog(@"地理编码检索失败");
    }
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    [_locService stopUserLocationService];
    NSLog(@"定位失败%@", error);
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (error == BMK_SEARCH_NO_ERROR) {
        self.cityName = result.addressDetail.city;
        self.address = result.address;
        [self.confirmTimer fire];
    }
}

#pragma mark - 数据处理
- (void)loadData {
    // orderinfo
    if (self.orderType == OrderTypeUncomplete) {
        self.order = [GuangdaOrder unCompleteOrderWithDict:self.orderInfoDic];
    } else if (self.orderType == OrderTypeWaitEvaluate) {
        self.order = [GuangdaOrder waitEvaluateOrderWithDict:self.orderInfoDic];
    } else if (self.orderType == OrderTypeComplete) {
        self.order = [GuangdaOrder completeOrderWithDict:self.orderInfoDic];
    } else if (self.orderType == OrderTypeComplained) {
        self.order = [GuangdaOrder complainedOrderWithDict:self.orderInfoDic];
    }
    
    // coachinfo
    self.coach = self.order.coach;
    
    _payType = [self.orderInfoDic[@"paytype"] intValue];
    
    _myEvaluationDic = self.orderInfoDic[@"myevaluation"];
    _evaluationDic =self.orderInfoDic[@"evaluation"];
    
    // myEvaluation
    _scoreToCoach = [_myEvaluationDic[@"score"] floatValue];
    _myEvaluationStr = _myEvaluationDic[@"content"];
    
    // evaluation
    _scoreToMe = [_evaluationDic[@"score"] floatValue];
    _evaluationStr = _evaluationDic[@"content"];
}

#pragma mark - 点击事件
// 取消订单(更多操作页)
- (void)clickForMoreOperation:(UIButton *)sender {
    [self.view addSubview:self.moreOperationView];
}

// 关闭更多操作页
- (IBAction)clickForCloseMoreOperation:(UIButton *)sender {
    [self.moreOperationView removeFromSuperview];
}

// 确认取消订单
- (IBAction)clickForSureCancelOrder:(UIButton *)sender {
    [self postCancelOrder];
}

// 投诉
- (void)complainClick {
    MyOrderComplainViewController *targetController = [[MyOrderComplainViewController alloc] initWithNibName:@"MyOrderComplainViewController" bundle:nil];
    targetController.orderid = _orderid;
    [self.navigationController pushViewController:targetController animated:YES];
}

// 取消投诉
//- (void)clickForCancelComplain {
//    [self postCancelComplaint];
//}

// 确认上车
- (void)confirmOnClick {
    //定位
    [self startLocation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认上车？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.confirmOnAlert = alert;
    [alert show];
}

// 确认下车
- (void)confirmDownClick {
    //定位
    [self startLocation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认下车？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.confirmDownAlert = alert;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 确认上车
    if ([alertView isEqual:self.confirmOnAlert]) {
        if (buttonIndex == 1) {
            [DejalBezelActivityView activityViewForView:self.view];
            self.confirmTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(postConfirmOn) userInfo:nil repeats:NO];
        }
    }
    // 确认下车
    else {
        if (buttonIndex == 1) {
            [DejalBezelActivityView activityViewForView:self.view];
            self.confirmTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(postConfirmDown) userInfo:nil repeats:NO];
            //            [self performSelector:@selector(postConfirmDown:) withObject:self.confirmOrderId afterDelay:5];
        }
    }
}

// 评价订单
- (void)eveluateClick {
    MyOrderEvaluationViewController *targetController = [[MyOrderEvaluationViewController alloc] initWithNibName:@"MyOrderEvaluationViewController" bundle:nil];
    targetController.orderid = self.orderid;
    [self.navigationController pushViewController:targetController animated:YES];
}

// 拨打教练电话
- (void)clickForCallCoachPhone {
    NSString *num = [NSString stringWithFormat:@"telprompt://%@", self.coach.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
}

// 继续预约
- (void)bookMoreClick
{
    // 预约教练
    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
    nextController.coachInfoDic = self.order.coachInfoDict;
    nextController.coachId = [self.order.coachInfoDict [@"coachid"] description];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)backClick:(id)sender
{
    if ([_isSkip isEqualToString:@"1"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
