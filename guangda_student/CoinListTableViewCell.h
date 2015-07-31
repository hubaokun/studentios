//
//  CoinListTableViewCell.h
//  guangda_student
//
//  Created by Ray on 15/7/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBCoin.h"

@interface CoinListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *orderTitle;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) XBCoin *coin;

- (void)loadData;

@end
