//
//  DNCoach.h
//  guangda_student
//
//  Created by 潘启飞 on 15/6/8.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNCoach : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *score;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)coachWithDict:(NSDictionary *)dict;

@end
