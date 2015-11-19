//
//  CoachListViewController.m
//  guangda_student
//
//  Created by Dino on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachListViewController.h"
#import "CoachListTableViewCell.h"
#import "MyOrderDetailViewController.h"
#import "CoachScreenViewController.h"
#import "AppointCoachViewController.h"
#import "CoachDetailViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "UIImageView+WebCache.h"
#import "UserBaseInfoViewController.h"
#import "CoachInfoView.h"
#import "AppDelegate.h"

@interface CoachListViewController ()
<UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient, UIAlertViewDelegate, CoachInfoViewDelegate>
{
    int _oldRow;
    
    NSInteger _searchPage;   // 检索页
}

@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

// 教练信息
@property (strong, nonatomic) CoachInfoView *coachInfoView;
@property (strong, nonatomic) UIButton *closeDetailBtn;     // 关闭底部教练信息view
@property (strong, nonatomic) NSMutableArray *coachList;    // 教练列表
@property (strong, nonatomic) NSDictionary *coachInfoDic;
@property (strong, nonatomic) NSString *coachId;

@property (copy, nonatomic) NSString *carModelID;           // 车型

- (IBAction)clickForGoMap:(id)sender;
- (IBAction)clickForGoSearch:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *screenBtn;

@property (strong, nonatomic) IBOutlet UIButton *allButton;
- (IBAction)clickForAllData:(id)sender;


@end

@implementation CoachListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _oldRow = 12138;
    
    // 车型
    self.carModelID = [MainViewController readCarModelID];
    
    self.coachList = [NSMutableArray array];
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.tableView withClient:self];
    
    //加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.tableView withClient:self];
    
    [self pullToRefreshTriggered:self.pullToRefresh];
    [_pullToMore setPullToMoreViewVisible:NO];
    
    // 教练信息
    self.coachInfoView = [[CoachInfoView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)]; // 高度据内容而定
    self.coachInfoView.delegate = self;
    
    // 关闭底部教练信息的按钮
    self.closeDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeDetailBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 80);
    self.closeDetailBtn.backgroundColor = [UIColor blackColor];
    self.closeDetailBtn.alpha = 0;
    [self.closeDetailBtn addTarget:self action:@selector(closeCoachInfoView) forControlEvents:UIControlEventTouchUpInside];
    
    // 筛选界面的观察者信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSearchCoachDict:) name:@"SearchCoachDict" object:nil];

    // 导航栏
    if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
        self.titleLabel.text = @"陪驾列表";
        self.screenBtn.hidden = YES;
        self.allButton.hidden = YES;
    } else {
        self.titleLabel.text = @"教练列表";
        if(self.searchParamDic){
            NSString *condition3 = self.searchParamDic[@"condition3"];
            NSString *condition6 = self.searchParamDic[@"condition6"];
            if([CommonUtil isEmpty:condition3] && [CommonUtil isEmpty:condition6]){
                self.allButton.hidden = YES;
            }else{
                self.allButton.hidden = NO;
            }
        }else{
            self.allButton.hidden = YES;
        }
    }
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - UIPicker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    myView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    label.text = @"dadas";
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [myView addSubview:label];
    
    return myView;
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coachList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellident = @"coachListCell";
    CoachListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellident];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"CoachListTableViewCell" bundle:nil] forCellReuseIdentifier:cellident];
        cell = [tableView dequeueReusableCellWithIdentifier:cellident];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.carModelID = self.carModelID;
    NSDictionary *coachDic = self.coachList[indexPath.row];
    [cell loadData:coachDic];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (_oldRow == indexPath.row && self.coachInfoView.superview) {
//        [self closeCoachInfoView];
//        _oldRow = 12138;
//    }else{
//        _oldRow = (int)indexPath.row;
        self.coachInfoDic = self.coachList[indexPath.row];
        [self.coachInfoView loadData:self.coachInfoDic withCarModelID:self.carModelID];
        [self coachInfoViewShow];
//    }
}

#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
    
    [_pullToMore relocatePullToMoreView];    // 重置加载更多控件位置
    [_pullToMore tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefresh tableViewReleased];
    [_pullToMore tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    _searchPage = 0;
    [self requestGetCoachList];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    _searchPage = _searchPage + 1;
    [self requestGetCoachList];
}

