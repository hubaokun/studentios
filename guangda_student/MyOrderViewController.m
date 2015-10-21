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
#import "OrderListTableViewCell.h"
#import "GuangdaOrder.h"
#import "AppDelegate.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "DSButton.h"
#import "AppointCoachViewController.h"
#import "LoginViewController.h"

typedef NS_OPTIONS(NSUInteger, OrderListType) {
    OrderListTypeUncomplete = 0,    // 未完成订单
    OrderListTypeWaitEvaluate,      // 待评价订单
    OrderListTypeComplete,          // 已完成订单
    OrderListTypeComplained,        // 待处理订单
};

@interface MyOrderViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKGeneralDelegate, UIAlertViewDelegate, OrderListTableViewCellDelegate> {
    CGFloat _rowHeight;
    NSString *_pageNum;
    BMKLocationService *_locService;
    int _alertType; // 提示框类型 1.确认上车 2.确认下车 3.取消投诉
}
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

// 确认取消订单页面
@property (strong, nonatomic) IBOutlet UIView *moreOperationView; // 更多操作
@property (strong, nonatomic) IBOutlet UIView *sureCancelOrderView; // 确认取消订单
@property (weak, nonatomic) IBOutlet UIButton *postCancelOrderBtn; // 请教练确认

// 导航栏选择条
@property (strong, nonatomic) IBOutlet UIView *selectBarView;
@property (strong, nonatomic) IBOutlet UIButton *unfinishedBtn;         // 未完成
@property (strong, nonatomic) IBOutlet UIButton *waiEvaluateBtn;        // 待评价
@property (strong, nonatomic) IBOutlet UIButton *historyBtn;            // 已完成
@property (strong, nonatomic) IBOutlet UIButton *complainedOrdersBtn;   // 已投诉

//用户定位
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (strong, nonatomic) NSString *cityName;//城市
@property (strong, nonatomic) NSString *address;//地址

// 页面数据
@property (assign, nonatomic) OrderListType orderListType;
@property (assign, nonatomic) OrderListType targetOrderListType;
@property (strong, nonatomic) NSMutableArray *orderList;
@property (copy, nonatomic) NSString *cancelOrderId;
@property (copy, nonatomic) NSString *confirmOrderId;
@property (copy, nonatomic) NSString *cancelComplainOrderId;
@property (strong, nonatomic) NSTimer *confirmTimer;

- (IBAction)clickForUnfinishedOrder:(id)sender;
- (IBAction)clickForWaitEvaluateOrder:(id)sender;
- (IBAction)clickForHistoricOrder:(id)sender;

@end

