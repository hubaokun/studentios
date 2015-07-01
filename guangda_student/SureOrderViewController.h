//
//  SureOrderViewController.h
//  guangda_student
//
//  Created by Dino on 15/4/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface SureOrderViewController : GreyTopViewController

@property (strong, nonatomic) NSArray *dateTimeSelectedList;
@property (strong, nonatomic) NSString *coachId;
@property (strong, nonatomic) NSString *priceSum;

@property (assign, nonatomic) CGFloat payMoney;
@end
