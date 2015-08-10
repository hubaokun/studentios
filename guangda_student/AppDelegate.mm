//
//  AppDelegate.m
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AppDelegate.h"
#import "RightViewController.h"
#import "LoginViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <AlipaySDK/AlipaySDK.h>
#import "WeiboSDK.h"
//#import "AlixPayResult.h"
//#import "PartnerConfig.h"
//#import "DataVerifier.h"
#import "MainViewController.h"
#import <PgySDK/PgyManager.h>
#import "MobClick.h"
#import "UIImageView+WebCache.h"

@interface AppDelegate ()
<BMKLocationServiceDelegate, WeiboSDKDelegate,BMKGeoCodeSearchDelegate>
{
    BMKMapManager* _mapManager;
    BMKLocationService *_locService;
    BOOL _advertisementReceived;
}

// 广告
@property (strong, nonatomic) UIView *lunchView;
@property (strong, nonatomic) NSDictionary *advertisementConfig;

@end

@implementation AppDelegate

// 注册通知
- (void)registerRemoteNotification
{
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 注册APNS
    [self registerRemoteNotification];
    
    // 注册微博
//    [WeiboSDK enableDebugMode:YES];
//    [WeiboSDK registerApp:kAppKey_Weibo];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
   
    
//    if (![[CommonUtil currentUtil] isLogin:NO]) {
//        UINavigationController *navi = nil;
//        LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//        navi = [[UINavigationController alloc] initWithRootViewController:viewController];
//        
//        navi.navigationBarHidden = YES;
//        self.window.rootViewController= navi;
//    }else{
//        [self jumpToMainController];
//    }
    
    [self autoLogin];
    
    [self jumpToMainController];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
//    BOOL ret = [_mapManager start:@"dSZ6WetNnUrCgcNkSS35GpGG"  generalDelegate:nil];
    BOOL ret = [_mapManager start:kAppKey_Baidu  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    // Add the navigation controller's view to the window and display.
//    [self.window addSubview:navigationController.view];
    [self startLocation];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //蒲公英
    // 设置用户反馈界面激活方式为三指拖动
    //    [[PgyManager sharedPgyManager] setFeedbackActiveType:kPGYFeedbackActiveTypeThreeFingersPan];
    
    // 设置用户反馈界面激活方式为摇一摇
    //    [[PgyManager sharedPgyManager] setFeedbackActiveType:kPGYFeedbackActiveTypeShake];
    
    [[PgyManager sharedPgyManager] startManagerWithAppId:PGY_APPKEY];
    [[PgyManager sharedPgyManager] setEnableFeedback:NO]; //关闭用户反馈功能
    
    [[PgyManager sharedPgyManager] setThemeColor:[UIColor blackColor]];
    
//    [[PgyManager sharedPgyManager] setShakingThreshold:3.0];//开发者可以自定义摇一摇的灵敏度，默认为2.3，数值越小灵敏度越高。
//    [[PgyManager sharedPgyManager] showFeedbackView];//直接显示用户反馈画面
    
    [[PgyManager sharedPgyManager] checkUpdate];//检查版本更新
    
    //友盟社会化分享与统计
    [MobClick startWithAppkey:@"55bf12f8e0f55a95d7002184" reportPolicy:BATCH   channelId:@"pgy"];
    
    // 广告页面
    [NSThread detachNewThreadSelector:@selector(startRequestAdvertisement) toTarget:self withObject:nil]; // 异步发起网络请求
    while (!_advertisementReceived) { // 阻塞主线程
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    [self showAdvertisment];
    return YES;
}

//在此接收设备号
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //[self addDeviceToken:deviceToken];
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    self.deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    [self autoLogin];
    [self updateUserAddress];
    // NSLog(@"deviceToken:%@", _deviceToken);
    //上传设备信息
    //[self toUploadDeviceInfo];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveTopMessage" object:nil];
    
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"Regist fail%@",error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [BMKMapView willBackGround];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[PgyManager sharedPgyManager] checkUpdate];//检查版本更新
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [BMKMapView didForeGround];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //AudioServicesPlaySystemSound(1007); //系统的通知声音
    // AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);//震动
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReceiveTopMessage" object:nil];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    NSString *message = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alert show];
    //通知更新小红点显示
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveMessageNoRead" object:self];
}


