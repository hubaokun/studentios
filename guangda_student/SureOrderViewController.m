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
#import "TypeinNumberViewController.h"
#import "LoginViewController.h"
#import "MyOrderViewController.h"
#import "XBBookOrder.h"

#define FOOTVIEW_HEIGHT 48
#define SELVIEW_HEIGHT 250
@interface SureOrderViewController ()<UITableViewDataSource, UITableViewDelegate> {
    int _validCouponNum; // 可用学时券总数
    int _validCoinNum; // 可用小巴币总数
    float _validMoney; // 余额总数
    int _remainderCouponNum; // 剩余学时券数
    int _remainderCoinNum; // 剩余学时币数
    float _remainderMoney; // 剩余余额
}

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

@property (assign, nonatomic) int canUseDiffCoupon;
@property (assign, nonatomic) int canUsedMaxCouponCount;

@property (weak, nonatomic) IBOutlet UIButton *goAppointBtn;


// 选择支付方式
@property (strong, nonatomic) IBOutlet UIView *payTypeSelectView;
@property (weak, nonatomic) IBOutlet UIControl *coverView;
@property (strong, nonatomic) UIButton *coverBgBtn;
@property (weak, nonatomic) IBOutlet UILabel *remainCouponLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainCoinLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainMoneyLabel;


@property (weak, nonatomic) IBOutlet UIButton *couponSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *coinSelectBtn;
@property (weak, nonatomic) IBOutlet UIButton *moneySelectBtn;
@property (strong, nonatomic) UIButton *selectedBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

// 页面数据
@property (strong, nonatomic) NSMutableArray *bookOrdersArray;  // 预约订单数组
@property (strong, nonatomic) XBBookOrder *targetBookOrder;     // 当前操作订单
@property (assign, nonatomic) BOOL moneyIsDeficit;              // 余额是否不足

@end

@implementation SureOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bookOrdersArray = [XBBookOrder bookOrdersWithArray:self.dateTimeSelectedList];
    self.priceSumLabel.text = [NSString stringWithFormat:@"应付金额%@元", self.priceSum];
    
    _orderArray = [NSMutableArray array];
    _couponArray = [NSMutableArray array];
    _delMoney = 0;
    self.payMoney = [self.priceSum floatValue];
    
    
    self.canUseDiffCoupon = 0;
    self.canUsedMaxCouponCount = 1;
    
    [self getOrderArray];
    
    // 注册通知，选择小巴券后的操作
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectCoupon:) name:@"changeSelectCoupon" object:nil];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    label.numberOfLines = 0;
    label.text = @"请事先与教练确认练车地址和交通方式";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor redColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    CGSize size = [CommonUtil sizeWithString:label.text fontSize:16 sizewidth:SCREEN_WIDTH sizeheight:CGFLOAT_MAX];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, size.height + 20);
    label.frame = CGRectMake(10, 0, SCREEN_WIDTH - 20, size.height + 20);
    [view addSubview:label];
    self.tableView.tableHeaderView = view;
    
    self.payTypeSelectView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SELVIEW_HEIGHT);
    [self.view addSubview:self.payTypeSelectView];
    
    self.coverBgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.coverBgBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.coverBgBtn.backgroundColor = [UIColor blackColor];
    self.coverBgBtn.alpha = 0;
    [self.coverBgBtn addTarget:self action:@selector(clickForHideSelectionView:) forControlEvents:UIControlEventTouchUpInside];
}

//刷新余额
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 获取可以使用的小巴券、小巴币数目、账户余额并配置界面
    [self getCanUseCouponList];
}

#pragma mark - 配置支付方式选择view
- (void)payTypeSelectViewConfig:(XBBookOrder *)bookOrder {
    if (bookOrder.payType == payTypeCoupon) {
        [self selectButton:self.couponSelectBtn];
        _remainderCouponNum++;
    }
    
    else if (bookOrder.payType == payTypeCoin) {
        [self selectButton:self.coinSelectBtn];
        _remainderCoinNum += [bookOrder.price intValue];
    }
    
    else if (bookOrder.payType == payTypeMoney) {
        [self selectButton:self.moneySelectBtn];
        _remainderMoney += [bookOrder.price floatValue];
    }
    
    [self allSelectBtnConfig:bookOrder];
    [self remainWealthShow:bookOrder];
}

// 初始化按钮组的选中状态
- (void)selectButton:(UIButton *)button {
    self.couponSelectBtn.selected = NO;
    self.coinSelectBtn.selected = NO;
    self.moneySelectBtn.selected = NO;
    button.selected = YES;
    self.selectedBtn = button;
}

