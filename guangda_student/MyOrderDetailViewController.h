//
//  MyOrderDetailViewController.h
//  guangda_student
//
//  Created by 冯彦 on 15/3/29.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
#import "DSButton.h"
@class GuangdaOrder;

@interface MyOrderDetailViewController : GreyTopViewController

@property (strong, nonatomic) NSString *isSkip;     // 是否弹回到rootView

/* input:订单ID */
@property (copy, nonatomic) NSString *orderid;

// orderinfo
@property (strong, nonatomic) IBOutlet UIView *orderInfoView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *orderInfoHeightCon;
@property (strong, nonatomic) IBOutlet UILabel *coachNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderCreateDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachTelLabel;
@property (strong, nonatomic) IBOutlet UILabel *coachPhoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderAddrLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *orderAddrLabelHeightCon;
@property (strong, nonatomic) IBOutlet UIView *priceView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *priceViewHeightCon;
@property (strong, nonatomic) IBOutlet UILabel *costLabel;

// btn
@property (strong, nonatomic) IBOutlet UIButton *complainBtn;       // 投诉
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *complainBtnRightSpaceCon;
@property (strong, nonatomic) IBOutlet UIButton *cancelComplainBtn; // 取消投诉
@property (strong, nonatomic) IBOutlet UIButton *cancelOrderBtn;    // 取消订单
@property (strong, nonatomic) IBOutlet UIButton *confirmOnBtn;      // 确认上车
@property (strong, nonatomic) IBOutlet UIButton *confirmDownBtn;    // 确认下车
@property (strong, nonatomic) IBOutlet UIButton *evaluateBtn;       // 评价
@property (weak, nonatomic) IBOutlet DSButton *continueAppointBtn;

// 我对教练的评价
@property (strong, nonatomic) IBOutlet UIView *seperateView1;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *seperateView1HeightCon;
@property (strong, nonatomic) IBOutlet UIView *myEvaluationView;
@property (assign, nonatomic) float scoreToCoach;
@property (copy, nonatomic) NSString *myEvaluationStr;
@property (strong, nonatomic) IBOutlet UILabel *myEvaluationLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreToCoachLabel;

// 教练对我的评价
@property (strong, nonatomic) IBOutlet UIView *seperateView2;
@property (strong, nonatomic) IBOutlet UIView *coachEvaluationView;
@property (assign, nonatomic) float scoreToMe;
@property (copy, nonatomic) NSString *evaluationStr;
@property (strong, nonatomic) IBOutlet UILabel *coachEvaluationLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreToMeLabel;

// 提示框
@property (strong, nonatomic) UIAlertView *confirmOnAlert;
@property (strong, nonatomic) UIAlertView *confirmDownAlert;
@property (strong, nonatomic) NSTimer *confirmTimer;

@end
