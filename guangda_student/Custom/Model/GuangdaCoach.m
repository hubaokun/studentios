//
//  GuangdaCoach.m
//  guangda_student
//
//  Created by duanjycc on 15/5/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GuangdaCoach.h"

@implementation GuangdaCoach

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _realName = [CommonUtil isEmpty:dict[@"realname"]] ? @"暂无" : dict[@"realname"];
        _tel = [CommonUtil isEmpty:dict[@"tel"]] ? @"暂无" : dict[@"tel"];
        _phone = [CommonUtil isEmpty:dict[@"phone"]] ? @"暂无" : dict[@"phone"];
        _price = [CommonUtil isEmpty:[dict[@"price"] description]] ? @"暂无" : [dict[@"price"] description];
        _score = [dict[@"score"] floatValue];
        _coachid = [dict[@"id"] description];
    }
    return self;
}

+ (instancetype)coachWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

@end
