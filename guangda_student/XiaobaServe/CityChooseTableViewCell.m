//
//  CityChooseTableViewCell.m
//  guangda_student
//
//  Created by 冯彦 on 15/11/17.
//  Copyright © 2015年 daoshun. All rights reserved.
//

#import "CityChooseTableViewCell.h"

@interface CityChooseTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;

@end

@implementation CityChooseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setProvince:(XBProvince *)province {
    _province = province;
    self.cityLabel.text = province.provinceName;
    if (province.citiesArray.count < 2) {
        self.arrowIcon.hidden = YES;
    } else {
        self.arrowIcon.hidden = NO;
    }
}

- (void)setCity:(XBCity *)city {
    _city = city;
    self.cityLabel.text = city.cityName;
    self.arrowIcon.hidden = YES;
}

@end
