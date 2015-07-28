//
//  SureOrderViewController.m
//  guangda_student
//
//  Created by Dino on 15/4/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SureOrderViewController.h"
#import "SureOrderTableViewCell.h"
#import <CoreText/CoreText.h>
#import "MyOrderDetailViewController.h"
#import "SelectOtherCouponViewController.h"
#import "TypeinNumberViewController.h"
#import "LoginViewController.h"
#import "MyOrderViewController.h"
@interface SureOrderViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *priceSumLabel;

// 预约结果view
@property (strong, nonatomic) IBOutlet UIView *appointResultView;
@property (strong, nonatomic) IBOutlet UIImageView *resultImageView;
@property (strong, nonatomic) IBOutlet UILabel *resultStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *accountLabel;//账户余额
@property (strong, nonatomic) IBOutlet UILabel *resultDetailsLabel;

@property (strong, nonatomic) IBOutlet UIButton *appointResultBtn;
@property (strong, nonatomic) IBOutlet UIView *resultContentView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *resultStatusHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusImageHeight;

@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) IBOutlet UILabel *tipTravel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tipTravelTopMargin;
@property (strong, nonatomic) NSMutableArray *orderArray;//订单数组
@property (strong, nonatomic) NSMutableArray *couponArray;//小巴券列表
@property (assign, nonatomic) int delMoney;//小巴券抵掉的钱

@property (strong, nonatomic) IBOutlet UILabel *couponCountLabel;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *usecouponLabel;
@property (assign, nonatomic) int canUseDiffCoupon;
@property (assign, nonatomic) int canUsedMaxCouponCount;

- (IBAction)clickForOtherCoupon:(id)sender;


@end

@implementation SureOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.priceSumLabel.text = [NSString stringWithFormat:@"应付金额%@元", self.priceSum];
    
    _orderArray = [NSMutableArray array];
    _couponArray = [NSMutableArray array];
    _delMoney = 0;
    self.payMoney = [self.priceSum floatValue];
    
    
    self.canUseDiffCoupon = 0;
    self.canUsedMaxCouponCount = 1;
    
    [self getOrderArray];
    
    //获取可以使用的小巴券
    [self getCanUseCouponList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectCoupon:) name:@"changeSelectCoupon" object:nil];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    label.numberOfLines = 0;
    label.text = @"请确认上车地址,具体交通事宜请与教练直接联系";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor redColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    CGSize size = [CommonUtil sizeWithString:label.text fontSize:16 sizewidth:SCREEN_WIDTH sizeheight:CGFLOAT_MAX];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, size.height + 20);
    label.frame = CGRectMake(10, 0, SCREEN_WIDTH - 20, size.height + 20);
    [view addSubview:label];
    self.tableView.tableHeaderView = view;
}

//刷新余额
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshUserMoney];
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
    [paramDic setObject:userId forKey:@"userid"];
    [paramDic setObject:userInfoDic[@"token"] forKey:@"token"];
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

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

- (void)changeSelectCoupon:(NSNotification*)dictionary{
    NSDictionary * dic = dictionary.object;
    if(dic){
        NSArray *couponArray = dic[@"couponArray"];
        NSArray *selectedCoupon = dic[@"selectedCoupon"];
        NSString *orderIndex = dic[@"orderIndex"];
        if(couponArray && selectedCoupon)
            [self handelCouponChangeWithcouponArray:couponArray andselectedCoupon:selectedCoupon withIndex:[orderIndex intValue]];
    }
}

