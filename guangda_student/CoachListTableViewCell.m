//
//  CoachListTableViewCell.m
//  guangda_student
//
//  Created by Dino on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachListTableViewCell.h"

@implementation CoachListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-92, 20, 80, 15)];
    [self.contentView addSubview:self.starView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
