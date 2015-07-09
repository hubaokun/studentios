//
//  SelectOtherCouponViewController.h
//  guangda_student
//
//  Created by guok on 15/6/3.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface SelectOtherCouponViewController : GreyTopViewController

@property (strong, nonatomic) NSDictionary *selectedOrderList;

@property (strong, nonatomic) NSMutableArray *couponArray;//小巴券列表,只包括能用的
@property (assign, nonatomic) int canUseDiffCoupon;
@property (assign, nonatomic) int canUsedMaxCouponCount;
@property (strong, nonatomic) NSMutableArray *selectedCoupon;//已经选择了的小巴券
@property (strong, nonatomic) NSString *orderIndex;

- (IBAction)clickForSubmit:(id)sender;

@end