- (void) handelCouponChangeWithcouponArray:(NSArray*) array andselectedCoupon:(NSArray*)selectedCoupon withIndex:(int)index{
    NSDictionary *order = _orderArray[index];
    [order setValue:selectedCoupon forKey:@"couponlist"];
    [_orderArray replaceObjectAtIndex:index withObject:order];
    
    for (int i = 0; i < _couponArray.count; i++) {
        NSDictionary *dic = _couponArray[i];
        for (int j = 0; j < array.count; j++) {
            NSDictionary *dic1 = array[j];
            int recordid = [dic[@"recordid"] intValue];
            int recordid1 = [dic1[@"recordid"] intValue];
            if(recordid == recordid1){
                [_couponArray replaceObjectAtIndex:i withObject:dic1];
            }
        }
    }
    [self.tableView reloadData];
    
    //计算小巴券的抵价
    int count = 0;
    int delmA = 0;
    for(int i = 0; i < _orderArray.count; i++){
        NSMutableDictionary *dic = [_orderArray[i] mutableCopy];
        int priceAll = [dic[@"priceAll"] intValue];
        int timecount = [dic[@"timecount"] intValue];
        int timeUsedcount = 0;
        int delm = 0;
        NSArray *times = dic[@"times"];
        if([[dic allKeys] containsObject:@"couponlist"]){
            NSMutableArray *couponlist = [dic[@"couponlist"] mutableCopy];
            if(couponlist){
                count += couponlist.count;
                for(int m = 0; m < couponlist.count; m++){
                    NSDictionary *coupon = couponlist[m];
                    int value = [coupon[@"value"] intValue];
                    int coupontype = [coupon[@"coupontype"] intValue];
                    if(coupontype == 1){
                        int usedvalue = 0;
                        for(int n = (timecount - timeUsedcount - 1); n >= 0;n--){
                            if(usedvalue < value){
                                usedvalue++;
                                timeUsedcount++;
                                NSDictionary *time = times[n];
                                int price = [time[@"price"] intValue];
                                if(delm + price <= priceAll){
                                    delm += price;
                                }else{
                                    delm = priceAll;
                                }
                            }
                        }
                    }else{
                        if(delm + value <= priceAll){
                            delm += value;
                        }else{
                            delm = priceAll;
                        }
                    }
                }
            }
        }
        delmA += delm;
        [dic setObject:[NSString stringWithFormat:@"%d",delm] forKey:@"delmoney"];
        [_orderArray replaceObjectAtIndex:i withObject:dic];
    }
    
    int sum = [self.priceSum intValue];
    sum = sum - delmA;
    self.payMoney = sum;
    self.priceSumLabel.text = [NSString stringWithFormat:@"应付金额 %d元",sum];
    if(delmA != 0){
        self.couponCountLabel.text = [NSString stringWithFormat:@"共使用%d张优惠券:抵%d元",count,delmA];
    }else{
        self.couponCountLabel.text = @"当前没有使用优惠券";
    }
}

/**
 对传过来的订单数据进行处理
 **/
