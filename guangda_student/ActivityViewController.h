//
//  ActivityViewController.h
//  guangda_student
//
//  Created by 冯彦 on 15/8/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface ActivityViewController : GreyTopViewController

@property (copy, nonatomic) NSString *advImageUrl;

- (void)postGetActivityInfo;

@end