// 配置所有选择按钮的状态
- (void)allSelectBtnConfig:(XBBookOrder *)bookOrder {
    if (_remainderCouponNum == 0 && self.couponSelectBtn.selected == NO) { // 已无更多学时券
        [self invalidSelectBtn:self.couponSelectBtn];
    } else {
        [self validSelectBtn:self.couponSelectBtn];
    }
    
    if (_remainderCoinNum < [bookOrder.price intValue] && self.coinSelectBtn.selected == NO) { // 已无更多小巴币
        [self invalidSelectBtn:self.coinSelectBtn];
    } else {
        [self validSelectBtn:self.coinSelectBtn];
    }
}

// 设置支付方式选择按钮为不可选
- (void)invalidSelectBtn:(UIButton *)button {
    [button setImage:[UIImage imageNamed:@"coupon_invalid"] forState:UIControlStateNormal];
    button.enabled = NO;
}

// 设置支付方式选择按钮为可选
- (void)validSelectBtn:(UIButton *)button {
    [button setImage:[UIImage imageNamed:@"coupon_unselected"] forState:UIControlStateNormal];
    button.enabled = YES;
}

// 显示可用的剩余财富
- (void)remainWealthShow:(XBBookOrder *)bookOrder {
    self.remainCouponLabel.text = [NSString stringWithFormat:@"%d张可用", _remainderCouponNum];
    self.remainCoinLabel.text = [NSString stringWithFormat:@"%d个可用", _remainderCoinNum];
    
    NSString *remainMoneyStr = nil;
    if (_remainderMoney >= [bookOrder.price floatValue]) { // 余额足够支付
        remainMoneyStr =  [NSString stringWithFormat:@"%d元可用", (int)_remainderMoney];
    } else { // 余额不足
        remainMoneyStr = [NSString stringWithFormat:@"余额不足"];
    }
    self.remainMoneyLabel.text = remainMoneyStr;
}

