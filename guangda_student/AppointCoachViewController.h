//
//  AppointCoachViewController.h
//  guangda_student
//
//  Created by Dino on 15/4/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
#import "SwipeView.h"

@interface AppointCoachViewController : GreyTopViewController

/* input */
@property (copy, nonatomic) NSString *carModelID;

@property (strong, nonatomic) NSDictionary *coachInfoDic;
@property (strong, nonatomic) NSString *coachId;

// IBOutlet
@property (strong, nonatomic) IBOutlet UIScrollView *coachTimeScrollView;
@property (strong, nonatomic) IBOutlet UIButton *sureAppointBtn;
@property (strong, nonatomic) IBOutlet SwipeView *swipeView;
@property (strong, nonatomic) IBOutlet UILabel *coachRealName;
@property (strong, nonatomic) IBOutlet UILabel *carAddress;
@property (strong, nonatomic) IBOutlet UIView *coachDetailsTopView; // 教练信息顶部view
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;

// 预约结果view
@property (strong, nonatomic) IBOutlet UIView *appointResultView;
@property (strong, nonatomic) IBOutlet UIImageView *resultImageView;
@property (strong, nonatomic) IBOutlet UILabel *resultStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *resultDetailsLabel;
@property (strong, nonatomic) IBOutlet UIButton *appointResultBtn;
@property (strong, nonatomic) IBOutlet UIView *resultContentView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *resultStatusHeight;

@end
