//
//  CourseTimetableViewController.m
//  guangda_student
//
//  Created by 冯彦 on 15/8/23.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CourseTimetableViewController.h"
#import "LoginViewController.h"


@interface CourseTimetableViewController ()

@end

@implementation CourseTimetableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeMutableList = [NSMutableArray array];
    [self timeTableCreate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self deselectedAllButton];
    [self resetSelectedButton];
    [self timeTableConfig];
//    [self printBtnState];
}

- (void)printBtnState {
    for (NSDictionary *dict in self.timeMutableList) {
        UILabel *timeLabel = dict[@"timeLabel"];
        NSString *time = timeLabel.text;
        
        DSButton *btn = dict[@"button"];
        NSString *state = nil;
        if (btn.enabled) {
            state = @"yes";
        } else {
            state = @"no";
        }
        
        NSLog(@"%@ : %@", time, state);
    }
}

// 时刻表生成
- (void)timeTableCreate
{
    CGFloat _y = 0;
    // 提示语
    UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, SCREEN_WIDTH, 20)];
    remindLabel.text = @"您预约的时间是指开始时间后的一个小时";
    remindLabel.font = [UIFont systemFontOfSize:10];
    remindLabel.textColor = RGB(184, 184, 184);
    remindLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:remindLabel];
    
    _y += 26;
    
    CGFloat _width = (SCREEN_WIDTH - 60 - 28) / 4;
    CGFloat _height = _width * 125/114;
    
    // 上午
    UIView *morningView = [[UIView alloc] initWithFrame:CGRectMake(0, _y, SCREEN_WIDTH, _height*2+5)];
    [self.view addSubview:morningView];
    [self addTimePointWithView:morningView andMode:1 timeNum:7];
    
    _y += _height*2+15;
    
    // 下午
    UIView *afternoonView = [[UIView alloc] initWithFrame:CGRectMake(0, _y, SCREEN_WIDTH, _height*2+5)];
    [self.view addSubview:afternoonView];
    [self addTimePointWithView:afternoonView andMode:2 timeNum:7];
    
    _y += _height*2+15;
    
    // 晚上
    UIView *nightView = [[UIView alloc] initWithFrame:CGRectMake(0, _y, SCREEN_WIDTH, _height*2+5)];
    [self.view addSubview:nightView];
    [self addTimePointWithView:nightView andMode:3 timeNum:5];
    
    _y += _height*2+15;
    
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, _y);
    self.viewHeight = _y;
}

