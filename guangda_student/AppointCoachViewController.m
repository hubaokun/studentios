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
#import "CourseTimetableViewController.h"
#import "MainViewController.h"

@interface AppointCoachViewController () <SwipeViewDelegate, SwipeViewDataSource, UIAlertViewDelegate, CourseTimetableViewControllerDelegate, UIGestureRecognizerDelegate>
{
    float _priceSum;   // 总价
    int _timeNum;    // 时间点的数量
    bool _pageIndex;        // 切换用页(这个页面实际只有两个childViewController，index为0和1，故用此bool值来做index)
    NSUInteger _curPageNum; // 当前页
}


@property (strong, nonatomic) IBOutlet UIScrollView *coachTimeScrollView;
@property (strong, nonatomic) IBOutlet UIButton *sureAppointBtn;
@property (strong, nonatomic) IBOutlet SwipeView *swipeView;
@property (strong, nonatomic) IBOutlet UILabel *coachRealName;
@property (strong, nonatomic) IBOutlet UILabel *carAddress;
@property (strong, nonatomic) IBOutlet UIView *coachDetailsTopView; // 教练信息顶部view
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remindTapRightSpaceCon; // 提醒教练开课按钮约束

// 陪驾是否需要用教练车
@property (strong, nonatomic) IBOutlet UIView *ifNeedCarMaskView;
@property (weak, nonatomic) IBOutlet UIView *ifNeedCarView;
@property (weak, nonatomic) IBOutlet UIButton *noNeedBtn;
@property (weak, nonatomic) IBOutlet UIButton *needBtn;
@property (weak, nonatomic) IBOutlet UILabel *carCostLabel;
@property (weak, nonatomic) IBOutlet UIButton *ifNeedCarSureBtn;
@property (assign, nonatomic) BOOL needCar; // 是否需要教练车
@property (assign, nonatomic) int rentalFeePerHour; // 教练车租赁费(每小时)


@property (strong, nonatomic) DNCoach *coach;
@property (strong, nonatomic) UIView *coachTimeContentView;
//@property (strong, nonatomic) NSMutableArray *timeMutableList;      // 时间点数据数组 用于存储各个时间点的数据 单价、科目、时间
@property (strong, nonatomic) IBOutlet UILabel *noTimeSelectedLabel;// 你还未选择任何时间 label
@property (strong, nonatomic) IBOutlet UIView *timePriceView;       // 小时数和价格label 的 view
@property (strong, nonatomic) IBOutlet UILabel *timeNumLabel;       // 已选择的小时数量
@property (strong, nonatomic) IBOutlet UILabel *priceSumLabel;      // 总价格label
@property (strong, nonatomic) NSString *nowSelectedDate;            // 当前选中的日期

@property (strong, nonatomic) NSMutableArray *selectDateList;       // 上方用来选择的日期的label的list

// 接口返回的dateList
@property (strong, nonatomic) NSArray *dateList;
@property (strong, nonatomic) NSMutableArray *dateLabelList;
@property (strong, nonatomic) NSMutableArray *dateTimeSelectedList;     // 被选中的时间点的列表  用于传递到下一个界面生成订单

@property (strong, nonatomic) CourseTimetableViewController *curVC;

@property (assign, nonatomic) BOOL hasFreeCourse; // 是否已选中一节体验课
@property (assign, nonatomic) BOOL hasAuthority;  // 是否有预约体验课的权限

@end

@implementation AppointCoachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coach = [DNCoach coachWithDict:self.coachInfoDic];
    
    self.dateTimeSelectedList = [NSMutableArray array];
    self.selectDateList = [NSMutableArray array];
    self.dateLabelList = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPriceNumStatus) name:@"appointCoachSuccess" object:nil];
    
    [self viewConfig];
    
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
    [self noCarNeedClick:self.noNeedBtn]; // 默认不使用教练车
}

