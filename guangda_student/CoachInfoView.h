//
//  CoachInfoView.h
//  guangda_student
//
//  Created by 冯彦 on 15/11/3.
//  Copyright © 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CoachInfoViewDelegate <NSObject>
- (void)coachDetailShow:(NSString *)coachID;
- (void)appointCoach:(NSDictionary *)coachInfoDict;
@end

@interface CoachInfoView : UIView
@property (weak, nonatomic) id<CoachInfoViewDelegate> delegate;
- (CGFloat)loadData:(NSDictionary *)coachInfoDict withCarModelID:(NSString *)carModelID;
@end
