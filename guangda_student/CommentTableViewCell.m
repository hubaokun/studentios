//
//  CommentTableViewCell.m
//  guangda_student
//
//  Created by guok on 15/5/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "TQStarRatingView.h"

@interface CommentTableViewCell()

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) TQStarRatingView *starView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelLeftSpaceCon;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    //     教练信息 星级View
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(0, 0, 68, 12)];
    self.starView.right = SCREEN_WIDTH - 41;
    self.starView.centerY = self.scoreLabel.centerY;
    [self.contentView addSubview:_starView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadData {
    // 头像
//    [self.avatar sd_setImageWithURL:[NSURL URLWithString:self.comment.avatarUrl] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    
    // 名称
    NSString *nickname = self.comment.studentName;
    if(![CommonUtil isEmpty:nickname]){
        self.nick.text = nickname;
    }else{
        self.nick.text = @"";
    }
    
    // 时间
    NSString *addtime = self.comment.addtime;
    if(![CommonUtil isEmpty:addtime]){
        self.time.text = [CommonUtil intervalSinceNow:addtime];
    }else{
        self.time.text = @"";
    }
    
    // 评分
    [self.starView changeStarForegroundViewWithScore:self.comment.score];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.1f", self.comment.score];
    
    // 评论内容
    NSString *content = self.comment.content;
    if([CommonUtil isEmpty:content]){
        content = @" ";
    }
    self.content.text = content;
    CGSize size = [CommonUtil sizeWithString:content fontSize:12.0 sizewidth:SCREEN_WIDTH - 120 sizeheight:CGFLOAT_MAX];
    self.contentHeightCon.constant = size.height;
}

+ (CGFloat)calculateHeight:(XBComment *)comment {
    NSString *content = comment.content;
    if([CommonUtil isEmpty:content]){
        content = @" ";
    }
    CGFloat textWidth = SCREEN_WIDTH - 120;
    CGSize size = [CommonUtil sizeWithString:content fontSize:12.0 sizewidth:textWidth sizeheight:CGFLOAT_MAX];
    return size.height + 43.0;
}

@end
