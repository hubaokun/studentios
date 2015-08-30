//
//  XBExame.m
//  guangda_student
//
//  Created by 冯彦 on 15/8/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XBExame.h"

@implementation XBExame

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _exameName = [dict[@"name"] description];
        _marketPrice = [dict[@"marketprice"] description];
        _xbPrice = [dict[@"xiaobaprice"] description];
    }
    return self;
}

+ (instancetype)exameWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)examesWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = nil;
    if (array.count > 0) {
        tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBExame exameWithDict:dict]];
        }
    }
    return tempArray;
}

@end
