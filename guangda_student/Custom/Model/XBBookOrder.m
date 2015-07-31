//
//  XBBookOrder.m
//  guangda_student
//
//  Created by 冯彦 on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XBBookOrder.h"

@implementation XBBookOrder

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _date = [dict[@"date"] description];
        NSArray *array = dict[@"times"];
        NSDictionary *infoDict = [array lastObject];
        _addressDetail = infoDict[@"addressdetail"];
        NSString *priceStr = [infoDict[@"price"] description];
        _price = [priceStr stringByReplacingOccurrencesOfString:@"元" withString:@""];;
        _subject = infoDict[@"subject"];
        _time = [infoDict[@"time"] description];
        _payType = payTypeCoupon; // 默认为学时券支付
        _isDeficit = NO;
    }
    return self;
}

+ (instancetype)bookOrderWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)bookOrdersWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = [NSMutableArray array];
    if (array.count > 0) {
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBBookOrder bookOrderWithDict:dict]];
        }
    }
    return tempArray;
}

@end
