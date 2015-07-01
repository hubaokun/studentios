//
//  HistoricOrderTableViewCell.h
//  guangda_student
//
//  Created by duanjycc on 15/3/31.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSButton.h"
@class GuangdaOrder;

@interface HistoricOrderTableViewCell : UITableViewCell

/* input:已完成订单 */
@property (strong, nonatomic) GuangdaOrder *historicOrder;

@property (strong, nonatomic) IBOutlet UILabel *coachNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *learnDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *learnTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *learnAddrLabel;
@property (strong, nonatomic) IBOutlet UILabel *costLabel;

@property (strong, nonatomic) IBOutlet UIButton *complainBtn;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *complainBtnRightSpaceCon;

@property (strong, nonatomic) IBOutlet UIButton *cancelComplainBtn;

@property (strong, nonatomic) IBOutlet UIButton *evaluateBtn;
@property (weak, nonatomic) IBOutlet DSButton *continueAppointBtn;
- (void)loadData:(NSDictionary *)dataDic;
@end
