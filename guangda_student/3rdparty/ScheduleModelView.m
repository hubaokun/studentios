//
//  ScheduleModelView.m
//  wedding
//
//  Created by Yuhangping on 14/11/14.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import "ScheduleModelView.h"
#import "UIImageView+WebCache.h"
@interface ScheduleModelView ()

@property (strong, nonatomic) IBOutlet UIImageView *scheduleImageView;//轮播图片
@property (strong, nonatomic) IBOutlet UILabel *titleLable;//标题
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;//时间
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;//价格
@property (strong, nonatomic) IBOutlet UILabel *unitLabel;//单位
@property (strong, nonatomic) IBOutlet UIView *titleBgView;//标题灰色背景

@end
@implementation ScheduleModelView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //初始化
        self.backgroundColor = [UIColor whiteColor];//设置背景颜色
        
    }
    return self;
}
/*
 title: 标题
 time: 时间
 price: 价格（600形式）
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)title time:(NSString *)time
              price:(NSString *)price buttonTag:(int)tag imageUrl:(NSString *)imageUrl {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];//设置背景颜色
        
        if ([CommonUtil isEmpty:title]) {
            //标题暂无
            _title = @"标题暂无";
        }else {
            _title = title;
        }
        
        if ([CommonUtil isEmpty:time]){
            _time = @"介绍暂无";
        }else {
            _time = time;
        }
        _price = price;
        _buttonTag = tag;
        _image = imageUrl;
        
        //初始化图片
        _scheduleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 30)];
        _scheduleImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_scheduleImageView sd_setImageWithURL:[NSURL URLWithString:_image] placeholderImage:[UIImage imageNamed:@"default_img"]];
        [self addSubview:self.scheduleImageView];
        
        //标题背景
        _titleBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.scheduleImageView.frame.size.height - 28, self.frame.size.width, 28)];
        _titleBgView.backgroundColor = [UIColor grayColor];
        _titleBgView.alpha = 0.5f;
        [self addSubview:_titleBgView];
        
        //标题
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(6, self.scheduleImageView.frame.size.height - 28, self.frame.size.width - 12, 28)];
        _titleLable.numberOfLines = 1;//行数
        _titleLable.text = _title;//标题内容
        _titleLable.textColor = [UIColor whiteColor];//字体颜色
        _titleLable.font = [UIFont systemFontOfSize:16];
        _titleLable.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.titleLable];
        
        //日期
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, self.scheduleImageView.frame.size.height, 160, 30)];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.numberOfLines = 1;//行数
        _timeLabel.text = _time;//日期内容
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];//字体颜色
        [self addSubview:self.timeLabel];
        
        //价格
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timeLabel.frame.origin.x+self.timeLabel.frame.size.width, self.scheduleImageView.frame.size.height, self.frame.size.width - 16 - 23 - self.timeLabel.frame.size.width, 30)] ;
        _priceLabel.font = [UIFont systemFontOfSize:17];
        _priceLabel.numberOfLines = 1;//行数
        _priceLabel.textColor = [UIColor colorWithRed:224/255.0 green:32/255.0 blue:32/255.0 alpha:1];
        _priceLabel.textAlignment = NSTextAlignmentRight;
        if (![CommonUtil isEmpty:_price]) {
            //有价格数据
            NSString *priceText = [NSString stringWithFormat:@"￥%@元/", _price];
            //价格样式
            _priceLabel.text = priceText;//价格内容
            //单位
            NSString *str = @"桌起";
            _unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 23 - 8, self.scheduleImageView.frame.size.height+2, 23, 28)];
            _unitLabel.text = str;
            _unitLabel.font = [UIFont systemFontOfSize:11];
            _unitLabel.textColor = [UIColor colorWithRed:224/255.0 green:32/255.0 blue:32/255.0 alpha:1];
            [self addSubview:self.priceLabel];
            [self addSubview:self.unitLabel];
        }else {
            //价格暂无
            NSString *priceText = @"价格暂无";
            _priceLabel.text = priceText;//价格内容
            [self addSubview:self.priceLabel];
        }
        
        //初始化按钮
        _imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] ;
        _imageButton.backgroundColor = [UIColor clearColor];//设置按钮透明颜色
        _imageButton.userInteractionEnabled = YES;//是否可点击
        _imageButton.tag = _buttonTag;
        [self addSubview:self.imageButton];
    }
    return self;
}
@end
