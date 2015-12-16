//
//  CoachInfoView.m
//  guangda_student
//
//  Created by 冯彦 on 15/11/3.
//  Copyright © 2015年 daoshun. All rights reserved.
//

#import "CoachInfoView.h"
#import "TQStarRatingView.h"
#import "UIImageView+WebCache.h"
#import "GuangdaCoach.h"

#define EDGE 10 // 左右两侧间隙
@interface CoachInfoView()
@property (strong, nonatomic) UIImageView *portraitPic;     // 头像
@property (strong, nonatomic) UILabel *nameLabel;           // 教练名
@property (strong, nonatomic) UIImageView *genderIcon;      // 性别
@property (strong, nonatomic) UIImageView *starcoachIcon;   // 明星教练
@property (strong, nonatomic) TQStarRatingView *scoreView;  // 教练评分
@property (strong, nonatomic) UILabel *countLabel;          // 预约次数
@property (strong, nonatomic) UILabel *addressLabel;        // 练车地点
@property (strong, nonatomic) UIView *line2;
@property (strong, nonatomic) UIView *freeCourseView;
@property (strong, nonatomic) UIButton *coachDetailBtn;
@property (strong, nonatomic) UIButton *appointBtn;
@property (copy, nonatomic) NSString *coachID;
@property (strong, nonatomic) NSDictionary *coachInfoDict;
@end

