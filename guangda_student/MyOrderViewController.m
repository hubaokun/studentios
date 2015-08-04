//
//  MyOrderViewController.m
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyOrderViewController.h"
#import "MyOrderDetailViewController.h"
#import "MyOrderEvaluationViewController.h"
#import "MyOrderComplainViewController.h"
#import "UnfinishedOrderTableViewCell.h"
#import "WaitEvaluationOrderTableViewCell.h"
#import "HistoricOrderTableViewCell.h"
#import "GuangdaOrder.h"
#import "AppDelegate.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import <BaiduMapAPI/BMapKit.h>
#import "DSButton.h"
#import "AppointCoachViewController.h"
#import "LoginViewController.h"

@interface MyOrderViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKGeneralDelegate, UIAlertViewDelegate> {
    CGFloat _rowHeight;
    NSString *_pageNum;
    BMKLocationService *_locService;
}
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) IBOutlet UIView *selectBarView;
@property (strong, nonatomic) IBOutlet UIButton *unfinishedBtn;
@property (strong, nonatomic) IBOutlet UIButton *waiEvaluateBtn;
@property (strong, nonatomic) IBOutlet UIButton *historyBtn;
@property (assign, nonatomic) int orderType; // 0:未完成订单 1:待评价订单 2:历史订单
@property (strong, nonatomic) NSMutableArray *orderListArray;

//用户定位
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (strong, nonatomic) NSString *cityName;//城市
@property (strong, nonatomic) NSString *address;//地址

- (IBAction)clickForUnfinishedOrder:(id)sender;
- (IBAction)clickForWaitEvaluateOrder:(id)sender;
- (IBAction)clickForHistoricOrder:(id)sender;

@end

@implementation MyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _orderType = unCompleteOrder;
    _orderListArray = [NSMutableArray array];
    _rowHeight = 250;
    [self settingView];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    //加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self getFreshData];
}

