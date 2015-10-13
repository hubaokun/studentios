//
//  Consts.h
//  HunBoHuiReqeust_demo
//
//  Created by HapN on 14-10-24.
//  Copyright (c) 2014年 HapN. All rights reserved.
//

#ifndef HunBoHuiReqeust_demo_Consts_h
#define HunBoHuiReqeust_demo_Consts_h

/* 服务器地址 */
//#define REQUEST_HOST   @"http://www.xiaobakaiche.com/dadmin/"    // 正式服
#define REQUEST_HOST   @"http://120.25.236.228/dadmin/"       // 测试服务器
//#define REQUEST_HOST   @"http://192.168.1.103:8080/"       // 胡博
//#define REQUEST_HOST   @"http://192.168.1.188:8080/xb/"       // 卢磊
//#define REQUEST_HOST   @"http://192.168.1.88:8080/xiaoba/"   // 佳瑞
// 道顺
//#define REQUEST_HOST   @"http://192.168.1.113:8080/guangda/"
//#define REQUEST_HOST   @"http://127.0.0.1:8080/guangda"   // 凯哥
//#define REQUEST_HOST   @"http://192.168.2.100:8080/guangda/"  // 测试服120.25.236.228


/* 第三方 */
//新浪微博AppKey
#define kAppKey_Weibo           @"2732734711"
#define kRedirectURI_Weibo      @"https://api.weibo.com/oauth2/default.html"
#define kAppSecret_Weibo        @"28c81a7a16a217322539fd69dbe87655"
//QQ AppID
#define kAppID_QQ               @"1104472861"
//微信 AppID
#define kAppID_Weixin           @"wxa508cf6ae267e0a8"
#define kAppSecret_Weixin       @"56ba2549a60c5d5ffaf6eeb036d26f5f"
//百度 AppKey
//#define kAppKey_Baidu           @"hLR2f2QZeTDuE2g7rFLVo0bc"    //微信版
#define kAppKey_Baidu           @"tf3pVGsiRgGMBjxnaefjNlIt"  //appstore
//蒲公英
#define PGY_APPKEY              @"a3c621d83ef41c7a790a7c070062a9d3"
//坤哥的id 37e76e809d2b7fc7612e14201e55b79a
//饶宏的id a3c621d83ef41c7a790a7c070062a9d3
//老庄的id ac484d6da6021dbfd5eb750827d8c1e4


/* 常用 */
#define ERR_NETWORK             @"当前网络不稳定，请重试！"
#define NO_NETWORK              @"没有连接网络"

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(1.0)]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define _screenWidth [UIScreen mainScreen].bounds.size.width
#define USERDICT [CommonUtil getObjectFromUD:@"UserInfo"]
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] // app版本
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// 颜色
#define CUSTOM_RED RGB(247,100,92)
#define CUSTOM_BLUE RGB(110,197,217)

#endif



