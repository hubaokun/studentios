//
//  XBBookOrder.h
//  guangda_student
//
//  Created by 冯彦 on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    payTypeCoupon = 1,  // 学时券支付
    payTypeCoin,        // 小巴币支付
    payTypeMoney,       // 余额支付
    payTypeMix          // 小巴币、余额混合支付
}   BookOrderPayType;
@interface XBBookOrder : NSObject

@property (copy, nonatomic) NSString *date;             // 日期
@property (copy, nonatomic) NSString *addressDetail;    // 详细地址
@property (copy, nonatomic) NSString *price;            // 价格
@property (copy, nonatomic) NSString *subject;          // 科目
@property (copy, nonatomic) NSString *time;             // 时间
@property (assign, nonatomic) BOOL needCar;            // 是否需要教练车(陪驾才有用)
@property (assign, nonatomic) int rentalFee;           // 教练车租金(陪驾才有用)
@property (assign, nonatomic) BookOrderPayType payType; // 支付方式
@property (assign, nonatomic) BOOL isDeficit;           // 余额是否不足
@property (assign, nonatomic) NSUInteger delMoney;      // 小巴币支付数目

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)bookOrderWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)bookOrdersWithArray:(NSArray *)array;
+ (NSMutableArray *)bookOrdersWithArray:(NSArray *)array needCar:(int)rentalFee;

@end
