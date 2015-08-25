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

@property (strong, nonatomic) TQStarRatingView *starView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelRightSpaceCon;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelLeftSpaceCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickLabelLeftSpaceCon;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    //     教练信息 星级View
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 99, 12, 87, 15)];
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
    
    [self viewConfig];
    
    // 评论内容
    NSString *content = self.comment.content;
    if([CommonUtil isEmpty:content]){
        content = @" ";
    }
    CGFloat textWidth = 0;
    if (self.comment.style == CommentStyleNormal) { // 评论不可点击
        self.contentLabelRightSpaceCon.constant = 11;
        self.arrowImageView.hidden = YES;
        textWidth = SCREEN_WIDTH - 23;
    } else { // 评论可点击
        self.contentLabelRightSpaceCon.constant = 44;
        self.arrowImageView.hidden = NO;
        textWidth = SCREEN_WIDTH - 56;
    }
    self.content.text = content;
    CGSize size = [CommonUtil sizeWithString:content fontSize:14.0 sizewidth:textWidth sizeheight:CGFLOAT_MAX];
    self.contentHeight.constant = size.height;
}

+ (CGFloat)calculateHeight:(XBComment *)comment {
    NSString *content = comment.content;
    if([CommonUtil isEmpty:content]){
        content = @" ";
    }
    CGFloat textWidth = 0;
    if (comment.style == CommentStyleNormal) { // 评论不可点击
        textWidth = SCREEN_WIDTH - 23;
    } else { // 评论可点击
        textWidth = SCREEN_WIDTH - 56;
    }
    CGSize size = [CommonUtil sizeWithString:content fontSize:14.0 sizewidth:textWidth sizeheight:CGFLOAT_MAX];
    return size.height + 47.0;
}

- (void)viewConfig {
    if (self.type == CommentCellTypeNewest ) {
        self.nick.hidden = NO;
        self.nickLabelLeftSpaceCon.constant = 12;
        self.timeLabelLeftSpaceCon.constant = (SCREEN_WIDTH - self.time.width) / 2;
        self.starView.hidden = YES;
    }
    else if (self.type == CommentCellTypeUniversal) {
        self.nick.hidden = NO;
        self.timeLabelLeftSpaceCon.constant = 12;
        self.nickLabelLeftSpaceCon.constant = self.time.x + self.time.width + 8;
        self.starView.hidden = NO;
    }
    else if (self.type == CommentCellTypePersonal) {
        self.nick.hidden = YES;
        self.timeLabelLeftSpaceCon.constant = 12;
        self.starView.hidden = NO;
}
}

@end
