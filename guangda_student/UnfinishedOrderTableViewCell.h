//
//  UnfinishedOrderTableViewCell.h
//  guangda_student
//
//  Created by duanjycc on 15/3/31.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSButton.h"
@class GuangdaOrder;

@interface UnfinishedOrderTableViewCell : UITableViewCell

/* input:未完成订单 */
@property (strong, nonatomic) GuangdaOrder *unfinishedOrder;

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
// 取消订单
@property (strong, nonatomic) IBOutlet UIButton *cancelOrderBtn;
// 确认上车
@property (strong, nonatomic) IBOutlet UIButton *confirmOnBtn;
// 确认下车
@property (strong, nonatomic) IBOutlet UIButton *confirmDownBtn;
// 评价
@property (strong, nonatomic) IBOutlet UIButton *evaluateBtn;

- (void)loadData:(NSDictionary *)dataDic;
@end
