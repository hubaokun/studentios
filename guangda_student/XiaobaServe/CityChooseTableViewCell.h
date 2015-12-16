//
//  CityChooseTableViewCell.h
//  guangda_student
//
//  Created by 冯彦 on 15/11/17.
//  Copyright © 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBProvince.h"

@interface CityChooseTableViewCell : UITableViewCell
@property (strong, nonatomic) XBProvince *province;
@property (strong, nonatomic) XBCity *city;
@end
