//
//  XBExameCity.h
//  guangda_student
//
//  Created by 冯彦 on 15/8/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBExameCity : NSObject

@property (copy, nonatomic) NSString *cityID;
@property (copy, nonatomic) NSString *cityName;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)cityWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)citiesWithArray:(NSArray *)array;

@end
