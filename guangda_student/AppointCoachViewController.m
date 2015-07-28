//
//  AppointCoachViewController.m
//  guangda_student
//
//  Created by Dino on 15/4/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AppointCoachViewController.h"
#import "DSButton.h"
#import "TypeinNumberViewController.h"
#import "MainViewController.h"
#import "SliderViewController.h"
#import <CoreText/CoreText.h>
#import "SureOrderViewController.h"
#import "MyOrderDetailViewController.h"
#import "TQStarRatingView.h"
#import "LoginViewController.h"
#import "SwipeView.h"
#import "AppDelegate.h"
#import "DNCoach.h"
#import "UserBaseInfoViewController.h"
@interface AppointCoachViewController ()
<SwipeViewDelegate, SwipeViewDataSource,UIAlertViewDelegate>
{
    float _priceSum;   // 总价
    int _timeNum;    // 时间点的数量
    float _remainMoney; // 用户余额
}

// 参数
@property (strong, nonatomic) DNCoach *coach;
@property (strong, nonatomic) UIView *coachTimeContentView;
@property (strong, nonatomic) NSMutableArray *timeMutableList;      // 时间点数据数组 用于存储各个时间点的数据 单价、科目、时间
@property (strong, nonatomic) IBOutlet UILabel *noTimeSelectedLabel;// 你还未选择任何时间 label
@property (strong, nonatomic) IBOutlet UIView *timePriceView;       // 小时数和价格label 的 view
@property (strong, nonatomic) IBOutlet UILabel *timeNumLabel;       // 已选择的小时数量
@property (strong, nonatomic) IBOutlet UILabel *priceSumLabel;      // 总价格label
@property (strong, nonatomic) NSString *nowSelectedDate;            // 当前选中的日期

@property (strong, nonatomic) NSMutableArray *selectDateList;       // 上方用来选择的日期的label的list
@property (strong, nonatomic) UIView *dateListView;

// 接口返回的dateList
@property (strong, nonatomic) NSArray *dateList;
@property (strong, nonatomic) NSMutableArray *dateLabelList;
@property (strong, nonatomic) NSMutableArray *dateTimeSelectedList;     // 被选中的时间点的列表  用于传递到下一个界面生成订单

@end

@implementation AppointCoachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.coach = [DNCoach coachWithDict:self.coachInfoDic];
    
//    // 请求刷新教练日程接口
//    self.nowSelectedDate = [CommonUtil getStringForDate:[NSDate date] format:@"yyyy-MM-dd"];
//    [self requestRefreshCoachSchedule];
    
//    self.coachTimeContentView.frame = self.coachTimeScrollView.bounds;
//    [self.coachTimeScrollView addSubview:self.coachTimeContentView];
    self.timeMutableList = [NSMutableArray array];
    self.dateTimeSelectedList = [NSMutableArray array];
    self.selectDateList = [NSMutableArray array];
    self.dateLabelList = [NSMutableArray array];
    
    self.coachTimeContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.coachTimeScrollView addSubview:_coachTimeContentView];
    
//    self.timeListView.frame = CGRectMake(0, 0, 600, 40);
//    [self.timeScrollView addSubview:_timeListView];
    
//    // 设置时间选择栏
//    self.clipView.scrollView = self.timeScrollView;
//    self.dateListView = [self getTimeForSelected];
//    [self.timeScrollView addSubview:self.dateListView];
//    self.timeScrollView.contentSize = CGSizeMake(self.dateListView.bounds.size.width, 0);
//
//    UIGestureRecognizer *gestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(dateSelectClick:)];
//    [self.clipView addGestureRecognizer:gestureRecognizer];
    
    CGFloat _y = 0;
    // 提示语
    UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, SCREEN_WIDTH, 20)];
    remindLabel.text = @"您预约的时间是指开始时间后的一个小时";
    remindLabel.font = [UIFont systemFontOfSize:10];
    remindLabel.textColor = RGB(184, 184, 184);
    remindLabel.textAlignment = NSTextAlignmentCenter;
    [_coachTimeContentView addSubview:remindLabel];
    
    _y += 26;
    
    CGFloat _width = (SCREEN_WIDTH - 60 - 28) / 4;
    CGFloat _height = _width * 125/114;
    
    // 上午
    UIView *morningView = [[UIView alloc] initWithFrame:CGRectMake(0, _y, SCREEN_WIDTH, _height*2+5)];
    [_coachTimeContentView addSubview:morningView];
    [self addTimePointWithView:morningView andMode:1 timeNum:7];
    
    _y += _height*2+15;
    
    // 下午
    UIView *afternoonView = [[UIView alloc] initWithFrame:CGRectMake(0, _y, SCREEN_WIDTH, _height*2+5)];
    [_coachTimeContentView addSubview:afternoonView];
    [self addTimePointWithView:afternoonView andMode:2 timeNum:7];
    
    _y += _height*2+15;
    
    // 晚上
    UIView *nightView = [[UIView alloc] initWithFrame:CGRectMake(0, _y, SCREEN_WIDTH, _height*2+5)];
    [_coachTimeContentView addSubview:nightView];
    [self addTimePointWithView:nightView andMode:3 timeNum:5];
    
    _y += _height*2+15;
    
    self.coachTimeScrollView.contentSize = CGSizeMake(0, _y);
    
    // 设置界面相关显示
