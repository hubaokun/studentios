//
//  MyOrderDetailViewController.h
//  guangda_student
//
//  Created by 冯彦 on 15/3/29.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
#import "DSButton.h"
#import "GuangdaOrder.h"

@interface MyOrderDetailViewController : GreyTopViewController

/* input */
@property (strong, nonatomic) NSString *isSkip;     // 是否弹回到rootView
/* input:订单ID */
@property (copy, nonatomic) NSString *orderid;
/* input:订单type */
@property (assign, nonatomic) OrderType orderType;

@end
