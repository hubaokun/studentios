//
//  CoachDetailViewController.h
//  guangda_student
//
//  Created by Dino on 15/4/24.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface CoachDetailViewController : GreyTopViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSString *coachId;

@end
