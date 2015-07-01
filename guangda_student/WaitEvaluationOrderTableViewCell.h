//
//  WaitEvaluationOrderTableViewCell.h
//  guangda_student
//
//  Created by duanjycc on 15/4/3.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSButton.h"
@class GuangdaOrder;

@interface WaitEvaluationOrderTableViewCell : UITableViewCell

/* input:待评价订单 */
@property (strong, nonatomic) GuangdaOrder *waitEvaluationOrder;

@property (strong, nonatomic) IBOutlet UILabel *coachNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *learnDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *learnTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *learnAddrLabel;
@property (strong, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet DSButton *continueAppointBtn;

// 投诉
@property (strong, nonatomic) IBOutlet UIButton *complainBtn;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *complainBtnRightSpaceCon;

// 取消投诉
@property (strong, nonatomic) IBOutlet UIButton *cancelComplainBtn;

// 评价
@property (strong, nonatomic) IBOutlet UIButton *evaluateBtn;

//@property (assign, nonatomic) int status; // 0:已学习 1:已付款
//@property (assign, nonatomic) int evaluateStatus; // 0:未评价 1:已评价

- (void)loadData:(NSDictionary *)dataDic;
@end
