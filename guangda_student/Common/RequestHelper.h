//
//  RequestHelper.h
//  wedding
//
//  Created by duanjycc on 14/11/14.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Request_GET @"GET"
#define Request_POST @"POST"

@interface RequestHelper : NSObject

/**
 * uri 请求短地址
 * parameters 请求参数
 * method "GET" "POST"
 */
+ (NSString *)getRequestUrlWithURI:(NSString *)uri Parameters:(NSDictionary *)parameters RequestMethod:(NSString *)method;

/**
 * 获得完整请求参数数据表
 *
 * uri 请求短地址
 * parameters 请求参数
 * method "GET" "POST"
 */
+ (NSDictionary *)getParamsWithURI:(NSString *)uri Parameters:(NSDictionary *)parameters RequestMethod:(NSString *)method;

+ (NSString *)getFullUrl:(NSString *)uri;

@end