// 跳转主界面
- (void)jumpToMainController {
    [SliderViewController sharedSliderController].LeftVC=[[SideBarViewController alloc] initWithNibName:@"SideBarViewController" bundle:nil];
    [SliderViewController sharedSliderController].RightVC=[[RightViewController alloc] init];
    [SliderViewController sharedSliderController].LeftSContentScale=1.0;
    [SliderViewController sharedSliderController].LeftSOpenDuration=0.3;
    [SliderViewController sharedSliderController].LeftSCloseDuration=0.3;
    [SliderViewController sharedSliderController].LeftSJudgeOffset=[UIScreen mainScreen].bounds.size.width-230.00;
    [SliderViewController sharedSliderController].LeftSContentOffset = 230.0;
    
    UINavigationController *navi = nil;
//    if ([CommonUtil isEmpty:_userid]) {
//        LoginViewController *viewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//        navi = [[UINavigationController alloc] initWithRootViewController:viewController];
//        
//    } else {
    
        navi = [[UINavigationController alloc] initWithRootViewController:[SliderViewController sharedSliderController]];
//    }
    navi.navigationBarHidden = YES;
    self.window.rootViewController= navi;
}

#pragma mark - 第三方url调用
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    
//    NSString *string =[url absoluteString];
//    
//    if ([string hasPrefix:@"wb"])
//    {
//        return [WeiboSDK handleOpenURL:url delegate:self];
//    }
//    else if ([string hasPrefix:@"wx"])
//    {
////        return [WXApi handleOpenURL:url delegate:self];
//    }
//    else if ([string hasPrefix:@"tencent"])
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"QQResp" object:nil];
//        return [TencentOAuth HandleOpenURL:url];
//    }
//    
//    return YES;
//}
//
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSString *string =[url absoluteString];
    if ([string hasPrefix:@"wb"])
    {
//        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    else if ([string hasPrefix:@"wx"])
    {
//        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([string hasPrefix:@"tencent"])
    {
    }
    
    if ([url.host isEqualToString:@"safepay"]) {
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                             NSLog(@"result = %@",resultDic);
//                                             NSString *resultStr = resultDic[@"result"];
                                         }];
        
    }
    return YES;
}

#pragma mark - 定位 BMKLocationServiceDelegate
- (void)startLocation {
    
    //定位 初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    
    /*
     *在打开定位服务前设置
     *指定定位的最小更新距离(米)，默认：kCLDistanceFilterNone
     */
    [BMKLocationService setLocationDistanceFilter:100];
    
    //启动LocationService
    [_locService startUserLocationService];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    _userCoordinate = userLocation.location.coordinate;
    if (_userCoordinate.latitude == 0 || _userCoordinate.longitude == 0) {
        NSLog(@"位置不正确");
        return;
    } else  {
        [_locService stopUserLocationService];
//        [CommonUtil saveObjectToUD:userLocation key:@"userLocation"];
        NSLog(@"userLocation == %@", userLocation);
        _userLocation = userLocation;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"setMapLocation" object:nil];
        NSLog(@"定位成功");
    }
    
//    //发起反向地理编码检索
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = _userCoordinate;
    
    BMKGeoCodeSearch *_geoSearcher = [[BMKGeoCodeSearch alloc] init];
    _geoSearcher.delegate = self;
    BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if (flag) {
        NSLog(@"地理编码检索");
    } else {
    }
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (error == BMK_SEARCH_NO_ERROR) {
        self.locationResult = result;
        
        [self updateUserAddress];
    }
}

- (void) updateUserAddress{
    if(![CommonUtil isEmpty:self.deviceToken] && self.locationResult){
        NSString *provience = self.locationResult.addressDetail.province;
        NSString *city = self.locationResult.addressDetail.city;
        NSString *area = self.locationResult.addressDetail.district;
        
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:[OpenUDID value] forKey:@"openid"];
        [params setObject:@"1" forKey:@"devicetype"];
        [params setObject:@"2" forKey:@"usertype"];
        [params setObject:[NSString stringWithFormat:@"%@%@",version,buildVersion] forKey:@"appversion"];
        [params setObject:provience forKey:@"province"];
        [params setObject:city forKey:@"city"];
        [params setObject:area forKey:@"area"];
        
        
        NSString *uri = @"/system?action=UpdateUserLocation";
        NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        }];
        
    }
}
/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    [_locService stopUserLocationService];
    NSLog(@"定位失败%@", error);
    
