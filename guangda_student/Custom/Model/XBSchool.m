//
//  XBSchool.m
//  guangda_student
//
//  Created by 冯彦 on 15/9/3.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XBSchool.h"

@implementation XBSchool

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _ID = [dict[@"schoolid"] description];
        _name = [dict[@"name"] description];
    }
    return self;
}

+ (instancetype)schoolWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)schoolsWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = nil;
    if (array.count > 0) {
        tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBSchool schoolWithDict:dict]];
        }
    }
    return tempArray;
}

@end
