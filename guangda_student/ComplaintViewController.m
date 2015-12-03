//
//  ComplaintViewController.m
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ComplaintViewController.h"
#import "ComplaintTableViewCell.h"
#import "MyOrderComplainViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "LoginViewController.h"

@interface ComplaintViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
{
    BOOL _isCoach;
    NSString *_pageNum;
}

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topLineHeight;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIView *noDataView;
@property (strong, nonatomic) NSMutableArray *complainListArray;

@end

@implementation ComplaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
    _complainListArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFreshData];
}

#pragma mark - 页面设置
- (void)settingView {
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    //加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    self.mainTableView.allowsSelection = NO;
}

#pragma mark - 页面特性
// 添加内容textView
- (void)addContentTextView {
    
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _complainListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // 取得数据
    NSDictionary *dict = _complainListArray[indexPath.row];
    NSArray *complainContentArray = dict[@"contentlist"]; // 投诉内容
    int state = 1;
    for (NSDictionary *dict in complainContentArray) { // 只要有一条投诉未解决就算未解决
        state *= [dict[@"state"] integerValue];
    }
    
    CGFloat topViewHeight = 0;
    if (state == 0) {
        topViewHeight = 110;
    } else {
        topViewHeight = 70;
    }
    
    CGFloat y = 0;
    for (int i = 0; i < complainContentArray.count; i++) {
        NSString *complainReason = complainContentArray[i][@"reason"];
        NSString *complainStr = complainContentArray[i][@"content"];
        NSString *text = [NSString stringWithFormat:@"#%@#%@", complainReason, complainStr];
        CGFloat textHeight = [CommonUtil sizeWithString:text fontSize:15 sizewidth:_screenWidth - 20 sizeheight:MAXFLOAT].height;
        
        y += (textHeight + 15);
    }
    if (indexPath.row == 0) {
        NSLog(@"y === %f", y);
    }
    y -= 15;

    return 261 - 110 + topViewHeight - 80 + y;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"ComplaintTableViewCell";
    ComplaintTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"ComplaintTableViewCell" bundle:nil] forCellReuseIdentifier:indentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    }
    
    cell.coachPortraitImageView.layer.cornerRadius = 18.0;
    cell.coachPortraitImageView.layer.masksToBounds = YES;
    // 取得数据
    NSDictionary *dict = _complainListArray[indexPath.row];
    [cell loadData:dict];

    /* 按钮点击事件 */
    // 追加投诉
    [cell.btnAddOutlet removeTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnAddOutlet addTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnAddOutlet.tag = 100 + indexPath.row;
    
    // 取消投诉
    [cell.btnCancelOutlet removeTarget:self action:@selector(clickForCancelComplaint:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnCancelOutlet addTarget:self action:@selector(clickForCancelComplaint:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnCancelOutlet.tag = 200 + indexPath.row;
    
    return cell;
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
    [self getFreshData];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    [self getMoreData];
}

- (void)getFreshData {
    _pageNum = @"0";
    [self postGetMyComplaint];
}

- (void)getMoreData {
    _pageNum = [NSString stringWithFormat:@"%d", (int)_complainListArray.count / 10];
    [self postGetMoreComplaint];
}

#pragma mark - 网络请求
// test
- (void)printDic:(NSDictionary *)responseObject withTitle:(NSString *)title {
}

// 我的投诉列表
- (void)postGetMyComplaint {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:_pageNum forKey:@"pagenum"];
    
    NSString *uri = @"/sorder?action=GetMyComplaint";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self printDic:responseObject withTitle:@"我的投诉-fresh"];
            
            [_complainListArray removeAllObjects];
            NSArray *array = [responseObject objectForKey:@"complaintlist"];
            [_complainListArray addObjectsFromArray:array];
            
            if (_complainListArray.count) {
                self.noDataView.hidden = YES;
            } else {
                self.noDataView.hidden = NO;
            }
            
            // 是否还有更多
            if ([responseObject[@"hasmore"] intValue] == 0) {
                [_pullToMore setPullToMoreViewVisible:NO];
            } else {
                [_pullToMore setPullToMoreViewVisible:YES];
                [_pullToMore relocatePullToMoreView];
            }
            
            [self.mainTableView reloadData];

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
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
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

// 更多投诉
- (void)postGetMoreComplaint {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:_pageNum forKey:@"pagenum"];
    
    NSString *uri = @"/sorder?action=GetMyComplaint";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        int code = [responseObject[@"code"] intValue];
        
        if (code == 1) {
            [self printDic:responseObject withTitle:@"我的投诉-more"];
            NSArray *array = [responseObject objectForKey:@"complaintlist"];
            [_complainListArray addObjectsFromArray:array];
            
            // 是否还有更多
            if ([responseObject[@"hasmore"] intValue] == 0) {
                [_pullToMore setPullToMoreViewVisible:NO];
            } else {
                [_pullToMore setPullToMoreViewVisible:YES];
                [_pullToMore relocatePullToMoreView];
            }
            
            [self.mainTableView reloadData];
            
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
        [_pullToMore tableViewReloadFinished];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_pullToMore tableViewReloadFinished];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
}

// 取消投诉
- (void)postCancelComplaint:(NSString *)orderId {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:orderId forKey:@"orderid"];
    
    NSString *uri = @"/sorder?action=CancelComplaint";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"取消投诉成功"];
            [self getFreshData];
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

#pragma mark - 点击事件
// 投诉
- (void)clickToComplain:(UIButton *)sender {
    NSInteger row = sender.tag - 100;
    NSDictionary *comDict = _complainListArray[row];
    NSDictionary *orderDic = comDict[@"contentlist"][0];
    NSString *orderId = orderDic[@"order_id"];
    
    MyOrderComplainViewController *targetController = [[MyOrderComplainViewController alloc] initWithNibName:@"MyOrderComplainViewController" bundle:nil];
    targetController.orderid = orderId;
    [self.navigationController pushViewController:targetController animated:YES];
}

// 取消投诉
- (void)clickForCancelComplaint:(UIButton *)sender {
    NSInteger row = sender.tag - 200;
    NSDictionary *comDict = _complainListArray[row];
    NSDictionary *orderDic = comDict[@"contentlist"][0];
    NSString *orderId = orderDic[@"order_id"];
    
    [self postCancelComplaint:orderId];
}

@end