@implementation MyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.orderListType = OrderListTypeUncomplete;
    _orderList = [NSMutableArray array];
    _rowHeight = 235;
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
    // 按钮组边框
    self.selectBarView.layer.cornerRadius = 4;
    self.selectBarView.layer.borderWidth = 1;
    self.selectBarView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.waiEvaluateBtn.layer.borderWidth = 1;
    self.waiEvaluateBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    self.historyBtn.layer.borderWidth = 1;
    self.historyBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [self.unfinishedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.unfinishedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.historyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.historyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.waiEvaluateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.waiEvaluateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.complainedOrdersBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.complainedOrdersBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self oneButtonSellected:self.unfinishedBtn];
    
    [self sureCancelOrderViewConfig];
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

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orderList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"OrderListTableViewCellIdentifier";
    OrderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"OrderListTableViewCell" bundle:nil] forCellReuseIdentifier:ID];
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    // 取得数据
    GuangdaOrder *order = _orderList[indexPath.row];
    // 加载数据
    cell.order = order;
    [cell loadData];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GuangdaOrder *order = _orderList[indexPath.row];
    MyOrderDetailViewController *targetController = [[MyOrderDetailViewController alloc] initWithNibName:@"MyOrderDetailViewController" bundle:nil];
    targetController.orderid = order.orderId;
    if (self.orderListType == OrderListTypeUncomplete) {
        targetController.orderType = OrderTypeUncomplete;
    } else if (self.orderListType == OrderListTypeWaitEvaluate) {
        targetController.orderType = OrderTypeWaitEvaluate;
    } else if (self.orderListType == OrderListTypeComplete) {
        targetController.orderType = OrderTypeComplete;
    } else if (self.orderListType == OrderListTypeComplained) {
        targetController.orderType = OrderTypeAbnormal;
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

#pragma mark - Private
// 判断是否有数据
- (void)ifNoData {
    if (_orderList.count == 0) {
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
    self.complainedOrdersBtn.backgroundColor = [UIColor clearColor];
    self.unfinishedBtn.selected = NO;
    self.waiEvaluateBtn.selected = NO;
    self.historyBtn.selected = NO;
    self.complainedOrdersBtn.selected = NO;
    
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
    if (self.targetOrderListType == OrderListTypeUncomplete) {
        uri = @"/sorder?action=GetUnCompleteOrder";
    }
    
    // 待评价订单列表
    else if (self.targetOrderListType == OrderListTypeWaitEvaluate) {
        uri = @"/sorder?action=GetWaitEvaluationOrder";
    }
    
    // 已完成订单列表
    else if (self.targetOrderListType == OrderListTypeComplete) {
        uri = @"/sorder?action=GetCompleteOrder";
    }
    
    // 待处理订单列表
    else if (self.targetOrderListType == OrderListTypeComplained) {
        uri = @"/sorder?action=GETCOMPLAINTORDER";
    }
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            self.orderListType = self.targetOrderListType;
            NSArray *array = [responseObject objectForKey:@"orderlist"];
            [_orderList removeAllObjects];
            
            // 未完成订单列表
            if (self.orderListType == OrderListTypeUncomplete) {
                if (self.unfinishedBtn.selected == NO) {
                    [self oneButtonSellected:self.unfinishedBtn];
                }
                [_orderList addObjectsFromArray:[GuangdaOrder unCompleteOrdersWithArray:array]];
            }
            // 待评价订单列表
            else if (self.orderListType == OrderListTypeWaitEvaluate) {
                if (self.waiEvaluateBtn.selected == NO) {
                    [self oneButtonSellected:self.waiEvaluateBtn];
                }
                [_orderList addObjectsFromArray:[GuangdaOrder waitEvaluateOrdersWithArray:array]];
            }
            // 已完成订单列表
            else if (self.orderListType == OrderListTypeComplete) {
                if (self.historyBtn.selected == NO) {
                    [self oneButtonSellected:self.historyBtn];
                }
                [_orderList addObjectsFromArray:[GuangdaOrder completeOrdersWithArray:array]];
            }
            // 投诉中订单列表
            else if (self.orderListType == OrderListTypeComplained) {
                if (self.complainedOrdersBtn.selected == NO) {
                    [self oneButtonSellected:self.complainedOrdersBtn];
                }
                [_orderList addObjectsFromArray:[GuangdaOrder complainedOrdersWithArray:array]];
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
    if (self.orderListType == OrderListTypeUncomplete) {
        uri = @"/sorder?action=GetUnCompleteOrder";
    }
    
    // 待评价订单列表
    else if (self.orderListType == OrderListTypeWaitEvaluate) {
        uri = @"/sorder?action=GetWaitEvaluationOrder";
    }
    
    // 已完成订单列表
    else if (self.orderListType == OrderListTypeComplete) {
        uri = @"/sorder?action=GetCompleteOrder";
    }
    
    // 已完成订单列表
    else if (self.targetOrderListType == OrderListTypeComplained) {
        uri = @"/sorder?action=GETCOMPLAINTORDER";
    }
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            NSArray *array = [responseObject objectForKey:@"orderlist"];
            
            if (self.orderListType == OrderListTypeUncomplete) {
//                [self printDic:responseObject withTitle:@"未完成订单"];
                [_orderList addObjectsFromArray:[GuangdaOrder unCompleteOrdersWithArray:array]];
            }
            else if (self.orderListType == OrderListTypeWaitEvaluate) {
//                [self printDic:responseObject withTitle:@"待评价订单"];
                [_orderList addObjectsFromArray:[GuangdaOrder waitEvaluateOrdersWithArray:array]];
            }
            else if (self.orderListType == OrderListTypeComplete) {
//                [self printDic:responseObject withTitle:@"已完成订单"];
                [_orderList addObjectsFromArray:[GuangdaOrder completeOrdersWithArray:array]];
            }
            else if (self.orderListType == OrderListTypeComplained) {
                [_orderList addObjectsFromArray:[GuangdaOrder complainedOrdersWithArray:array]];
            }
            
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
//            [self makeToast:@"订单已取消"];
            [self clickForCloseMoreOperation:nil];
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

#pragma mark - OrderListTableViewCellDelegate 订单操作
// 取消订单
- (void)cancelOrder:(GuangdaOrder *)order
{
    self.cancelOrderId = order.orderId;
    [self.view addSubview:self.moreOperationView];
}

// 投诉
- (void)complain:(GuangdaOrder *)order
{
    MyOrderComplainViewController *nextVC = [[MyOrderComplainViewController alloc] init];
    nextVC.orderid = order.orderId;
    [self.navigationController pushViewController:nextVC animated:YES];
}

// 取消投诉
- (void)cancelComplain:(GuangdaOrder *)order
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定要取消投诉？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    _alertType = 3;
    self.cancelComplainOrderId = order.orderId;
    [alert show];
}

// 确认上车
- (void)confirmOn:(GuangdaOrder *)order
{
    //定位
    [self startLocation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认上车？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    _alertType = 1;
    [alert show];
    self.confirmOrderId = order.orderId;
}

// 确认下车
- (void)confirmDown:(GuangdaOrder *)order
{
    //定位
    [self startLocation];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认下车？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    _alertType = 2;
    [alert show];
    self.confirmOrderId = order.orderId;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_alertType == 1) { // 确认上车
        if (buttonIndex == 1) {
            [DejalBezelActivityView activityViewForView:self.view];
            self.confirmTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(postConfirmOn) userInfo:nil repeats:NO];
        }
    } else if (_alertType == 2) { // 确认下车
        if (buttonIndex == 1) {
            [DejalBezelActivityView activityViewForView:self.view];
            self.confirmTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(postConfirmDown) userInfo:nil repeats:NO];
        }
    } else if (_alertType == 3) { // 取消投诉
        if (buttonIndex == 1) {
            [self postCancelComplaint:self.cancelComplainOrderId];
        }
    }
}

// 评价
- (void)eveluate:(GuangdaOrder *)order
{
    NSString *orderId = order.orderId;
    MyOrderEvaluationViewController *targetController = [[MyOrderEvaluationViewController alloc] initWithNibName:@"MyOrderEvaluationViewController" bundle:nil];
    targetController.orderid = orderId;
    [self.navigationController pushViewController:targetController animated:YES];
}

// 继续预约
- (void)bookMore:(GuangdaOrder *)order
{
    NSDictionary *coachInfoDict = order.coachInfoDict;
    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
    nextController.coachInfoDic = coachInfoDict;
    nextController.coachId = [coachInfoDict[@"coachid"] description];
    if ([order.subjectName isEqualToString:@"陪驾"]) {
        nextController.carModelID = @"19";
    }
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - 按钮方法
// 未完成订单
- (IBAction)clickForUnfinishedOrder:(id)sender {
    if (self.unfinishedBtn.selected == YES) return;
    self.targetOrderListType = OrderListTypeUncomplete;
    [self getFreshData];
}

// 待评价订单
- (IBAction)clickForWaitEvaluateOrder:(id)sender {
    self.targetOrderListType = OrderListTypeWaitEvaluate;
    if (self.waiEvaluateBtn.selected == YES) return;
    [self getFreshData];
}

// 已完成订单
- (IBAction)clickForHistoricOrder:(id)sender {
    if (self.historyBtn.selected == YES) return;
    self.targetOrderListType = OrderListTypeComplete;
    [self getFreshData];
}

// 已投诉订单
- (IBAction)clickForComplainedOrder:(id)sender {
    if (self.complainedOrdersBtn.selected == YES) return;
    self.targetOrderListType = OrderListTypeComplained;
    [self getFreshData];
}

// 关闭更多操作页
- (IBAction)clickForCloseMoreOperation:(UIButton *)sender {
    [self.moreOperationView removeFromSuperview];
}

// 确认取消订单
- (IBAction)clickForSureCancelOrder:(UIButton *)sender {
    [self postCancelOrder];
}

// 确认取消订单
- (IBAction)backClick:(id)sender {
    if (self.comeFrom == 1) {
        NSUInteger index = self.navigationController.viewControllers.count;
        index -= 3;
        [self.navigationController popToViewController:self.navigationController.viewControllers[index] animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