//    self.coachRealName.text = self.coachInfoDic[@"realname"];
//    self.carAddress.text = self.coachInfoDic[@"detail"];
//    NSString *scoreStr = [self.coachInfoDic[@"score"] description];
//    int score = [scoreStr intValue];
    
    if (self.coach.phone == nil) {
        self.phoneBtn.hidden = YES;
    }else{
        [self.phoneBtn setTitle:self.coach.phone forState:UIControlStateNormal];
    }
    
    self.coachRealName.text = self.coach.name;
    self.carAddress.text = self.coach.detail;
    int score = [self.coach.score intValue];
    
//    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
//    _remainMoney = [userInfo[@"money"] floatValue];
//    self.remainMoneyLabel.text = [NSString stringWithFormat:@"账户余额：%.1f元", _remainMoney];
    TQStarRatingView *starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(10, 27, 88, 15)];
    [starView changeStarForegroundViewWithScore:score];
    [self.coachDetailsTopView addSubview:starView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPriceNumStatus) name:@"appointCoachSuccess" object:nil];
    
    //configure swipe view
    _swipeView.alignment = SwipeViewAlignmentCenter;
    _swipeView.pagingEnabled = YES;
    _swipeView.wrapEnabled = NO;
    _swipeView.itemsPerPage = 1;
    _swipeView.truncateFinalPage = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 请求刷新教练日程接口
    if (!self.nowSelectedDate) {
        self.nowSelectedDate = [CommonUtil getStringForDate:[NSDate date] format:@"yyyy-MM-dd"];
    }
    [self requestRefreshCoachSchedule];
    [self refreshUserMoney];
    
    if (![[CommonUtil currentUtil] isLogin:NO]) {
        self.remainMoneyLabel.hidden = YES;
        self.rechargeBtn.hidden = YES;
    }else{
        
        NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
        _remainMoney = [userInfo[@"money"] floatValue];
        self.remainMoneyLabel.text = [NSString stringWithFormat:@"账户余额：%.2f元", _remainMoney];
        
        self.remainMoneyLabel.hidden = NO;
        self.rechargeBtn.hidden = NO;
    }
}

- (void)resetPriceNumStatus
{
    [self.dateTimeSelectedList removeAllObjects]; 
    _priceSum = 0;
    _timeNum = 0;

//    for (int i = 0; i < 19; i++) {
//        NSDictionary *dict = self.timeMutableList[i];
//        UIButton *button = dict[@"button"];
//        if (button.selected) {
//            _timeNum++;
//            UILabel *priceLabel = dict[@"priceLabel"];
//            NSString *priceStr = priceLabel.text;
//            float price = [priceStr floatValue];
//            _priceSum += price;
//            
//        }
//    }
//    
    // 控制各控件的显示/隐藏
    if (_priceSum > 0 && _timeNum > 0) {
        self.timeNumLabel.text = [NSString stringWithFormat:@"已选择%d个小时", _timeNum];
        self.priceSumLabel.text = [NSString stringWithFormat:@"合计%.2f元", _priceSum];
        self.sureAppointBtn.enabled = YES;
        self.timePriceView.hidden = NO;
        self.noTimeSelectedLabel.hidden = YES;
    }else{
        self.timePriceView.hidden = YES;
        self.sureAppointBtn.enabled = NO;
        self.noTimeSelectedLabel.hidden = NO;
    }
    
    // 所有的按钮都回到未选择状态
    [self deselectedAllButton];
}

/* 弹窗提示 
 type = 
 0 余额不足
 1 预约成功 已审核
 2 预约成功 未审核
 3 时间被抢订
 */
