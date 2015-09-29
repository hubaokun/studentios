//
//  OrderListTableViewCell.m
//  guangda_student
//
//  Created by 冯彦 on 15/8/19.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "OrderListTableViewCell.h"
#import "GuangdaCoach.h"

#define CUSTOM_GREY RGB(60, 60, 60)
#define CUSTOM_GREEN RGB(80, 203, 140)
#define BORDER_WIDTH 0.7

@interface OrderListTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;        // 时间
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;        // 日期
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;      // 订单状态
@property (weak, nonatomic) IBOutlet UILabel *coachLabel;       // 教练
@property (weak, nonatomic) IBOutlet UILabel *addrLabel;        // 地址
@property (weak, nonatomic) IBOutlet UILabel *costLabel;        // 金额
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;        // 右边按钮
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;         // 左边按钮

@property (weak, nonatomic) IBOutlet UILabel *cancelOrderBannerLabel; // 等待教练取消订单

@end

@implementation OrderListTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)loadData
{
    // 日期时间
    NSArray *startTimeArray = [self.order.startTime componentsSeparatedByString:@" "];
    NSString *startDateStr = startTimeArray[0];
    NSString *startTimeStr = [startTimeArray[1] substringToIndex:5];
    NSArray *endTimeArray = [self.order.endTime componentsSeparatedByString:@" "];
    NSString *endTimeStr = [endTimeArray[1] substringToIndex:5];
    if ([endTimeStr isEqualToString:@"00:00"]) {
        endTimeStr = @"24:00";
    }
    self.dateLabel.text = startDateStr;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", startTimeStr, endTimeStr];
    
    // 订单状态文字
    [self orderStateTextConfig];
    
    // 教练
    NSString *coachText = nil;
    NSString *nameStr = [NSString stringWithFormat:@"教练: %@", self.order.coach.realName];
    NSString *carStr = nil;
    if ([CommonUtil isEmpty:self.order.carLicense]) {
        coachText =  nameStr;
    } else {
        carStr = [NSString stringWithFormat:@" (%@)", self.order.carLicense];
        coachText = [NSString stringWithFormat:@"%@%@", nameStr, carStr];
    }
    NSMutableAttributedString *coachAttText = [[NSMutableAttributedString alloc] initWithString:coachText];
    if (![CommonUtil isEmpty:self.order.carLicense]) {
       [coachAttText addAttribute:NSForegroundColorAttributeName value:RGB(170, 170, 170) range:NSMakeRange(nameStr.length, carStr.length)];
    }
    self.coachLabel.attributedText = coachAttText;

    
    // 地址
    self.addrLabel.text = [NSString stringWithFormat:@"地址: %@", self.order.detailAddr];
    
    // 金额 科目类型
    NSString *costText = nil;
    NSString *costStr = [NSString stringWithFormat:@"金额: %@", self.order.cost];
    NSString *subjectStr = self.order.subjectName;
    if ([CommonUtil isEmpty:subjectStr]) {
        costText = costStr;
    } else {
        subjectStr = [NSString stringWithFormat:@" (%@)", subjectStr];
        costText = [NSString stringWithFormat:@"%@%@", costStr, subjectStr];
    }
    NSMutableAttributedString *costAttText = [[NSMutableAttributedString alloc] initWithString:costText];
    if (![CommonUtil isEmpty:subjectStr]) {
        [costAttText addAttribute:NSForegroundColorAttributeName value:RGB(170, 170, 170) range:NSMakeRange(costStr.length, subjectStr.length)];
    }
    self.costLabel.attributedText = costAttText;
    
    // 按钮配置
    [self operationBtnsConfig];
    
    // 订单是否正在取消中
    if ((self.order.orderType == OrderTypeUncomplete) && (self.order.studentState == 4) && (self.order.coachState != 4)) {
        self.cancelOrderBannerLabel.hidden = NO;
        self.leftBtn.hidden = YES;
        self.rightBtn.hidden = YES;
    } else {
        self.cancelOrderBannerLabel.hidden = YES;
    }
}

// 订单状态文字配置
- (void)orderStateTextConfig
{
    int minutes = self.order.minutes;
    
    // 未完成订单
    if (self.order.orderType == OrderTypeUncomplete) {
        if (minutes > 0) {
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
            self.statusLabel.text = @"订单即将开始";
        }
        else if (minutes == -1) {
            self.statusLabel.text = @"正在学车中...";
        }
        else if (minutes == -2) {
            self.statusLabel.text = @"等待投诉处理";
        }
        else if (minutes == -3) {
            self.statusLabel.text = @"等待确认上车";
        }
        else if (minutes == -4) {
            self.statusLabel.text = @"等待确认下车";
        }
        
    }
    
    // 待评价订单
    else if (self.order.orderType == OrderTypeWaitEvaluate) {
        self.statusLabel.text = @"学车结束，请评价";
    }
    
    // 已完成订单
    else if (self.order.orderType == OrderTypeComplete) {
        self.statusLabel.text = @"学车完成";
    }
    
    // 待处理订单
    else if (self.order.orderType == OrderTypeAbnormal) {
        if (minutes == -5) {
            self.statusLabel.text = @"投诉处理中...";
        }
        else if (minutes == -6) {
            self.statusLabel.text = @"客服协调中...";
        }
    }
}

