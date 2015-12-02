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
#import "MobClick.h"
#import "UIImageView+WebCache.h"
#import "RecommendCodeViewController.h"
#import "ActivityViewController.h"

// 微信
#import "WXApi.h"

// 环信
#import "EaseMob.h"
#import "LocalDefine.h"
#import "AppDelegate+EaseMob.h"

#define WX_PAY_ALERT_TAG 10000
@interface AppDelegate ()
<BMKLocationServiceDelegate, WeiboSDKDelegate,BMKGeoCodeSearchDelegate,UIApplicationDelegate, IChatManagerDelegate, WXApiDelegate, UIAlertViewDelegate>
{
    BMKMapManager* _mapManager;
    BMKLocationService *_locService;
    BOOL _advertisementReceived;
    UINavigationController *_navi;
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
    
    // 初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
    //下面这句话不注释就变成环信了= =
    //[self loginStateChange:nil];
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    //设置是否自动登录
    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
    
    
    // 注册APNS
    //    [self registerRemoteNotification];
    
    // 注册微博
    //    [WeiboSDK enableDebugMode:YES];
    //    [WeiboSDK registerApp:kAppKey_Weibo];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // 自动登录
    [self autoLogin];
    
    // 生成地图主页
    [self createMainController];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    //    BOOL ret = [_mapManager start:@"dSZ6WetNnUrCgcNkSS35GpGG"  generalDelegate:nil];
    BOOL ret = [_mapManager start:kAppKey_Baidu  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    // 启用定位服务
    [self startLocation];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //友盟社会化分享与统计
    [MobClick startWithAppkey:@"55bf12f8e0f55a95d7002184" reportPolicy:BATCH channelId:@"pgy"];
    
    // 广告闪屏页
    [NSThread detachNewThreadSelector:@selector(startRequestAdvertisement) toTarget:self withObject:nil]; // 异步发起网络请求
    while (!_advertisementReceived) { // 阻塞主线程
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    [self showAdvertisment];
    
    // 微信注册
    [WXApi registerApp:kAppID_Weixin withDescription:@"小巴学车"];
    
    //微博注册
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey_Weibo];
    
    return YES;
}

//在此接收设备号
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    self.deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
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
    
    //通知更新小红点显示
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveMessageNoRead" object:self];
}


// 生成地图主界面
- (void)createMainController {
    [SliderViewController sharedSliderController].LeftVC=[[SideBarViewController alloc] initWithNibName:@"SideBarViewController" bundle:nil];
    [SliderViewController sharedSliderController].RightVC=[[RightViewController alloc] init];
    [SliderViewController sharedSliderController].LeftSContentScale=1.0;
    [SliderViewController sharedSliderController].LeftSOpenDuration=0.3;
    [SliderViewController sharedSliderController].LeftSCloseDuration=0.3;
    [SliderViewController sharedSliderController].LeftSJudgeOffset=[UIScreen mainScreen].bounds.size.width-230.00;
    [SliderViewController sharedSliderController].LeftSContentOffset = 230.0;
    
    _navi = [[UINavigationController alloc] initWithRootViewController:[SliderViewController sharedSliderController]];
    _navi.navigationBarHidden = YES;
    self.window.rootViewController= _navi;
}

#pragma mark - 第三方url调用
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
//    NSString *string =[url absoluteString];
    
    //    if ([string hasPrefix:@"wb"])
    //    {
    //        return [WeiboSDK handleOpenURL:url delegate:self];
    //    }
    //    else if ([string hasPrefix:@"wx"])
    //    {
    return [WXApi handleOpenURL:url delegate:self];
    //    }
    //    else if ([string hasPrefix:@"tencent"])
    //    {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:@"QQResp" object:nil];
    //        return [TencentOAuth HandleOpenURL:url];
    //    }
    //
    //    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSString *string =[url absoluteString];
    if ([string hasPrefix:@"wb"])
    {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    else if ([string hasPrefix:@"wx"])
    {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([string hasPrefix:@"tencent"])
    {
        return [TencentOAuth HandleOpenURL:url];
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
    _locService.distanceFilter = 100;
    
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
//        NSLog(@"userLocation == %@", userLocation);
        _userLocation = userLocation;
        self.locationPoint = [NSString stringWithFormat:@"%f,%f", _userCoordinate.longitude, _userCoordinate.latitude];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setMapLocation" object:nil];
        NSLog(@"定位成功");
    }
    
    // 发起反向地理编码检索
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
        NSString *locateCityName = result.addressDetail.city;
        self.locateCity = [locateCityName stringByReplacingOccurrencesOfString:@"市" withString:@""]; // 去掉城市名里的“市”
//        [self updateUserAddress];
        NSLog(@"反地理编码 ------  %@",result.address);
    }
}

