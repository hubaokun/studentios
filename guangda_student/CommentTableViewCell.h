//
//  CommentTableViewCell.h
//  guangda_student
//
//  Created by guok on 15/5/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBComment.h"

@interface CommentTableViewCell : UITableViewCell
@property (strong, nonatomic) XBComment *comment;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *nick;
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UILabel *time;

- (void)loadData;
+ (CGFloat)calculateHeight:(XBComment *)comment;

@end
