//
//  HistoricOrderTableViewCell.m
//  guangda_student
//
//  Created by duanjycc on 15/3/31.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "HistoricOrderTableViewCell.h"
#import "GuangdaOrder.h"
#import "GuangdaCoach.h"

@implementation HistoricOrderTableViewCell

- (void)awakeFromNib {
    _complainBtn.layer.borderWidth = 0.6;
    _complainBtn.layer.borderColor = [RGB(121, 121, 121) CGColor];
    _complainBtn.layer.cornerRadius = 4;
    
    _cancelComplainBtn.layer.cornerRadius = 4;
    
    _evaluateBtn.layer.borderWidth = 0.6;
    _evaluateBtn.layer.cornerRadius = 4;
    
    _continueAppointBtn.layer.borderWidth = 0.6;
    _continueAppointBtn.layer.cornerRadius = 4;
    _continueAppointBtn.layer.borderColor = RGB(246, 102, 93).CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadData:(NSDictionary *)dataDic {
    
    // 取得教练数据
    GuangdaCoach *coach = self.historicOrder.coach;
    
    // 显示数据
    self.coachNameLabel.text = coach.realName;
    self.learnAddrLabel.text = self.historicOrder.detailAddr;
    self.costLabel.text = [NSString stringWithFormat:@"%@元", self.historicOrder.cost];
    NSArray *startTimeArray = [self.historicOrder.startTime componentsSeparatedByString:@" "];
    NSString *startDateStr = startTimeArray[0];
    NSString *startTimeStr = [startTimeArray[1] substringToIndex:5];
    NSArray *endTimeArray = [self.historicOrder.endTime componentsSeparatedByString:@" "];
    NSString *endTimeStr = [endTimeArray[1] substringToIndex:5];
    if ([endTimeStr isEqualToString:@"00:00"]) {
        endTimeStr = @"24:00";
    }
    self.learnDateLabel.text = startDateStr;
    self.learnTimeLabel.text = [NSString stringWithFormat:@"%@~%@", startTimeStr, endTimeStr];
    
    // button的显示
    if (self.historicOrder.canComplain) { // 可以投诉
        self.complainBtn.hidden = NO;
    } else {
        self.complainBtn.hidden = YES;
    }
    
    if (self.historicOrder.needUncomplain) { // 可以取消投诉
        self.cancelComplainBtn.hidden = NO;
        [self.complainBtn setTitle:@"追加投诉" forState:UIControlStateNormal];
    } else {
        self.cancelComplainBtn.hidden = YES;
        [self.complainBtn setTitle:@"投诉" forState:UIControlStateNormal];
    }
    
    if (self.historicOrder.canComment) { // 可以评论
        self.evaluateBtn.hidden = NO;
    } else {
        self.evaluateBtn.hidden = YES;
    }
    
    if (self.evaluateBtn.hidden == YES) {
        self.complainBtnRightSpaceCon.constant = 0;
    } else {
        self.complainBtnRightSpaceCon.constant = 80;
    }
}

@end
