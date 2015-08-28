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
#import "TQStarRatingView.h"
#import "UserBaseInfoViewController.h"
#import "AppDelegate.h"

#define _screenWidth [UIScreen mainScreen].bounds.size.width
#define _screenHeight [UIScreen mainScreen].bounds.size.height

@interface CoachListViewController ()
<UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient,UIAlertViewDelegate>
{
    int _oldRow;
    
    NSInteger _searchPage;   // 检索页
}
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) NSMutableArray *coachList;    // 教练列表
@property (strong, nonatomic) IBOutlet UILabel *coachRealName;
@property (strong, nonatomic) IBOutlet UILabel *coachDetails;
@property (strong, nonatomic) TQStarRatingView *starView;

@property (strong, nonatomic) NSDictionary *coachInfoDic;       // 教练资料

- (IBAction)clickForGoMap:(id)sender;
- (IBAction)clickForGoSearch:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *allButton;
- (IBAction)clickForAllData:(id)sender;


@end

@implementation CoachListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _oldRow = 12138;
    
    self.coachList = [NSMutableArray array];
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.tableView withClient:self];
    
    //加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.tableView withClient:self];
    
    [self pullToRefreshTriggered:self.pullToRefresh];
    [_pullToMore setPullToMoreViewVisible:NO];
    
    //     教练信息 星级View
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 15, 87, 15)];
    [self.chooseCoachTimeView addSubview:_starView];
    
    // 筛选界面的观察者信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSearchCoachDict:) name:@"SearchCoachDict" object:nil];

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.chooseCoachTimeView.superview) {
        [self closeDetailsView];
    }
}

#pragma mark - actions
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
        cell.userLogo.layer.cornerRadius = cell.userLogo.bounds.size.width / 2;
        cell.userLogo.layer.masksToBounds = YES;
    }
    
    NSDictionary *coachDic = self.coachList[indexPath.row];
    NSString *logoUrl = coachDic[@"avatarurl"];
    cell.userLogo.layer.cornerRadius = cell.userLogo.bounds.size.width/2;
    cell.userLogo.layer.masksToBounds = YES;
    [cell.userLogo sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    
    NSString *sumnum = [coachDic[@"sumnum"] description];
    NSString *sumnumStr = [NSString stringWithFormat:@"总单数:%@",sumnum];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:sumnumStr];
    [string addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(4,sumnum.length)];
    cell.orderCount.attributedText = string;
    
    cell.userName.text = coachDic[@"realname"];