// 按钮组配置
- (void)operationBtnsConfig
{
    self.rightBtn.hidden = YES;
    self.leftBtn.hidden = YES;
    
    // 未完成订单
    if (self.order.orderType == OrderTypeUncomplete) {
        if (self.order.canCancel) { // 可以取消订单
            [self cancelOrderBtnConfig:self.rightBtn];
        }
        
        else {
            if (self.order.canUp) { // 可以确认上车
            }
            
            else if (self.order.canDown) { // 可以确认下车
                [self confirmDownBtnConfig:self.rightBtn];
                [self complainBtnConfig:self.leftBtn];
            }
        }
    }
    
    // 待评价订单
    else if (self.order.orderType == OrderTypeWaitEvaluate) {
        // 投诉
        [self complainBtnConfig:self.leftBtn];
        // 评价
        [self eveluateBtnConfig:self.rightBtn];
    }
    
    // 已完成订单
    else if (self.order.orderType == OrderTypeComplete) {
        // 继续预约
        [self bookMoreBtnConfig:self.rightBtn];
    }
    
    // 待处理订单
    else if (self.order.orderType == OrderTypeAbnormal) {
        if (self.order.minutes == -5) { // 投诉订单
            [self cancelComplainBtnConfig:self.rightBtn];
        }
    }
}

#pragma mark - 按钮样式
- (void)btnConfig:(UIButton *)btn
  withBorderWidth:(CGFloat)borderWidth
      borderColor:(CGColorRef)borderColor
     cornerRadius:(CGFloat)cornerRadius
  backgroundColor:(UIColor *)backgroundColor
            title:(NSString *)title
       titleColor:(UIColor *)titleColor
           action:(SEL)action
{
    btn.layer.borderWidth = borderWidth;
    btn.layer.borderColor = borderColor;
    btn.layer.cornerRadius = cornerRadius;
    btn.backgroundColor = backgroundColor;
    btn.hidden = NO;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:titleColor forState:UIControlStateNormal];
    [btn removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

// 取消订单按钮
- (void)cancelOrderBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:BORDER_WIDTH
        borderColor:[CUSTOM_GREY CGColor]
       cornerRadius:4
     backgroundColor:[UIColor whiteColor]
              title:@"取消订单"
         titleColor:CUSTOM_GREY
             action:@selector(cancelOrderClick)];
}

// 确认上车按钮
- (void)confirmOnBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:0
        borderColor:[[UIColor clearColor] CGColor]
       cornerRadius:4
     backgroundColor:CUSTOM_GREEN
              title:@"确认上车"
         titleColor:[UIColor whiteColor]
             action:@selector(confirmOnClick)];
}

// 确认下车按钮
- (void)confirmDownBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:0
        borderColor:[[UIColor clearColor] CGColor]
       cornerRadius:4
    backgroundColor:CUSTOM_GREEN
              title:@"确认下车"
         titleColor:[UIColor whiteColor]
             action:@selector(confirmDownClick)];
}

// 投诉按钮
- (void)complainBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:BORDER_WIDTH
        borderColor:[CUSTOM_GREY CGColor]
       cornerRadius:4
    backgroundColor:[UIColor whiteColor]
              title:@"投诉"
         titleColor:CUSTOM_GREY
             action:@selector(complainClick)];
}

// 取消投诉按钮
- (void)cancelComplainBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:BORDER_WIDTH
        borderColor:[CUSTOM_GREEN CGColor]
       cornerRadius:4
    backgroundColor:[UIColor whiteColor]
              title:@"取消投诉"
         titleColor:CUSTOM_GREEN
             action:@selector(cancelComplainClick)];
}

// 评价按钮
- (void)eveluateBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:0
        borderColor:[[UIColor clearColor] CGColor]
       cornerRadius:4
    backgroundColor:CUSTOM_GREEN
              title:@"立即评价"
         titleColor:[UIColor whiteColor]
             action:@selector(eveluateClick)];
}

// 继续预约按钮
- (void)bookMoreBtnConfig:(UIButton *)btn
{
    [self btnConfig:btn withBorderWidth:BORDER_WIDTH
        borderColor:[CUSTOM_GREEN CGColor]
       cornerRadius:4
    backgroundColor:[UIColor whiteColor]
              title:@"继续预约"
         titleColor:CUSTOM_GREEN
             action:@selector(bookMoreClick)];
}

#pragma mark - 点击事件
// 取消订单
- (void)cancelOrderClick
{
    if ([self.delegate respondsToSelector:@selector(cancelOrder:)]) {
        [self.delegate cancelOrder:self.order];
    }
}

// 确认上车
- (void)confirmOnClick
{
    if ([self.delegate respondsToSelector:@selector(confirmOn:)]) {
        [self.delegate confirmOn:self.order];
    }
}

// 确认下车
- (void)confirmDownClick
{
    if ([self.delegate respondsToSelector:@selector(confirmDown:)]) {
        [self.delegate confirmDown:self.order];
    }
}

// 投诉
- (void)complainClick
{
    if ([self.delegate respondsToSelector:@selector(complain:)]) {
        [self.delegate complain:self.order];
    }
}

// 取消投诉
- (void)cancelComplainClick
{
    if ([self.delegate respondsToSelector:@selector(cancelComplain:)]) {
        [self.delegate cancelComplain:self.order];
    }
}

// 评价
- (void)eveluateClick
{
    if ([self.delegate respondsToSelector:@selector(eveluate:)]) {
        [self.delegate eveluate:self.order];
    }
}

// 继续预约
- (void)bookMoreClick
{
    if ([self.delegate respondsToSelector:@selector(bookMore:)]) {
        [self.delegate bookMore:self.order];
    }
}

@end