- (void) getOrderArray{
    
    for (NSDictionary *dic in self.dateTimeSelectedList) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:dic[@"date"] forKey:@"date"];//订单的日期
        NSArray *times = dic[@"times"];
        NSMutableArray *timesArray = [NSMutableArray array];
        int timeCount = 0;
        int priceAll = 0;
        for (NSDictionary *timDic in times) {
            timeCount ++;
            NSMutableDictionary *time = [NSMutableDictionary dictionary];
            NSString *price = [[timDic[@"price"] description] stringByReplacingOccurrencesOfString:@"元" withString:@""];
            priceAll += [price intValue];
            [time setObject:price forKey:@"price"];//价格
            [time setObject:timDic[@"time"] forKey:@"time"];//时间点
            [timesArray addObject:time];
        }
        //对timesArray排序－－从小到大
        NSArray *array = [timesArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            int price1 = [obj1[@"price"] intValue];
            int price2 = [obj2[@"price"] intValue];
            if (price1 > price2) {
                return NSOrderedDescending;
            }
            
            if (price1 < price2) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
        [dictionary setObject:array forKey:@"times"];
        [dictionary setObject:[NSString stringWithFormat:@"%d",priceAll] forKey:@"priceAll"];//总价
        [dictionary setObject:[NSString stringWithFormat:@"%d",timeCount] forKey:@"timecount"];//时间点的个数
        [_orderArray addObject:dictionary];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 66)];
    view.backgroundColor = RGB(246, 246, 246);
    //还有可用的小巴券
    int count = 0;
    for(int i = 0; i < _couponArray.count; i++){
        NSDictionary *dic = _couponArray[i];
        int used = [dic[@"used"] intValue];
        if(used == 0)
            count++;
    }
    
    if(section < _orderArray.count){
        NSDictionary *dic = _orderArray[section];
        if([[dic allKeys] containsObject:@"couponlist"]){
            NSArray *usedcoupon = dic[@"couponlist"];
            if(usedcoupon && usedcoupon.count > 0){
                
                UIView *View1 = [[UIView alloc] initWithFrame:CGRectMake(0, 7, SCREEN_WIDTH, 52)];
                View1.backgroundColor = [UIColor whiteColor];
                [view addSubview:View1];
                
                UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 7, SCREEN_WIDTH, 1)];
                line1.backgroundColor = RGB(219, 220, 223);
                [view addSubview:line1];
                
                UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 58, SCREEN_WIDTH, 1)];
                line2.backgroundColor = RGB(219, 220, 223);
                [view addSubview:line2];
                
                NSString *inString = [NSString stringWithFormat:@"%lu",(unsigned long)usedcoupon.count];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 150, 50)];
                NSString *text = [NSString stringWithFormat:@"已使用%@张优惠券",inString];
                NSMutableAttributedString *attributeDateStr = [[NSMutableAttributedString alloc] initWithString:text];
                [attributeDateStr addAttribute:NSForegroundColorAttributeName value:RGB(60, 60, 60) range:NSMakeRange(0, 3)];
                [attributeDateStr addAttribute:NSForegroundColorAttributeName value:RGB(247, 100, 92) range:NSMakeRange(3, inString.length)];
                [attributeDateStr addAttribute:NSForegroundColorAttributeName value:RGB(60, 60, 60) range:NSMakeRange(inString.length + 3, text.length - 3 - inString.length)];
                [attributeDateStr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, text.length)];
                label.attributedText = attributeDateStr;
                [view addSubview:label];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(SCREEN_WIDTH - 130, 8, 120, 50);
                button.titleLabel.font = [UIFont systemFontOfSize:14.0];
                [button setTitle:@"[选择其它优惠券]" forState:UIControlStateNormal];
                [button setTitleColor:RGB(60, 60, 60) forState:UIControlStateNormal];
                button.tag = section;
                [button addTarget:self action:@selector(clickForSelectOther:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:button];
            }else{
                if(count > 0){
                    UIView *View1 = [[UIView alloc] initWithFrame:CGRectMake(0, 7, SCREEN_WIDTH, 52)];
                    View1.backgroundColor = [UIColor whiteColor];
                    [view addSubview:View1];
                    
                    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 7, SCREEN_WIDTH, 1)];
                    line1.backgroundColor = RGB(219, 220, 223);
                    [view addSubview:line1];
                    
                    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 58, SCREEN_WIDTH, 1)];
                    line2.backgroundColor = RGB(219, 220, 223);
                    [view addSubview:line2];
                    
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 150, 50)];
                    label.text = @"有可用的优惠券";
                    [view addSubview:label];
                    
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(SCREEN_WIDTH - 130, 8, 120, 50);
                    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
                    [button setTitle:@"[选择优惠券]" forState:UIControlStateNormal];
                    [button setTitleColor:RGB(60, 60, 60) forState:UIControlStateNormal];
                    button.tag = section;
                    [button addTarget:self action:@selector(clickForSelectOther:) forControlEvents:UIControlEventTouchUpInside];
                    [view addSubview:button];
                }
            }
        }else{
            if(count > 0){
                
                UIView *View1 = [[UIView alloc] initWithFrame:CGRectMake(0, 7, SCREEN_WIDTH, 52)];
                View1.backgroundColor = [UIColor whiteColor];
                [view addSubview:View1];
                
                UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 7, SCREEN_WIDTH, 1)];
                line1.backgroundColor = RGB(219, 220, 223);
                [view addSubview:line1];
                
                UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 58, SCREEN_WIDTH, 1)];
                line2.backgroundColor = RGB(219, 220, 223);
                [view addSubview:line2];
                
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, 150, 50)];
                label.text = @"有可用的优惠券";
                [view addSubview:label];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(SCREEN_WIDTH - 130, 8, 120, 50);
                button.titleLabel.font = [UIFont systemFontOfSize:14.0];
                [button setTitle:@"[选择优惠券]" forState:UIControlStateNormal];
                [button setTitleColor:RGB(60, 60, 60) forState:UIControlStateNormal];
                button.tag = section;
                [button addTarget:self action:@selector(clickForSelectOther:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:button];
            }
        }
    }
    return view;
}


