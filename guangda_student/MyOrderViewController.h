//
//  MyOrderViewController.h
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"


@interface MyOrderViewController : GreyTopViewController

@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) UIAlertView *cancelOrderAlert;
@property (copy, nonatomic) NSString *cancelOrderId;
@property (strong, nonatomic) UIAlertView *confirmOnAlert;
@property (strong, nonatomic) UIAlertView *confirmDownAlert;
@property (copy, nonatomic) NSString *confirmOrderId;
@property (strong, nonatomic) NSTimer *confirmTimer;

@end