// 添加时间点view
- (void)addTimePointWithView:(UIView *)timeView andMode:(int)mode timeNum:(int)timeNum
{
    CGFloat _x = 0;
    CGFloat _y = 0;
    CGFloat _width = (SCREEN_WIDTH - 60 - 28) / 4;
    CGFloat _height = _width * 125/114;
    float _bili = SCREEN_WIDTH / 320;     // 比例
    
    int time = 0;
    
    // 上午标题
    UILabel *timeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 28, _height*2+5)];
    timeTitleLabel.backgroundColor = RGB(115, 119, 128);
    timeTitleLabel.textColor = [UIColor whiteColor];
    timeTitleLabel.numberOfLines = 2;
    timeTitleLabel.textAlignment = NSTextAlignmentCenter;
    timeTitleLabel.layer.cornerRadius = 10;
    timeTitleLabel.layer.masksToBounds = YES;
    timeTitleLabel.font = [UIFont systemFontOfSize:12];
    switch (mode) {
        case 1:
            timeTitleLabel.text = @"上\n午";
            time = 5;
            break;
        case 2:
            timeTitleLabel.text = @"下\n午";
            time = 12;
            break;
        case 3:
            timeTitleLabel.text = @"晚\n上";
            time = 19;
            break;
            
        default:
            break;
    }
    [timeView addSubview:timeTitleLabel];
    
    UIImage *image1 = [UIImage imageNamed:@"time_point_bg_blue"];   // 正常状态
    UIImage *image2 = [UIImage imageNamed:@"time_point_bg_grey"];   // 不可用
    UIImage *image3 = [UIImage imageNamed:@"time_point_bg_green"];  // 选中
    [image1 resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [image2 resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [image3 resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    // 时间点
    for (int i = 0; i < timeNum; i++)
    {
        // 各个时间点的view
        UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(38 + _x, _y, _width, _height)];
        //        pointView.backgroundColor = RGB(126, 207, 224);
        pointView.layer.cornerRadius = 10;
        [timeView addSubview:pointView];
        
        // 向view中添加子元素
        
        // 按钮
        DSButton *button = [DSButton buttonWithType:UIButtonTypeCustom];
        button.frame = pointView.bounds;
        button.tag = time+i;    // tag = 时间点的值
        [button setBackgroundImage:image1 forState:UIControlStateNormal];
        [button setBackgroundImage:image2 forState:UIControlStateDisabled];
        [button setBackgroundImage:image3 forState:UIControlStateSelected];
        [button addTarget:self action:@selector(timeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.enabled = NO;
        [pointView addSubview:button];
        
        //        button.value = @"120";
        
        // 时间点标识
        UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5*_bili, _width, 20*_bili)];
        pointLabel.text = [NSString stringWithFormat:@"%d:00", time + i];
        pointLabel.textColor = [UIColor whiteColor];
        pointLabel.textAlignment = NSTextAlignmentCenter;
        pointLabel.font = [UIFont systemFontOfSize:20];
        pointLabel.tag = 1;
        [pointView addSubview:pointLabel];
        
        // 科目标识
        UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 29*_bili, _width, 15*_bili)];
        //        classLabel.text = @"科目三";
        classLabel.textColor = RGB(52, 136, 153);
        classLabel.textAlignment = NSTextAlignmentCenter;
        classLabel.font = [UIFont systemFontOfSize:12];
        classLabel.tag = 2;
        [pointView addSubview:classLabel];
        
        // 价格/状态
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45*_bili, _width, 13)];
        //        priceLabel.text = @"120.0元";
        priceLabel.textColor = RGB(52, 136, 153);
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.tag = 3;
        [pointView addSubview:priceLabel];
        
        NSMutableDictionary *timeDic = [NSMutableDictionary dictionary];
        [timeDic setObject:pointLabel forKey:@"timeLabel"];
        [timeDic setObject:classLabel forKey:@"classLabel"];
        [timeDic setObject:priceLabel forKey:@"priceLabel"];
        [timeDic setObject:button forKey:@"button"];
        
        [self.timeMutableList addObject:timeDic];
        //        NSLog(@"timeMutableList=== %@", _timeMutableList);
        
        // 设置xy值
        _x += 10 + _width;
        if (i == 3) {
            _x = 0;
            _y += 5 + _height;
        }
    }
}