#pragma mark - 页面配置
- (void)viewConfig
{
    self.coachTimeContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, SCREEN_HEIGHT)];
    [self.coachTimeScrollView addSubview:self.coachTimeContentView];
    
    if (self.coach.phone == nil) {
        self.phoneBtn.hidden = YES;
    }else{
        [self.phoneBtn setTitle:self.coach.phone forState:UIControlStateNormal];
    }
    
    self.coachRealName.text = self.coach.name;
    self.carAddress.text = self.coach.detail;
    int score = [self.coach.score intValue];
    
    // 教练综合评分
    TQStarRatingView *starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(10, 27, 88, 15)];
    [starView changeStarForegroundViewWithScore:score];
    [self.coachDetailsTopView addSubview:starView];
    
    //configure swipe view
    _swipeView.alignment = SwipeViewAlignmentCenter;
    _swipeView.pagingEnabled = YES;
    _swipeView.wrapEnabled = NO;
    _swipeView.itemsPerPage = 1;
    _swipeView.truncateFinalPage = YES;
    
    // 添加教练课程表
    [self timeTableAdd];
    
    self.ifNeedCarMaskView.frame = [UIScreen mainScreen].bounds;
    self.ifNeedCarView.layer.cornerRadius = 3;
    self.ifNeedCarSureBtn.layer.cornerRadius = 3;
}

