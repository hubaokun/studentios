//
//  RequestHelper.m
//  wedding
//
//  Created by duanjycc on 14/11/14.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import "RequestHelper.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"
#import "base64.h"

@implementation RequestHelper

+ (NSString *)getFullUrl:(NSString *)uri {
    NSString* url= [NSString stringWithFormat:@"%@%@",REQUEST_HOST, uri];
    NSLog(@"%@",url)
    return url;
}

+ (NSDictionary *)getParamsWithURI:(NSString *)uri Parameters:(NSDictionary *)parameters RequestMethod:(NSString *)method {
    NSMutableDictionary *reqParams = [NSMutableDictionary dictionary];
    if (parameters) {
        [reqParams addEntriesFromDictionary:parameters];
    }
    
    [reqParams addEntriesFromDictionary:[RequestHelper getDefaultParameters]];
//    [reqParams setObject:[RequestHelper getAppUsignWithParamters:reqParams URI:uri Method:method] forKey:@"app_usign"];
    
//    NSArray *allkeys = reqParams.allKeys;
//    for (int i=0; i<[allkeys count]; i++) {
//        NSString *key = [allkeys objectAtIndex:i];
//        NSString *value = [reqParams objectForKey:key];
//        [reqParams setObject:[RequestHelper encodeURL:value] forKey:key];
//    }
    
    return reqParams;
}

+ (NSString *)getRequestUrlWithURI:(NSString *)uri Parameters:(NSMutableDictionary *)parameters RequestMethod:(NSString *)method {
    if (!parameters) {
        parameters = [NSMutableDictionary dictionary];
    } else {
        if (![parameters isKindOfClass:[NSMutableDictionary class]]) {
            parameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        }
    }
    
    [parameters addEntriesFromDictionary:[RequestHelper getDefaultParameters]];
//    [parameters setObject:[RequestHelper getAppUsignWithParamters:parameters URI:uri Method:method] forKey:@"app_usign"];

    if ([method isEqualToString:@"POST"]) {
        return [NSString stringWithFormat:@"%@%@",REQUEST_HOST, uri];
    } else {
        NSMutableString *sortString = [NSMutableString string];
        NSArray *allkeys = parameters.allKeys;
        for (int i=0; i<[allkeys count]; i++) {
            NSString *key = [allkeys objectAtIndex:i];
            NSString *value = [parameters objectForKey:key];

            [sortString appendFormat:@"%@=%@",key,[RequestHelper encodeURL:value]];
            if (i < [allkeys count]-1) {
                [sortString appendString:@"&"];
            }
        }
        if ([uri rangeOfString:@"?"].location == NSNotFound)
        {
            return [NSString stringWithFormat:@"%@%@?%@",REQUEST_HOST, uri, sortString];
        }else{
            return [NSString stringWithFormat:@"%@%@&%@",REQUEST_HOST, uri, sortString];
        }
    }
}


#pragma mark - private
/*
 *每个请求的默认请求参数
 *
 *  params:
 *
 *  app_id:协定的app id
 *  client_timestamp:当前时间戳
 *  client_version:app当前版本号
 *  client_guid:每个客户端申请的唯一ID(客户端静默注册)
 *  access_token:用户访问凭证token(用户登录后所有请求都需要带此参数）
 *
 */
+ (NSDictionary *)getDefaultParameters{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
//    [params setObject:APP_ID forKey:@"app_id"];
//    
//    NSString *timeInterval = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
//    [params setObject:timeInterval forKey:@"client_timestamp"];
//    
//    [params setObject:APP_VERSION forKey:@"client_version"];
//    
//    NSString *client_id = [CommonUtil getObjectFromUD:@"client_id"];
//    if (![CommonUtil isEmpty:client_id]) {
//        [params setObject:client_id forKey:@"client_guid"];
//    }
    //用户ID
    NSString *userid = [[CommonUtil currentUtil] getLoginUserid];
    if (![CommonUtil isEmpty:userid]) {
        [params setObject:userid forKey:@"userid"];
    }
    
    return params;
}

/*-----------------------------生成签名值步骤------------------------------------------------
 *-----------------------------------------------------------------------------------------
 *生成签名值
 */
//+ (NSString *)getAppUsignWithParamters:(NSDictionary *)parameters URI:(NSString *)string Method:(NSString *)requestMethod {
//    NSString *uri = [RequestHelper encodeURL:string];
//    NSArray *allKeys = [parameters allKeys];
//    NSMutableArray *keys = [NSMutableArray arrayWithArray:allKeys];
//    for (NSString *key in allKeys) {
//        if ([RequestHelper deleteKey:key]) {
//            [keys removeObject:key];
//        }
//    }
//    NSArray *sorts = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
//        return [key1 caseInsensitiveCompare:key2];
//    }];
//    NSMutableString *sortString = [NSMutableString string];
//    for (int i=0; i<[sorts count]; i++) {
//        NSString *key = [sorts objectAtIndex:i];
//        NSString *value = [parameters objectForKey:key];
//        [sortString appendFormat:@"%@=%@",key,value];
//        if (i < [sorts count]-1) {
//            [sortString appendString:@"&"];
//        }
//    }
//    NSString *paras = [RequestHelper encodeURL:sortString];
//    NSString *value = [NSString stringWithFormat:@"%@&%@&%@",requestMethod, uri, paras];
//    NSString *key = [NSString stringWithFormat:@"%@&",APP_KEY];
//    NSString *usign = [RequestHelper hmacsha1:value key:key];
//
//    return usign;
//}

/*
 *不参与签名参数：
 *      a.	长度大于3 并且r[a-z]_开头或者_s[a-z]结尾 ；
 *      b.	app_usign
 *  （   再此将改字段过滤掉）
 */
+ (BOOL)deleteKey:(NSString *)key{
    if ([key length] <= 3) {
        return NO;
    }
    if ([key isEqualToString:@"upload"]) {
        return YES;
    }
    NSString *regex = @"r[a-z]_[a-zA-Z0-9_]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isDelete = [predicate evaluateWithObject:key];
    if (!isDelete) {
        regex = @"[a-zA-Z0-9_]+_s[a-z]";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        isDelete = [predicate evaluateWithObject:key];
    }
    return isDelete;
}

/*
 *使用HMAC-SHA1加密算法，将构造源串以密钥进行加密
 */
//+ (NSString *)hmacsha1:(NSString *)text key:(NSString *)key{
//    NSData *secretData = [key dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
//    unsigned char result[20];
//    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
//    char base64Result[32];
//    size_t theResultLength = 32;
//    Base64EncodeData(result, 20, base64Result, &theResultLength, YES);
//    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
//    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
//    return base64EncodedResult;
//}

/*
 *encodeURL
 */
+ (NSString*)encodeURL:(NSString *)string{
    if (![string isKindOfClass:[NSString class]]) {
        return string;
    }
    NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))) ;
    if (newString) {
        return newString;
    }
    return @"";
}

@end