- (void)letoutResultViewWithType:(int)type
{
    self.appointResultView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.appointResultView];
    self.resultContentView.layer.cornerRadius = 10;
    self.resultContentView.layer.masksToBounds = YES;
    switch (type) {
        case 0:
            // 余额不足
            self.resultImageView.image = [UIImage imageNamed:@"icon_no_money"];
            self.resultStatusLabel.text = @"您的余额不足\n请充值";
            self.resultStatusLabel.numberOfLines = 2;
            self.resultStatusHeight.constant = 45;
            self.resultDetailsLabel.hidden = YES;
            self.contentViewHeight.constant = 220;
            [self.appointResultBtn setTitle:@"去充值" forState:UIControlStateNormal];
            [self.appointResultBtn addTarget:self action:@selector(rechargeClick:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
//        case 1:
//            // 已审核
//            self.resultImageView.image = [UIImage imageNamed:@"icon_appoint_success"];
//            self.resultStatusLabel.text = @"预约成功";
//            self.resultStatusLabel.numberOfLines = 1;
//            self.resultStatusHeight.constant = 21;
//            self.resultDetailsLabel.hidden = YES;
//            self.contentViewHeight.constant = 220;
//            [self.appointResultBtn addTarget:self action:@selector(orderDetailsClick:) forControlEvents:UIControlEventTouchUpInside];
//            break;
//            
//        case 2:
//            // 未审核
//            self.resultImageView.image = [UIImage imageNamed:@"icon_appoint_success"];
//            self.resultStatusLabel.text = @"预约成功";
//            self.resultStatusLabel.numberOfLines = 1;
//            self.resultStatusHeight.constant = 21;
//            self.contentViewHeight.constant = 250;
//            [self.appointResultBtn addTarget:self action:@selector(orderDetailsClick:) forControlEvents:UIControlEventTouchUpInside];
//            break;
//            
//        case 3:
//            self.resultImageView.image = nil;
//            self.resultImageView.hidden = YES;
//            self.contentViewHeight.constant = 175;
//            self.resultStatusLabel.text = @"您预约的时间已被\n其他学员抢走了~";
//            self.resultStatusLabel.numberOfLines = 2;
//            self.resultStatusHeight.constant = 50;
//            break;
            
        default:
            break;
    }
}

- (IBAction)removeResultClick:(id)sender {
    [self.appointResultView removeFromSuperview];
}

//- (IBAction)orderDetailsClick:(id)sender {
//    [self.appointResultView removeFromSuperview];
//    
//    MyOrderDetailViewController *viewController = [[MyOrderDetailViewController alloc] initWithNibName:@"MyOrderDetailViewController" bundle:nil];
//    [self.navigationController pushViewController:viewController animated:YES];
//}

#pragma mark - 添加横向滚动的时间选栏
- (UIView *)getTimeForSelected
{
    NSDate *nowDate = [NSDate date];
//    NSString *nowDateStr = [CommonUtil getStringForDate:nowDate format:@"yyyy\nMM/dd"];
    UIView *dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 73*30, 40)];
    
    CGFloat _x = 0;
    for (int i = 0; i < 30; i++) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(_x, 0, 73, 40)];
        [dateView addSubview:contentView];
        
        NSString *newDateStr = [CommonUtil getStringForDate:nowDate format:@"yyyy\nMM/dd"];
        NSMutableAttributedString *attributeDateStr = [[NSMutableAttributedString alloc] initWithString:newDateStr];
        [attributeDateStr addAttribute:NSForegroundColorAttributeName value:RGB(168, 170, 179) range:NSMakeRange(0, 4)];
        [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, 4)];
        [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(4, 6)];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 73, 40)];
        dateLabel.numberOfLines = 2;
        dateLabel.attributedText = attributeDateStr;
        dateLabel.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:dateLabel];
        [self.selectDateList addObject:dateLabel];
        
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(0, 0, 73, 40);
//        button.tag = i;
//        button.backgroundColor = [UIColor greenColor];
//        [button addTarget:self action:@selector(dateSelectClick:) forControlEvents:UIControlEventTouchUpInside];
//        [contentView addSubview:button];
        
        nowDate = [[NSDate date] initWithTimeInterval:24*60*60 sinceDate:nowDate];
        _x += 73;
    }
    
    return dateView;
}

#pragma mark - 添加上午视图
//- (void)addTimeViewWithY:(CGFloat)pointY
//{
//    UIView *morningView = [[UIView alloc] initWithFrame:CGRectMake(0, pointY, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    [_coachTimeContentView addSubview:morningView];
//    
//    [self addTimePointWithView:morningView];
//}