- (void)settingView {
    
    // 设置边框
    self.selectBarView.layer.cornerRadius = 4;
    self.selectBarView.layer.borderWidth = 0.6;
    self.selectBarView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.waiEvaluateBtn.layer.borderWidth = 0.6;
    self.waiEvaluateBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [self.unfinishedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.unfinishedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.historyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.historyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.waiEvaluateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.waiEvaluateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self oneButtonSellected:self.unfinishedBtn];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orderListArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 未完成订单
    if (_orderType == unCompleteOrder) {
        static NSString *ID = @"UnfinishedOrderTableViewCellIdentifier";
        UnfinishedOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"UnfinishedOrderTableViewCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // 取得数据
        NSDictionary *orderDic = _orderListArray[indexPath.row];
        
        // 加载数据
        GuangdaOrder *unfinishedOrder = [GuangdaOrder orderWithDict:orderDic];
        cell.unfinishedOrder = unfinishedOrder;
        [cell loadData:nil];
        
        // 按钮点击事件
        [cell.complainBtn removeTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
        [cell.complainBtn addTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
        cell.complainBtn.tag = 100 + indexPath.row;
        
        [cell.cancelComplainBtn removeTarget:self action:@selector(clickForCancelComplaint:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cancelComplainBtn addTarget:self action:@selector(clickForCancelComplaint:) forControlEvents:UIControlEventTouchUpInside];
        cell.cancelComplainBtn.tag = 200 + indexPath.row;
        
        [cell.cancelOrderBtn removeTarget:self action:@selector(clickForCancelOrder:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cancelOrderBtn addTarget:self action:@selector(clickForCancelOrder:) forControlEvents:UIControlEventTouchUpInside];
        cell.cancelOrderBtn.tag = 300 + indexPath.row;
        

        [cell.confirmOnBtn removeTarget:self action:@selector(clickForConfirmOn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.confirmOnBtn addTarget:self action:@selector(clickForConfirmOn:) forControlEvents:UIControlEventTouchUpInside];
        cell.confirmOnBtn.tag = 400 + indexPath.row;
        
        [cell.confirmDownBtn removeTarget:self action:@selector(clickForConfirmDown:) forControlEvents:UIControlEventTouchUpInside];
        [cell.confirmDownBtn addTarget:self action:@selector(clickForConfirmDown:) forControlEvents:UIControlEventTouchUpInside];
        cell.confirmDownBtn.tag = 500 + indexPath.row;
        
        [cell.evaluateBtn removeTarget:self action:@selector(clickToMyOrderEvaluation:) forControlEvents:UIControlEventTouchUpInside];
        [cell.evaluateBtn addTarget:self action:@selector(clickToMyOrderEvaluation:) forControlEvents:UIControlEventTouchUpInside];
        cell.evaluateBtn.tag = 600 + indexPath.row;
        
        [cell.continueAppointBtn removeTarget:self action:@selector(appointCoachClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.continueAppointBtn addTarget:self action:@selector(appointCoachClick:) forControlEvents:UIControlEventTouchUpInside];
        NSMutableDictionary *dict = [orderDic[@"cuserinfo"] mutableCopy];
        NSString *detail = [orderDic[@"detail"] description];
        [dict setObject:detail forKey:@"detail"];
        cell.continueAppointBtn.data = dict;
        
        return cell;
    }
    
    // 待评价订单
    else if (_orderType == waitEvaluationOrder) {
        static NSString *ID = @"WaitEvaluationOrderTableViewCellIdentifier";
        WaitEvaluationOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"WaitEvaluationOrderTableViewCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // 取得数据
        NSDictionary *orderDic = _orderListArray[indexPath.row];
        
        // 加载数据
        GuangdaOrder *waitEvaluationOrder = [GuangdaOrder orderWithDict:orderDic];
        cell.waitEvaluationOrder = waitEvaluationOrder;
        [cell loadData:nil];
        
        // 按钮点击事件
        [cell.complainBtn removeTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
        [cell.complainBtn addTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
        cell.complainBtn.tag = 100 + indexPath.row;
        
        [cell.evaluateBtn removeTarget:self action:@selector(clickToMyOrderEvaluation:) forControlEvents:UIControlEventTouchUpInside];
        [cell.evaluateBtn addTarget:self action:@selector(clickToMyOrderEvaluation:) forControlEvents:UIControlEventTouchUpInside];
        cell.evaluateBtn.tag = 600 + indexPath.row;
        
        [cell.continueAppointBtn removeTarget:self action:@selector(appointCoachClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.continueAppointBtn addTarget:self action:@selector(appointCoachClick:) forControlEvents:UIControlEventTouchUpInside];
        NSMutableDictionary *dict = [orderDic[@"cuserinfo"] mutableCopy];
        NSString *detail = [orderDic[@"detail"] description];
        [dict setObject:detail forKey:@"detail"];
        cell.continueAppointBtn.data = dict;

        return cell;
    }
    
    // 已完成订单
    else {
        static NSString *ID = @"HistoricOrderTableViewCellIdentifier";
        HistoricOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (nil == cell) {
            [tableView registerNib:[UINib nibWithNibName:@"HistoricOrderTableViewCell" bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.complainBtn addTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        // 取得数据
        NSDictionary *orderDic = _orderListArray[indexPath.row];
        
        // 加载数据
        GuangdaOrder *historicOrder = [GuangdaOrder orderWithDict:orderDic];
        cell.historicOrder = historicOrder;
        [cell loadData:nil];
        
        // 按钮点击事件
        [cell.complainBtn removeTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
        [cell.complainBtn addTarget:self action:@selector(clickToComplain:) forControlEvents:UIControlEventTouchUpInside];
        cell.complainBtn.tag = 100 + indexPath.row;
        
        [cell.cancelComplainBtn removeTarget:self action:@selector(clickForCancelComplaint:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cancelComplainBtn addTarget:self action:@selector(clickForCancelComplaint:) forControlEvents:UIControlEventTouchUpInside];
        cell.cancelComplainBtn.tag = 200 + indexPath.row;
        
        [cell.evaluateBtn removeTarget:self action:@selector(clickToMyOrderEvaluation:) forControlEvents:UIControlEventTouchUpInside];
        [cell.evaluateBtn addTarget:self action:@selector(clickToMyOrderEvaluation:) forControlEvents:UIControlEventTouchUpInside];
        cell.evaluateBtn.tag = 600 + indexPath.row;
        
        [cell.continueAppointBtn removeTarget:self action:@selector(appointCoachClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.continueAppointBtn addTarget:self action:@selector(appointCoachClick:) forControlEvents:UIControlEventTouchUpInside];
        NSMutableDictionary *dict = [orderDic[@"cuserinfo"] mutableCopy];
        NSString *detail = [orderDic[@"detail"] description];
        [dict setObject:detail forKey:@"detail"];
        cell.continueAppointBtn.data = dict;

        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取得订单id
    NSDictionary *orderDic = _orderListArray[indexPath.row];
    NSString *orderid = [NSString stringWithFormat:@"%d", [orderDic[@"orderid"] intValue]];
    
    MyOrderDetailViewController *targetController = [[MyOrderDetailViewController alloc] initWithNibName:@"MyOrderDetailViewController" bundle:nil];
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    targetController.orderid = orderid;
    if (self.orderType == unCompleteOrder) {
        targetController.orderType = 1;
    } else if (self.orderType == waitEvaluationOrder) {
        targetController.orderType = 2;
    } else if (self.orderType == completeOrder) {
        targetController.orderType = 3;
    }
    [self.navigationController pushViewController:targetController animated:YES];
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
    [self postGetOrder];
}

- (void)getMoreData {
    _pageNum = [NSString stringWithFormat:@"%d", [_pageNum intValue] + 1];
    [self postGetMoreOrder];
}

- (void)pageNumMinus {
    _pageNum = [NSString stringWithFormat:@"%d", [_pageNum intValue] - 1];
}

#pragma mark - 页面特性
// 判断是否有数据
- (void)ifNoData {
    if (_orderListArray.count == 0) {
        self.mainTableView.hidden = YES;
        self.bgImageView.hidden = NO;
    }
    else {
        self.mainTableView.hidden = NO;
        self.bgImageView.hidden = YES;
    }
}

// 设置按钮状态
- (void)oneButtonSellected:(UIButton *)button {
    self.unfinishedBtn.backgroundColor = [UIColor clearColor];
    self.waiEvaluateBtn.backgroundColor = [UIColor clearColor];
    self.historyBtn.backgroundColor = [UIColor clearColor];
    self.unfinishedBtn.selected = NO;
    self.waiEvaluateBtn.selected = NO;
    self.historyBtn.selected = NO;
    
    button.backgroundColor = [UIColor blackColor];
    button.selected = YES;
}

#pragma mark - 网络请求
// test
- (void)printDic:(NSDictionary *)responseObject withTitle:(NSString *)title {
//    NSLog(@"**************%@**************", title);
//    NSLog(@"response ===== %@", responseObject);
//    NSLog(@"code = %@",  responseObject[@"code"]);
//    NSLog(@"message = %@", responseObject[@"message"]);
}

// 请求订单列表
- (void)postGetOrder {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:_pageNum forKey:@"pagenum"];
    
    NSString *uri = nil;
    
    // 未完成订单列表
    if (_orderType == unCompleteOrder) {
        uri = @"/sorder?action=GetUnCompleteOrder";
    }
    
    // 待评价订单列表
    else if (_orderType == waitEvaluationOrder) {
        uri = @"/sorder?action=GetWaitEvaluationOrder";
    }
    
    // 已完成订单列表
    else if (_orderType == completeOrder) {
        uri = @"/sorder?action=GetCompleteOrder";
    }
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            
            if (_orderType == unCompleteOrder) {
                if (self.unfinishedBtn.selected == NO) {
                    [self oneButtonSellected:self.unfinishedBtn];
                }
            }
            else if (_orderType == waitEvaluationOrder) {
                if (self.waiEvaluateBtn.selected == NO) {
                    [self oneButtonSellected:self.waiEvaluateBtn];
                }
            }
            else if (_orderType == completeOrder) {
                if (self.historyBtn.selected == NO) {
                    [self oneButtonSellected:self.historyBtn];
                }
            }
            
            [_orderListArray removeAllObjects];
            NSArray *array = [responseObject objectForKey:@"orderlist"];
            [_orderListArray addObjectsFromArray:array];
            
            
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
        [self ifNoData];
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        [DejalBezelActivityView removeViewAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
        [self ifNoData];
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        [DejalBezelActivityView removeViewAnimated:YES];
    }];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

// 请求更多订单
- (void)postGetMoreOrder {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:_pageNum forKey:@"pagenum"];
    
    NSString *uri = nil;
    
    // 未完成订单列表
    if (_orderType == unCompleteOrder) {
        uri = @"/sorder?action=GetUnCompleteOrder";
    }
    
    // 待评价订单列表
    else if (_orderType == waitEvaluationOrder) {
        uri = @"/sorder?action=GetWaitEvaluationOrder";
    }
    
    // 已完成订单列表
    else if (_orderType == completeOrder) {
        uri = @"/sorder?action=GetCompleteOrder";
    }
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            
            if (_orderType == unCompleteOrder) {
                [self printDic:responseObject withTitle:@"未完成订单"];
            }
            else if (_orderType == waitEvaluationOrder) {
                [self printDic:responseObject withTitle:@"待评价订单"];
            }
            else if (_orderType == completeOrder) {
                [self printDic:responseObject withTitle:@"已完成订单"];
            }
            
            NSArray *array = [responseObject objectForKey:@"orderlist"];
            [_orderListArray addObjectsFromArray:array];
            
            // 是否还有更多
            if ([responseObject[@"hasmore"] intValue] == 0) {
                [_pullToMore setPullToMoreViewVisible:NO];
            } else {
                [_pullToMore setPullToMoreViewVisible:YES];
                [_pullToMore relocatePullToMoreView];
            }
            
            [self.mainTableView reloadData];
            
        }
        else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(backLogin)
                                           userInfo:nil
                                            repeats:NO];
            [self pageNumMinus];
        }
        else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [self pageNumMinus];
        }
        [self ifNoData];
        [_pullToMore tableViewReloadFinished];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self pageNumMinus];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
        [_pullToMore tableViewReloadFinished];
        [self ifNoData];
    }];
}

// 取消订单
- (void)postCancelOrder {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:self.cancelOrderId forKey:@"orderid"];
    
    NSString *uri = @"/sorder?action=CancelOrder";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"订单已取消"];
            [self postGetOrder];
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
        
        int code = [responseObject[@"code"] intValue] ;
        if (code == 1) {
            [self makeToast:@"取消投诉成功"];
            [self postGetOrder];
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
    [paramDic setObject:self.confirmOrderId forKey:@"orderid"];
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
            [self postGetOrder];
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
    [paramDic setObject:self.confirmOrderId forKey:@"orderid"];
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
            // 跳转到订单评价页面
            MyOrderEvaluationViewController *targetController = [[MyOrderEvaluationViewController alloc] initWithNibName:@"MyOrderEvaluationViewController" bundle:nil];
            targetController.orderid = self.confirmOrderId;
            [self.navigationController pushViewController:targetController animated:YES];
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

// 测试反地理编码
- (void)testLocation {
    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc] init];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    reverseGeoCodeSearchOption.reverseGeoPoint = delegate.userCoordinate;
    
    BMKGeoCodeSearch *_geoSearcher = [[BMKGeoCodeSearch alloc] init];
    _geoSearcher.delegate = self;
    BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if (flag) {
        NSLog(@"地理编码检索");
    } else {
        NSLog(@"地理编码检索失败");
    }
}

#pragma mark - 按钮方法
// 未完成订单
- (IBAction)clickForUnfinishedOrder:(id)sender {
    _orderType = unCompleteOrder;
    if (self.unfinishedBtn.selected == YES)
        return;
    [self getFreshData];
}

// 待评价订单
- (IBAction)clickForWaitEvaluateOrder:(id)sender {
    _orderType = waitEvaluationOrder;
    if (self.waiEvaluateBtn.selected == YES)
        return;
    [self getFreshData];
}

// 已完成订单
- (IBAction)clickForHistoricOrder:(id)sender {
    _orderType = completeOrder;
    if (self.historyBtn.selected == YES)
        return;
    [self getFreshData];
}

// 投诉
- (void)clickToComplain:(UIButton *)sender {
    NSInteger row = sender.tag - 100;
    NSDictionary *orderDic = _orderListArray[row];
    NSString *orderId = orderDic[@"orderid"];
    
    MyOrderComplainViewController *targetController = [[MyOrderComplainViewController alloc] initWithNibName:@"MyOrderComplainViewController" bundle:nil];
    targetController.orderid = orderId;
    [self.navigationController pushViewController:targetController animated:YES];
}

// 取消投诉
- (void)clickForCancelComplaint:(UIButton *)sender {
    NSInteger row = sender.tag - 200;
    NSDictionary *orderDic = _orderListArray[row];
    NSString *orderId = orderDic[@"orderid"];
    
    [self postCancelComplaint:orderId];
}

// 取消订单
- (void)clickForCancelOrder:(UIButton *)sender {
    NSInteger row = sender.tag - 300;
    NSDictionary *orderDic = _orderListArray[row];
    self.cancelOrderId = orderDic[@"orderid"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定要取消订单？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.cancelOrderAlert = alert;
    [alert show];
}

// 确认上车
- (void)clickForConfirmOn:(UIButton *)sender {
    //定位
    [self startLocation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认上车？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.confirmOnAlert = alert;
    [alert show];
    NSInteger row = sender.tag - 400;
    NSDictionary *orderDic = _orderListArray[row];
    self.confirmOrderId = orderDic[@"orderid"];
}

// 确认下车
- (void)clickForConfirmDown:(UIButton *)sender {
    //定位
    [self startLocation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认下车？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.confirmDownAlert = alert;
    [alert show];
    NSInteger row = sender.tag - 500;
    NSDictionary *orderDic = _orderListArray[row];
    self.confirmOrderId = orderDic[@"orderid"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:self.cancelOrderAlert]) { // 取消订单
        if (buttonIndex == 1) {
            [self postCancelOrder];
        }
    }
    else if ([alertView isEqual:self.confirmOnAlert]) { // 确认上车
        if (buttonIndex == 1) {
            [DejalBezelActivityView activityViewForView:self.view];
            self.confirmTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(postConfirmOn) userInfo:nil repeats:NO];
        }
    } else {
        if (buttonIndex == 1) { // 确认下车
            [DejalBezelActivityView activityViewForView:self.view];
            self.confirmTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(postConfirmDown) userInfo:nil repeats:NO];
//            [self performSelector:@selector(postConfirmDown:) withObject:self.confirmOrderId afterDelay:5];
        }
    }
}

// 评价订单
- (void)clickToMyOrderEvaluation:(UIButton *)sender {
    NSInteger row = sender.tag - 600;
    NSDictionary *orderDic = _orderListArray[row];
    NSString *orderId = orderDic[@"orderid"];
    
    MyOrderEvaluationViewController *targetController = [[MyOrderEvaluationViewController alloc] initWithNibName:@"MyOrderEvaluationViewController" bundle:nil];
    targetController.orderid = orderId;
    [self.navigationController pushViewController:targetController animated:YES];
}

- (void)appointCoachClick:(DSButton *)sender
{
    // 预约教练
//    AppointCoachViewController *viewcontroller = [[AppointCoachViewController alloc] init];
//    viewcontroller.coachId = [sender.data [@"coachid"] description];
//    viewcontroller.coachInfoDic = sender.data;
//     [self presentViewController:viewcontroller animated:YES completion:nil];
    
    
    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
    nextController.coachInfoDic = sender.data;
    nextController.coachId = [sender.data [@"coachid"] description];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
