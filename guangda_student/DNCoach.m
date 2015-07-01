//
//  DNCoach.m
//  guangda_student
//
//  Created by 潘启飞 on 15/6/8.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "DNCoach.h"

@implementation DNCoach

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        DNCoach *coach = [[DNCoach alloc] init];
        coach.name = [dict[@"realname"] description];
        coach.phone = [dict[@"phone"] description];
        coach.detail = [dict[@"detail"] description];
        coach.score = [dict[@"score"] description];
        return coach;
    }
    return nil;
}

+ (instancetype)coachWithDict:(NSDictionary *)dict;
{
    return [[DNCoach alloc] initWithDict:dict];
}


//{
//    address = "\U676d\U5dde\U5e02\U83ab\U5e72\U5c71\U8def\U767b\U4e91\U8def\U53e3ii";
//    addtime = "2015-05-15 05:27:02";
//    age = 0;
//    avatar = 16;
//    avatarurl = "http://120.25.236.228:8080/upload/20150515/054020794_7.jpg";
//    birthday = "1915-06-01";
//    cancancel = 0;
//    "car_cardexptime" = "2016-05-15";
//    "car_cardnum" = 6273737474747477;
//    "car_cardpicb" = 14;
//    "car_cardpicf" = 13;
//    carlicense = 72727273737;
//    carmodelid = 4;
//    city = "\U6d59\U6c5f\U7701  \U676d\U5dde\U5e02";
//    "coach_cardexptime" = "2020-05-15";
//    "coach_cardnum" = 72737373737;
//    "coach_cardpic" = 11;
//    coachid = 5;
//    couponhour = 0;
//    detail = "\U6d59\U6c5f\U7701\U676d\U5dde\U5e02\U897f\U6e56\U533a\U6587\U4e00\U8def256\U53f7";
//    "drive_cardexptime" = "2024-05-15";
//    "drive_cardnum" = 72737373782;
//    "drive_cardpic" = 12;
//    "drive_school" = "\U676d\U5dde\U957f\U6c5f\U9a7e\U6821";
//    "drive_schoolid" = 3;
//    fmoney = 500;
//    gender = 1;
//    gmoney = 500;
//    "id_cardexptime" = "2021-05-15";
//    "id_cardnum" = 410581198810019079;
//    "id_cardpicb" = 10;
//    "id_cardpicf" = 9;
//    isfrozen = 0;
//    isquit = 0;
//    latitude = "30.295312";
//    level = 0;
//    longitude = "120.134597";
//    modelid = 10;
//    money = 100030;
//    newtasknoti = 0;
//    password = e10adc3949ba59abbe56e057f20f883e;
//    phone = 18258124488;
//    price = 51;
//    realname = "\U90ed\U51ef\U5929\U5929\U542c";
//    realpic = 15;
//    score = 0;
//    selfeval = "j\U5c31\U662f\U4efb\U6027\U5929\U5929\U5929\U5929\U5929\U5929\U5929";
//    state = 2;
//    subjectdef = 3;
//    telphone = "182 5812 4486";
//    totaltime = 0;
//    "urgent_person" = "\U90ed\U51ef";
//    "urgent_phone" = "185 2395 7465";
//    years = 0;
//}

@end
