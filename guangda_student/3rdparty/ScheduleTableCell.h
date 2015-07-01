//
//  ScheduleTableCell.h
//  wedding
//
//  Created by Yuhangping on 14/11/13.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *mainCellView;
@property (strong, nonatomic) IBOutlet UIImageView *scheduleImageView;//轮播图片
@property (strong, nonatomic) IBOutlet UILabel *scheduleTileLabel;//标题标签
@property (strong, nonatomic) IBOutlet UILabel *scheduleTimeLabel;//时间标签
@property (strong, nonatomic) IBOutlet UILabel *schedulePriceLabel;//价格标签
@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UILabel *unitLabel;//单位
@end