- (void) clickForSelectOther:(id) sender{
    NSInteger tag = ((UIButton*)sender).tag;
    
    SelectOtherCouponViewController *nextViewController = [[SelectOtherCouponViewController alloc] initWithNibName:@"SelectOtherCouponViewController" bundle:nil];
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < _couponArray.count; i++){
        NSDictionary *dic = _couponArray[i];
        int used = [dic[@"used"] intValue];
        if(used == 0){
            [array addObject:dic];
        }
    }
    NSDictionary *order = _orderArray[tag];
    NSArray *couponlist = order[@"couponlist"];
    if(couponlist)
        [array addObjectsFromArray:couponlist];
    
    nextViewController.couponArray = [array mutableCopy];
    if(couponlist)
        nextViewController.selectedCoupon = [couponlist mutableCopy];
    nextViewController.canUseDiffCoupon = self.canUseDiffCoupon;
    nextViewController.orderIndex = [NSString stringWithFormat:@"%ld",(long)tag];
    nextViewController.canUsedMaxCouponCount = self.canUsedMaxCouponCount;
    nextViewController.selectedOrderList = self.dateTimeSelectedList[tag];
    [self.navigationController pushViewController:nextViewController animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section >= _orderArray.count)
        return 0;
    //已经选择了小巴券
    NSDictionary *dic = _orderArray[section];
    if([[dic allKeys] containsObject:@"couponlist"]){
        NSArray *usedcoupon = dic[@"couponlist"];
        if(usedcoupon && usedcoupon.count > 0){
            return 66;
        }
    }
    //还有可用的小巴券
    int count = 0;
    for(int i = 0; i < _couponArray.count; i++){
        NSDictionary *dic = _couponArray[i];
        int used = [dic[@"used"] intValue];
        if(used == 0)
            count++;
    }
    if(count > 0)
        return 66;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 37)];
    
    UIView *smallView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 8)];
    smallView.backgroundColor = RGB(246, 246, 246);
    [view addSubview:smallView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 8, SCREEN_WIDTH, 1)];
    line.backgroundColor = RGB(219, 220, 223);
    [view addSubview:line];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(75, 8, SCREEN_WIDTH-150, 25)];
    titleView.backgroundColor = RGB(80, 203, 140);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:titleView.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(13, 13)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = titleView.bounds;
    maskLayer.path = maskPath.CGPath;
    titleView.layer.mask = maskLayer;
    [view addSubview:titleView];
    
    NSString *date = self.dateTimeSelectedList[section][@"date"];
    
    UILabel *label = [[UILabel alloc] initWithFrame:titleView.bounds];
    label.text = date;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:label];
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dateTimeSelectedList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic = self.dateTimeSelectedList[section];
    NSArray *timeList = dic[@"times"];
    
    return timeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"SureOrderTableViewCell";
    SureOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"SureOrderTableViewCell" bundle:nil] forCellReuseIdentifier:indentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    }
    
    NSDictionary *dic = self.dateTimeSelectedList[indexPath.section];
    NSArray *timeList = dic[@"times"];
    NSDictionary *timeDic = timeList[indexPath.row];
    
    NSString *time = timeDic[@"time"];
    NSString *price = timeDic[@"price"];
    NSString *subject = timeDic[@"subject"];
    NSString *addressDetail = timeDic[@"addressdetail"];
    
    int timeValue = [time intValue];
    NSString *string = nil;
    if (timeValue < 12) {
        string = @"上午";
    }else if (timeValue < 19) {
        string = @"下午";
    }else{
        string = @"晚上";
    }
    
    // 时间
    NSMutableAttributedString *timeAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@的%d:00-%d:00)", time, string, timeValue, timeValue+1]];
    [timeAttr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, time.length)];
    [timeAttr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(time.length, timeAttr.length - time.length)];
    [timeAttr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, time.length)];
    [timeAttr addAttribute:NSForegroundColorAttributeName value:RGB(184, 184, 184) range:NSMakeRange(time.length, timeAttr.length - time.length)];
    
    // 地址
    NSMutableAttributedString *addressAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@", subject, addressDetail]];
    [addressAttr addAttribute:NSForegroundColorAttributeName value:RGB(184, 184, 184) range:NSMakeRange(subject.length, 1)];
    [addressAttr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, subject.length)];
    
    cell.timeLabel.attributedText = timeAttr;
    cell.priceLabel.text = [NSString stringWithFormat:@"%@", price];
    cell.addressDetailLabel.attributedText = addressAttr;
    
    if (indexPath.row == timeList.count-1) {
        cell.leftLength.constant = 0;
        cell.rightLength.constant = 0;
    }else{
        cell.leftLength.constant = 20;
        cell.rightLength.constant = 20;
    }
    
    return cell;
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self requestBookCoach];
    }
}