// 添加时间点view
- (void)addTimePointWithView:(UIView *)timeView andMode:(int)mode timeNum:(int)timeNum
{
    CGFloat _x = 0;
    CGFloat _y = 0;
    CGFloat _width = (SCREEN_WIDTH - 60 - 28) / 4;
    CGFloat _height = _width * 125/114;
    float _bili = SCREEN_WIDTH / 320;     // 比例
    
    int time = 0;
    
    // 上午标题
    UILabel *timeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 28, _height*2+5)];
    timeTitleLabel.backgroundColor = RGB(115, 119, 128);
    timeTitleLabel.textColor = [UIColor whiteColor];
    timeTitleLabel.numberOfLines = 2;
    timeTitleLabel.textAlignment = NSTextAlignmentCenter;
    timeTitleLabel.layer.cornerRadius = 10;
    timeTitleLabel.layer.masksToBounds = YES;
    timeTitleLabel.font = [UIFont systemFontOfSize:12];
    switch (mode) {
        case 1:
            timeTitleLabel.text = @"上\n午";
            time = 5;
            break;
        case 2:
            timeTitleLabel.text = @"下\n午";
            time = 12;
            break;
        case 3:
            timeTitleLabel.text = @"晚\n上";
            time = 19;
            break;
            
        default:
            break;
    }
    [timeView addSubview:timeTitleLabel];
    
    UIImage *image1 = [UIImage imageNamed:@"time_point_bg_blue"];   // 正常状态
    UIImage *image2 = [UIImage imageNamed:@"time_point_bg_grey"];   // 不可用
    UIImage *image3 = [UIImage imageNamed:@"time_point_bg_green"];  // 选中
    [image1 resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [image2 resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [image3 resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    // 时间点
    for (int i = 0; i < timeNum; i++)
    {
        // 各个时间点的view
        UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(38 + _x, _y, _width, _height)];
//        pointView.backgroundColor = RGB(126, 207, 224);
        pointView.layer.cornerRadius = 10;
        [timeView addSubview:pointView];
        
        // 向view中添加子元素
        
        // 按钮
        DSButton *button = [DSButton buttonWithType:UIButtonTypeCustom];
        button.frame = pointView.bounds;
        button.tag = time+i;    // tag = 时间点的值
        [button setBackgroundImage:image1 forState:UIControlStateNormal];
        [button setBackgroundImage:image2 forState:UIControlStateDisabled];
        [button setBackgroundImage:image3 forState:UIControlStateSelected];
        [button addTarget:self action:@selector(timeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.enabled = NO;
        [pointView addSubview:button];
        
//        button.value = @"120";
        
        // 时间点标识
        UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5*_bili, _width, 20*_bili)];
        pointLabel.text = [NSString stringWithFormat:@"%d:00", time + i];
        pointLabel.textColor = [UIColor whiteColor];
        pointLabel.textAlignment = NSTextAlignmentCenter;
        pointLabel.font = [UIFont systemFontOfSize:20];
        pointLabel.tag = 1;
        [pointView addSubview:pointLabel];
        
        // 科目标识
        UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 29*_bili, _width, 15*_bili)];
//        classLabel.text = @"科目三";
        classLabel.textColor = RGB(52, 136, 153);
        classLabel.textAlignment = NSTextAlignmentCenter;
        classLabel.font = [UIFont systemFontOfSize:12];
        classLabel.tag = 2;
        [pointView addSubview:classLabel];
        
        // 价格/状态
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45*_bili, _width, 13)];
//        priceLabel.text = @"120.0元";
        priceLabel.textColor = RGB(52, 136, 153);
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.tag = 3;
        [pointView addSubview:priceLabel];
        
        NSMutableDictionary *timeDic = [NSMutableDictionary dictionary];
        [timeDic setObject:pointLabel forKey:@"timeLabel"];
        [timeDic setObject:classLabel forKey:@"classLabel"];
        [timeDic setObject:priceLabel forKey:@"priceLabel"];
        [timeDic setObject:button forKey:@"button"];
        
        [self.timeMutableList addObject:timeDic];
//        NSLog(@"timeMutableList=== %@", _timeMutableList);
        
        // 设置xy值
        _x += 10 + _width;
        if (i == 3) {
            _x = 0;
            _y += 5 + _height;
        }
    }
}

