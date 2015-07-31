//
//  MainViewController.h
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
#import <BaiduMapAPI/BMapKit.h>

@interface MainViewController : GreyTopViewController

@property (strong, nonatomic) BMKMapView *mapView;

@property (strong, nonatomic) BMKUserLocation *userLocation;

+ (MainViewController *)sharedMainController;

@property (strong, nonatomic) NSDictionary *searchParamDic; // 需要传入的参数

@property (strong, nonatomic) IBOutlet UIView *mapContentView;          // 地图view

@property (strong, nonatomic) IBOutlet UIView *selectedView;            // 选择框view
@property (strong, nonatomic) IBOutlet UIButton *accurateBtnOutlet;     // 精确筛选
@property (strong, nonatomic) IBOutlet UIButton *fuzzyBtnOutlet;        // 模糊筛选
@property (strong, nonatomic) IBOutlet UIView *coachDetailsView;        // 教练详情view
@property (strong, nonatomic) IBOutlet UIButton *showCoachTimeClick;    // 显示教练事件btn
@property (strong, nonatomic) IBOutlet UIView *coachDetailWordView;     // 教练详细资料文字view
@property (strong, nonatomic) IBOutlet UIScrollView *coachDetailWordScroll; // 教练详细资料文字scrollView
@property (strong, nonatomic) IBOutlet UIImageView *userLogo;           // 用户头像

@property (strong, nonatomic) IBOutlet UIView *chooseCoachTimeView;     // 选择教练的时间view
@property (strong, nonatomic) IBOutlet UIScrollView *timeScrollView;    // 时间滚动view
@property (strong, nonatomic) IBOutlet UIView *timeListView;            // 时间轴view
@property (strong, nonatomic) IBOutlet UIView *timeDetailsView;         // 时间预约详情view
@property (strong, nonatomic) IBOutlet UIView *timeDetailsContentView;  // 时间预约详情的内容view（圈圈时间点view）
@property (strong, nonatomic) IBOutlet UIView *coachDetailsViewAll;     // 教练详细资料View
@property (strong, nonatomic) IBOutlet UIScrollView *timeDetailsScrollView; // 时间详情scrolView （圆圈圈的时间选择）

@property (strong, nonatomic) IBOutlet UIView *checkNumView;            // 是否通过证件号审核
@property (strong, nonatomic) IBOutlet UIView *appointResultView;       // 预约结果View
@property (strong, nonatomic) IBOutlet UITextField *driveNumLabel;      // 驾驶证号label
@property (strong, nonatomic) IBOutlet UITextField *studentNumLabel;    // 学员证号label
@property (strong, nonatomic) IBOutlet UIButton *sureSubmitClick;       // 确认提交按钮
@property (strong, nonatomic) IBOutlet UIView *pickerView;              // 选择view
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shangXiaWu;  // 上午和下午的约束（圈圈时间点）
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shijiuShiliu;// 19：00和16：00的约束

@property (strong, nonatomic) IBOutlet UIView *remainTimeView;          // 教练在..时间内..剩余时间
@property (strong, nonatomic) IBOutlet UIButton *showHideTimeDetailsBtn;// 显示或隐藏圈圈时间详情View

@property (strong, nonatomic) IBOutlet UILabel *priceAndHourLabel;      // 单价和时间label
@property (strong, nonatomic) IBOutlet UILabel *allPriceLabel;          // 总价label
@property (strong, nonatomic) IBOutlet UIView *perPriceView;            // 单价view
@property (strong, nonatomic) IBOutlet UILabel *perPriceLabel;          // 单价label

@property (strong, nonatomic) IBOutlet UIView *appointResultContentView;// 预约成功结果view

@property (strong, nonatomic) IBOutlet UIView *coachDetailShowBtn;      // 显示教练详情 (点击事件 和 向上滑动手势) 按钮
@property (strong, nonatomic) IBOutlet UIButton *coachDetailHideBtn;    // 显示教练详情 (点击事件 和 向下滑动手势) 按钮

@property (strong, nonatomic) IBOutlet UIButton *sureAppointBtn;        // 确认预约Btn 时刻表界面

@property (strong, nonatomic) NSArray *coachList;               // 教练列表
@property (strong, nonatomic) NSMutableArray *annotationsList;  // 标注数组

// 教练详细信息
@property (strong, nonatomic) IBOutlet UILabel *coachNameLabel;      // 教练姓名
@property (strong, nonatomic) IBOutlet UILabel *coachAddressLabel;   // 详细地址
@property (strong, nonatomic) NSString *coachId;    // 教练ID

@property (strong, nonatomic) IBOutlet UILabel *detailsCoachName;   // 姓名
@property (strong, nonatomic) IBOutlet UILabel *detailsSex;         // 性别
@property (strong, nonatomic) IBOutlet UILabel *detailsAge;         // 年龄
@property (strong, nonatomic) IBOutlet UILabel *detailsAddress;     // 地址
@property (strong, nonatomic) IBOutlet UILabel *detailsCardnum;     // 身份证号
@property (strong, nonatomic) IBOutlet UILabel *detailsCoachCardnum;// 教练证号
@property (strong, nonatomic) IBOutlet UILabel *detailsCarType;     // 准教车型
@property (strong, nonatomic) IBOutlet UILabel *detailsCarNum;      // 车牌号
@property (strong, nonatomic) IBOutlet UILabel *detailsCoachSchool; // 所属学校
@property (strong, nonatomic) IBOutlet UILabel *detailsCoachLevel;  // 教练等级
@property (strong, nonatomic) IBOutlet UITextView *detailsCocahComment; // 自我评价

@property (strong, nonatomic) IBOutlet UIView *coachInfoView;       // 教练信息view
@property (weak, nonatomic) IBOutlet UIScrollView *carModelScrollView;  // uber
@property (strong, nonatomic) IBOutlet UIView *footView;                //底部的view
@property (strong, nonatomic) NSMutableArray *carModelImageViewList;
@property (strong, nonatomic) NSMutableArray *carModelLabelList;

@property (copy, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSTimer *confirmTimer;

@end
