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

/* input */
@property (copy, nonatomic) NSString *carModelID;

- (void)loadData:(id)data;

@end
