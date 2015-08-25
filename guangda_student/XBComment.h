//
//  XBComment.h
//  guangda_student
//
//  Created by 冯彦 on 15/8/11.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CommentStyle) {
    CommentStyleNormal  = 1,              // 普通评论
    CommentStyleOneStudentGather  = 2,    // 单学员汇总评论
};

@interface XBComment : NSObject

@property (copy, nonatomic) NSString *studentID;    // 学员id
@property (copy, nonatomic) NSString *coachID;      // 教练id
@property (copy, nonatomic) NSString *avatarUrl;    // 学员头像
@property (copy, nonatomic) NSString *studentName;  // 学员姓名
@property (copy, nonatomic) NSString *content;      // 评论内容
@property (copy, nonatomic) NSString *addtime;      // 评论时间
@property (copy, nonatomic) NSString *count;        // 该学员评论数
@property (assign, nonatomic) float score;          // 评分
@property (assign, nonatomic) CommentStyle style;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)commentWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)commentsWithArray:(NSArray *)array;
+ (NSMutableArray *)gatherCommentsWithArray:(NSArray *)array;

@end
