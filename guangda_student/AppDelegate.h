//
//  AppDelegate.h
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderViewController.h"
#import "SideBarViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "OpenUDID.h"

#define APP_DELEGATE ([UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) BOOL flgAutoLogin;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *isregister;
@property (nonatomic, copy) NSString *isInvited;
@property (strong, nonatomic) NSMutableDictionary *searchDict; // 教练搜索条件

// 用户定位
@property (assign, nonatomic) CLLocationCoordinate2D userCoordinate;
@property (strong, nonatomic) BMKUserLocation *userLocation;
@property (copy, nonatomic) NSString *locationPoint;
@property (nonatomic, strong) BMKReverseGeoCodeResult *locationResult; // 反地理编码结果
@property (copy, nonatomic) NSString *locateCity; // 定位到的城市
@property (assign, nonatomic) BOOL openLocationService; // 设为YES开启定位服务，设为NO关闭定位服务

// 新浪微博
@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

// 设备号
@property (strong, atomic) NSString *deviceToken;


@end

