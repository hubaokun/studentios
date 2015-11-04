//
//  CoachListTableViewCell.m
//  guangda_student
//
//  Created by Dino on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachListTableViewCell.h"
#import "UIImageView+EMWebCache.h"

@interface CoachListTableViewCell()

@property (strong, nonatomic) IBOutlet UIImageView *userLogo;
@property (strong, nonatomic) IBOutlet UILabel *orderCount;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *driveSchoolLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeCourseLabel;

@property (strong, nonatomic) TQStarRatingView *starView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressLabelTopSpace;

@end

@implementation CoachListTableViewCell

- (void)awakeFromNib {
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 78, 17, 68, 12)];
    [self.contentView addSubview:self.starView];
    
    self.userLogo.layer.cornerRadius = self.userLogo.bounds.size.width / 2;
    self.userLogo.layer.masksToBounds = YES;
    
    self.freeCourseLabel.layer.cornerRadius = 2;
    self.freeCourseLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadData:(id)data {
    NSDictionary *coachDic = data;
    
    NSString *logoUrl = coachDic[@"avatarurl"];
    [self.userLogo sd_setImageWithURL:[NSURL URLWithString:logoUrl] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    
    // 总单数
    if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
        NSString *sumnum = [coachDic[@"accompanynum"] description];
        if ([CommonUtil isEmpty:sumnum]) {
            sumnum = @"0";
        }
        NSString *sumnumStr = [NSString stringWithFormat:@"陪驾数:%@",sumnum];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:sumnumStr];
        [string addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(4,sumnum.length)];
        self.orderCount.attributedText = string;
    } else {
        NSString *sumnum = [coachDic[@"sumnum"] description];
        NSString *sumnumStr = [NSString stringWithFormat:@"总单数:%@",sumnum];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:sumnumStr];
        [string addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(4,sumnum.length)];
        self.orderCount.attributedText = string;
    }
    
    // 教练名
    NSString *name = coachDic[@"realname"];
    if (name == nil) {
        name = @"无名";
    }
    self.userName.text = name;
    
    // 驾校名
    NSString *schoolName = coachDic[@"drive_school"];
    if ([CommonUtil isEmpty:schoolName]) {
        self.driveSchoolLabel.text = @"";
    } else {
        self.driveSchoolLabel.text = schoolName;
    }
    
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
    
    [self.starView changeStarForegroundViewWithScore:[[coachDic[@"score"] description] floatValue]];
    

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
    
    // 是否开了体验课
    int freeCourseState = [coachDic[@"freecoursestate"] intValue];
    if (freeCourseState) {
        self.freeCourseLabel.hidden = NO;
        self.addressLabelTopSpace.constant = 12;
    } else {
        self.freeCourseLabel.hidden = YES;
        self.addressLabelTopSpace.constant = 6;
    }
}

@end
