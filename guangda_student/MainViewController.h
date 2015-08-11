//
//  MainViewController.h
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
#import <BaiduMapAPI/BMapKit.h>

@interface MainViewController : GreyTopViewController

@property (strong, nonatomic) BMKMapView *mapView;

@property (strong, nonatomic) BMKUserLocation *userLocation;

+ (MainViewController *)sharedMainController;

@property (strong, nonatomic) NSDictionary *searchParamDic; // 需要传入的参数

@property (strong, nonatomic) IBOutlet UIView *mapContentView;          // 地图view

@property (strong, nonatomic) IBOutlet UIImageView *userLogo;           // 用户头像



@property (strong, nonatomic) NSArray *coachList;               // 教练列表
@property (strong, nonatomic) NSMutableArray *annotationsList;  // 标注数组

// 教练详细信息
@property (strong, nonatomic) IBOutlet UILabel *coachNameLabel;      // 教练姓名
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coachNameLabelWidthCon;
@property (weak, nonatomic) IBOutlet UIImageView *coachGenderIcon;
@property (strong, nonatomic) IBOutlet UILabel *coachAddressLabel;   // 详细地址
@property (strong, nonatomic) NSString *coachId;    // 教练ID

@property (strong, nonatomic) IBOutlet UIView *coachInfoView;       // 教练信息view
@property (strong, nonatomic) IBOutlet UILabel *orderCountLabel; // 总单数
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orderCountLabelWidthCon;

@property (weak, nonatomic) IBOutlet UIScrollView *carModelScrollView;  // uber
@property (strong, nonatomic) IBOutlet UIView *footView;                //底部的view
@property (strong, nonatomic) NSMutableArray *carModelImageViewList;
@property (strong, nonatomic) NSMutableArray *carModelLabelList;

@property (copy, nonatomic) NSString *cityName;

@end
