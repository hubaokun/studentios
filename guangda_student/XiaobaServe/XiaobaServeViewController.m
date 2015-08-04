//
//  XiaobaServeViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XiaobaServeViewController.h"
#import "SignUpViewController.h"
#import "ImproveInfoViewController.h"

@interface XiaobaServeViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;

// 页面数据
@property (copy, nonatomic) NSString *cityName;
@property (copy, nonatomic) NSString *provinceID;
@property (copy, nonatomic) NSString *cityID;
@property (copy, nonatomic) NSString *areaID;
@property (copy, nonatomic) NSString *trainingUrl; //模拟培训
@property (copy, nonatomic) NSString *examUrl; //在线约考

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
        ImproveInfoViewController *nextVC = [[ImproveInfoViewController alloc] init];
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
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
//预约考试
- (IBAction)clickForTest:(id)sender {
    if ([CommonUtil isEmpty:self.examUrl]) {
        [self makeToast:@"抱歉，该城市暂未收录"];
        return;
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.examUrl]];
    }
}

//预约培训
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
    ImproveInfoViewController *nextVC = [[ImproveInfoViewController alloc] init];
    [self.navigationController pushViewController:nextVC animated:YES];
}
@end
