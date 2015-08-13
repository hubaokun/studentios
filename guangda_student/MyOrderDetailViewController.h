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

/* input */
@property (strong, nonatomic) NSString *isSkip;     // 是否弹回到rootView
/* input:订单ID */
@property (copy, nonatomic) NSString *orderid;
/* input:订单type */
@property (assign, nonatomic) int orderType;    // 1:未完成 2:待评价 3:已完成

@end