// 添加教练课程表
-(void) timeTableAdd
{
    for (int i = 0; i < 2; i++) {
        CourseTimetableViewController *contentVC = [[CourseTimetableViewController alloc] init];
        [self addChildViewController:contentVC];
        contentVC.delegate = self;
        if (i == 0) {
            [self.coachTimeContentView addSubview:contentVC.view];
        }
    }
    
    // 左扫手势
    UISwipeGestureRecognizer *swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [swipeLeftGR setCancelsTouchesInView:YES];
    [swipeLeftGR setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.coachTimeScrollView addGestureRecognizer:swipeLeftGR];
    
    // 右扫手势
    UISwipeGestureRecognizer *swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [swipeRightGR setCancelsTouchesInView:YES];
    [swipeRightGR setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.coachTimeScrollView addGestureRecognizer:swipeRightGR];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isKindOfClass:[UIButton class]]){
//        return NO;
//    }
//    return YES;
//}

// 重新计算总价
- (void)resetPriceNumStatus
{
    [self.dateTimeSelectedList removeAllObjects];
    _priceSum = 0;
    _timeNum = 0;

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
}

// 提醒教练开课标签设置
- (void)remindTapConfig:(NSDictionary *)dict
{
    // 教练状态 0:未开课 1:已开课
    int coachState = [dict[@"coachstate"] intValue];
    // 提醒状态 1:已提醒过  0:未提醒
    int remindState = [dict[@"remindstate"] intValue];
    
    // 非陪驾课表
    if (![self.carModelID isEqualToString:@"19"]) {
        if (coachState == 0 && remindState == 0) { // 提醒教练开课按钮显示
            [self remindTapShow];
        } else {
            [self remindTapHide];
        }
    }
}

- (void)remindTapShow
{
    [UIView animateWithDuration:0.25 animations:^{
        self.remindTapRightSpaceCon.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)remindTapHide
{
    [UIView animateWithDuration:0.25 animations:^{
        self.remindTapRightSpaceCon.constant = -117;
        [self.view layoutIfNeeded];
    }];
}

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

#pragma mark - 请求接口
// 刷新教练日程安排
- (void)requestRefreshCoachSchedule
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    
    AppDelegate *appdelegate = APP_DELEGATE;
    NSString *studentID = appdelegate.userid;
    if (studentID) {
        [paramDic setObject:studentID forKey:@"studentid"];
    }
    [paramDic setObject:_coachId forKey:@"coachid"];
    [paramDic setObject:self.nowSelectedDate forKey:@"date"];
    // 版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [paramDic setObject:app_Version forKey:@"version"];
    
    // 车型
    if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
        [paramDic setObject:@"1" forKey:@"scheduletype"];
    } else {
        [paramDic setObject:@"0" forKey:@"scheduletype"];
    }
    
    NSString *uri = @"/sbook?action=RefreshCoachSchedule";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
  
        if ([responseObject[@"code"] integerValue] == 1) {
            // 教练当天是否有开课
            [self remindTapConfig:responseObject];
            CourseTimetableViewController *curVC = self.childViewControllers[_pageIndex];
            self.curVC = curVC;
            NSArray *dataList = responseObject[@"datelist"];
            curVC.dateList = dataList;
            curVC.nowSelectedDate = self.nowSelectedDate;
            curVC.dateTimeSelectedList = self.dateTimeSelectedList;
            [curVC viewWillAppear:YES];
            self.coachTimeScrollView.contentSize = CGSizeMake(0, curVC.viewHeight);
            
            // 教练车租赁费
            if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
                NSDictionary *dict = dataList.firstObject;
                self.rentalFeePerHour = [dict[@"cuseraddtionalprice"] intValue];
//                NSLog(@"rentalFeePerHour = %d", self.rentalFeePerHour);
            }
            
            if (studentID) {
                [self requestAthority:studentID];
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

// 是否有预约体验课的权限
- (void)requestAthority:(NSString *)studentID
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentID forKey:@"studentid"];
    
    NSString *uri = @"/suser?action=GETFREECOURSESTATE";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            self.hasAuthority = [responseObject[@"freecoursestate"] boolValue];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

// 提醒教练开课
- (void)requestRemindCoach
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    NSString *userId = appdelegate.userid;
    if (userId) {
        [paramDic setObject:userId forKey:@"studentid"];
    }
    [paramDic setObject:_coachId forKey:@"coachid"];
    [paramDic setObject:self.nowSelectedDate forKey:@"date"];
    // 版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [paramDic setObject:app_Version forKey:@"version"];
    
    NSString *uri = @"/sbook?action=REMINDCOACH";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            // 教练当天是否有开课
            [self remindTapHide];
            [self makeToast:@"提醒教练开课成功"];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

// 更新用户余额
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

#pragma mark - Custom
- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

// 左右扫动手势
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)swipeGR {
    // 左扫
    if (swipeGR.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (_curPageNum == 9) return;
        _curPageNum++;
        CourseTimetableViewController *fromVC = self.childViewControllers[_pageIndex];
        bool toIndex = !_pageIndex;
        CourseTimetableViewController *toVC = self.childViewControllers[toIndex];
        self.curVC = toVC;
        __weak id weakSelf = self;
        [self transitionFromViewController:fromVC
                          toViewController:toVC
                                  duration:0.05
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{}
                                completion:^(BOOL finished){
                                    _pageIndex = toIndex;
                                    [fromVC.view removeFromSuperview];
                                    [toVC didMoveToParentViewController:weakSelf];
                                    [self swipeView:self.swipeView didSelectItemAtIndex:_curPageNum];
                                }];
    }
    // 右扫
    if (swipeGR.direction == UISwipeGestureRecognizerDirectionRight) {
        if (_curPageNum == 0) return;
        _curPageNum--;
        CourseTimetableViewController *fromVC = self.childViewControllers[_pageIndex];
        bool toIndex = !_pageIndex;
        CourseTimetableViewController *toVC = self.childViewControllers[toIndex];
        self.curVC = toVC;
        __weak id weakSelf = self;
        [self transitionFromViewController:fromVC
                          toViewController:toVC
                                  duration:0.05
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{}
                                completion:^(BOOL finished){
                                    _pageIndex = toIndex;
                                    [fromVC.view removeFromSuperview];
                                    [toVC didMoveToParentViewController:weakSelf];
                                    [self swipeView:self.swipeView didSelectItemAtIndex:_curPageNum];
                                }];
        
    }
    
}

// 判断是否已经选了体验课
- (BOOL)ifHasFreeCourse {
    self.hasFreeCourse = NO;
    for (NSDictionary *hourDict in self.dateTimeSelectedList) {
        NSArray *timeData = hourDict[@"times"];
        if ([timeData.firstObject[@"freecoursestate"] intValue]) {
            self.hasFreeCourse = YES;
        }
    }
    return self.hasFreeCourse;
}



#pragma mark - CourseTimetableViewControllerDelegate
// 选择时刻点
- (void)timeSelect:(DSButton *)sender
{
    if (![[CommonUtil currentUtil] isLogin:NO]) {
        LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    
//    DSButton *button = (DSButton *)sender;
    
    // 判断是否是体验课
    NSMutableDictionary *dateDic = sender.data;
    int isFreeCourse = [dateDic[@"isfreecourse"] intValue];
    if (isFreeCourse) {
        if (self.hasAuthority == NO) {
            [self makeToast:@"您不是新用户，不能预约体验课。"];
            return;
        }
        if ([self ifHasFreeCourse] && sender.selected == NO) {
            sender.selected = NO;
            [self makeToast:@"您只能预约一节免费体验课。"];
            return;
        }
    }
    
    // 最多只能选6节课
    if (self.dateTimeSelectedList.count == 6 && sender.selected == NO) {
        [self makeToast:@"抱歉，您一天最多只能预定6小时课程"];
        return;
    }
    
    sender.selected = !sender.selected;
    
    
    // 计算总价
    if (sender.selected) {
        _priceSum += [sender.value floatValue];
        _timeNum++;
    }else{
        _priceSum -= [sender.value floatValue];
        _timeNum--;
    }
//    if (_priceSum < 0 || _timeNum == 0)
//    {
//        _priceSum = 0;
//    }
    
    // 隐藏科目和价格
    for (id objc in sender.superview.subviews) {
        if ([objc isKindOfClass:[UILabel class]]) {
            UILabel *label = objc;
            if (label.tag != 1) {
                label.hidden = sender.selected;
            }
        }
    }
    
    // 控制各控件的显示/隐藏
    if (_timeNum > 0) {
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
    
    
    // 清空之前存储的该天的数据
    NSMutableArray *removeNum = [NSMutableArray array];
    for (int i = 0; i < self.dateTimeSelectedList.count; i++) {
        NSDictionary *dic = self.dateTimeSelectedList[i];
        NSString *dateStr = dic[@"date"];
        if ([dateStr isEqualToString:self.nowSelectedDate]) {
            NSString *num = [NSString stringWithFormat:@"%d", i];
            [removeNum addObject:num];
        }
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
    [dateTimesDic setObject:self.nowSelectedDate forKey:@"date"];
    
    NSMutableArray *timesList = [NSMutableArray array];
    
    NSMutableArray *selectArray = [NSMutableArray array];
    
    for (int i=0; i<self.curVC.timeMutableList.count; i++) {
        // 取出本地的时间点按钮字典
        NSDictionary *timePointDic = self.curVC.timeMutableList[i];
        DSButton *timeButton = timePointDic[@"button"];
        if (timeButton.selected) {
            UILabel *timeLabel = timePointDic[@"timeLabel"];
            NSString *time = timeLabel.text;
            [selectArray addObject:time];
            
        }
    }
    
    NSDictionary *timePointDic = self.curVC.timeMutableList[sender.tag-5];
    UILabel *timeLabel = timePointDic[@"timeLabel"];
    NSString *time = timeLabel.text; //选中的时间
    
    NSString *time1; //选中时间的后一小时
    if (sender.tag-5 == 18) {
        time1 = @"0:00";
    }else{
        NSDictionary *timePointDic1 = self.curVC.timeMutableList[sender.tag-4];
        UILabel *timeLabel1 = timePointDic1[@"timeLabel"];
        time1 = timeLabel1.text;
    }
    
    NSString *time2; //选中时间的前一小时
    if (sender.tag-5 == 0) {
        time2 = @"0:00";
    }else{
        NSDictionary *timePointDic2 = self.curVC.timeMutableList[sender.tag-6];
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
    
    // 生成self.dateTimeSelectedList
    for (int i = 0; i < self.curVC.timeMutableList.count; i++) {
        
        // 取出本地的时间点按钮字典
        NSDictionary *timePointDic = self.curVC.timeMutableList[i];
        DSButton *timeButton = timePointDic[@"button"];
        if (timeButton.selected) {
            
            // 取出选中的时间和价格
            UILabel *timeLabel = timePointDic[@"timeLabel"];
            UILabel *priceLabel = timePointDic[@"priceLabel"];
            UILabel *subjectLabel = timePointDic[@"classLabel"];
            
            NSString *time = timeLabel.text;
            NSString *price = priceLabel.text;
            if ([price isEqualToString:@"免费"]) {
                price = @"0";
            }
            NSString *addressDetail = sender.name;
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
            
            NSString *freeCourseState = @"0";
            NSMutableDictionary *timeData = timeButton.data;
            if ([timeData[@"isfreecourse"] intValue]) {
                freeCourseState = @"1";
            }
            
            // 存储时间、价格等信息
            NSMutableDictionary *timePriceDic = [NSMutableDictionary dictionary];
            [timePriceDic setObject:time forKey:@"time"];
            [timePriceDic setObject:price forKey:@"price"];
            [timePriceDic setObject:addressDetail forKey:@"addressdetail"];
            [timePriceDic setObject:subject forKey:@"subject"];
            [timePriceDic setObject:freeCourseState forKey:@"freecoursestate"];
            if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
                // 教练车租赁费
                [timePriceDic setObject:[NSNumber numberWithInt:self.rentalFeePerHour] forKey:@"cuseraddtionalprice"];
            }
            
            [timesList addObject:timePriceDic];
            
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
    return 10;
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
    _curPageNum = index;
    
    NSDate *date = [[NSDate date] initWithTimeInterval:24*60*60*index sinceDate:[NSDate date]];
    NSString *dateStr = [CommonUtil getStringForDate:date format:@"yyyy-MM-dd"];
    self.nowSelectedDate = dateStr;
    
    [self setDateLabelFont:index];
    [self requestRefreshCoachSchedule];
}

- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView
{
//    [swipeView reloadData];
    int index = (int)swipeView.currentPage;
    _curPageNum = index;
    NSDate *date = [[NSDate date] initWithTimeInterval:24*60*60*index sinceDate:[NSDate date]];
    NSString *dateStr = [CommonUtil getStringForDate:date format:@"yyyy-MM-dd"];
    self.nowSelectedDate = dateStr;
    
    [self setDateLabelFont:index];
    [self requestRefreshCoachSchedule];
}

// 改变相应日期的字体
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

#pragma mark - actions
- (IBAction)dismissViewControlClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 去支付
- (IBAction)sureAppointClick:(id)sender
{
    if ([[CommonUtil currentUtil] isLogin]) {
        NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
        NSString *realname = user_info[@"realname"];
        if (realname.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"教练该如何称呼您？请设置真实姓名后再预约" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前去设置", nil];
            [alert show];
        }else{
            if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
                int count = (int)self.dateTimeSelectedList.count;
                int price = self.rentalFeePerHour;
                NSString *carCostText = [NSString stringWithFormat:@"使用费:%d元(%d元 x %d小时)", price * count, price, count];
                if (price == 0) {
                    carCostText = @"使用费:0元";
                }
                self.carCostLabel.text = carCostText;
                [self.view addSubview:self.ifNeedCarMaskView];
            }
            else {
                SureOrderViewController *viewController = [[SureOrderViewController alloc] initWithNibName:@"SureOrderViewController" bundle:nil];
                viewController.dateTimeSelectedList = self.dateTimeSelectedList;
                viewController.coachId = self.coachId;
                viewController.priceSum = [NSString  stringWithFormat:@"%d", (int)_priceSum];
                viewController.carModelID = self.carModelID;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 资料不完善，前去完善
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

// 提醒教练开课
- (IBAction)remindCoachClick:(id)sender {
    [self requestRemindCoach];
}

// 选择不需要教练车
- (IBAction)noCarNeedClick:(UIButton *)sender {
    if (sender.selected) return;
    self.noNeedBtn.selected = YES;
    self.needBtn.selected = NO;
    self.needCar = NO;
}

// 选择需要教练车
- (IBAction)needCarClick:(UIButton *)sender {
    if (sender.selected) return;
    self.needBtn.selected = YES;
    self.noNeedBtn.selected = NO;
    self.needCar = YES;
}

// 确定是否需要教练车
- (IBAction)ifNeedCarSureClick:(id)sender {
    [self.ifNeedCarMaskView removeFromSuperview];
    
    SureOrderViewController *viewController = [[SureOrderViewController alloc] initWithNibName:@"SureOrderViewController" bundle:nil];
    viewController.dateTimeSelectedList = self.dateTimeSelectedList;
    viewController.coachId = self.coachId;
    if (self.needCar) {
        int originSum = (int)_priceSum;
        int totalSum = originSum + self.rentalFeePerHour * (int)self.dateTimeSelectedList.count;
        viewController.priceSum = [NSString  stringWithFormat:@"%d", totalSum];
    } else {
        viewController.priceSum = [NSString  stringWithFormat:@"%d", (int)_priceSum];
    }
    viewController.carModelID = self.carModelID;
    viewController.needCar = self.needCar;
    viewController.rentalFeePerHour = self.rentalFeePerHour;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)closeIfNeedCarViewClick:(id)sender {
    [self.ifNeedCarMaskView removeFromSuperview];
}
@end
