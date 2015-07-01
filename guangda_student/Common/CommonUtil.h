//
//  CommonUtil.h
//  wedding
//
//  Created by duanjycc on 14/11/14.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

/**
 *  共同处理类单例实例化
 *
 *  @return 共同处理类单例
 */
+ (instancetype)currentUtil;

// 判断空字符串
+ (BOOL)isEmpty:(NSString *)string;
+ (NSString *)stringForID:(id)objectid;


//读取 NSUserDefaults
+ (id)getObjectFromUD:(NSString *)key;

//存储 NSUserDefaults
+ (void)saveObjectToUD:(id)value key:(NSString *)key;
+ (void)deleteObjectFromUD:(NSString *)key;

//MD5加密
+ (NSString *)md5:(NSString *)password;

//手机号码验证
+ (BOOL)checkPhonenum:(NSString *)phone;

//获得设备型号
+ (NSString *)getCurrentDeviceModel;

//判断是否登录
- (BOOL)isLogin;
- (BOOL)isLogin:(BOOL)needLogin;
- (NSString *)getLoginUserid;


/****************** 关于时间方法 <S> ******************/
// Date 转换 NSString (默认格式：自定义)
+ (NSString *)getStringForDate:(NSDate *)date format:(NSString *)format;

// NSString 转换 Date (默认格式：自定义)
+ (NSDate *)getDateForString:(NSString *)string format:(NSString *)format;


// 记录debug数据(log)
+ (void)writeDebugLogName:(NSString *)name data:(NSString *)data;


// 根据文字，字号及固定宽(固定高)来计算高(宽)
+ (CGSize)sizeWithString:(NSString *)text
                fontSize:(CGFloat)fontsize
               sizewidth:(CGFloat)width
              sizeheight:(CGFloat)height;

// 窗口弹出动画
+ (void)shakeToShow:(UIView*)aView;

// 图片缩小
+ (UIImage *)scaleImage:(UIImage *)image minLength:(float)length;

+ (void) logout;

@end
