//
//  XBCoupon.h
//  guangda_student
//
//  Created by 冯彦 on 15/7/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBCoupon : NSObject

@property (copy, nonatomic) NSString *couponID;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)couponWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)couponsWithArray:(NSArray *)array;

@end
