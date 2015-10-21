//
//  SureOrderTableViewCell.m
//  guangda_student
//
//  Created by Dino on 15/4/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SureOrderTableViewCell.h"
#import <CoreText/CoreText.h>

@implementation SureOrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadData:(XBBookOrder *)data
{
    XBBookOrder *order = data;
    
    NSString *priceStr = [NSString stringWithFormat:@"%@元", order.price];
    NSString *subjectName = order.subject;
    if (order.isFreeCourse) { // 体验课
        subjectName = [NSString stringWithFormat:@"%@%@", subjectName, @"体验课"];
    }
    NSString *addressDetail = order.addressDetail;
    int timeValue = [order.time intValue];
    
    NSString *timeStr = [NSString stringWithFormat:@"%d:00-%d:00", timeValue, timeValue + 1];
    NSString *subjectStr = [NSString stringWithFormat:@" (%@)", subjectName];
    
    // 时间
    NSMutableAttributedString *timeAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", timeStr, subjectStr]];
    [timeAttr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, timeStr.length)];
    [timeAttr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, timeStr.length)];
    [timeAttr addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(timeStr.length, subjectStr.length)];
    [timeAttr addAttribute:NSForegroundColorAttributeName value:RGB(184, 184, 184) range:NSMakeRange(timeStr.length, subjectStr.length)];
    
    // 地址
//    NSMutableAttributedString *addressAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", addressDetail]];
//    [addressAttr addAttribute:NSForegroundColorAttributeName value:RGB(184, 184, 184) range:NSMakeRange(subject.length, 1)];
//    [addressAttr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, subject.length)];
    
    self.timeLabel.attributedText = timeAttr;
    self.priceLabel.text = priceStr;
//    self.addressDetailLabel.attributedText = addressAttr;
    self.addressDetailLabel.text = addressDetail;
}

@end
