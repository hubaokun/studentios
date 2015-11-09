//
//  XiaobaServeViewController.h
//  guangda_student
//
//  Created by Ray on 15/7/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface XiaobaServeViewController : GreyTopViewController
@property (strong, nonatomic) IBOutlet UIButton *ServeBtn;
@property (copy, nonatomic) void (^showLeftSideBlock)();
@end