// 设置确认支付按钮状态
- (void)goAppointBtnConfig {
    if (self.moneyIsDeficit) { // 余额不足
        [self.goAppointBtn setTitle:@"请充值" forState:UIControlStateNormal];
        [self.goAppointBtn setBackgroundImage:[UIImage imageNamed:@"sure_appoint_green"] forState:UIControlStateNormal];
        [self.goAppointBtn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.goAppointBtn addTarget:self action:@selector(rechargeClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    else { // 余额充足
        [self.goAppointBtn setTitle:@"确认支付" forState:UIControlStateNormal];
        [self.goAppointBtn setBackgroundImage:[UIImage imageNamed:@"sure_appoint_red"] forState:UIControlStateNormal];
        [self.goAppointBtn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [self.goAppointBtn addTarget:self action:@selector(goAppointClick:) forControlEvents:UIControlEventTouchUpInside];
    }
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

#pragma mark - UITableView
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FOOTVIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    // 取得数据
    XBBookOrder *bookOrder = self.bookOrdersArray[section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FOOTVIEW_HEIGHT)];
//    view.backgroundColor = RGB(246, 246, 246);
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *leftLabel = [[UILabel alloc] init];
    [view addSubview:leftLabel];
    CGFloat leftLabelW = 100;
    CGFloat leftLabelH = 16;
    CGFloat leftLabelX = 18;
    CGFloat leftLabelY = (FOOTVIEW_HEIGHT - leftLabelH)/2;
    leftLabel.frame = CGRectMake(leftLabelX, leftLabelY, leftLabelW, leftLabelH);
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.font = [UIFont systemFontOfSize:14];
    leftLabel.textColor = [UIColor blackColor];
    leftLabel.textAlignment = NSTextAlignmentLeft;
    leftLabel.text = @"选择支付方式";
    
    UIView *bottomLine = [[UIView alloc] init];
    [view addSubview:bottomLine];
    CGFloat bottomLineW = SCREEN_WIDTH;
    CGFloat bottomLineH = 1;
    CGFloat bottomLineX = 0;
    CGFloat bottomLineY = FOOTVIEW_HEIGHT - 1;
    bottomLine.frame = CGRectMake(bottomLineX, bottomLineY, bottomLineW, bottomLineH);
    bottomLine.backgroundColor = RGB(219, 220, 223);
    
    UIImageView *arrowIcon = [[UIImageView alloc] init];
    [view addSubview:arrowIcon];
    CGFloat arrowIconW = 7;
    CGFloat arrowIconH = 12;
    CGFloat arrowIconX = SCREEN_WIDTH - arrowIconW -18;
    CGFloat arrowIconY = (FOOTVIEW_HEIGHT - arrowIconH)/2;
    arrowIcon.frame = CGRectMake(arrowIconX, arrowIconY, arrowIconW, arrowIconH);
    arrowIcon.backgroundColor = [UIColor clearColor];
    [arrowIcon setImage:[UIImage imageNamed:@"arrow_userinfohome"]];
    
    UILabel *payTypeLabel = [[UILabel alloc] init];
    [view addSubview:payTypeLabel];
    CGFloat payTypeLabelW = 80;
    CGFloat payTypeLabelH = leftLabelH;
    CGFloat payTypeLabelX = arrowIconX - payTypeLabelW - 8;
    CGFloat payTypeLabelY = leftLabelY;
    payTypeLabel.frame = CGRectMake(payTypeLabelX, payTypeLabelY, payTypeLabelW, payTypeLabelH);
    payTypeLabel.backgroundColor = [UIColor clearColor];
    payTypeLabel.font = [UIFont systemFontOfSize:14];
    payTypeLabel.textColor = [UIColor blackColor];
    payTypeLabel.textAlignment = NSTextAlignmentRight;
    // 根据订单的payType显示支付方式
    if (bookOrder.payType == payTypeCoupon) {
        payTypeLabel.text = @"学时券";
    }
    else if (bookOrder.payType == payTypeCoin) {
        payTypeLabel.text = @"小巴币";
    }
    else if (bookOrder.payType == payTypeMoney) {
        payTypeLabel.text = @"账户余额";
    }
    
    // 选择支付方式
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:selectBtn];
    selectBtn.frame = view.bounds;
    selectBtn.backgroundColor = [UIColor clearColor];
    selectBtn.tag = section;
    [selectBtn addTarget:self action:@selector(clickForSelectionView:) forControlEvents:UIControlEventTouchUpInside];

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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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

#pragma mark - 接口请求
// 获取可用的账户余额、小巴币、小巴券数目及小巴券列表
- (void) getCanUseCouponList {
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
            // 获取可用小巴币数目
            _validCoinNum = [responseObject[@"coinnum"] intValue];
            _remainderCoinNum = _validCoinNum;
            
            // 获取可用账户余额并保存到本地
            NSString *money = [responseObject[@"money"] description];
            if (![CommonUtil isEmpty:money]) {
                NSMutableDictionary *userInfoDic = [[CommonUtil getObjectFromUD:@"UserInfo"] mutableCopy];
                [userInfoDic setObject:money forKey:@"money"];
                [CommonUtil saveObjectToUD:userInfoDic key:@"UserInfo"];
                _validMoney = [money floatValue];
                _remainderMoney = _validMoney;
            }
            
            // 获取学时券数目
            _couponArray = [responseObject[@"couponlist"] mutableCopy];
            _validCouponNum = (int)_couponArray.count;
            _remainderCouponNum = _validCouponNum;
            if(_couponArray && _couponArray.count > 0){
                if([[responseObject allKeys] containsObject:@"canUseDiff"])
                    self.canUseDiffCoupon = [responseObject[@"canUseDiff"] intValue];
                
                if([[responseObject allKeys] containsObject:@"canUseMaxCount"])
                    self.canUsedMaxCouponCount = [responseObject[@"canUseMaxCount"] intValue];
                
            }
            
            // 配置页面默认支付方式
            [self defaultPayConfig];
            [self.tableView reloadData];
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
        [self makeToast:ERR_NETWORK];
        self.tableView.hidden = YES;
        self.bottomBar.hidden = YES;
    }];
}

- (void)requestBookCoach
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.coachId forKey:@"coachid"];
    
    NSDictionary *studentDic = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *studentId = studentDic[@"studentid"];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:studentDic[@"token"] forKey:@"token"];
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [paramDic setObject:app_Version forKey:@"version"];
    
    // 生成订单相关请求参数
    NSMutableArray *times = [self postParamConfig];
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
        NSString *message = responseObject[@"message"];
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
        }
        else if (code == 4 ) {
            [self makeToast:@"版本太旧,预约失败,请更新至最新版本!"];
        }
        else if (code == 10) {
            [self letoutResultViewWithType:3];
            NSLog(@"book_failed : code = %d  message = %@", code, message);
        }
        else if (code == -1) {
            [self makeToast:@"当前网络繁忙，请稍后再试。"];
        }
        else {
            [self makeToast:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"error == %@", ERR_NETWORK);
        [self makeToast:ERR_NETWORK];
    }];
}

