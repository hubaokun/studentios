//
//  XBComment.m
//  guangda_student
//
//  Created by 冯彦 on 15/8/11.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XBComment.h"

@implementation XBComment

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _studentID = [dict[@"from_user"] description];
        _coachID = [dict[@"to_user"] description];
        _avatarUrl = [dict[@"avatarUrl"] description];
        _studentName = [dict[@"nickname"] description];
        _content = [dict[@"content"] description];
        _addtime = [dict[@"addtime"] description];
        _count = [dict[@"count"] description];
        if ([CommonUtil isEmpty:_count]) {
            _style = CommentStyleNormal;
        } else {
            _style = CommentStyleOneStudentGather;
        }
        _score = [dict[@"score"] floatValue];
    }
    return self;
}

+ (instancetype)commentWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

+ (NSMutableArray *)commentsWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = nil;
    if (array.count > 0) {
        tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [tempArray addObject:[XBComment commentWithDict:dict]];
        }
    }
    return tempArray;
}

+ (NSMutableArray *)gatherCommentsWithArray:(NSArray *)array
{
    NSMutableArray *tempArray = nil;
    if (array.count > 0) {
        tempArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            XBComment *comment = [XBComment commentWithDict:dict];
            comment.style = CommentStyleOneStudentGather;
            [tempArray addObject:comment];
        }
    }
    return tempArray;
}

@end
