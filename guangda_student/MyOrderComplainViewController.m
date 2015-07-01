//
//  MyOrderComplainViewController.m
//  guangda_student
//
//  Created by duanjycc on 15/4/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MyOrderComplainViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "GuangdaOrder.h"
#import "GuangdaCoach.h"
#import "LoginViewController.h"

@interface MyOrderComplainViewController () <UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UILabel *complainReasonLabel;
@property (strong, nonatomic) IBOutlet UITextView *complainTextView;
@property (strong, nonatomic) IBOutlet UILabel *complainPlaceholderLabel;

// 投诉原因选择器
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (nonatomic, strong) IBOutlet UIPickerView *complainReasonPicker;
@property (strong, nonatomic) IBOutlet UIButton *complainReasonConfirmBtn;
@property (strong, nonatomic) NSArray *complainReasonArray;

@property (strong, nonatomic) GuangdaOrder *order;          // 订单
@property (strong, nonatomic) GuangdaCoach *coach;          // 订单信息
@property (strong, nonatomic) NSDictionary *orderInfoDic;   // 订单信息

- (IBAction)clickForSelect:(id)sender;
- (IBAction)clickForCancelSelect:(id)sender;
- (IBAction)clickForComfirmReason:(id)sender;
- (IBAction)clickForCommit:(id)sender;
@end

@implementation MyOrderComplainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
    [self postGetOrderDetail];
}

#pragma mark - 页面设置
- (void)settingView {
    self.selectView.frame = [UIScreen mainScreen].bounds;
    self.complainReasonPicker.dataSource = self;
    self.complainReasonPicker.delegate = self;
    self.complainReasonConfirmBtn.layer.borderWidth = 1;
    self.complainReasonConfirmBtn.layer.borderColor = [RGB(248, 99, 95) CGColor];
    self.complainReasonConfirmBtn.layer.cornerRadius = 4;
    
    [self keyboardHiddenFun];
}

- (void)showData {
    // orderInfo
    self.orderCreateDateLabel.text = self.order.creatTime;
    self.coachNameLabel.text = [NSString stringWithFormat:@"%@ 教练", self.coach.realName];
    self.orderAddrLabel.text = self.order.detailAddr;
    self.costLabel.text = [NSString stringWithFormat:@"%@元(%@元/小时)", self.order.cost, self.coach.price];
    
    NSArray *startTimeArray = [self.order.startTime componentsSeparatedByString:@" "];
    NSString *startDateStr = startTimeArray[0];
    NSString *startTimeStr = [startTimeArray[1] substringToIndex:5];
    NSArray *endTimeArray = [self.order.endTime componentsSeparatedByString:@" "];
    NSString *endTimeStr = [endTimeArray[1] substringToIndex:5];
    if ([endTimeStr isEqualToString:@"00:00"]) {
        endTimeStr = @"24:00";
    }
    self.orderTimeLabel.text = [NSString stringWithFormat:@"%@ %@~%@", startDateStr, startTimeStr, endTimeStr];
    
    // 计算预约地址文字高度
    CGFloat addrStrHeight =  [CommonUtil sizeWithString:self.order.detailAddr fontSize:13 sizewidth:_screenWidth - 105 sizeheight:MAXFLOAT].height;
    self.orderAddrLabelHeightCon.constant = addrStrHeight;
}

#pragma mark - 页面特性
// 点击背景退出键盘
- (void)keyboardHiddenFun {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}
-(void)backupgroupTap:(id)sender {
    [self.complainTextView resignFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.complainPlaceholderLabel.hidden = NO;
    } else {
        self.complainPlaceholderLabel.hidden = YES;
    }
}

#pragma mark - PickerVIew
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.0;
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _complainReasonArray.count;
}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;

    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _screenWidth, 45)];
    
    myView.textAlignment = NSTextAlignmentCenter;
    
    myView.text = _complainReasonArray[row][@"content"];
    
    myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
    
    myView.textColor = [UIColor whiteColor];
    
    myView.backgroundColor = [UIColor clearColor];
    
    return myView;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

#pragma mark - 网络请求
// test
- (void)printDic:(NSDictionary *)responseObject withTitle:(NSString *)title {}

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
            [self printDic:responseObject withTitle:@"订单投诉-订单详细"];
            _orderInfoDic =[responseObject objectForKey:@"orderinfo"];
            [self postGetComplaintReason];
            [self loadData];
            [self showData];
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

// 获取投诉原因
- (void)postGetComplaintReason {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:@"2" forKey:@"type"];
    
    NSString *uri = @"/sorder?action=GetComplaintReason";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        if ([responseObject[@"code"] integerValue] == 1) {
            [self printDic:responseObject withTitle:@"订单投诉-投诉原因"];
            _complainReasonArray =[responseObject objectForKey:@"reasonlist"];
            
        }else {
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
}

// 提交投诉
- (void)postComplaint {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"userid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:@"2" forKey:@"type"];
    [paramDic setObject:_orderid forKey:@"orderid"];
    [paramDic setObject:_complainReasonId forKey:@"reason"];
    [paramDic setObject:_complainContentStr forKey:@"content"];
    
    NSString *uri = @"/sorder?action=Complaint";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self printDic:responseObject withTitle:@"订单投诉-提交"];
            [self makeToast:@"提交成功"];
            [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - 数据处理
// 取得输入数据
- (void)catchInputData {
    _complainContentStr = self.complainTextView.text;
}

- (void)loadData {
    self.order = [GuangdaOrder orderWithDict:_orderInfoDic];
    self.coach = self.order.coach;
}

#pragma mark - 点击事件
// 打开选择页面
- (IBAction)clickForSelect:(id)sender {
    if (self.complainReasonArray.count < 1) {
        [self makeToast:@"未能获取投诉原因"];
        return;
    }
    [self.view addSubview:self.selectView];
}

// 取消选择
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}

// 确认选择
- (IBAction)clickForComfirmReason:(id)sender {
    NSInteger row = [self.complainReasonPicker selectedRowInComponent:0];
    NSString *typeStr = _complainReasonArray[row][@"content"];
    self.complainReasonLabel.text = typeStr;
    _complainReasonId = [NSString stringWithFormat:@"%d", [_complainReasonArray[row][@"setid"] intValue]];
    self.complainReasonLabel.textColor = RGB(80, 204, 141);
    [self.selectView removeFromSuperview];
}

// 提交
- (IBAction)clickForCommit:(id)sender {
    [self catchInputData];
    if ([_complainReasonLabel.text isEqualToString:@"请选择投诉类型"]) {
        [self makeToast:@"请选择投诉原因"];
        return;
    }
    if ([CommonUtil isEmpty:_complainContentStr]) {
        [self makeToast:@"请输入投诉内容"];
        return;
    }
    [self postComplaint];
}

@end