#pragma mark - 订单支付相关
// 配置默认支付方式
- (void)defaultPayConfig {
    int orderNum = (int)self.bookOrdersArray.count; // 总订单数
    int orderIndex = 0; // 订单索引
    XBBookOrder *curBookOrder = nil; // 索引对应的当前订单
    
    if (_validCouponNum >= orderNum) { // 可用学时券数目大于等于订单数
        for (XBBookOrder *bookOrder in self.bookOrdersArray) {
            bookOrder.payType = payTypeCoupon;
            _remainderCouponNum--;
        }
    }
    else {
        // 将_validCouponNum张学时券都用上
        for (orderIndex = 0; orderIndex < _validCouponNum; orderIndex++) {
            XBBookOrder *bookOrder = self.bookOrdersArray[orderIndex];
            bookOrder.payType = payTypeCoupon;
            _remainderCouponNum--;
        }
        
        // 剩余订单默认用小巴币支付
        int coinNeedCost = 0;
        if (_validCoinNum > 0) {
            // 一一提取剩下的订单
            for (; orderIndex < orderNum; orderIndex++) {
                curBookOrder = self.bookOrdersArray[orderIndex];
                coinNeedCost += [curBookOrder.price intValue];
                if (_validCoinNum >= coinNeedCost) { // 当小巴币足以支付剩下订单时
                    curBookOrder.payType = payTypeCoin;
                    _remainderCoinNum -= [curBookOrder.price intValue];
                } else {
                    break;
                }
            }
        }
        
        // 再剩余订单默认用余额支付
        float moneyNeedCost = 0.0;
        for (; orderIndex < orderNum; orderIndex++) {
            curBookOrder = self.bookOrdersArray[orderIndex];
            curBookOrder.payType = payTypeMoney;
            moneyNeedCost += [curBookOrder.price floatValue];
            _remainderMoney -= [curBookOrder.price floatValue];
            if (_validMoney < moneyNeedCost) { // 当余额不足时
                curBookOrder.isDeficit = YES;
            } else {
                curBookOrder.isDeficit = NO;
            }
        }
    }
    [self payDetailStatistics];
}

// 统计订单支付
- (void)payDetailStatistics {
    NSString *payStr = nil;
    
    // 学时券支付统计
    NSString *couponPayStr = @"";
    int useCouponNum = _validCouponNum - _remainderCouponNum;
    int couponCost = 0;
    if (useCouponNum > 0) {
        for (XBBookOrder *bookOrder in self.bookOrdersArray) {
            if (bookOrder.payType == payTypeCoupon) {
                couponCost += [bookOrder.price intValue];
            }
        }
        couponPayStr = [NSString stringWithFormat:@"使用%d张学时券，抵%d元。", useCouponNum, couponCost];
    }
    
    // 小巴币支付统计
    NSString *coinPayStr = @"";
    int useCoinNum = _validCoinNum - _remainderCoinNum;
    int coinCost = 0;
    if (useCoinNum > 0) {
        coinCost = useCoinNum;
        coinPayStr = [NSString stringWithFormat:@"使用%d个小巴币，抵%d元。", useCoinNum, coinCost];
    }
    
    // 余额支付统计
    NSString *moneyPayStr = @"";
    int needMoney = [self.priceSum intValue] - couponCost - coinCost;// 需要用余额支付的数目
    if (_validMoney >= (float)needMoney) { // 余额充足
        if (needMoney > 0) { // 使用到余额支付时
            moneyPayStr = [NSString stringWithFormat:@"使用余额支付%d元。", needMoney];
        }
        self.moneyIsDeficit = NO;
    } else {
        moneyPayStr = [NSString stringWithFormat:@"需用余额支付%d元,余额不足请充值！", needMoney];
        self.moneyIsDeficit = YES;
    }
    
    payStr = [NSString stringWithFormat:@"%@%@%@", couponPayStr, coinPayStr, moneyPayStr];
    
    self.couponCountLabel.text = payStr;
    
    // 根据余额是否足够，改变支付按钮状态
    [self goAppointBtnConfig];
}

