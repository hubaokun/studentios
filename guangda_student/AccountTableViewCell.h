//
//  AccountTableViewCell.h
//  guangda_student
//
//  Created by Dino on 15/3/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *inOrOut;
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyNum;

- (void)loadData:(NSDictionary *)data;

@end
