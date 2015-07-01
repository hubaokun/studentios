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
//#import "AlixPayResult.h"
//#import "PartnerConfig.h"
//#import "DataVerifier.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    [self jumpToMainController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QQResp" object:nil];
        return [TencentOAuth HandleOpenURL:url];
    }
    
    return YES;
}

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
//        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"QQResp" object:nil];
//        NSDictionary *paramDic = [MyKit GetUriParametersWithUrl:[url absoluteString]];
//        NSInteger code = [[paramDic objectForKey:@"error"] integerValue];
//        [self shareResultsWithStatus:(code == 0 ? 1 : 0)];
//        NSLog(@"分享到 QQ(QQ空间) %@!",code == 0?@"成功":@"失败");
        return [TencentOAuth HandleOpenURL:url];
    }
    
    if ([url.host isEqualToString:@"safepay"]) {
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                             NSLog(@"result = %@",resultDic);
                                             NSString *resultStr = resultDic[@"result"];
                                         }];
        
    }
//    if([string hasPrefix:@"alisdkdemo12345"])
//    {
//        [self parse:url application:application];
//        return YES;
//    }


    
    return YES;
}

//- (void)parse:(NSURL *)url application:(UIApplication *)application {
//    
//    //结果处理
//    //结果处理
//    AlixPayResult* result = [self handleOpenURL:url];
//    
//    if (result)
//    {
//        
//        if (result.statusCode == 9000)
//        {
//            
//            /*
//             *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
//             */
//            
//            //交易成功
//            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
//            id<DataVerifier> verifier;
//            verifier = CreateRSADataVerifier(key);
//            
//            if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                //验证签名成功，交易结果无篡改
//                //征集的场合
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"PaySuccess" object:nil];
//            }
//        }
//        else
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"PayFail" object:result.statusMessage];
//            //交易失败
//        }
//    }
//    else
//    {
//        //失败
//    }
//}
//
//- (AlixPayResult *)resultFromURL:(NSURL *)url {
//    NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//#if ! __has_feature(objc_arc)
//    return [[[AlixPayResult alloc] initWithString:query] autorelease];
//#else
//    return [[AlixPayResult alloc] initWithString:query];
//#endif
//}
//
//- (AlixPayResult *)handleOpenURL:(NSURL *)url {
//    AlixPayResult * result = nil;
//    
//    if (url != nil && [[url host] compare:@"safepay"] == 0) {
//        result = [self resultFromURL:url];
//    }
//    
//    return result;
//}




@end
