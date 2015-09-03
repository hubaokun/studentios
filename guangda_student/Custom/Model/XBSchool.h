//
//  XBSchool.h
//  guangda_student
//
//  Created by 冯彦 on 15/9/3.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBSchool : NSObject

@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *name;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)schoolWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)schoolsWithArray:(NSArray *)array;

@end