// 生成订单请求参数
- (NSMutableArray *)postParamConfig {
    NSMutableArray *times = [NSMutableArray array];
    int couponIndex = 0;
    for (int i = 0; i < self.dateTimeSelectedList.count; i++) {
        NSDictionary *dateDic = self.dateTimeSelectedList[i];
        XBBookOrder *bookOrder = self.bookOrdersArray[i];
        
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
        
        // 支付方式
        NSString *payType = @"0";
        NSString *delMoney = @"0"; // 抵扣金额
        NSString *recordid = @"0"; // 学时券记录id
        // 学时券
        if (bookOrder.payType == payTypeCoupon) {
            NSDictionary *couponDict = self.couponArray[couponIndex];
            int cid = [couponDict[@"recordid"] intValue];
            recordid = [NSString stringWithFormat:@"%d",cid];
            delMoney = [NSString stringWithFormat:@"%d", [bookOrder.price intValue]];
            payType = @"2";
            couponIndex ++;
        }
        // 小巴币
        else if (bookOrder.payType == payTypeCoin) {
            delMoney = [NSString stringWithFormat:@"%d", [bookOrder.price intValue]];
            payType = @"3";
        }
        // 余额
        else if (bookOrder.payType == payTypeMoney) {
            payType = @"1";
        }
        
        [mutableDic setObject:recordid forKey:@"recordid"];
        [mutableDic setObject:delMoney forKey:@"delmoney"];
        [mutableDic setObject:payType forKey:@"paytype"];
        [mutableDic setObject:date forKey:@"date"];
        [mutableDic setObject:array forKey:@"time"];
        [times addObject:mutableDic];
    }
    return times;
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

#pragma mark - Action
- (void)goAppointClick:(id)sender
{
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    float userMoney = [userInfo[@"money"] floatValue];
    float fMoney = [userInfo[@"fmoney"] floatValue];
    if (userMoney < 0) {
        [self makeToast:@"您的账户已欠费!"];
        return;
    }
    if (fMoney < 0) {
        [self makeToast:@"您的冻结金额异常!"];
        return;
    }
    if (_validCoinNum < 0) {
        [self makeToast:@"您的小巴币数额异常!"];
        return;
    }
    if(self.moneyIsDeficit){ // 余额不足
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

- (void)changeTimeClick:(id)sender
{
    [self.appointResultView removeFromSuperview];
    [self backClick:sender];
}

// 充值
- (void)rechargeClick:(id)sender {
    [self.appointResultView removeFromSuperview];
    
    TypeinNumberViewController *viewController = [[TypeinNumberViewController alloc] initWithNibName:@"TypeinNumberViewController" bundle:nil];
    viewController.status = @"1";
    [self.navigationController  pushViewController:viewController animated:YES];
}

- (IBAction)removeResultClick:(id)sender {
    [self.appointResultView removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 弹出选择支付方式view
- (void)clickForSelectionView:(UIButton *)sender {
    // 取得目标订单
    self.targetBookOrder = self.bookOrdersArray[sender.tag];
    // 根据订单配置view
    [self payTypeSelectViewConfig:self.targetBookOrder];
    [self.view addSubview:self.coverBgBtn];
    [self.view addSubview:self.payTypeSelectView];
    [UIView animateWithDuration:0.35 animations:^{
        self.coverBgBtn.alpha = 0.7;
        self.payTypeSelectView.frame = CGRectMake(0, (SCREEN_HEIGHT - SELVIEW_HEIGHT), SCREEN_WIDTH, SELVIEW_HEIGHT);
    }];
}

// 选择支付方式
- (IBAction)choosePayType:(UIButton *)sender {
    if ([sender isEqual:self.selectedBtn]) {
        return;
    }
    else {
        sender.selected = YES;
        self.selectedBtn = sender;
        
        // 改变订单支付方式
        if ([sender isEqual:self.couponSelectBtn]) {
            self.targetBookOrder.payType = payTypeCoupon;
        }
        else if ([sender isEqual:self.coinSelectBtn]) {
            self.targetBookOrder.payType = payTypeCoin;
        }
        else if ([sender isEqual:self.moneySelectBtn]) {
            self.targetBookOrder.payType = payTypeMoney;
        }
        [self clickForHideSelectionView:nil];
    }
}

// 确认并隐藏选择支付方式view
- (IBAction)clickForHideSelectionView:(id)sender {
    // 根据支付方式扣除对应金额
    if (self.targetBookOrder.payType == payTypeCoupon) {
        _remainderCouponNum--;
    }
    else if (self.targetBookOrder.payType == payTypeCoin) {
        _remainderCoinNum -= [self.targetBookOrder.price intValue];
    }
    else if (self.targetBookOrder.payType == payTypeMoney) {
        _remainderMoney -= [self.targetBookOrder.price floatValue];
    }
    
    [UIView animateWithDuration:0.35 animations:^{
        self.coverBgBtn.alpha = 0;
        self.payTypeSelectView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SELVIEW_HEIGHT);
    }completion:^(BOOL finished) {
        [self.coverBgBtn removeFromSuperview];
        [self.payTypeSelectView removeFromSuperview];
    }];
    
    [self.tableView reloadData];
    [self payDetailStatistics];
}


@end
