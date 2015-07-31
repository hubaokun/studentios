//
//  XBCoupon.m
//  guangda_student
//
//  Created by 冯彦 on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XBCoupon.h"

@implementation XBCoupon

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _couponID = [dict[@"couponid"] description];
    }
    return self;
}

+ (instancetype)couponWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)couponsWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = [NSMutableArray array];
    if (array.count > 0) {
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBCoupon couponWithDict:dict]];
        }
    }
    return tempArray;
}

@end