#pragma mark - 请求接口
// 刷新教练日程安排
- (void)requestRefreshCoachSchedule
{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    NSString *userId = appdelegate.userid;
    
    NSString *date = self.nowSelectedDate;
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:_coachId forKey:@"coachid"];
    [paramDic setObject:date forKey:@"date"];
    if (userId) {
        [paramDic setObject:userId forKey:@"studentid"];
    }
    
    NSString *uri = @"/sbook?action=RefreshCoachSchedule";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        [self resetSelectedButton];
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            CGFloat _width = (SCREEN_WIDTH - 60 - 28) / 4;
            CGFloat _height = _width * 125/114;
            float _bili = SCREEN_WIDTH / 320;     // 比例
            
            self.dateList = responseObject[@"datelist"];
            
            for (int i = 0; i < self.dateList.count; i++) {
                NSDictionary *dateDic = [self.dateList objectAtIndex:i];        // 接口取到的数据
                NSMutableDictionary *timeDic = [[self.timeMutableList objectAtIndex:i] mutableCopy]; // 本地存储的时间点的dic
                
                NSString *subjectName = [dateDic[@"subject"] description];
                NSString *price = [dateDic[@"price"] description];
                int isRest = [dateDic[@"isrest"] intValue];
                NSString *isBooked = [dateDic[@"isbooked"] description];
                
                // 本地时间点view内的控件
                UILabel *timeLabel = timeDic[@"timeLabel"];
                UILabel *classLabel = timeDic[@"classLabel"];
                UILabel *priceLabel = timeDic[@"priceLabel"];
                DSButton *button = timeDic[@"button"];
                
                // 是否已经过期
                NSString *passTimeStr = [dateDic[@"pasttime"] description];
                int passedTime = [passTimeStr intValue];
                
                button.name = dateDic[@"addressdetail"];
                
                if (isRest == 0) {
                    // 不休息
                    timeLabel.textColor = [UIColor whiteColor];
                    classLabel.text = subjectName;
                    priceLabel.text = [NSString stringWithFormat:@"%.1f元", [price floatValue]];
                    button.enabled = YES;
                    button.value = price;
                    priceLabel.textColor = RGB(52, 136, 153);
                    classLabel.textColor = RGB(52, 136, 153);
                    classLabel.hidden = button.selected;
                    priceLabel.hidden = button.selected;
                    if ([classLabel.text isEqualToString:@"科目三"]) {
                        classLabel.textColor = RGB(255, 127, 17);
                    }
                    
                    if ([isBooked isEqualToString:@"1"]) {//教练被别人预约
                        // 被预约了
                        timeLabel.textColor = RGB(179, 179, 179);
                        classLabel.text = nil;
                        priceLabel.text = @"教练已被\n别人预约";
                        priceLabel.textColor = RGB(179, 179, 179);
                        priceLabel.numberOfLines = 0;
                        priceLabel.frame = CGRectMake(0, 45*_bili - 20, _width, 33);
                        button.enabled = NO;
                        button.selected = NO;
                        priceLabel.hidden = NO;
                    }else if ([isBooked isEqualToString:@"2"]) {//教练被自己预约
                        // 已有课程
                        timeLabel.textColor = RGB(179, 179, 179);
                        classLabel.text = nil;
                        priceLabel.text = @"您已预约\n这个教练";
                        priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        priceLabel.textColor = [UIColor redColor];
                        priceLabel.numberOfLines = 0;
                        priceLabel.frame = CGRectMake(0, 45*_bili - 20, _width, 33);
                        button.enabled = NO;
                        button.selected = NO;
                        priceLabel.hidden = NO;

                    }else if([isBooked isEqualToString:@"3"]){
                        timeLabel.textColor = RGB(179, 179, 179);
                        classLabel.text = nil;
                        priceLabel.text = @"您已预约\n其他教练";
                        priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        priceLabel.textColor = [UIColor redColor];
                        priceLabel.numberOfLines = 0;
                        priceLabel.frame = CGRectMake(0, 45*_bili - 20, _width, 33);
                        button.enabled = NO;
                        button.selected = NO;
                        priceLabel.hidden = NO;
                    }else{
                        button.enabled = YES;
                        priceLabel.frame = CGRectMake(0, 45*_bili, _width, 13);
                        // 时间已过期
                        if (passedTime == 1) {
                            button.enabled = NO;
                            timeLabel.textColor = RGB(179, 179, 179);
                            priceLabel.textColor = RGB(179, 179, 179);
                            classLabel.textColor = RGB(179, 179, 179);
                        }else{
                            button.enabled = YES;
                        }
                    }
                    
                }else{
                    // 未开课
                    priceLabel.frame = CGRectMake(0, 45*_bili, _width, 13);
                    timeLabel.textColor = RGB(179, 179, 179);
                    classLabel.hidden = YES;
                    priceLabel.text = @"未开课";
                    priceLabel.hidden = NO;
                    priceLabel.textColor = RGB(179, 179, 179);
                    button.enabled = NO;
                }
                
                [timeDic setObject:button forKey:@"button"];
                [self.timeMutableList replaceObjectAtIndex:i withObject:timeDic];
            }
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

