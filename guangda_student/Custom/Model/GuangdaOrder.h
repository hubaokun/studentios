//
//  GuangdaOrder.h
//  guangda_student
//
//  Created by duanjycc on 15/5/20.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, OrderType) {
    OrderTypeUncomplete = 0,    // 未完成订单
    OrderTypeWaitEvaluate,      // 待评价订单
    OrderTypeComplete,          // 已完成订单
    OrderTypeComplained,        // 已投诉订单
};

@class GuangdaCoach;
@interface GuangdaOrder : NSObject

// 教练信息
@property (strong, nonatomic) NSDictionary *coachInfoDict;
@property (strong, nonatomic) GuangdaCoach *coach;

// 订单每小时信息
@property (strong, nonatomic) NSArray *hourArray;

@property (copy, nonatomic) NSString *orderId;      // 订单ID
@property (copy, nonatomic) NSString *creatTime;    // 下单时间
@property (copy, nonatomic) NSString *startTime;    // 任务开始时间
@property (copy, nonatomic) NSString *endTime;      // 任务结束时间
@property (copy, nonatomic) NSString *detailAddr;   // 订单上车地址
@property (copy, nonatomic) NSString *cost;         // 订单总价
@property (copy, nonatomic) NSString *carLicense;   // 牌照
@property (copy, nonatomic) NSString *modelid;      // 准教车型
@property (copy, nonatomic) NSString *subjectName;  // 科目
@property (assign, nonatomic) int minutes;          // 距离订单开始的分钟数
@property (assign, nonatomic) int studentState;     // 学员状态
@property (assign, nonatomic) int coachState;       // 教练状态

@property (assign, nonatomic) int canComplain;      // 订单是否可以投诉 0不可以 1可以
@property (assign, nonatomic) int needUncomplain;   // 订单是否需要取消投诉 0不需要 1需要
@property (assign, nonatomic) int canCancel;        // 订单是否可以取消 0不可以 1可以
@property (assign, nonatomic) int canUp;            // 订单是否可以确认上车 0不可以 1可以
@property (assign, nonatomic) int canDown;          // 订单是否可以确认下车 0不可以 1可以
@property (assign, nonatomic) int canComment;       // 订单是否可以评论 0不可以 1可以

@property (assign, nonatomic) OrderType orderType; // 订单状态

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)orderWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)ordersWithArray:(NSArray *)array;
// 未完成订单
+ (instancetype)unCompleteOrderWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)unCompleteOrdersWithArray:(NSArray *)array;
// 待评价订单
+ (instancetype)waitEvaluateOrderWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)waitEvaluateOrdersWithArray:(NSArray *)array;
// 已完成订单
+ (instancetype)completeOrderWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)completeOrdersWithArray:(NSArray *)array;
// 已投诉订单
+ (instancetype)complainedOrderWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)complainedOrdersWithArray:(NSArray *)array;
@end
