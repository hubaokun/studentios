//
//  CityChooseViewController.h
//  guangda_student
//
//  Created by 冯彦 on 15/11/17.
//  Copyright © 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface CityChooseViewController : GreyTopViewController
/* input */
@property (copy, nonatomic) NSString *cityName;
@property (copy, nonatomic) NSString *locationCityName;
@property (copy, nonatomic) NSString *locationCityID;
@property (copy, nonatomic) NSString *cityID;
@property (copy, nonatomic)  void (^backBlock)(NSString *cityName, NSString *cityID);
@end