#pragma mark - CoachInfoViewDelegate
- (void)coachDetailShow:(NSString *)coachID
{
    CoachDetailViewController *nextController = [[CoachDetailViewController alloc] initWithNibName:@"CoachDetailViewController" bundle:nil];
    nextController.coachId = coachID;
    nextController.carModelID = self.carModelID;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)appointCoach:(NSDictionary *)coachInfoDict
{
    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
    nextController.coachInfoDic = coachInfoDict;
    NSString *coachID = [coachInfoDict[@"coachid"] description];
    nextController.coachId = coachID;
    nextController.carModelID = self.carModelID;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Custom
- (void)coachInfoViewShow
{
    // 添加底部的教练信息栏
    [self.view addSubview:self.closeDetailBtn];
    [self.view addSubview:self.coachInfoView];
    [UIView animateWithDuration:0.35 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         //动画设置区域
                         self.coachInfoView.bottom = SCREEN_HEIGHT;
                         self.closeDetailBtn.alpha = 0.5;
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         //............
                     }];
    
}

- (void)closeCoachInfoView
{
    [UIView animateWithDuration:0.35 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         //动画设置区域
                         self.coachInfoView.top = SCREEN_HEIGHT;
                         self.closeDetailBtn.alpha = 0;
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         [self.coachInfoView removeFromSuperview];
                         [self.closeDetailBtn removeFromSuperview];
                     }];
}

// 添加筛选页面传递过来的条件
- (void)setSearchCoachDict:(id)dictionary
{
    
    if (dictionary == nil) {
        self.allButton.hidden = YES;
        return;
    }
    
    if ([dictionary isKindOfClass:[NSNotification class]])
    {
        NSNotification *notification = (NSNotification *)dictionary;
        if ([CommonUtil isEmpty:notification.object])
        {
            self.allButton.hidden = YES;
            self.searchParamDic = nil;
            return;
        }
        self.searchParamDic = [NSMutableDictionary dictionaryWithDictionary:notification.object];
    } else {
        self.searchParamDic = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    
    NSString *condition3 = self.searchParamDic[@"condition3"];
    NSString *condition6 = self.searchParamDic[@"condition6"];
    if([CommonUtil isEmpty:condition3] && [CommonUtil isEmpty:condition6]){
        self.allButton.hidden = YES;
    }else{
        self.allButton.hidden = NO;
    }
    
    [self pullToRefreshTriggered:self.pullToRefresh];
    
}


#pragma mark - 接口请求
- (void)requestGetCoachList
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic = [self.searchParamDic mutableCopy];
    if (!paramDic) {
        paramDic = [NSMutableDictionary dictionary];
    }
    
    [paramDic setObject:[NSString stringWithFormat:@"%ld", (long)_searchPage] forKey:@"pagenum"];
    
    // 城市id
//    NSString *cityID = [USERDICT[@"cityid"] description];
//    if (![CommonUtil isEmpty:cityID]) {
//        paramDic[@"cityid"] = cityID;
//    }
    
    // 定位城市名
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//    NSString *locateCityName = delegate.locationResult.addressDetail.city;
//    locateCityName = [locateCityName stringByReplacingOccurrencesOfString:@"市" withString:@""]; // 去掉城市名里的“市”
//    if (![CommonUtil isEmpty:locateCityName]) {
//        paramDic[@"fixedposition"] = locateCityName;
//    }
    
    // 经纬度
    if (![CommonUtil isEmpty:delegate.pointCenter]) {
        paramDic[@"pointcenter"] = delegate.pointCenter;
    }
    
    // 测试账号studentID
    AppDelegate *deleget = [UIApplication sharedApplication].delegate;
    if (![CommonUtil isEmpty:deleget.userid]) {
        paramDic[@"studentid"] = deleget.userid;
    }
    
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [paramDic setObject:app_Version forKey:@"version"];
    
    // 车型ID
    if (![CommonUtil isEmpty:self.carModelID]) {
        [paramDic setObject:self.carModelID forKey:@"condition11"];
    }
    
    NSString *uri = @"/sbook?action=GetCoachList";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20;     // 网络超时时长设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            // 是否还有更多
            if ([responseObject[@"hasmore"] intValue] == 0) {
                [_pullToMore setPullToMoreViewVisible:NO];
            } else {
                [_pullToMore setPullToMoreViewVisible:YES];
                [_pullToMore relocatePullToMoreView];
            }
            
            if (_searchPage == 0) {
                [self.coachList removeAllObjects];
                self.coachList = [responseObject[@"coachlist"] mutableCopy];
                if (self.coachList.count == 0) {
                    self.emptyView.hidden = NO;
                } else {
                    self.emptyView.hidden = YES;
                }
            }else{
                NSArray *array = responseObject[@"coachlist"];
                [self.coachList addObjectsFromArray:array];
            }
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.coachList];
//            for (int i= 0; i<self.coachList.count; i++) {
//                NSDictionary *coachDic =self.coachList[i];
//                NSString *string = coachDic[@"phone"];
//                if ([string isEqualToString:@"18888888888"]) {
//                    [array removeObjectAtIndex:i];
//                }
//            }
            NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
            if (user_info) {
                if ([[user_info[@"phone"] description] isEqualToString:@"18888888888"]) {
                    
                }else{
                    self.coachList = array;
                }
            }else{
                self.coachList = array;
            }