//    finishLocation = YES;
//    [self installApp];
}

#pragma mark - 新浪微博回掉
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
        [alert show];
//        [alert release];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *title = NSLocalizedString(@"认证结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        [alert show];
//        [alert release];
    }
    else if ([response isKindOfClass:WBPaymentResponse.class])
    {
        NSString *title = NSLocalizedString(@"支付结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
//        [alert release];
    }
}

//自动登录
- (void)autoLogin {
    
    NSString *username = [CommonUtil getObjectFromUD:@"loginusername"];
    NSString *password = [CommonUtil getObjectFromUD:@"loginpassword"];
    NSString *type = [CommonUtil getObjectFromUD:@"logintype"];
    if ([CommonUtil isEmpty:username] || [CommonUtil isEmpty:type]) {
        return;
    }
    self.flgAutoLogin = YES;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if([@"1" isEqualToString:type]){
        [params setObject:username forKey:@"phone"];
        [params setObject:password forKey:@"password"];
    }
    
    NSString *uri = @"/suser?action=login";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        NSString *code = responseObject[@"code"];
        
        if ([code intValue] == 1) {
            NSDictionary *user = [responseObject objectForKey:@"UserInfo"];
            NSNumber *studentID = user[@"studentid"];
            self.userid = [NSString stringWithFormat:@"%@", studentID];
            [CommonUtil saveObjectToUD:user key:@"UserInfo"];
            // 3秒后在异步线程中上传设备号
            dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
            dispatch_after(time, queue, ^{
                if (![CommonUtil isEmpty:self.deviceToken]) {
                    [self uploadDeviceToken];
                }
            });
        }
        
        self.flgAutoLogin = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"autologincomplete" object:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.flgAutoLogin = NO;
    }];
}

// 上传设备号
- (void)uploadDeviceToken
{
    NSString *userId = self.userid;
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    if (!userId) {
        return;
    }
    [paramDic setObject:userId forKey:@"userid"];
    [paramDic setObject:@"2" forKey:@"usertype"]; // 用户类型 1.教练  2 学员
    [paramDic setObject:@"1" forKey:@"devicetype"]; // 设备类型 0安卓  1IOS
    [paramDic setObject:self.deviceToken forKey:@"devicetoken"];
    NSString *uri = @"/system?action=UpdatePushInfo";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            NSLog(@"上传设备号成功");
        }else{
            NSString *message = responseObject[@"message"];
            NSLog(@"code = %@",  responseObject[@"code"]);
            NSLog(@"message = %@", message);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self makeToast:ERR_NETWORK];
    }];
}

#pragma mark - 广告页相关
//获取是否要使用广告
-(void)startRequestAdvertisement{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *uri = @"/system?action=CHECKCONFIG";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 3;
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *code = [responseObject[@"code"] description];
        if ([code isEqualToString:@"1"]) {
            self.advertisementConfig = responseObject[@"config"];
        }
        // 发送通知取消主线程阻塞
        [self performSelectorOnMainThread:@selector(receivedAdvertisement) withObject:nil waitUntilDone:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelectorOnMainThread:@selector(receivedAdvertisement) withObject:nil waitUntilDone:NO];
    }];
}

// 接收到广告
- (void)receivedAdvertisement {
    _advertisementReceived = YES;
}

// 显示广告页
- (void)showAdvertisment {
    // 如果取得广告页
    if (self.advertisementConfig) {
        NSDictionary *config = self.advertisementConfig;
        NSString *advertisement_flag = [config[@"advertisement_flag"] description];
        if ([advertisement_flag isEqualToString:@"1"]) {
            NSString *advertisement_url = [config[@"advertisement_url"] description];
            self.lunchView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [self.window addSubview:self.lunchView];
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.screen.bounds.size.width, self.window.screen.bounds.size.height)];
            [imageV sd_setImageWithURL:[NSURL URLWithString:advertisement_url] placeholderImage:[UIImage imageNamed:@"default1.jpg"]]; [self.lunchView addSubview:imageV];
            [self.window bringSubviewToFront:self.lunchView];
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLun) userInfo:nil repeats:NO];
        }
    }
    // 未取得
    else {}
}

- (void)removeLun {
    [self.lunchView removeFromSuperview];
}

@end
