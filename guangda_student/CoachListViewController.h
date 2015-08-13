//
//  CoachListViewController.h
//  guangda_student
//
//  Created by Dino on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface CoachListViewController : GreyTopViewController

@property (strong, nonatomic) NSDictionary *searchParamDic; // 需要传入的参数
@property (strong, nonatomic) NSString *coachId;

@property (strong, nonatomic) IBOutlet UIView *chooseView;
@property (strong, nonatomic) IBOutlet UIButton *accurateBtnOutlet;     // 精确筛选
@property (strong, nonatomic) IBOutlet UIButton *fuzzyBtnOutlet;        // 模糊筛选

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIImageView *userLogo;           // 用户头像

@property (strong, nonatomic) IBOutlet UIView *chooseCoachTimeView;     // 选择教练的时间view




@end