//            self.coachList = array;     //屏蔽特殊教练       
            
            [self.tableView reloadData];
            
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        [_pullToMore tableViewReloadFinished];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        [_pullToMore tableViewReloadFinished];
        [self makeToast:ERR_NETWORK];
    }];
}

#pragma mark - Actions
- (IBAction)clickForGoMap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickForGoSearch:(id)sender {
    CoachScreenViewController *nextController = [[CoachScreenViewController alloc] initWithNibName:@"CoachScreenViewController" bundle:nil];
    nextController.searchDic = self.searchParamDic;
    nextController.comeFrom = @"2";
    [self presentViewController:nextController animated:YES completion:nil];
    
}

- (IBAction)clickForAllData:(id)sender {
    self.searchParamDic = nil;
    self.allButton.hidden = YES;
    [self pullToRefreshTriggered:self.pullToRefresh];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetCoachDict" object:nil];
}

#pragma mark - 废弃
//@property (strong, nonatomic) IBOutlet UIImageView *userLogo;           // 用户头像

// 动画显示效果
//- (void)animationOfBlock
//{
//    self.coachDetailsView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//
//    [UIView animateWithDuration:1 //时长
//                          delay:0 //延迟时间
//                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
//                     animations:^{
//
//                         //动画设置区域
//                         self.coachDetailsView.frame=CGRectMake(50, 50,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//
//                     } completion:^(BOOL finish){
//                         //动画结束时调用
//                         //............
//                     }];
//
//}

//#pragma mark 展开选择教练时间段详情页
//- (void)showCoachTimeClick:(id)sender
//{
//    self.coachInfoView.frame = CGRectMake(0, SCREEN_HEIGHT-171, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//    [self.view addSubview:self.coachInfoView];
//
//    [UIView animateWithDuration:0.5 //时长
//                          delay:0 //延迟时间
//                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
//                     animations:^{
//
//                         //动画设置区域
//                         self.coachInfoView.frame=CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//
//                     } completion:^(BOOL finish){
//                     }];
//
//}

// 移除教练头像control
//- (void)removeCoachHeadControl
//{
//    for (id objc in self.view.subviews)
//    {
//        if ([objc isKindOfClass:[UIControl class]])
//        {
//            UIControl *contro = (UIControl *)objc;
//
//            // tag = 1 为教练头像control
//            if (contro.tag == 1)
//            {
//                [contro removeFromSuperview];
//            }
//        }
//    }
//}

//- (IBAction)coachDetailsClick:(id)sender
//{
//    CoachDetailViewController *nextController = [[CoachDetailViewController alloc] initWithNibName:@"CoachDetailViewController" bundle:nil];
//    nextController.coachId = self.coachId;
//    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
//    navigationController.navigationBarHidden = YES;
//    [self presentViewController:navigationController animated:YES completion:nil];
//}
//
//- (IBAction)appointCoachClick:(id)sender
//{
//    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
//    nextController.coachId = self.coachId;
//    nextController.coachInfoDic = self.coachInfoDic;
//    nextController.carModelID = self.carModelID;
//    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
//    navigationController.navigationBarHidden = YES;
//    [self presentViewController:navigationController animated:YES completion:nil];
//    
//}

@end
