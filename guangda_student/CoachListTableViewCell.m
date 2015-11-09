//
//  CoachListTableViewCell.m
//  guangda_student
//
//  Created by Dino on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachListTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "GuangdaCoach.h"

@interface CoachListTableViewCell()

@property (strong, nonatomic) IBOutlet UIImageView *userLogo;
@property (strong, nonatomic) UILabel *orderCount;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) UIView *freeCourseIcon;
@property (strong, nonatomic) UIImageView *starcoachIcon;

@property (strong, nonatomic) TQStarRatingView *starView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressLabelTopSpace;

@end

@implementation CoachListTableViewCell

- (void)awakeFromNib {
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(self.userLogo.right + 15, self.userName.bottom + 6, 68, 12)];
    [self.contentView addSubview:self.starView];
    
    self.userLogo.layer.cornerRadius = self.userLogo.bounds.size.width / 2;
    self.userLogo.layer.masksToBounds = YES;
    
    // 明星教练
    UIImageView *starcoachIcon = [[UIImageView alloc] init];
    self.starcoachIcon = starcoachIcon;
    [self addSubview:starcoachIcon];
    starcoachIcon.width = 41;
    starcoachIcon.height = 15;
    starcoachIcon.centerY = self.userName.centerY;
    starcoachIcon.image = [UIImage imageNamed:@"ic_starcoach"];
    
    // 体验课标识
    self.freeCourseIcon = [GuangdaCoach createFreeCourseIcon];
    [self.contentView addSubview:self.freeCourseIcon];
    self.freeCourseIcon.centerY = self.userName.centerY;
    
    // 订单数
    UILabel *orderCount = [[UILabel alloc] init];
    self.orderCount = orderCount;
    [self.contentView addSubview:orderCount];
    orderCount.width = 150;
    orderCount.height = 12;
    orderCount.left = self.starView.right + 6;
    orderCount.centerY = self.starView.centerY;
    orderCount.font = [UIFont systemFontOfSize:10];
    orderCount.textColor = RGB(153, 153, 153);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadData:(id)data {
    NSDictionary *coachDic = data;
    
    // 头像
    NSString *logoUrl = coachDic[@"avatarurl"];
    [self.userLogo sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    
    // 教练名
    NSString *name = coachDic[@"realname"];
    if (name == nil) {
        name = @"无名";
    }
    self.userName.text = name;
    CGFloat nameStrWidth = [CommonUtil sizeWithString:name fontSize:14 sizewidth:80 sizeheight:self.userName.height].width;
    self.userName.width = nameStrWidth; // 设置教练名label长度
    
    // 明星教练
    int signState = [coachDic[@"signstate"] intValue];
    if (signState == 1) {
        self.starcoachIcon.hidden = NO;
        self.starcoachIcon.left = self.userName.right + 10;
    } else {
        self.starcoachIcon.hidden = YES;
    }
    
    // 体验课
    int freeCourseState = [coachDic[@"freecoursestate"] intValue];
    if (freeCourseState) {
        self.freeCourseIcon.hidden = NO;
        if (self.starcoachIcon.hidden) {
            self.freeCourseIcon.left = self.userName.right + 6;
        } else {
            self.freeCourseIcon.left = self.starcoachIcon.right +6;
        }
        
    } else {
        self.freeCourseIcon.hidden = YES;
    }
    
    // 星级
    [self.starView changeStarForegroundViewWithScore:[[coachDic[@"score"] description] floatValue]];
    
    // 总单数
    if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
        NSString *sumnum = [coachDic[@"accompanynum"] description];
        if ([CommonUtil isEmpty:sumnum]) {
            sumnum = @"0";
        }
        NSString *sumnumStr = [NSString stringWithFormat:@"预约次数:%@",sumnum];
//        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:sumnumStr];
//        [string addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(4,sumnum.length)];
//        self.orderCount.attributedText = string;
        self.orderCount.text = sumnumStr;
    } else {
        NSString *sumnum = [coachDic[@"sumnum"] description];
        NSString *sumnumStr = [NSString stringWithFormat:@"陪驾次数:%@",sumnum];
//        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:sumnumStr];
//        [string addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(4,sumnum.length)];
//        self.orderCount.attributedText = string;
        self.orderCount.text = sumnumStr;
    }
    
    // 驾校名
//    NSString *schoolName = coachDic[@"drive_school"];
//    if ([CommonUtil isEmpty:schoolName]) {
//        self.driveSchoolLabel.text = @"";
//    } else {
//        self.driveSchoolLabel.text = schoolName;
//    }
    
    // 车型
    if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
        NSArray *modelArray = coachDic[@"modellist"];
        if (modelArray.count > 0) {
            NSDictionary *modelDict = modelArray.firstObject;
            NSString *modelID = [modelDict[@"modelid"] description];
            if ([modelID isEqualToString:@"17"]) {
                self.addressLabel.text = @"手动挡";
            } else {
                self.addressLabel.text = @"自动挡";
            }
        }
    }
    // 练车地址
    else {
        NSString *detail = coachDic[@"detail"];
        self.addressLabel.text = detail;
    }

    // 教练是否开课
    int courseState = 0;
    if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
        courseState = [coachDic[@"accompanycoursestate"] intValue];
    }
    else {
        courseState = [coachDic[@"coursestate"] intValue];
    }
    if (courseState == 0) { // 未开课
        self.contentView.alpha = 0.5;
    } else {
        self.contentView.alpha = 1.0;
    }
    
}

@end