// 配置时刻表
- (void)timeTableConfig
{
    CGFloat _width = (SCREEN_WIDTH - 60 - 28) / 4;
    float _bili = SCREEN_WIDTH / 320;     // 比例
    
    for (int i = 0; i < self.dateList.count; i++) {
        NSDictionary *dateDic = [self.dateList objectAtIndex:i];        // 接口取到的数据
        NSMutableDictionary *timeDic = [[self.timeMutableList objectAtIndex:i] mutableCopy]; // 本地存储的时间点的dic
        
        NSString *subjectName = [dateDic[@"subject"] description];
        NSString *price = [dateDic[@"price"] description];
        int isRest = [dateDic[@"isrest"] intValue];
        NSString *isBooked = [dateDic[@"isbooked"] description];
        
        // 本地时间点view内的控件
        UILabel *timeLabel = timeDic[@"timeLabel"];
        UILabel *classLabel = timeDic[@"classLabel"];
        UILabel *priceLabel = timeDic[@"priceLabel"];
        DSButton *button = timeDic[@"button"];
        
        // 是否已经过期
        NSString *passTimeStr = [dateDic[@"pasttime"] description];
        int passedTime = [passTimeStr intValue];
        
        button.name = dateDic[@"addressdetail"];
        
        if (isRest == 0) {
            // 不休息
            timeLabel.textColor = [UIColor whiteColor];
            classLabel.text = subjectName;
            priceLabel.text = [NSString stringWithFormat:@"%.1f元", [price floatValue]];
            button.enabled = YES;
            button.value = price;
            priceLabel.textColor = RGB(52, 136, 153);
            classLabel.textColor = RGB(52, 136, 153);
            classLabel.hidden = button.selected;
            priceLabel.hidden = button.selected;
            if ([classLabel.text isEqualToString:@"科目三"]) {
                classLabel.textColor = RGB(255, 127, 17);
            }
            
            if ([isBooked isEqualToString:@"1"]) {//教练被别人预约
                // 被预约了
                timeLabel.textColor = RGB(179, 179, 179);
                classLabel.text = nil;
                priceLabel.text = @"教练已被\n别人预约";
                priceLabel.textColor = RGB(179, 179, 179);
                priceLabel.numberOfLines = 0;
                priceLabel.frame = CGRectMake(0, 45*_bili - 20, _width, 33);
                button.enabled = NO;
                button.selected = NO;
                priceLabel.hidden = NO;
            }else if ([isBooked isEqualToString:@"2"]) {//教练被自己预约
                // 已有课程
                timeLabel.textColor = RGB(179, 179, 179);
                classLabel.text = nil;
                priceLabel.text = @"您已预约\n这个教练";
                priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
                priceLabel.textColor = [UIColor redColor];
                priceLabel.numberOfLines = 0;
                priceLabel.frame = CGRectMake(0, 45*_bili - 20, _width, 33);
                button.enabled = NO;
                button.selected = NO;
                priceLabel.hidden = NO;
                
            }else if([isBooked isEqualToString:@"3"]){
                timeLabel.textColor = RGB(179, 179, 179);
                classLabel.text = nil;
                priceLabel.text = @"您已预约\n其他教练";
                priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
                priceLabel.textColor = [UIColor redColor];
                priceLabel.numberOfLines = 0;
                priceLabel.frame = CGRectMake(0, 45*_bili - 20, _width, 33);
                button.enabled = NO;
                button.selected = NO;
                priceLabel.hidden = NO;
            }else{
                button.enabled = YES;
                priceLabel.frame = CGRectMake(0, 45*_bili, _width, 13);
                // 时间已过期
                if (passedTime == 1) {
                    button.enabled = NO;
                    timeLabel.textColor = RGB(179, 179, 179);
                    priceLabel.textColor = RGB(179, 179, 179);
                    classLabel.textColor = RGB(179, 179, 179);
                }else{
                    button.enabled = YES;
                }
            }
            
        }else{
            // 未开课
            priceLabel.frame = CGRectMake(0, 45*_bili, _width, 13);
            timeLabel.textColor = RGB(179, 179, 179);
            classLabel.hidden = YES;
            priceLabel.text = @"未开课";
            priceLabel.hidden = NO;
            priceLabel.textColor = RGB(179, 179, 179);
            button.enabled = NO;
        }
        
        [timeDic setObject:button forKey:@"button"];
        [self.timeMutableList replaceObjectAtIndex:i withObject:timeDic];
    }
}

// 重置按钮状态
- (void)deselectedAllButton
{
    // 刷新按钮的状态
    for (int i = 0; i < self.timeMutableList.count; i++)
    {
        NSDictionary *timeDic = [self.timeMutableList objectAtIndex:i]; // 本地存储的时间点的dic
        DSButton *button = timeDic[@"button"];
        button.selected = NO;
    }
}

// 根据数据选择按钮
- (void)resetSelectedButton
{
    for (int i = 0; i < self.dateTimeSelectedList.count; i++)
    {
        NSDictionary *timeDiction = self.dateTimeSelectedList[i];
        NSString *dateSelected = timeDiction[@"date"];  // 被选中的日期
        if ([dateSelected isEqualToString:self.nowSelectedDate])
        {
            NSArray *timeArray = timeDiction[@"times"];
            for (int j = 0; j < timeArray.count; j++)
            {
                NSDictionary *timesDic = timeArray[j];
                NSString *timeStr = timesDic[@"time"];  // 被选中的时间点
                
                for (int k = 0; k < self.timeMutableList.count; k++)
                {
                    NSDictionary *timeDic = [self.timeMutableList objectAtIndex:k]; // 本地存储的时间点的dic
                    UILabel *timeLabel = timeDic[@"timeLabel"];
                    if ([timeLabel.text isEqualToString:timeStr])
                    {
                        DSButton *button = timeDic[@"button"];
                        button.selected = YES;
                        
                        UILabel *classLabel = timeDic[@"classLabel"];
                        UILabel *priceLabel = timeDic[@"priceLabel"];
                        
                        classLabel.hidden = YES;
                        priceLabel.hidden = YES;
                    }
                }
                
            }
        }
    }
}

#pragma mark - 点击事件
- (void)timeButtonClick:(DSButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(timeSelect:)]) {
        [self.delegate timeSelect:sender];
    }
}

@end
