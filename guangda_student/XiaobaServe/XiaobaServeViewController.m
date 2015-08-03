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
@property (copy, nonatomic) NSString *cityID;

@end

@implementation XiaobaServeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cityBtn addTarget:self action:@selector(clickToImproveInfoView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self positionConfirm];
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
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
        self.cityID = [[userInfo objectForKey:@"cityid"] description];
        [self.cityBtn setTitle:self.cityName forState:UIControlStateNormal];
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
// 提交账号信息
- (void)postGetServiceUrl {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *uri = @"/xbservice?action=xiaobaservice";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hzti.com:9004/drv_web/index.do"]];
}

//预约培训
- (IBAction)clickForTrain:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://xqc.qc5qc.com/reservation"]];
}

// 修改城市
- (void)clickToImproveInfoView {
    ImproveInfoViewController *nextVC = [[ImproveInfoViewController alloc] init];
    [self.navigationController pushViewController:nextVC animated:YES];
}
@end