- (void) updateUserAddress{
    if(![CommonUtil isEmpty:self.deviceToken] && self.locationResult){
        NSString *provience = self.locationResult.addressDetail.province;
        NSString *city = self.locationResult.addressDetail.city;
        NSString *area = self.locationResult.addressDetail.district;
        
        self.locateCity = city;
        
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
//- (void)didFailToLocateUserWithError:(NSError *)error {
//    [_locService stopUserLocationService];
//    NSLog(@"定位失败%@", error);
//}

//- (void)setOpenLocationService:(BOOL)openLocationService{
//    _openLocationService = openLocationService;
//    if (openLocationService) {
//        [_locService startUserLocationService];
//    } else {
//        [_locService stopUserLocationService];
//    }
//}

#pragma mark - 微信支付回调
- (void)onResp:(BaseResp*)resp {
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    NSString *strTitle;
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        [[NSNotificationCenter defaultCenter] postNotificationName:WeixinLogin
                                                            object:authResp];
        
    }else{
        if([resp isKindOfClass:[SendMessageToWXResp class]])
        {
            strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
        }
        if([resp isKindOfClass:[PayResp class]]){
            //支付返回结果，实际支付结果需要去微信服务器端查询
            strTitle = [NSString stringWithFormat:@"支付结果"];
            
            switch (resp.errCode) {
                case WXSuccess:
                    strMsg = @"支付结果：成功！";
//                    NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                    break;
                    
                default:
                    strMsg = [NSString stringWithFormat:@"支付失败！"];
//                    NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                    break;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = WX_PAY_ALERT_TAG;
            [alert show];
        }
    }
}

#pragma mark - 新浪微博回掉
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
//        NSString *title = NSLocalizedString(@"发送结果", nil);
//        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                              otherButtonTitles:nil];
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
        //        [alert show];
        //        [alert release];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
//        NSString *title = NSLocalizedString(@"认证结果", nil);
//        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                              otherButtonTitles:nil];
        
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
        [[NSNotificationCenter defaultCenter] postNotificationName:WeiboLogin
                                                            object:self.wbCurrentUserID];
        //        [alert show];
        //        [alert release];
    }
//    else if ([response isKindOfClass:WBPaymentResponse.class])
//    {
//        NSString *title = NSLocalizedString(@"支付结果", nil);
//        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                              otherButtonTitles:nil];
        //        [alert show];
        //        [alert release];
//    }
}

#pragma mark - 网络请求
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
    params[@"devicetype"] = @"1"; // 设备类型
    params[@"version"] = APP_VERSION; // 版本号
    params[@"ostype"] = @"1"; // 操作平台
    
    NSString *uri = @"/suser?action=login";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *code = responseObject[@"code"];
        if ([code intValue] == 1) {
            
            //登录环信
            [[EMIMHelper defaultHelper] loginEasemobSDK];
            
            NSDictionary *user = [responseObject objectForKey:@"UserInfo"];
            NSNumber *studentID = user[@"studentid"];
            self.userid = [NSString stringWithFormat:@"%@", studentID];
            [CommonUtil saveObjectToUD:user key:@"UserInfo"];
            
            int isregister = [[responseObject objectForKey:@"isregister"] intValue];
            self.isregister = [NSString stringWithFormat:@"%d",isregister];
            int isInvited = [[responseObject objectForKey:@"isInvited"] intValue];
            self.isInvited = [NSString stringWithFormat:@"%d",isInvited];
            
//            if ([self.isInvited integerValue]== 1) {    //1代表未被邀请，0代表已被邀请
//                RecommendCodeViewController *nextController = [[RecommendCodeViewController alloc] initWithNibName:@"RecommendCodeViewController" bundle:nil];
//                [_navi pushViewController:nextController animated:YES];
//            }
            
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
    NSThread *cur = [NSThread currentThread];
    NSLog(@"curThread == %@", cur);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"model"] = @"1"; // 1:ios 2:安卓
    params[@"type"] = @"2"; // 1:教练 2:学员
    params[@"width"] = [NSString stringWithFormat:@"%d", (int)SCREEN_WIDTH * 2]; // 屏幕宽，单位：像素
    params[@"height"] = [NSString stringWithFormat:@"%d", (int)SCREEN_HEIGHT * 2]; // 屏幕高，单位：像素
    NSString *uri = @"/adver?action=GETADVERTISEMENT";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.requestSerializer.timeoutInterval = 3;
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *code = [responseObject[@"code"] description];
        if ([code isEqualToString:@"1"]) {
            self.advertisementConfig = responseObject;
        }
        // 发送通知取消主线程阻塞
        [self performSelectorOnMainThread:@selector(receivedAdvertisement) withObject:nil waitUntilDone:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelectorOnMainThread:@selector(receivedAdvertisement) withObject:nil waitUntilDone:NO];
    }];
}

// 广告接口请求结束
- (void)receivedAdvertisement {
    _advertisementReceived = YES;
}

// 显示广告页
- (void)showAdvertisment {
    // 如果取得广告页
    if (self.advertisementConfig) {
        NSDictionary *config = self.advertisementConfig;
        NSString *s_flash_flag = [config[@"s_flash_flag"] description];
        if ([s_flash_flag isEqualToString:@"1"]) {
            NSString *advertisement_url = [config[@"s_img_ios_flash"] description];
            self.lunchView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [self.window addSubview:self.lunchView];
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.screen.bounds.size.width, self.window.screen.bounds.size.height)];
            [imageV sd_setImageWithURL:[NSURL URLWithString:advertisement_url] placeholderImage:[UIImage imageNamed:@"default1.jpg"]]; [self.lunchView addSubview:imageV];
            [self.window bringSubviewToFront:self.lunchView];
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(removeLun:) userInfo:nil repeats:NO];
        }
    }
    // 未取得
    else {
        
    }
}

// 移除广告页
- (void)removeLun:(NSTimer *)timer {
    [self.lunchView removeFromSuperview];
    self.lunchView = nil;
}

// 弹窗（目前只有微信支付成功了会有该弹窗）
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == WX_PAY_ALERT_TAG) { // 微信支付结束后弹窗
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wxpaycomplete" object:nil];
    }
}

@end
