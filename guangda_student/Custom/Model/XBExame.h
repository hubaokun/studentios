//
//  XBExame.h
//  guangda_student
//
//  Created by 冯彦 on 15/8/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBExame : NSObject

@property (copy, nonatomic) NSString *exameName;    // 驾考名
@property (copy, nonatomic) NSString *marketPrice;  // 市场价
@property (copy, nonatomic) NSString *xbPrice;      // 小巴一口价

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)exameWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)examesWithArray:(NSArray *)array;

@end