#pragma mark - actions
- (IBAction)goAppointClick:(id)sender
{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    CGFloat userMoney = [userInfo[@"money"] floatValue];
    if(userMoney < _payMoney && _payMoney != 0){//需付金额不为零 且余额不足的情况下
        [self letoutResultViewWithType:0];
        return;
    }
    [self requestBookCoach];
}

- (IBAction)orderDetailClick:(id)sender
{
    if (self.orderId) {
        MyOrderViewController *viewController = [[MyOrderViewController alloc] initWithNibName:@"MyOrderViewController" bundle:nil];
//        viewController.orderid = self.orderId;
//        viewController.isSkip = @"1";
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)changeTimeClick:(id)sender
{
    [self.appointResultView removeFromSuperview];
    [self backClick:sender];
}

#pragma mark - 接口请求
- (void)requestBookCoach
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.coachId forKey:@"coachid"];
    
    NSDictionary *studentDic = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *studentId = studentDic[@"studentid"];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:studentDic[@"token"] forKey:@"token"];
    
    NSMutableArray *times = [NSMutableArray array];
    for (int i = 0; i < self.dateTimeSelectedList.count; i++) {
        NSDictionary *dateDic = self.dateTimeSelectedList[i];
        
        NSDictionary *order;
        NSArray *couponlist = nil;
        NSString *firstTime = [[dateDic[@"times"] objectAtIndex:0] objectForKey:@"time"];
        for(int j = 0; j < _orderArray.count; j++){
            NSDictionary *dic = _orderArray[j];
            NSString *first = [[dic[@"times"] objectAtIndex:0] objectForKey:@"time"];
            if([dic[@"date"] isEqualToString:dateDic[@"date"]] && [first isEqualToString:firstTime]){
                couponlist = dic[@"couponlist"];
                order = dic;
            }
        }
        
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
        // 取出日期
        NSString *date = dateDic[@"date"];
        // 取出日期的时间点字典
        NSArray *timesList = dateDic[@"times"];
        NSMutableArray *array = [NSMutableArray array];
        for (int j = 0; j < timesList.count; j++) {
            NSString *timeStr = timesList[j][@"time"];
            int time = [timeStr intValue];
            [array addObject:[NSString stringWithFormat:@"%d", time]];
        }
        
        NSString *recordid = @"";
        if(couponlist){
            for(int j = 0; j < couponlist.count; j++){
                NSDictionary *coupon = couponlist[j];
                int cid = [coupon[@"recordid"] intValue];
                if(recordid.length == 0)
                    recordid = [NSString stringWithFormat:@"%d",cid];
                else{
                    recordid = [NSString stringWithFormat: @"%@,%d",recordid,cid];
                }
            }
        }
        if (recordid.length > 0) {
            [mutableDic setObject:recordid forKey:@"recordid"];
        }else{
            [mutableDic setObject:@"0" forKey:@"recordid"];
        }
        NSString *delmoney = order[@"delmoney"];
        if([CommonUtil isEmpty:delmoney]){
            [mutableDic setObject:@"0" forKey:@"delmoney"];
        }else{
            [mutableDic setObject:delmoney forKey:@"delmoney"];
        }
        
        [mutableDic setObject:date forKey:@"date"];
        [mutableDic setObject:array forKey:@"time"];
        [times addObject:mutableDic];
    }
    
    NSData *jsonData = [self toJSONData:times];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [paramDic setObject:jsonString   forKey:@"date"];
    
    NSString *uri = @"/sbook?action=BookCoach";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;     // 网络超时时长设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1)
        {
            NSString *successId = responseObject[@"successorderid"];
            self.orderId = successId;
            int coachauth = [responseObject[@"coachauth"] intValue];
            if(coachauth == 1){
                [self letoutResultViewWithType:1];
            }else{
                [self letoutResultViewWithType:2];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"appointCoachSuccess" object:nil];
        }else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(backLogin)
                                           userInfo:nil
                                            repeats:NO];
        }else if (code == -1){
            [self makeToast:@"版本太久了哦,请退出程序后再次进入,程序将自动更新"];
        }else{
            [self letoutResultViewWithType:3];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"GetNearByCoach == %@", ERR_NETWORK);
        [self makeToast:ERR_NETWORK];
    }];
}

