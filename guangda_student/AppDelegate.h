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
#import <BaiduMapAPI/BMapKit.h>
#import <BaiduMapAPI/BMKMapManager.h>
#import <BaiduMapAPI/BMKMapView.h>
#import <BaiduMapAPI/BMKLocationService.h>
#import "OpenUDID.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) BOOL flgAutoLogin;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *isregister;
@property (nonatomic, copy) NSString *isInvited;

//用户定位
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (strong, nonatomic) BMKUserLocation *userLocation;

//新浪微博
@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

//设备号
@property (strong, atomic) NSString *deviceToken;
@property (nonatomic, strong) BMKReverseGeoCodeResult *locationResult;

@end

