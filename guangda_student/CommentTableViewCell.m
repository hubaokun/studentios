//
//  CommentTableViewCell.m
//  guangda_student
//
//  Created by guok on 15/5/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface CommentTableViewCell()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelRightSpaceCon;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadData {
    // 头像
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:self.comment.avatarUrl] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    
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
    
    // 评论内容
    NSString *content = self.comment.content;
    CGFloat textWidth = 0;
    if (self.comment.style == CommentStyleNormal) { // 评论不可点击
        self.contentLabelRightSpaceCon.constant = 11;
        self.arrowImageView.hidden = YES;
        textWidth = SCREEN_WIDTH - 55;
    } else { // 评论可点击
        self.contentLabelRightSpaceCon.constant = 44;
        self.arrowImageView.hidden = NO;
        textWidth = SCREEN_WIDTH - 88;
    }
    if(![CommonUtil isEmpty:content]){
        self.content.text = content;
        CGSize size = [CommonUtil sizeWithString:content fontSize:14.0 sizewidth:textWidth sizeheight:CGFLOAT_MAX];
        self.contentHeight.constant = size.height;
    }else{
        self.content.text = @"";
        self.contentHeight.constant = 25;
    }
}

+ (CGFloat)calculateHeight:(XBComment *)comment {
    NSString *content = comment.content;
    if(![CommonUtil isEmpty:content]){
        CGFloat textWidth = 0;
        if (comment.style == CommentStyleNormal) { // 评论不可点击
            textWidth = SCREEN_WIDTH - 55;
        } else { // 评论可点击
            textWidth = SCREEN_WIDTH - 88;
        }
        CGSize size = [CommonUtil sizeWithString:content fontSize:14.0 sizewidth:textWidth sizeheight:CGFLOAT_MAX];
        return size.height + 45.0;
    }
    else {
        return 72.0;
    }
}

@end