// 将数组转JSON
- (NSData *)toJSONData:(id)theData
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil)
    {
        return jsonData;
    }else{
        return nil;
    }
}

#pragma mark - 弹窗提示
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
    
    //可用余额
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *money = [userInfo[@"money"] description];
    NSString *accountMoney = [NSString stringWithFormat:@"仅剩 %@元", money];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:accountMoney];
    
    [string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                           [UIFont systemFontOfSize:20],NSFontAttributeName,
                           RGB(246, 102, 93),NSForegroundColorAttributeName,
                           nil] range:NSMakeRange(3,money.length+1)];
    
    switch (type) {
        case 0:
            // 余额不足
            self.resultImageView.image = [UIImage imageNamed:@"icon_no_money"];
            self.resultStatusLabel.text = @"您的余额不足";
            self.accountLabel.attributedText = string;
            self.accountLabel.hidden = NO;
            self.resultStatusLabel.numberOfLines = 2;
            self.resultStatusHeight.constant = 45;
            self.resultDetailsLabel.hidden = YES;
            self.contentViewHeight.constant = 220;
            [self.appointResultBtn setTitle:@"去充值" forState:UIControlStateNormal];
            [self.appointResultBtn removeTarget:self action:@selector(changeTimeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.appointResultBtn removeTarget:self action:@selector(changeTimeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.appointResultBtn addTarget:self action:@selector(rechargeClick:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case 1:
            // 已审核
            self.statusImageHeight.constant = 60;
            self.resultImageView.image = [UIImage imageNamed:@"icon_appoint_success"];
            self.resultStatusLabel.text = @"预约成功";
            self.accountLabel.hidden = YES;
            self.resultStatusLabel.numberOfLines = 1;
            self.resultStatusHeight.constant = 21;
            self.resultDetailsLabel.hidden = YES;
            self.contentViewHeight.constant = 220;
            self.tipTravelTopMargin.constant = 10;
            [self.appointResultBtn setTitle:@"订单详情" forState:UIControlStateNormal];
            [self.appointResultBtn removeTarget:self action:@selector(changeTimeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.appointResultBtn removeTarget:self action:@selector(rechargeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.appointResultBtn addTarget:self action:@selector(orderDetailClick:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case 2:
            // 未审核
            self.statusImageHeight.constant = 60;
            self.resultImageView.image = [UIImage imageNamed:@"icon_appoint_success"];
            self.resultStatusLabel.text = @"预约成功";
            self.accountLabel.hidden = YES;
            self.resultDetailsLabel.hidden = NO;
            self.resultStatusLabel.numberOfLines = 1;
            self.resultStatusHeight.constant = 21;
            self.contentViewHeight.constant = 250;
            [self.appointResultBtn setTitle:@"订单详情" forState:UIControlStateNormal];
            [self.appointResultBtn removeTarget:self action:@selector(changeTimeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.appointResultBtn removeTarget:self action:@selector(rechargeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.appointResultBtn addTarget:self action:@selector(orderDetailClick:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        case 3:
            self.statusImageHeight.constant = 0;
            self.contentViewHeight.constant = 175;
            self.resultStatusLabel.text = @"您预约的时间已被\n其他学员抢走了~";
            self.accountLabel.hidden = YES;
            self.resultDetailsLabel.hidden = YES;
            self.resultStatusLabel.numberOfLines = 2;
            self.resultStatusHeight.constant = 50;
            [self.appointResultBtn setTitle:@"重新选择时间" forState:UIControlStateNormal];
            [self.appointResultBtn removeTarget:self action:@selector(orderDetailClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.appointResultBtn removeTarget:self action:@selector(rechargeClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.appointResultBtn addTarget:self action:@selector(changeTimeClick:) forControlEvents:UIControlEventTouchUpInside];
            break;
            
        default:
            break;
    }
}

// 充值
- (IBAction)rechargeClick:(id)sender {
    [self.appointResultView removeFromSuperview];
    
    TypeinNumberViewController *viewController = [[TypeinNumberViewController alloc] initWithNibName:@"TypeinNumberViewController" bundle:nil];
    viewController.status = @"1";
    [self.navigationController  pushViewController:viewController animated:YES];
}

- (IBAction)removeResultClick:(id)sender {
    [self.appointResultView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) getCanUseCouponList{
    [DejalBezelActivityView activityViewForView:self.view];
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    NSString *uri = @"/sbook?action=GetCanUseCouponList";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"studentid"] forKey:@"studentid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    [paramDic setObject:self.coachId forKey:@"coachid"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            _couponArray = [responseObject[@"couponlist"] mutableCopy];
            
            if(_couponArray && _couponArray.count > 0){
                if([[responseObject allKeys] containsObject:@"canUseDiff"])
                    self.canUseDiffCoupon = [responseObject[@"canUseDiff"] intValue];
                
                if([[responseObject allKeys] containsObject:@"canUseMaxCount"])
                    self.canUsedMaxCouponCount = [responseObject[@"canUseMaxCount"] intValue];
                
                [self.tableView reloadData];
            }
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
        [DejalBezelActivityView removeViewAnimated:YES];
    }];
}


- (IBAction)clickForOtherCoupon:(id)sender {
    SelectOtherCouponViewController *nextViewController = [[SelectOtherCouponViewController alloc] initWithNibName:@"SelectOtherCouponViewController" bundle:nil];
    nextViewController.couponArray = [_couponArray mutableCopy];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
@end
