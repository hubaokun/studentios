//
//  XiaobaServeViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XiaobaServeViewController.h"
#import "SignUpViewController.h"
#import "UserBaseInfoViewController.h"

@interface XiaobaServeViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;

@property (weak, nonatomic) IBOutlet UIView *examView; // 在线约考
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *examViewHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *examViewTopSpaceCon;

@property (weak, nonatomic) IBOutlet UIView *trainingView; // 模拟培训
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trainViewHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trainViewTopSpaceCon;

// 页面数据
@property (copy, nonatomic) NSString *cityName;
@property (copy, nonatomic) NSString *provinceID;
@property (copy, nonatomic) NSString *cityID;
@property (copy, nonatomic) NSString *areaID;
@property (copy, nonatomic) NSString *examUrl; // 在线约考
@property (copy, nonatomic) NSString *trainingUrl; // 模拟培训

@end

@implementation XiaobaServeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cityBtn addTarget:self action:@selector(clickToImproveInfoView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self positionConfirm];
    
}

// 界面设置
- (void)viewConfig {
    if ([CommonUtil isEmpty:self.examUrl]) { // 在线约考未收录
        self.examView.hidden = YES;
        self.examViewHeightCon.constant = 0;
        self.examViewTopSpaceCon.constant = 0;
    } else {
        self.examView.hidden = NO;
        self.examViewHeightCon.constant = 88;
        self.examViewTopSpaceCon.constant = 8;
    }
    
    if ([CommonUtil isEmpty:self.examUrl]) { // 在模拟培训未收录
        self.trainingView.hidden = YES;
        self.trainViewHeightCon.constant = 0;
        self.trainViewTopSpaceCon.constant = 0;
    } else {
        self.trainingView.hidden = NO;
        self.trainViewHeightCon.constant = 88;
        self.trainViewTopSpaceCon.constant = 8;
    }
}

// 确认用户位置信息
- (void)positionConfirm {
    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *position = [userInfo objectForKey:@"locationname"];
    
    if ([CommonUtil isEmpty:position]) { // 未设置驾考城市
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请前往设置您的驾考城市!" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else {
        NSArray *subStrArray = [position componentsSeparatedByString:@"-"];
        if (subStrArray.count > 1) {
            self.cityName = subStrArray[1];
        }
        self.provinceID = [[userInfo objectForKey:@"provinceid"] description];
        self.cityID = [[userInfo objectForKey:@"cityid"] description];
        self.areaID = [[userInfo objectForKey:@"areaid"] description];
        [self.cityBtn setTitle:self.cityName forState:UIControlStateNormal];
        [self postGetServiceUrl];
    }
}

// 点击确认
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (buttonIndex == 1) {
        UserBaseInfoViewController *nextVC = [[UserBaseInfoViewController alloc] init];
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

#pragma mark - 网络请求
// 获取服务url
- (void)postGetServiceUrl {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic[@"provinceid"] = self.provinceID;
    paramDic[@"cityid"] = self.cityID;
    paramDic[@"areaid"] = self.areaID;
    NSString *uri = @"/location?action=GETAUTOPOSITION";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    [DejalBezelActivityView activityViewForView:self.view];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            self.trainingUrl = responseObject[@"simulateUrl"];
            self.examUrl = responseObject[@"bookreceptionUrl"];
            [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
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

#pragma mark - private
- (void)showMainView{
    //    scrollFrame = self.view.frame;
    [self viewConfig];
    CGRect frame = self.mainView.frame;
    frame.size.width = CGRectGetWidth(self.view.frame);
    self.mainView.frame = frame;
    
    [self.mainScrollView addSubview:self.mainView];
    self.mainScrollView.contentSize = CGSizeMake(0, self.footView.frame.origin.y + CGRectGetHeight(self.footView.frame) + 20);
}
//在线报名
- (IBAction)clickForSign:(id)sender {
    if ([[CommonUtil currentUtil] isLogin]) {
        SignUpViewController *nextViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
        nextViewController.comeFrom = 1;
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

//在线约考
- (IBAction)clickForTest:(id)sender {
    if ([CommonUtil isEmpty:self.examUrl]) {
        [self makeToast:@"抱歉，该城市暂未收录"];
        return;
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.examUrl]];
    }
}

//模拟培训
- (IBAction)clickForTrain:(id)sender {
    if ([CommonUtil isEmpty:self.trainingUrl]) {
        [self makeToast:@"抱歉，该城市暂未收录"];
        return;
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.trainingUrl]];
    }
}

// 修改城市
- (void)clickToImproveInfoView {
    UserBaseInfoViewController *nextVC = [[UserBaseInfoViewController alloc] init];
    [self.navigationController pushViewController:nextVC animated:YES];
}
@end