@implementation CoachInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        // 头像
        UIImageView *portraitPic = [[UIImageView alloc] init];
        self.portraitPic = portraitPic;
        [self addSubview:portraitPic];
        portraitPic.width = 50;
        portraitPic.height = portraitPic.width;
        portraitPic.x = EDGE;
        portraitPic.y = 7;
        portraitPic.layer.cornerRadius = portraitPic.width / 2;
        portraitPic.layer.borderWidth = 1;
        portraitPic.layer.borderColor = RGB(215, 215, 215).CGColor;
        portraitPic.layer.masksToBounds = YES;
        
        // 教练名
        UILabel *nameLabel = [[UILabel alloc] init];
        self.nameLabel = nameLabel;
        [self addSubview:nameLabel];
        nameLabel.width = 50;
        nameLabel.height = 19;
        nameLabel.x = portraitPic.right + 15;
        nameLabel.y = 13;
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = RGB(60, 60, 60);
        
        // 性别
        UIImageView *genderIcon = [[UIImageView alloc] init];
        self.genderIcon = genderIcon;
        [self addSubview:genderIcon];
        genderIcon.width = 13;
        genderIcon.height = 13;
        genderIcon.centerY = nameLabel.centerY;
        genderIcon.layer.cornerRadius = 2;
        genderIcon.contentMode = UIViewContentModeCenter;
        
        // 明星教练
        UIImageView *starcoachIcon = [[UIImageView alloc] init];
        self.starcoachIcon = starcoachIcon;
        [self addSubview:starcoachIcon];
        starcoachIcon.width = 41;
        starcoachIcon.height = 15;
        starcoachIcon.centerY = nameLabel.centerY;
        starcoachIcon.image = [UIImage imageNamed:@"ic_starcoach"];
        
        // 教练评分
        TQStarRatingView *scoreView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(nameLabel.x, nameLabel.bottom + 8, 68, 12)];
        self.scoreView = scoreView;
        [self addSubview:scoreView];
        
        // 预约次数
        UILabel *countLabel = [[UILabel alloc] init];
        self.countLabel = countLabel;
        [self addSubview:countLabel];
        countLabel.width = 150;
        countLabel.height = 14;
        countLabel.x = scoreView.right + 8;
        countLabel.centerY = scoreView.centerY;
        countLabel.font = [UIFont systemFontOfSize:12];
        countLabel.textColor = RGB(153, 153, 153);
        countLabel.text = @"预约次数：";
        
        // line1
        UIView *line1 = [[UIView alloc] init];
        [self addSubview:line1];
        line1.width = SCREEN_WIDTH;
        line1.height = 1;
        line1.x = 0;
        line1.y = 64.5;
        line1.backgroundColor = RGB(229, 229, 229);
        
        // 练车地点
        UILabel *addressLabel = [[UILabel alloc] init];
        self.addressLabel = addressLabel;
        [self addSubview:addressLabel];
        addressLabel.x = EDGE;
        addressLabel.y = line1.bottom + 10;
        addressLabel.width = SCREEN_WIDTH - addressLabel.x * 2;
        addressLabel.height = 14;
        addressLabel.font = [UIFont systemFontOfSize:12];
        addressLabel.textColor = RGB(153, 153, 153);
        addressLabel.numberOfLines = 0;
        addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        addressLabel.text = @"练车地点：";
        
        // line2
        UIView *line2 = [[UIView alloc] init];
        self.line2 = line2;
        [self addSubview:line2];
        line2.x = EDGE;
        line2.y = addressLabel.bottom + 10;
        line2.width = SCREEN_WIDTH - EDGE * 2;
        line2.height = 0.6;
        line2.backgroundColor = RGB(229, 229, 229);
        
        // 免费体验课
        [self addFreeCourseViewUnder:line2];
        
        // 教练详情按钮
        UIButton *coachDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.coachDetailBtn = coachDetailBtn;
        [self addSubview:coachDetailBtn];
        coachDetailBtn.width = 143;
        coachDetailBtn.height = 37;
        CGFloat gap = (SCREEN_WIDTH - coachDetailBtn.width * 2) / 3;
        coachDetailBtn.x = gap;
        coachDetailBtn.y = line2.bottom + 12;
        coachDetailBtn.backgroundColor = CUSTOM_BLUE;
        [coachDetailBtn setTitle:@"教练详情" forState:UIControlStateNormal];
        [coachDetailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        coachDetailBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [coachDetailBtn addTarget:self action:@selector(coachDetailClick) forControlEvents:UIControlEventTouchUpInside];
        coachDetailBtn.layer.cornerRadius = 2;
        coachDetailBtn.layer.masksToBounds = YES;
        
        // 课程预约按钮
        UIButton *appointBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.appointBtn = appointBtn;
        [self addSubview:appointBtn];
        appointBtn.width = coachDetailBtn.width;
        appointBtn.height = coachDetailBtn.height;
        appointBtn.x = coachDetailBtn.right + gap;
        appointBtn.y = coachDetailBtn.y;
        appointBtn.backgroundColor = CUSTOM_GREEN;
        [appointBtn setTitle:@"课程预约" forState:UIControlStateNormal];
        [appointBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        appointBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [appointBtn addTarget:self action:@selector(appointClick) forControlEvents:UIControlEventTouchUpInside];
        appointBtn.layer.cornerRadius = 2;
        appointBtn.layer.masksToBounds = YES;
    }
    return self;
}

- (void)addFreeCourseViewUnder:(UIView *)line2
{
    UIView *freeCourseView = [[UIView alloc] init];
    self.freeCourseView = freeCourseView;
    [self addSubview:freeCourseView];
    freeCourseView.width = SCREEN_WIDTH - EDGE * 2;
    freeCourseView.height = 24;
    freeCourseView.x = EDGE;
    freeCourseView.y = line2.bottom + 8;
    
//    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
//    [freeCourseView addSubview:icon];
//    icon.image = [UIImage imageNamed:@"ic_free"];
    
    UIView *icon = [GuangdaCoach createFreeCourseIcon];
    [freeCourseView addSubview:icon];
    icon.x = 0;
    icon.centerY = freeCourseView.height / 2;
    
    UILabel *label = [[UILabel alloc] init];
    [freeCourseView addSubview:label];
    label.x = icon.right + 4;
    label.y = 0;
    label.width = 280;
    label.height = freeCourseView.height;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = CUSTOM_RED;
    label.text = @"新用户首单免费体验学车课程";
}

