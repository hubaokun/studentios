//
//  CommentListViewController.h
//  guangda_student
//
//  Created by guok on 15/5/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GreyTopViewController.h"

@interface CommentListViewController : GreyTopViewController<UITabBarDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSString *coachid;
@end
