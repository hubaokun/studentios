//
//  XBCoin.m
//  guangda_student
//
//  Created by 冯彦 on 15/7/31.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XBCoin.h"

@implementation XBCoin

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _addTime = [dict[@"addtime"] description];
        _coinNum = [dict[@"coinnum"] intValue];
        _coinRecordID = [dict[@"coinrecordid"] intValue];
        _ownerID = [dict[@"ownerid"] intValue];
        _ownerType = [dict[@"ownertype"] intValue];
        _payerID = [dict[@"payerid"] intValue];
        _payerType = [dict[@"payertype"] intValue];
        _receiverID = [dict[@"receiverid"] intValue];
        _receiverType = [dict[@"receivertype"] intValue];
        _receiverID = [dict[@"receiverid"] intValue];
        _receiverType = [dict[@"receivertype"] intValue];
        _type = [dict[@"type"] intValue];
        
        // 判断自己是否为接收者
        NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
        if ([studentId intValue] == _receiverID && _receiverType == 3) {
            _isReceiver = YES;
        } else {
            _isReceiver = NO;
        }
        
    }
    return self;
}

+ (instancetype)coinWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)coinsWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = [NSMutableArray array];
    if (array.count > 0) {
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBCoin coinWithDict:dict]];
        }
    }
    return tempArray;
}

@end
