//
//  ScheduleModelView.h
//  wedding
//
//  Created by Yuhangping on 14/11/14.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleModelView : UIView

@property (nonatomic)  NSString *image;
@property (nonatomic)  NSString *title;
@property (nonatomic)  NSString *time;
@property (nonatomic)  NSString *price;
@property (nonatomic) int buttonTag;
@property (nonatomic) CGFloat scale;//缩放比例


@property (nonatomic)  NSString *imageLink;//图片链接

@property (strong, nonatomic) IBOutlet UIButton *imageButton;//轮播图的点击按钮
/*
 title: 标题
 time: 时间
 price: 价格（600形式）
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)title time:(NSString *)time
              price:(NSString *)price buttonTag:(int)tag imageUrl:(NSString *)imageUrl;
@end