//    NSString *coachInfoStr = nil;
    NSString *detail = coachDic[@"detail"];
    NSString *schoolName = coachDic[@"drive_school"];
    if ([CommonUtil isEmpty:schoolName]) {
        cell.driveSchoolLabel.text = @"";
    } else {
        cell.driveSchoolLabel.text = schoolName;
    }
    cell.contentDetailLabel.text = detail;
    
    [cell.starView changeStarForegroundViewWithScore:[[coachDic[@"score"] description] floatValue]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    // 教练是否开课
    int courseState = [coachDic[@"coursestate"] intValue];
    if (courseState == 0) { // 未开课
        cell.contentView.alpha = 0.5;
    } else {
        cell.contentView.alpha = 1.0;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_oldRow == indexPath.row && self.chooseCoachTimeView.superview) {
        [self closeDetailsView];
        _oldRow = 12138;
    }else{
        NSDictionary *coachInfoDict = self.coachList[indexPath.row];
        NSString *avatarStr = [coachInfoDict[@"avatarurl"] description];
        NSString *coachName = coachInfoDict[@"realname"];
        NSString *coachdetail = coachInfoDict[@"detail"];
        NSString *scoreStr = coachInfoDict[@"score"];
        CGFloat score = [scoreStr floatValue];
        int gender = [coachInfoDict[@"gender"] intValue];
        NSString *genderStr = nil;
        if (gender == 1) {
            genderStr = @"男";
        }else if (gender == 2)
        {
            genderStr = @"女";
        }else{
            genderStr = @"未设置";
        }
        
        self.coachId = [coachInfoDict[@"coachid"] description];
        self.userLogo.layer.cornerRadius = self.userLogo.bounds.size.width/2;
        self.userLogo.layer.masksToBounds = YES;
        [self.userLogo sd_setImageWithURL:[NSURL URLWithString:avatarStr] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
        self.coachRealName.text = [NSString stringWithFormat:@"%@(%@)", coachName, genderStr];
//        self.coachRealName.text = coachName;
        self.coachDetails.text = coachdetail;
        [self.starView changeStarForegroundViewWithScore:score];
        
        [self carBtnClick];
        _oldRow = (int)indexPath.row;
        
        self.coachInfoDic = self.coachList[indexPath.row];
    }
}

#pragma mark - actions
- (IBAction)coachDetailsClick:(id)sender
{
    CoachDetailViewController *nextController = [[CoachDetailViewController alloc] initWithNibName:@"CoachDetailViewController" bundle:nil];
        nextController.coachId = self.coachId;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)appointCoachClick:(id)sender
{
    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
    nextController.coachId = self.coachId;
    nextController.coachInfoDic = self.coachInfoDic;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

#pragma mark 小汽车 button 点击事件
- (void)carBtnClick
{
    // 添加底部的教练信息栏
    self.chooseCoachTimeView.frame = CGRectMake(0, _screenHeight, _screenWidth, 122);
    [self.view addSubview:self.chooseCoachTimeView];
    
    [UIView animateWithDuration:0.5 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.chooseCoachTimeView.frame=CGRectMake(0, _screenHeight - 122, _screenWidth, 122);
                         
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         //............
                     }];
    
}

- (void)closeDetailsView
{
    //    for (id objc in self.view.subviews) {
    //        if ([objc isEqual:self.chooseCoachTimeView]) {
    
    self.chooseCoachTimeView.frame=CGRectMake(0, _screenHeight - 122, _screenWidth, _screenHeight);
    [UIView animateWithDuration:0.5 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.chooseCoachTimeView.frame=CGRectMake(0, _screenHeight, _screenWidth, 292);
                         
                         
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         [self.chooseCoachTimeView removeFromSuperview];
                     }];
    //        }
    //    }
//    [self removeCoachHeadControl];
//    [[SliderViewController sharedSliderController] closeSideBar];
}

// 移除教练头像control
- (void)removeCoachHeadControl
{
    for (id objc in self.view.subviews)
    {
        if ([objc isKindOfClass:[UIControl class]])
        {
            UIControl *contro = (UIControl *)objc;
            
            // tag = 1 为教练头像control
            if (contro.tag == 1)
            {
                [contro removeFromSuperview];
            }
        }
    }
}

#pragma mark 展开选择教练时间段详情页
- (void)showCoachTimeClick:(id)sender
{
    self.chooseCoachTimeView.frame = CGRectMake(0, _screenHeight-171, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:self.chooseCoachTimeView];
    
    [UIView animateWithDuration:0.5 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.chooseCoachTimeView.frame=CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                         
                     } completion:^(BOOL finish){
                     }];

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
    NSString *cityID = [USERDICT[@"cityid"] description];
    if (![CommonUtil isEmpty:cityID]) {
        paramDic[@"cityid"] = cityID;
    }
    
    // 测试账号studentID
    AppDelegate *deleget = [UIApplication sharedApplication].delegate;
    if (![CommonUtil isEmpty:deleget.userid]) {
        if ([deleget.userid isEqualToString:@"18"]) {
            paramDic[@"studentid"] = deleget.userid;
        }
    }
    
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [paramDic setObject:app_Version forKey:@"version"];
    
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
        NSLog(@"GetNearByCoach == %@", ERR_NETWORK);
        [self makeToast:ERR_NETWORK];
    }];
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
}

#pragma mark - 废弃
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



@end
