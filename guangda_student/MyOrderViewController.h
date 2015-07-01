//
//  MyOrderViewController.h
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

typedef enum {
    unCompleteOrder = 0,    // 0:未完成订单
    waitEvaluationOrder,    // 1:待评价订单
    completeOrder           // 2:已完成订单
} myOrderType;

@interface MyOrderViewController : GreyTopViewController

@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) UIAlertView *cancelOrderAlert;
@property (copy, nonatomic) NSString *cancelOrderId;
@property (strong, nonatomic) UIAlertView *confirmOnAlert;
@property (strong, nonatomic) UIAlertView *confirmDownAlert;
@property (copy, nonatomic) NSString *confirmOrderId;
@property (strong, nonatomic) NSTimer *confirmTimer;

@end
