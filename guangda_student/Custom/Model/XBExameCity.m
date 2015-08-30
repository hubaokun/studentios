//
//  XBExameCity.m
//  guangda_student
//
//  Created by 冯彦 on 15/8/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XBExameCity.h"

@implementation XBExameCity

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _cityID = [dict[@"cityid"] description];
        _cityName = dict[@"cityname"];
    }
    return self;
}

+ (instancetype)cityWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)citiesWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = nil;
    if (array.count > 0) {
        tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBExameCity cityWithDict:dict]];
        }
    }
    return tempArray;
}

@end
