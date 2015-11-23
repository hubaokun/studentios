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
#import "SliderViewController.h"
#import "XBWebViewController.h"
#import "CityChooseViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

#import "EMIMHelper.h"
#import "ChatViewController.h"

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
@property (copy, nonatomic) NSString *locationCityName;
@property (copy, nonatomic) NSString *locationCityID;
@property (copy, nonatomic) NSString *provinceID;
@property (copy, nonatomic) NSString *cityID;
@property (copy, nonatomic) NSString *areaID;
@property (copy, nonatomic) NSString *examUrl; // 在线约考
@property (copy, nonatomic) NSString *trainingUrl; // 模拟培训

@end

@implementation XiaobaServeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cityBtn addTarget:self action:@selector(clickToCityChooseView) forControlEvents:UIControlEventTouchUpInside];
    [self.ServeBtn addTarget:self action:@selector(chatItemAction) forControlEvents:UIControlEventTouchUpInside];
    [self postGetServeUrlAndCity];
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

#pragma mark - 网络请求
// 获取服务url
- (void)postGetServeUrlAndCity {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    if (![CommonUtil isEmpty:self.cityID]) {
        paramDic[@"cityid"] = self.cityID;
    }
    AppDelegate *app = APP_DELEGATE;
    paramDic[@"pointcenter"] = app.pointCenter;
    
    NSString *uri = @"/location?action=getAddressUrl";
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
            self.cityName = responseObject[@"cityname"];
            if ([CommonUtil isEmpty:self.locationCityName]) {
                self.locationCityName = self.cityName;
            }
            self.cityID = [responseObject[@"cityid"] description];
            if ([CommonUtil isEmpty:self.locationCityID]) {
                self.locationCityID = self.cityID;
            }
//            [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
            [self showMainView];
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
    [self viewConfig];
    CGRect frame = self.mainView.frame;
    frame.size.width = CGRectGetWidth(self.view.frame);
    self.mainView.frame = frame;
    
    [self.mainScrollView addSubview:self.mainView];
    self.mainScrollView.contentSize = CGSizeMake(0, self.footView.frame.origin.y + CGRectGetHeight(self.footView.frame) + 20);
    
    [self.cityBtn setTitle:self.cityName forState:UIControlStateNormal];
}

#pragma mark - Action
//小巴商城
- (IBAction)clickForMall:(id)sender {
    XBWebViewController *nextVC = [[XBWebViewController alloc] initWithNibName:@"XBWebViewController" bundle:nil];
    nextVC.titleStr = @"小巴商城";
    nextVC.mainUrl = @"http://shop13287486.wxrrd.com";
    [[SliderViewController sharedSliderController].navigationController pushViewController:nextVC animated:YES];
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

// 更改城市
- (void)clickToCityChooseView {
    CityChooseViewController *nextVC = [[CityChooseViewController alloc] init];
    nextVC.cityName = self.cityName;
    nextVC.locationCityName = self.locationCityName;
    nextVC.locationCityID = self.locationCityID;
    nextVC.cityID = self.cityID;
    nextVC.backBlock = ^(NSString *cityName, NSString *cityID) {
        if (![self.cityID isEqualToString:cityID]) {
            self.cityName = cityName;
            self.cityID = cityID;
            [self postGetServeUrlAndCity];
        }
    };
    [[SliderViewController sharedSliderController].navigationController pushViewController:nextVC animated:YES];
}


- (IBAction)showSideBarClick:(id)sender {
    if (self.showLeftSideBlock) {
        self.showLeftSideBlock();
    }
}

#pragma mark - Chat
- (void)chatItemAction
{
    if ([[CommonUtil currentUtil] isLogin:NO]) {
        [self chatAction:nil];
    } else {
        LoginViewController *nextVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        nextVC.afterLoginBlock = ^(){
            [self chatAction:nil];
        };
        [[SliderViewController sharedSliderController].navigationController pushViewController:nextVC animated:YES];
    }
}

- (void)chatAction:(NSNotification *)notification
{
    [[EMIMHelper defaultHelper] loginEasemobSDK];
    NSString *cname = [[EMIMHelper defaultHelper] cname];
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:cname isGroup:NO];
    chatController.title = @"在线客服";
    if (notification.object) {
        chatController.commodityInfo = (NSDictionary *)notification.object;
    }
    [[SliderViewController sharedSliderController].navigationController pushViewController:chatController animated:YES];
    [SliderViewController sharedSliderController].navigationController.navigationBarHidden = NO;
}

#pragma mark - 废弃
// 确认用户位置信息
//- (void)positionConfirm {
//    NSDictionary *userInfo = [CommonUtil getObjectFromUD:@"UserInfo"];
//    NSString *position = [userInfo objectForKey:@"locationname"];
//
//    if ([CommonUtil isEmpty:position]) { // 未设置驾考城市
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请前往设置您的驾考城市!" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alert show];
//    }
//    else {
//        NSArray *subStrArray = [position componentsSeparatedByString:@"-"];
//        if (subStrArray.count > 1) {
//            self.cityName = subStrArray[1];
//        }
//        self.provinceID = [[userInfo objectForKey:@"provinceid"] description];
//        self.cityID = [[userInfo objectForKey:@"cityid"] description];
//        self.areaID = [[userInfo objectForKey:@"areaid"] description];
//        [self.cityBtn setTitle:self.cityName forState:UIControlStateNormal];
//        [self postGetServiceUrl];
//    }
//}
//
//// 点击确认
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    if (buttonIndex == 1) {
//        UserBaseInfoViewController *nextVC = [[UserBaseInfoViewController alloc] init];
//        [self.navigationController pushViewController:nextVC animated:YES];
//    }
//}

//- (void)postGetServiceUrl {
//    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
//    paramDic[@"provinceid"] = self.provinceID;
//    paramDic[@"cityid"] = self.cityID;
//    paramDic[@"areaid"] = self.areaID;
//    NSString *uri = @"/location?action=GETAUTOPOSITION";
//    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
//    [DejalBezelActivityView activityViewForView:self.view];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//
//        [DejalBezelActivityView removeViewAnimated:YES];
//
//        int code = [responseObject[@"code"] intValue];
//        if (code == 1) {
//            self.trainingUrl = responseObject[@"simulateUrl"];
//            self.examUrl = responseObject[@"bookreceptionUrl"];
//            [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
//        }else{
//            NSString *message = responseObject[@"message"];
//            [self makeToast:message];
//        }
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [DejalBezelActivityView removeViewAnimated:YES];
//        NSLog(@"连接失败");
//        [self makeToast:ERR_NETWORK];
//    }];
//}

//在线报名
//- (IBAction)clickForSign:(id)sender {
//    if ([[CommonUtil currentUtil] isLogin]) {
//        SignUpViewController *nextVC = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
//        nextVC.comeFrom = 1;
//        [self.navigationController pushViewController:nextViewController animated:YES];
//        [[SliderViewController sharedSliderController].navigationController pushViewController:nextVC animated:YES];
//    }
//}

//// 修改城市
//- (void)clickToImproveInfoView {
//    UserBaseInfoViewController *nextVC = [[UserBaseInfoViewController alloc] init];
////    [self.navigationController pushViewController:nextVC animated:YES];
//    [[SliderViewController sharedSliderController].navigationController pushViewController:nextVC animated:YES];
//}
@end