// 刷新用户余额
- (void)refreshUserMoney
{
    NSMutableDictionary *userInfoDic = [[CommonUtil getObjectFromUD:@"UserInfo"] mutableCopy];
    NSString *userId = [userInfoDic objectForKey:@"studentid"];
    
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    if (!userId) {
        return;
    }
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    [paramDic setObject:userId forKey:@"userid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    [paramDic setObject:@"2" forKey:@"usertype"];
    
    NSString *uri = @"/system?action=refreshUserMoney";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        int code = [responseObject[@"code"] intValue];
        
        if (code == 1)
        {
            NSString *money = [responseObject[@"money"] description];
            NSString *fmoney = [responseObject[@"fmoney"] description];
            
            _remainMoney = [money floatValue];
            self.remainMoneyLabel.text = [NSString stringWithFormat:@"账户余额：%.2f元", [money doubleValue]];
            
            [userInfoDic setObject:money forKey:@"money"];
            [userInfoDic setObject:fmoney forKey:@"fmoney"];
            
            [CommonUtil saveObjectToUD:userInfoDic key:@"UserInfo"];
            
        }else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(backLogin)
                                           userInfo:nil
                                            repeats:NO];
        }
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark - actions
- (IBAction)dismissViewControlClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)timeButtonClick:(id)sender
{
    if (![[CommonUtil currentUtil] isLogin:NO]) {
        LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    DSButton *button = (DSButton *)sender;
    button.selected = !button.selected;
    
    // 计算总价
    if (button.selected) {
        _priceSum += [button.value floatValue];
        _timeNum++;
//        if (_remainMoney < _priceSum) {
//            // 弹窗 提示余额不足
//            [self letoutResultViewWithType:0];
//            button.selected = NO;
//            _priceSum -= [button.value floatValue];
//            _timeNum--;
//            return;
//        }
    }else{
        _priceSum -= [button.value floatValue];
        _timeNum--;
    }
    if (_priceSum < 0 || _timeNum == 0)
    {
        _priceSum = 0;
    }
    
    // 隐藏科目和价格
    for (id objc in button.superview.subviews) {
        if ([objc isKindOfClass:[UILabel class]]) {
            UILabel *label = objc;
            if (label.tag != 1) {
                label.hidden = button.selected;
            }
        }
    }
    
    // 控制各控件的显示/隐藏
    if (_priceSum > 0 && _timeNum > 0) {
        self.timeNumLabel.text = [NSString stringWithFormat:@"已选择%d个小时", _timeNum];
        self.priceSumLabel.text = [NSString stringWithFormat:@"合计%.2f元", _priceSum];
        self.sureAppointBtn.enabled = YES;
        self.timePriceView.hidden = NO;
        self.noTimeSelectedLabel.hidden = YES;
    }else{
        self.timePriceView.hidden = YES;
        self.sureAppointBtn.enabled = NO;
        self.noTimeSelectedLabel.hidden = NO;
    }
    
    
    // 清空之前存储的同一天的数据
    NSMutableArray *removeNum = [NSMutableArray array];
    for (int i = 0; i < self.dateTimeSelectedList.count; i++) {
        NSDictionary *dic = self.dateTimeSelectedList[i];
        NSString *dateStr = dic[@"date"];
        if ([dateStr isEqualToString:_nowSelectedDate]) {
            NSString *num = [NSString stringWithFormat:@"%d", i];
            [removeNum addObject:num];
        }
    }
    
    for (int i=0; i<removeNum.count; i++) {
        
    }
    
    NSMutableIndexSet *removeIndex = [NSMutableIndexSet indexSet];
    for (int i = 0; i < removeNum.count; i++) {
        NSString *numStr = removeNum[i];
        int num = [numStr intValue];
        [removeIndex addIndex:num];
    }
    
    
    [self.dateTimeSelectedList removeObjectsAtIndexes:removeIndex];
    
    
    // 将已选择的时间点存储到 dateTimeSelectedList 数组中，用于传递到下一个界面
    NSMutableDictionary *dateTimesDic = [NSMutableDictionary dictionary];
    [dateTimesDic setObject:_nowSelectedDate forKey:@"date"];
    
    NSMutableArray *timesList = [NSMutableArray array];
    
    NSMutableArray *selectArray = [NSMutableArray array];
    
    for (int i=0; i<self.timeMutableList.count; i++) {
        // 取出本地的时间点按钮字典
        NSDictionary *timePointDic = self.timeMutableList[i];
        DSButton *timeButton = timePointDic[@"button"];
        if (timeButton.selected) {
            UILabel *timeLabel = timePointDic[@"timeLabel"];
            NSString *time = timeLabel.text;
            [selectArray addObject:time];
        }
    }
    
    NSDictionary *timePointDic = self.timeMutableList[button.tag-5];
    UILabel *timeLabel = timePointDic[@"timeLabel"];
    NSString *time = timeLabel.text; //选中的时间
    
    NSString *time1; //选中时间的后一小时
    if (button.tag-5 == 18) {
        time1 = @"0:00";
    }else{
        NSDictionary *timePointDic1 = self.timeMutableList[button.tag-4];
        UILabel *timeLabel1 = timePointDic1[@"timeLabel"];
        time1 = timeLabel1.text;
    }

    NSString *time2; //选中时间的前一小时
    if (button.tag-5 == 0) {
        time2 = @"0:00";
    }else{
        NSDictionary *timePointDic2 = self.timeMutableList[button.tag-6];
        UILabel *timeLabel2 = timePointDic2[@"timeLabel"];
        time2 = timeLabel2.text;
    }
    
    BOOL isTwoHours = NO;
    if ([selectArray containsObject:time]) {
        for (int i=0; i<selectArray.count; i++) {
            if ([selectArray containsObject:time1]) {
                isTwoHours = YES;
                break;
            }
            if ([selectArray containsObject:time2]) {
                isTwoHours = YES;
                break;
            }
        }
    }
    
    if (isTwoHours) {
        [self makeToast:[NSString stringWithFormat:@"连续上课两小时很累，慎重考虑哦亲"]];
    }
    
    for (int i = 0; i < self.timeMutableList.count; i++) {

        // 取出本地的时间点按钮字典
        NSDictionary *timePointDic = self.timeMutableList[i];
        DSButton *timeButton = timePointDic[@"button"];
        if (timeButton.selected) {
            
            // 取出选中的时间和价格
            UILabel *timeLabel = timePointDic[@"timeLabel"];
            UILabel *priceLabel = timePointDic[@"priceLabel"];
            UILabel *subjectLabel = timePointDic[@"classLabel"];
            
            NSString *time = timeLabel.text;
            NSString *price = priceLabel.text;
            NSString *addressDetail = button.name;
            NSString *subject = subjectLabel.text;
            if (!price) {
                price = @" ";
            }
            if (!addressDetail) {
                addressDetail = @" ";
            }
            if (!subject) {
                subject = @" ";
            }
            
            // 存储时间价格的信息
            NSMutableDictionary *timePriceDic = [NSMutableDictionary dictionary];
            [timePriceDic setObject:time forKey:@"time"];
            [timePriceDic setObject:price forKey:@"price"];
            [timePriceDic setObject:addressDetail forKey:@"addressdetail"];
            [timePriceDic setObject:subject forKey:@"subject"];
            
            [timesList addObject:timePriceDic];
//            if (i == 18) {
//                NSArray *array = [NSArray arrayWithArray:timesList];
//                [dateTimesDic setObject:array forKey:@"times"];
//                
//                NSDictionary *dic = [NSDictionary dictionaryWithDictionary:dateTimesDic];
//                [self.dateTimeSelectedList addObject:dic];
//            }
//        }else{
            if (timesList.count != 0) {
                NSArray *array = [NSArray arrayWithArray:timesList];
                [dateTimesDic setObject:array forKey:@"times"];
                
                NSDictionary *dic = [NSDictionary dictionaryWithDictionary:dateTimesDic];
                [self.dateTimeSelectedList addObject:dic];
            }
            [timesList removeAllObjects];
        }
    }
}

// 充值
- (IBAction)rechargeClick:(id)sender {
    TypeinNumberViewController *viewController = [[TypeinNumberViewController alloc] initWithNibName:@"TypeinNumberViewController" bundle:nil];
    viewController.status = @"1";
    [self.navigationController  pushViewController:viewController animated:YES];
}

- (IBAction)sureAppointClick:(id)sender
{
    if ([[CommonUtil currentUtil] isLogin]) {
        NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
        NSString *realname = user_info[@"realname"];
        if (realname.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"教练该如何称呼您？请设置真实姓名后再预约" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前去设置", nil];
            [alert show];
        }else{
            SureOrderViewController *viewController = [[SureOrderViewController alloc] initWithNibName:@"SureOrderViewController" bundle:nil];
            viewController.dateTimeSelectedList = self.dateTimeSelectedList;
            viewController.coachId = self.coachId;
            viewController.priceSum = [NSString  stringWithFormat:@"%.1f", _priceSum];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UserBaseInfoViewController *nextController = [[UserBaseInfoViewController alloc] initWithNibName:@"UserBaseInfoViewController" bundle:nil];
        UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
        navigationController.navigationBarHidden = YES;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (IBAction)phoneCallClick:(id)sender
{
    NSString *phoneNum = [NSString stringWithFormat:@"telprompt:%@", self.coach.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (void)deselectedAllButton
{
    // 刷新按钮的状态
    for (int i = 0; i < self.timeMutableList.count; i++)
    {
        NSDictionary *timeDic = [self.timeMutableList objectAtIndex:i]; // 本地存储的时间点的dic
        DSButton *button = timeDic[@"button"];
        button.selected = NO;
    }
}

- (void)resetSelectedButton
{
    for (int i = 0; i < self.dateTimeSelectedList.count; i++)
    {
        NSDictionary *timeDiction = _dateTimeSelectedList[i];
        NSString *dateSelected = timeDiction[@"date"];  // 被选中的日期
        if ([dateSelected isEqualToString:_nowSelectedDate])
        {
            NSArray *timeArray = timeDiction[@"times"];
            for (int j = 0; j < timeArray.count; j++)
            {
                NSDictionary *timesDic = timeArray[j];
                NSString *timeStr = timesDic[@"time"];  // 被选中的时间点
                
                for (int k = 0; k < self.timeMutableList.count; k++)
                {
                    NSDictionary *timeDic = [self.timeMutableList objectAtIndex:k]; // 本地存储的时间点的dic
                    UILabel *timeLabel = timeDic[@"timeLabel"];
                    if ([timeLabel.text isEqualToString:timeStr])
                    {
                        DSButton *button = timeDic[@"button"];
                        button.selected = YES;
                        
                        UILabel *classLabel = timeDic[@"classLabel"];
                        UILabel *priceLabel = timeDic[@"priceLabel"];
                        
                        classLabel.hidden = YES;
                        priceLabel.hidden = YES;
                    }
                }
                
            }
        }
    }
}

#pragma mark - UISwipeViewDelegate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    //generate 100 item views
    //normally we'd use a backing array
    //as shown in the basic iOS example
    //but for this example we haven't bothered
    return 30;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
        //load new item view instance from nib
        //control events are bound to view controller in nib file
        //note that it is only safe to use the reusingView if we return the same nib for each
        //item view, if different items have different contents, ignore the reusingView value
        view = [[[NSBundle mainBundle] loadNibNamed:@"SwipTimeView" owner:self options:nil] lastObject];
    }
    
    UILabel *label = (UILabel *)[view.subviews lastObject];
    
    NSDate *date = [[NSDate date] initWithTimeInterval:24*60*60*index sinceDate:[NSDate date]];
    NSString *dateStr = [CommonUtil getStringForDate:date format:@"yyyy\nMM/dd"];
    
    NSMutableAttributedString *attributeDateStr = [[NSMutableAttributedString alloc] initWithString:dateStr];
    [attributeDateStr addAttribute:NSForegroundColorAttributeName value:RGB(168, 170, 179) range:NSMakeRange(0, 4)];
    [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, 4)];
    if (index == swipeView.currentPage) {
        [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(4, 6)];
    }else{
        [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(4, 6)];
    }
    
    label.attributedText = attributeDateStr;
    label.tag = index;
    [self.dateLabelList addObject:label];
    
    return view;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    swipeView.currentPage = index;
    
    NSDate *date = [[NSDate date] initWithTimeInterval:24*60*60*index sinceDate:[NSDate date]];
    NSString *dateStr = [CommonUtil getStringForDate:date format:@"yyyy-MM-dd"];
    self.nowSelectedDate = dateStr;
    
    [self setDateLabelFont:index];
    [self deselectedAllButton];
    [self requestRefreshCoachSchedule];
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
//    [swipeView reloadData];
    int index = (int)swipeView.currentPage;
    NSDate *date = [[NSDate date] initWithTimeInterval:24*60*60*index sinceDate:[NSDate date]];
    NSString *dateStr = [CommonUtil getStringForDate:date format:@"yyyy-MM-dd"];
    self.nowSelectedDate = dateStr;
    
    [self setDateLabelFont:index];
    [self deselectedAllButton];
    [self requestRefreshCoachSchedule];
}

- (void)setDateLabelFont:(NSInteger)index
{
    for (UILabel *label in self.dateLabelList) {
        
        NSDate *date = [[NSDate date] initWithTimeInterval:24*60*60*label.tag sinceDate:[NSDate date]];
        NSString *dateStr = [CommonUtil getStringForDate:date format:@"yyyy\nMM/dd"];
        NSMutableAttributedString *attributeDateStr = [[NSMutableAttributedString alloc] initWithString:dateStr];
        [attributeDateStr addAttribute:NSForegroundColorAttributeName value:RGB(168, 170, 179) range:NSMakeRange(0, 4)];
        [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, 4)];
        if (label.tag == index) {
            [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(4, 6)];
        }else{
            [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(4, 6)];
        }
        label.attributedText = attributeDateStr;
    }
}

@end
