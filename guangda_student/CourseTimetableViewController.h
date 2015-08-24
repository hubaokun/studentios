//
//  CourseTimetableViewController.h
//  guangda_student
//
//  Created by 冯彦 on 15/8/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GreyTopViewController.h"
#import "DSButton.h"

@protocol CourseTimetableViewControllerDelegate <NSObject>
// 课时被点击
- (void)timeSelect:(DSButton *)dataBtn;
@end

@interface CourseTimetableViewController : GreyTopViewController

/* input */
@property (strong, nonatomic) NSArray *dateList;
@property (strong, nonatomic) NSString *nowSelectedDate;            // 当前选中的日期
@property (strong, nonatomic) NSMutableArray *dateTimeSelectedList;     // 被选中的时间点的列表  用于传递到下一个界面生成订单

/* output */
@property (assign, nonatomic) CGFloat viewHeight;

@property (weak, nonatomic) id<CourseTimetableViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *timeMutableList;      // 时间点数据数组 用于存储各个时间点的数据 单价、科目、时间

@end
