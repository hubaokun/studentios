//
//  XBBookOrder.h
//  guangda_student
//
//  Created by 冯彦 on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    payTypeCoupon = 0,  // 0:学时券支付
    payTypeCoin,        // 1:小巴币支付
    payTypeMoney        // 2:余额支付
}   BookOrderPayType;
@interface XBBookOrder : NSObject

@property (copy, nonatomic) NSString *date;             // 日期
@property (copy, nonatomic) NSString *addressDetail;    // 详细地址
@property (copy, nonatomic) NSString *price;            // 价格
@property (copy, nonatomic) NSString *subject;          // 科目
@property (copy, nonatomic) NSString *time;             // 时间
@property (assign, nonatomic) BookOrderPayType payType; // 支付方式
@property (assign, nonatomic) BOOL isDeficit;           // 余额是否不足

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)bookOrderWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)bookOrdersWithArray:(NSArray *)array;

@end
