//
//  CoinListTableViewCell.m
//  guangda_student
//
//  Created by Ray on 15/7/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoinListTableViewCell.h"

@implementation CoinListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)loadData {
    // 时间
    self.timeLabel.text = self.coin.addTime;
    
    // 数目
    NSString *coinNumStr = nil;
    if (self.coin.isReceiver) { // 接收者
        coinNumStr = [NSString stringWithFormat:@"+%d", self.coin.coinNum];
        self.moneyLabel.textColor = [UIColor greenColor];
    } else {
        coinNumStr = [NSString stringWithFormat:@"-%d", self.coin.coinNum];
        self.moneyLabel.textColor = [UIColor redColor];
    }
    self.moneyLabel.text = coinNumStr;
    
    // 描述
    NSString *describeStr = nil;
    if (self.coin.isReceiver) { // 接收者
//        if (self.coin.payerType == 0) {
//            describeStr = [NSString stringWithFormat:@"小巴平台发放"];
//        }
//        else if (self.coin.payerType == 1) {
//            describeStr = [NSString stringWithFormat:@"驾校发放"];
//        } else {
//            describeStr = [NSString stringWithFormat:@"教练发放"];
//        }
        describeStr = [NSString stringWithFormat:@"收到"];
    } else {
        describeStr = [NSString stringWithFormat:@"预约学车支出"];
    }
    self.orderTitle.text = describeStr;
}

@end
