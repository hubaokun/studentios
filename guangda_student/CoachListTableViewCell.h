//
//  CoachListTableViewCell.h
//  guangda_student
//
//  Created by Dino on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQStarRatingView.h"

@interface CoachListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userLogo;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *contentDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *driveSchoolLabel;

@property (strong, nonatomic) TQStarRatingView *starView;

@end
