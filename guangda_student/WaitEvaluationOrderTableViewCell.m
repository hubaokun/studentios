//
//  WaitEvaluationOrderTableViewCell.m
//  guangda_student
//
//  Created by duanjycc on 15/4/3.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "WaitEvaluationOrderTableViewCell.h"
#import "GuangdaCoach.h"
#import "GuangdaOrder.h"

@implementation WaitEvaluationOrderTableViewCell

- (void)awakeFromNib {
    _complainBtn.layer.borderWidth = 0.6;
    _complainBtn.layer.borderColor = [RGB(121, 121, 121) CGColor];
    _complainBtn.layer.cornerRadius = 4;
    
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
    GuangdaCoach *coach = self.waitEvaluationOrder.coach;
    
    self.complainBtn.hidden = YES; //在外面把投诉按钮隐藏
    
    // 显示数据
    self.coachNameLabel.text = coach.realName;
    self.learnAddrLabel.text = self.waitEvaluationOrder.detailAddr;
    self.costLabel.text = [NSString stringWithFormat:@"%@元", self.waitEvaluationOrder.cost];
    NSArray *startTimeArray = [self.waitEvaluationOrder.startTime componentsSeparatedByString:@" "];
    NSString *startDateStr = startTimeArray[0];
    NSString *startTimeStr = [startTimeArray[1] substringToIndex:5];
    NSArray *endTimeArray = [self.waitEvaluationOrder.endTime componentsSeparatedByString:@" "];
    NSString *endTimeStr = [endTimeArray[1] substringToIndex:5];
    if ([endTimeStr isEqualToString:@"00:00"]) {
        endTimeStr = @"24:00";
    }
    self.learnDateLabel.text = startDateStr;
    self.learnTimeLabel.text = [NSString stringWithFormat:@"%@~%@", startTimeStr, endTimeStr];
}

@end
