//
//  TabBarView.h
//  guangda_student
//
//  Created by 冯彦 on 15/10/28.
//  Copyright © 2015年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TabBarViewDelegate <NSObject>
- (void)itemClick:(NSUInteger)itemIndex;
@end

@interface TabBarView : UIView

@property (weak, nonatomic) id<TabBarViewDelegate> delegate;
@property (assign, nonatomic) NSUInteger itemsCount; // 传入所需的item个数，即会生成相应的items
- (void)itemsTitleConfig:(NSArray *)titleArray; // 传入item子标题的数组

@end
