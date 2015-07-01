//
//  UnfinishedOrderTableViewCell.m
//  guangda_student
//
//  Created by duanjycc on 15/3/31.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "UnfinishedOrderTableViewCell.h"
#import "GuangdaCoach.h"
#import "GuangdaOrder.h"

@implementation UnfinishedOrderTableViewCell

- (void)awakeFromNib {
    _complainBtn.layer.borderWidth = 0.6;
    _complainBtn.layer.borderColor = [RGB(121, 121, 121) CGColor];
    _complainBtn.layer.cornerRadius = 4;
    
    _cancelComplainBtn.layer.cornerRadius = 4;
    
    _cancelOrderBtn.layer.borderWidth = 0.6;
    _cancelOrderBtn.layer.borderColor = [RGB(246, 102, 93) CGColor];
    _cancelOrderBtn.layer.cornerRadius = 4;
    
    _confirmOnBtn.layer.cornerRadius = 4;

    _confirmDownBtn.layer.cornerRadius = 4;
    
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
    GuangdaCoach *coach = self.unfinishedOrder.coach;
    
    // 显示数据
    self.coachNameLabel.text = coach.realName;
    self.learnAddrLabel.text = self.unfinishedOrder.detailAddr;
    self.costLabel.text = [NSString stringWithFormat:@"%@元", self.unfinishedOrder.cost];
    NSArray *startTimeArray = [self.unfinishedOrder.startTime componentsSeparatedByString:@" "];
    NSString *startDateStr = startTimeArray[0];
    NSString *startTimeStr = [startTimeArray[1] substringToIndex:5];
    NSArray *endTimeArray = [self.unfinishedOrder.endTime componentsSeparatedByString:@" "];
    NSString *endTimeStr = [endTimeArray[1] substringToIndex:5];
    if ([endTimeStr isEqualToString:@"00:00"]) {
        endTimeStr = @"24:00";
    }
    self.learnDateLabel.text = startDateStr;
    self.learnTimeLabel.text = [NSString stringWithFormat:@"%@~%@", startTimeStr, endTimeStr];
    
    // button的显示
    if (self.unfinishedOrder.canComplain) { // 可以投诉
        self.complainBtn.hidden = NO;
    } else {
        self.complainBtn.hidden = YES;
    }
    
    if (self.unfinishedOrder.needUncomplain) { // 可以取消投诉
        self.cancelComplainBtn.hidden = NO;
        [self.complainBtn setTitle:@"追加投诉" forState:UIControlStateNormal];
    } else {
        self.cancelComplainBtn.hidden = YES;
        [self.complainBtn setTitle:@"投诉" forState:UIControlStateNormal];
    }
    
    if (self.unfinishedOrder.canCancel) { // 可以取消订单
        self.cancelOrderBtn.hidden = NO;
    } else {
        self.cancelOrderBtn.hidden = YES;
    }
    
    if (self.unfinishedOrder.canUp) { // 可以确认上车
        self.confirmOnBtn.hidden = NO;
    } else {
        self.confirmOnBtn.hidden = YES;
    }
    
    if (self.unfinishedOrder.canDown) { // 可以确认下车
        self.confirmDownBtn.hidden = NO;
    } else {
        self.confirmDownBtn.hidden = YES;
    }
    
    if (self.unfinishedOrder.canComment) { // 可以评论
        self.evaluateBtn.hidden = NO;
    } else {
        self.evaluateBtn.hidden = YES;
    }
    
    if (self.cancelOrderBtn.hidden == YES && self.confirmOnBtn.hidden == YES && self.confirmDownBtn.hidden == YES && self.evaluateBtn.hidden == YES) {
        self.complainBtnRightSpaceCon.constant = 0;
    } else {
        self.complainBtnRightSpaceCon.constant = 80;
    }
    
    // 订单状态文字显示
    int minutes = self.unfinishedOrder.minutes;
    if (minutes > 0) {
        self.statusLabel.textColor = RGB(115, 120, 128);
        if (minutes > 24 * 60) {
            int days = minutes / (24 * 60);
            self.statusLabel.text = [NSString stringWithFormat:@"离学车还有%d天", days];
        } else {
            int hours = minutes / 60;
            int restMinutes = minutes %60;
            self.statusLabel.text = [NSString stringWithFormat:@"离学车还有%d小时%d分", hours, restMinutes];
        }
    }
    else if (minutes == 0) {
        self.statusLabel.textColor = RGB(246, 102, 93);
        self.statusLabel.text = @"订单即将开始";
    }
    else if (minutes == -1) {
        self.statusLabel.textColor = RGB(81, 203, 142);
        self.statusLabel.text = @"正在学车中...";
    }
    else if (minutes == -2) {
        self.statusLabel.textColor = RGB(246, 102, 93);
        self.statusLabel.text = @"等待投诉处理";
    }
    else if (minutes == -3) {
        self.statusLabel.textColor = RGB(246, 102, 93);
        self.statusLabel.text = @"等待确认上车";
    }
    else if (minutes == -4) {
        self.statusLabel.textColor = RGB(246, 102, 93);
        self.statusLabel.text = @"等待确认下车";
    }
}

@end
