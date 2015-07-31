//
//  GuangdaOrder.m
//  guangda_student
//
//  Created by duanjycc on 15/5/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GuangdaOrder.h"
#import "GuangdaCoach.h"

@implementation GuangdaOrder

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        // 订单信息
        _coach = [GuangdaCoach coachWithDict:dict[@"cuserinfo"]];
        _orderId = dict[@"orderid"];
        _creatTime = dict[@"creat_time"];
        _startTime = dict[@"start_time"];
        _endTime = dict[@"end_time"];
        _detailAddr = [CommonUtil isEmpty:dict[@"detail"]]? @"暂无" : dict[@"detail"];
        _cost = [dict[@"total"] description];
        _minutes = [dict[@"hours"] intValue];
        _hourArray = dict[@"orderprice"];
        _studentState = [dict[@"studentstate"] intValue];
        _coachState = [dict[@"coachstate"] intValue];
        // 按钮信息
        _canComplain = [dict[@"can_complaint"] intValue];
        _needUncomplain = [dict[@"need_uncomplaint"] intValue];
        _canCancel = [dict[@"can_cancel"] intValue];
        _canUp = [dict[@"can_up"] intValue];
        _canDown = [dict[@"can_down"] intValue];
        _canComment = [dict[@"can_comment"] intValue];
    }
    return self;
}

+ (instancetype)orderWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)ordersWithArray:(NSArray *)array
{
    NSMutableArray *outcomeArray = [NSMutableArray array];
    if (array.count > 0) {
        for (NSDictionary *dict in array) {
            [outcomeArray addObject:[GuangdaOrder orderWithDict:dict]];
        }
    }
    return outcomeArray;
}

@end

