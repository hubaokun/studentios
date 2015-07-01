//
//  CoachScreenViewController.h
//  guangda_student
//
//  Created by Dino on 15/4/24.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"
#import "MyDate.h"

@interface CoachScreenViewController : GreyTopViewController

@property (strong, nonatomic) IBOutlet UIView *detailContentView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *starLevelView;           // 星级
@property (strong, nonatomic) IBOutlet UIView *sexView;                 // 性别
@property (strong, nonatomic) IBOutlet UIView *priceView;               // 价格区间
@property (strong, nonatomic) IBOutlet UIView *carTypeView;             // 教练车型
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UITextField *priceLowTextField;  // 起始价格
@property (strong, nonatomic) IBOutlet UITextField *priceHighTextField; // 戒指价格
@property (strong, nonatomic) IBOutlet UIButton *btnGoSearch;
@property (strong, nonatomic) IBOutlet UIButton *btnReset;
@property (strong, nonatomic) IBOutlet UIButton *allSelectedStarLevelBtn;
@property (strong, nonatomic) IBOutlet UIButton *allSelectedSexBtn;
@property (strong, nonatomic) IBOutlet UIButton *allSelectedCarTypeBtn;

// 价格区间
@property (strong, nonatomic) IBOutlet UIButton *leapTypeBtn;
@property (strong, nonatomic) IBOutlet UIButton *midTypeBtn;
@property (strong, nonatomic) IBOutlet UIButton *goodTypeBtn;

// 时间段
@property (strong, nonatomic) NSDate *dateScreenBegin;      // 开始日期
@property (strong, nonatomic) NSDate *dateScreenEnd;
@property (strong, nonatomic) IBOutlet UILabel *dateBeginLabel;     // 日期label
@property (strong, nonatomic) IBOutlet UILabel *dateEndLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeBeginLabel;     // 时间label
@property (strong, nonatomic) IBOutlet UILabel *timeEndLabel;

@property (strong, nonatomic) IBOutlet UIButton *leftUpBtn;
@property (strong, nonatomic) IBOutlet UIButton *rightUpBtn;
@property (strong, nonatomic) IBOutlet UIButton *leftUpBtn2;
@property (strong, nonatomic) IBOutlet UIButton *rightUpBtn2;
@property (strong, nonatomic) IBOutlet UIButton *leftDownBtn;
@property (strong, nonatomic) IBOutlet UIButton *rightDownBtn;
@property (strong, nonatomic) IBOutlet UIButton *leftDownBtn2;
@property (strong, nonatomic) IBOutlet UIButton *rightDownBtn2;

// 教练星级
@property (strong, nonatomic) NSString *starLevel;

@property (strong, nonatomic) UITextField *nowTextField;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *timeWidth;   // 时间段8点 的宽度约束

//底部的view
@property (strong, nonatomic) IBOutlet UIView *footView;

// 日期选择器
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (strong, nonatomic) IBOutlet UIPickerView *datePicker;
@property (strong, nonatomic) IBOutlet UIButton *dateConfirmBtn;
@property (strong, nonatomic) MyDate *myPickerDate;
@property (strong, nonatomic) NSString *myYear;
@property (strong, nonatomic) NSString *myMonth;
@property (strong, nonatomic) NSString *myDay;

@property (strong, nonatomic) NSString *carTypeId;
@property (strong, nonatomic) NSString *subjectID;

@property (strong, nonatomic) IBOutlet UIView *subjectView;

- (IBAction)clickForSubjectNone:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *subjectNoneButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *subjectVIewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *carViewHeight;

@property (strong, nonatomic) IBOutlet UIView *selectContentView;
@property (strong, nonatomic) IBOutlet UIView *selectSubjectView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectSubjevtViewHeight;
@property (strong, nonatomic) IBOutlet NSDictionary *searchDic;



@end
