//
//  MainViewController.h
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
#import "AppDelegate.h"

@interface MainViewController : GreyTopViewController

/* input */
@property (strong, nonatomic) NSDictionary *searchParamDic; // 需要传入的参数


+ (NSString *)readCarModelID; // 获取车型id

//+ (MainViewController *)sharedMainController;

@end
