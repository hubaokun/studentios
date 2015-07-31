//
//  XBCoin.h
//  guangda_student
//
//  Created by 冯彦 on 15/7/31.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBCoin : NSObject
/*
0=平台
1=驾校
2=教练
3=学员
 */
@property (copy, nonatomic) NSString *addTime;      // 日期
@property (assign, nonatomic) int coinNum;          // 数目
@property (assign, nonatomic) int coinRecordID;     // ???????????
@property (assign, nonatomic) int ownerID;          // 拥有者id
@property (assign, nonatomic) int ownerType;        // 拥有者type
@property (assign, nonatomic) int payerID;          // 支付者id
@property (assign, nonatomic) int payerType;        // 支付者type
@property (assign, nonatomic) int receiverID;       // 接收者id
@property (assign, nonatomic) int receiverType;     // 接收者type
@property (assign, nonatomic) int type;             // ??????????????
@property (assign, nonatomic) BOOL isReceiver;      // 是否为接收者


- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)coinWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)coinsWithArray:(NSArray *)array;

@end