- (CGFloat)loadData:(NSDictionary *)coachInfoDict withCarModelID:(NSString *)carModelID
{
    self.coachInfoDict = coachInfoDict;

    // 头像
    NSString *avatarStr = [coachInfoDict[@"avatarurl"] description];
    [self.portraitPic sd_setImageWithURL:[NSURL URLWithString:avatarStr] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];

    // 教练名
    NSString *realName = [coachInfoDict[@"realname"] description];
    if (realName == nil) {
        realName = @"无名";
    }
    self.nameLabel.text = [NSString stringWithFormat:@"%@", realName];
    CGFloat realNameStrWidth = [CommonUtil sizeWithString:realName fontSize:16 sizewidth:80 sizeheight:self.nameLabel.height].width;
    self.nameLabel.width = realNameStrWidth; // 设置教练名label长度

    // 性别
    int gender = [coachInfoDict[@"gender"] intValue];
    if (gender == 1) {
        self.genderIcon.backgroundColor = RGB(120, 190, 245);
        self.genderIcon.image = [UIImage imageNamed:@"ic_male"];
    } else if (gender == 2) {
        self.genderIcon.backgroundColor = RGB(245, 135, 176);
        self.genderIcon.image = [UIImage imageNamed:@"ic_female"];
    } else{
        self.genderIcon.backgroundColor = RGB(120, 190, 245);
        self.genderIcon.image = [UIImage imageNamed:@"ic_male"];
    }
    self.genderIcon.left = self.nameLabel.right + 8;

    // 明星教练
    self.starcoachIcon.left = self.genderIcon.right + 6;
    int signState = [coachInfoDict[@"signstate"] intValue];
    if (signState == 1) {
        self.starcoachIcon.hidden = NO;
    } else {
        self.starcoachIcon.hidden = YES;
    }
    
    // 评分
    CGFloat starScore = [coachInfoDict[@"score"] floatValue];
    [self.scoreView changeStarForegroundViewWithScore:starScore];
    
    // 教练总单数
    NSString *sumnum = nil;
    NSString *preWords = nil;
    if ([carModelID isEqualToString:@"19"]) { // 陪驾
        sumnum = [coachInfoDict[@"accompanynum"] description];
        preWords = @"陪驾数:";
    } else {
        sumnum = [coachInfoDict[@"sumnum"] description];
        preWords = @"预约数:";
    }
    if (sumnum) {
        self.countLabel.hidden = NO;
        NSString *sumnumStr = [NSString stringWithFormat:@"%@%@", preWords, sumnum];
        self.countLabel.text = sumnumStr;
    } else {
        self.countLabel.hidden = YES;
    }

    // 练车地址
    NSMutableString *address = [[NSMutableString alloc] initWithString:@"练车地点:"] ;
    [address appendString:[coachInfoDict[@"detail"] description]];
    self.addressLabel.text = address;
    CGFloat addrStrHeight = [CommonUtil sizeWithString:address fontSize:12 sizewidth:self.addressLabel.width sizeheight:150].height;
    self.addressLabel.height = addrStrHeight;
    self.line2.y = self.addressLabel.bottom + 10;
    
    // 体验课
    int freeCourseState = [coachInfoDict[@"freecoursestate"] intValue];
    if (freeCourseState) {
        self.freeCourseView.hidden = NO;
        self.freeCourseView.y = self.line2.bottom + 8;
        self.coachDetailBtn.y = self.freeCourseView.bottom + 8;
    } else {
        self.freeCourseView.hidden = YES;
        self.coachDetailBtn.y = self.line2.bottom + 12;
    }
    
    // 高度调整
    self.appointBtn.y = self.coachDetailBtn.y;
    self.height = self.appointBtn.bottom + 10;
    
    return self.height;
}

- (void)coachDetailClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(coachDetailShow:)]) {
        if (self.coachInfoDict) {
            NSString *coachID = [self.coachInfoDict[@"coachid"] description];
            [self.delegate coachDetailShow:coachID];
        }
    }
}

- (void)appointClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(appointCoach:)]) {
        if (self.coachInfoDict) {
            [self.delegate appointCoach:self.coachInfoDict];
        }
    }
}

@end
