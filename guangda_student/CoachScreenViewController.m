//
//  CoachScreenViewController.m
//  guangda_student
//
//  Created by Dino on 15/4/24.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachScreenViewController.h"
#import "CommonUtil+Date.h"

@interface CoachScreenViewController ()
<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    CGFloat _keyboardY;     // 键盘弹出时的y坐标
    BOOL _upOrDown;         // yes == up / no == down
    BOOL _dateOrTime;       // yes == date / no == time
    
    int timeScreenBegin;    // 开始时间
    int timeScreenEnd;
    
    int _sex;
}

@property (strong, nonatomic) NSDate *maxDate;

@end

@implementation CoachScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    self.detailContentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 755);
    //    [self.scrollView addSubview:self.detailContentView];
    
    self.selectContentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 110);
    [self.scrollView addSubview:self.selectContentView];
    self.scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT - 110);
    self.timeWidth.constant = SCREEN_WIDTH/600*163;
    
    [self setButtonLayerInView:self.starLevelView];
    [self setButtonLayerInView:self.sexView];
    [self setButtonLayerInView:self.priceView];
    [self setButtonLayerInView:self.carTypeView];
    
    self.btnGoSearch.layer.cornerRadius = 3;
    self.btnReset.layer.cornerRadius = 3;
    self.btnReset.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnReset.layer.borderWidth = 1;
    //    self.subjectNoneButton.layer.cornerRadius = 3;
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardClick:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    //注册监听，防止键盘遮挡视图
    self.searchTextField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.myPickerDate = [[MyDate alloc] initWithMaxDayFromNow:29];
    
    // 设置默认值
    _sex = 0;
    
    
    self.maxDate = [CommonUtil addDate2:[NSDate date] year:0 month:0 day:29];
    
    [self initWithDic];
    
    //    [self getAllTeachCarModel];
    
    [self getAllSubject];
    
    self.carTypeId = @"0";
    self.subjectID = @"0";
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH - 110);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//根据已有的条件初始化
- (void) initWithDic{
    if(self.searchDic){
        NSString * date = self.searchDic[@"condition3"];
        
        if(date){
            NSDate *difDate = [CommonUtil getDateForString:date format:@"yyyy-MM-dd HH:mm:ss"];
            self.dateBeginLabel.text = [CommonUtil getStringForDate:difDate format:@"yyyy-MM-dd"];
            
            NSDate *selectedDate = [CommonUtil getDateForString:self.dateBeginLabel.text format:@"yyyy-MM-dd"];
            if (([selectedDate timeIntervalSinceDate:self.maxDate] > 0.0)) {
                self.rightUpBtn.enabled = NO;
            }else{
                self.rightUpBtn.enabled = YES;
            }
            
            if(([selectedDate timeIntervalSinceDate:[NSDate date]] < 0.0)){
                self.leftUpBtn.enabled = NO;
            }else{
                self.leftUpBtn.enabled = YES;
            }
            //            _myYear = [NSString stringWithFormat:@"%ld",(long)[CommonUtil getYearOfDate:selectedDate]];
            //            _myMonth = [NSString stringWithFormat:@"%ld",(long)[CommonUtil getMonthOfDate:selectedDate]];
            //            _myDay = [NSString stringWithFormat:@"%ld",(long)[CommonUtil getdayOfDate:selectedDate]];
            
        }else{
            self.dateBeginLabel.text = @"未选择";
        }
        
    }else{
        self.dateBeginLabel.text = @"未选择";
    }
    [self buttonClick:self.subjectNoneButton];
}

// 设置各个选项的默认值
- (IBAction)setSectionStatus:(id)sender
{
    
    //    self.searchTextField.text = @"";
    //    // 设置时间段默认显示时间
    //    NSDate *nowDate = [NSDate date];
    //    NSString *dateStr = [CommonUtil getStringForDate:nowDate format:@"yyyy-MM-dd"];
    self.dateBeginLabel.text = @"未选择";
    
    //    NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:30*24*60*60];
    //    self.dateEndLabel.text = [CommonUtil getStringForDate:endDate format:@"yyyy-MM-dd"];
    //    timeScreenBegin = [[CommonUtil getStringForDate:nowDate format:@"HH"] intValue];
    //    timeScreenEnd = 23;
    //    self.dateScreenBegin = nowDate;
    //    self.dateScreenEnd = endDate;
    //    self.timeBeginLabel.text = [CommonUtil getStringForDate:nowDate format:@"HH"];
    //    self.timeEndLabel.text = @"23";
    //    self.leftUpBtn2.enabled = NO;
    //    self.rightDownBtn.enabled = NO;
    //    self.leftUpBtn.enabled = NO;
    //    self.rightDownBtn2.enabled = NO;
    //
    //    self.myYear = [CommonUtil getStringForDate:nowDate format:@"yyyy"];
    //    self.myMonth = [CommonUtil getStringForDate:nowDate format:@"MM"];
    //    self.myDay = [CommonUtil getStringForDate:nowDate format:@"dd"];
    //
    //    [self buttonClick:self.allSelectedStarLevelBtn];
    //    [self buttonClick:self.allSelectedSexBtn];
    //    [self buttonClick:self.allSelectedCarTypeBtn];
    [self buttonClick:self.subjectNoneButton];
    
    //    _sex = 0;
    //
    //    self.priceLowTextField.text = nil;
    //    self.priceHighTextField.text = nil;
    //    [self deselectedButton:self.leapTypeBtn];
    //    [self deselectedButton:self.midTypeBtn];
    //    [self deselectedButton:self.goodTypeBtn];
    //
    //    self.carTypeId = @"0";
    self.subjectID = @"0";
}

// 设置button圆角
- (void)setButtonLayerInView:(UIView *)buttonView
{
    for (id objc in buttonView.subviews) {
        if ([objc isKindOfClass:[UIButton class]]) {
            UIButton *button = objc;
            button.layer.cornerRadius = 3;
        }else if ([objc isKindOfClass:[UIView class]])
        {
            UIView *view = objc;
            view.layer.cornerRadius = 3;
        }
    }
}

#pragma mark - actions
- (IBAction)dismissSelfView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 时间选择器action
- (IBAction)dateBtnClick:(id)sender
{
    [self hideKeyboardClick:nil];
    
    self.selectView.frame = self.view.bounds;
    [self.view addSubview:self.selectView];
    
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0)
    {
        // 上面的date按钮
        _upOrDown = YES;
    }else{
        _upOrDown = NO;
    }
    _dateOrTime = YES;
    
    NSString *dateString = self.dateBeginLabel.text;
    NSDate *selectedDate = nil;
    if([@"未选择" isEqualToString:dateString]){
        selectedDate = [NSDate date];
    }else{
        selectedDate = [CommonUtil getDateForString:self.dateBeginLabel.text format:@"yyyy-MM-dd"];
    }

    _myYear = [NSString stringWithFormat:@"%ld",(long)[CommonUtil getYearOfDate:selectedDate]];
    _myMonth = [NSString stringWithFormat:@"%ld",(long)[CommonUtil getMonthOfDate:selectedDate]];
    _myDay = [NSString stringWithFormat:@"%ld",(long)[CommonUtil getdayOfDate:selectedDate]];
    
    [self.datePicker reloadAllComponents];

    for(int i = 0; i < _myPickerDate.year.count; i++){
        NSString *year = _myPickerDate.year[i];
        if([_myYear intValue] == [year intValue]){
            [self.datePicker selectRow:i inComponent:0 animated:YES];
            break;
        }
    }
    
    for(int i = 0; i < _myPickerDate.month.count; i++){
        NSString *month = _myPickerDate.month[i];
        if([_myMonth intValue] == [month intValue]){
            [self.datePicker selectRow:i inComponent:1 animated:YES];
            break;
        }
    }
    
    for(int i = 0; i < _myPickerDate.day.count; i++){
        NSString *day = _myPickerDate.day[i];
        if([_myDay intValue] == [day intValue]){
            [self.datePicker selectRow:i inComponent:2 animated:YES];
            break;
        }
    }
    
    
}

- (IBAction)timeBtnClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0)
    {
        // 上面的time按钮
        _upOrDown = YES;
    }else{
        _upOrDown = NO;
    }
    _dateOrTime = NO;
}

#pragma mark 各种参数选择
// 性别
- (IBAction)sexBtnClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    _sex = (int)button.tag;
    if (!button.selected) {
        // selected
        button.selected = YES;
        button.backgroundColor = RGB(80, 203, 140);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gou_selected"]];
        imageView.frame = CGRectMake(button.frame.origin.x-7, button.frame.origin.y-7, 14, 14);
        imageView.tag = button.tag;
        [button.superview addSubview:imageView];
        
        for (id objc in button.superview.subviews) {
            // 移除其他的button的选中效果
            if ([objc isKindOfClass:[UIButton class]]) {
                UIButton *button2 = (UIButton *)objc;
                if (button2.tag != button.tag) {
                    button2.selected = NO;
                    button2.backgroundColor = RGB(240, 243, 244);
                    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
            
            if ([objc isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView2 = (UIImageView *)objc;
                if (imageView2.tag != imageView.tag) {
                    [imageView2 removeFromSuperview];
                }
            }
        }
    }
    button.layer.cornerRadius = 3;
}

// 价格区间buttonClick
- (IBAction)buttonClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        // selected
        button.selected = YES;
        button.backgroundColor = RGB(80, 203, 140);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gou_selected"]];
        imageView.frame = CGRectMake(button.frame.origin.x-7, button.frame.origin.y-7, 14, 14);
        imageView.tag = button.tag;
        [button.superview addSubview:imageView];
        
        if (button.tag == 101) {
            self.priceLowTextField.text = @"1";
            self.priceHighTextField.text = @"50";
            [self selectedButton:self.leapTypeBtn];
            [self deselectedButton:self.midTypeBtn];
            [self deselectedButton:self.goodTypeBtn];
            
        }else if (button.tag == 102) {
            self.priceLowTextField.text = @"50";
            self.priceHighTextField.text = @"100";
            [self deselectedButton:self.leapTypeBtn];
            [self selectedButton:self.midTypeBtn];
            [self deselectedButton:self.goodTypeBtn];
            
        }else if (button.tag == 103) {
            self.priceLowTextField.text = @"100";
            self.priceHighTextField.text = @"150";
            [self deselectedButton:self.leapTypeBtn];
            [self deselectedButton:self.midTypeBtn];
            [self selectedButton:self.goodTypeBtn];
        }
        
        for (id objc in button.superview.subviews) {
            // 移除其他的button的选中效果
            if ([objc isKindOfClass:[UIButton class]]) {
                UIButton *button2 = (UIButton *)objc;
                if (button2.tag != button.tag) {
                    button2.selected = NO;
                    button2.backgroundColor = RGB(240, 243, 244);
                    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
            
            if ([objc isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView2 = (UIImageView *)objc;
                if (imageView2.tag != imageView.tag) {
                    [imageView2 removeFromSuperview];
                }
            }
        }
    }
    button.layer.cornerRadius = 3;
}

- (void)deselectedButton:(UIButton *)button
{
    button.selected = NO;
    button.backgroundColor = RGB(240, 243, 244);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    for (id objc in button.superview.subviews) {
        // 移除tag非0的button
        if ([objc isKindOfClass:[UIButton class]]) {
            UIButton *button2 = (UIButton *)objc;
            if (button2.tag == button.tag) {
                button2.selected = NO;
                button2.backgroundColor = RGB(240, 243, 244);
                [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
        // 移除tag非0的imageview
        if ([objc isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)objc;
            if (imageView.tag == button.tag) {
                [imageView removeFromSuperview];
            }
        }
    }
}

- (void)selectedButton:(UIButton *)button
{
    button.selected = YES;
    button.backgroundColor = RGB(80, 203, 140);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gou_selected"]];
    imageView.frame = CGRectMake(button.frame.origin.x-7, button.frame.origin.y-7, 14, 14);
    imageView.tag = button.tag;
    [button.superview addSubview:imageView];
}

- (IBAction)hideKeyboardClick:(id)sender
{
    [_searchTextField resignFirstResponder];
    [_priceLowTextField resignFirstResponder];
    [_priceHighTextField resignFirstResponder];
}

#pragma mark 完成 、 取消
// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender
{
    [self.selectView removeFromSuperview];
}

// 完成日期选择
- (IBAction)clickForDateDone:(id)sender
{
    
    NSString *selectedDateStr = [NSString stringWithFormat:@"%@-%@-%@", _myYear, _myMonth, _myDay];
    NSDate *selectedDate = [CommonUtil getDateForString:selectedDateStr format:@"yyyy-MM-dd"];
    NSInteger year = [CommonUtil getYearOfDate:selectedDate];
    NSInteger day = [CommonUtil getdayOfDate:selectedDate];
    NSInteger month = [CommonUtil getMonthOfDate:selectedDate];
    
    NSDate *now = [NSDate date];
    NSInteger yearNow = [CommonUtil getYearOfDate:now];
    NSInteger dayNow = [CommonUtil getdayOfDate:now];
    NSInteger monthNow = [CommonUtil getMonthOfDate:now];
    
    if(year < yearNow){
        [self makeToast:@"开始日期不能早于当前日期"];
        return;
    }else if(month < monthNow){
        [self makeToast:@"开始日期不能早于当前日期"];
        return;
    }else if(year == yearNow && month == monthNow && day < dayNow){
        [self makeToast:@"开始日期不能早于当前日期"];
        return;
    }
    
    self.dateScreenBegin = selectedDate;
    self.dateBeginLabel.text = selectedDateStr;
    
    if (([selectedDate timeIntervalSinceDate:self.maxDate] > 0.0)) {
        self.rightUpBtn.enabled = NO;
    }else{
        self.rightUpBtn.enabled = YES;
    }
    
    if(([selectedDate timeIntervalSinceDate:[NSDate date]] < 0.0)){
        self.leftUpBtn.enabled = NO;
    }else{
        self.leftUpBtn.enabled = YES;
    }
    
    
    //    NSDate *endDate = [[NSDate date] initWithTimeInterval:30*24*60*60 sinceDate:[NSDate date]];
    //
    //    NSString *selectedDateStr = [NSString stringWithFormat:@"%@-%@-%@", _myYear, _myMonth, _myDay];
    //    NSDate *selectedDate = [CommonUtil getDateForString:selectedDateStr format:@"yyyy-MM-dd"];
    //    if (_upOrDown) {
    //        // up
    //        if (_dateOrTime) {
    //            // up date
    //            if ([selectedDate timeIntervalSinceDate:[NSDate date]] < 0.0) {
    //                [self makeToast:@"开始日期不能早于当前日期"];
    //                return;
    //            }else if ([selectedDate timeIntervalSinceDate:self.dateScreenEnd] > 0.0) {
    //                [self makeToast:@"开始日期不能晚于结束日期"];
    //                return;
    //            }
    //            self.dateScreenBegin = selectedDate;
    //            self.dateBeginLabel.text = selectedDateStr;
    //        }else{
    //            // up time
    //            self.timeBeginLabel.text = @"5";
    //        }
    //    }else{
    //        // down
    //        if (_dateOrTime) {
    //            // down date
    //            if ([selectedDate timeIntervalSinceDate:self.dateScreenBegin] < 0.0) {
    //                [self makeToast:@"结束日期不能早于开始日期"];
    //                return;
    //            }else if ([selectedDate timeIntervalSinceDate:endDate] > 0.0) {
    //                [self makeToast:@"只能预约30天内的课程"];
    //                return;
    //            }
    //
    //            self.dateScreenEnd = selectedDate;
    //            self.dateEndLabel.text = selectedDateStr;
    //        }else{
    //            // down time
    //            self.timeEndLabel.text = @"5";
    //        }
    //    }
    [self.selectView removeFromSuperview];
}

#pragma mark 去筛选
- (IBAction)goSearchClick:(id)sender
{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *searchStr = self.searchTextField.text;
    if (searchStr.length > 0) {
        [paramDic setObject:searchStr forKey:@"condition1"];   // 搜索
    }
    
    //    NSString *starLevel = nil;
    //    for (id objc in self.starLevelView.subviews) {
    //        if ([objc isKindOfClass:[UIButton class]]) {
    //            UIButton *button = (UIButton *)objc;
    //            if (button.selected) {
    //                int tag = (int)button.tag;
    //                starLevel = [NSString stringWithFormat:@"%d", 5 - tag];
    //            }
    //        }
    //    }
    //
    //    if (starLevel && ![starLevel isEqualToString:@"5"]) {
    //        [paramDic setObject:starLevel forKey:@"condition2"];   // 星级查询条件下限<根据这个字段查询星级在某个值以上的教练>
    //    }
    
    NSString *dateDown = self.dateBeginLabel.text;  // 日期下线
    if(![@"未选择" isEqualToString:dateDown]){
        NSDate *date = [NSDate date];
        NSInteger year = [CommonUtil getYearOfDate:date];
        NSInteger month = [CommonUtil getMonthOfDate:date];
        NSInteger day = [CommonUtil getdayOfDate:date];
        
        NSDate *date1 = [CommonUtil getDateForString:dateDown format:@"yyyy-MM-dd"];
        NSInteger year1 = [CommonUtil getYearOfDate:date1];
        NSInteger month1 = [CommonUtil getMonthOfDate:date1];
        NSInteger day1 = [CommonUtil getdayOfDate:date1];
        
        NSInteger hour;
        if(year == year1 && month == month1 && day == day1){
            hour  = [CommonUtil getHourOfDate:[NSDate date]];
        }else{
            hour = 5;
        }
        
        NSString *timeDown = [NSString stringWithFormat:@"%ld",(long)hour];  // 时间下线
        if ([timeDown intValue] < 10) {
            timeDown = [NSString stringWithFormat:@"0%@", timeDown];
        }
        NSString *dateTimeDown = [NSString stringWithFormat:@"%@ %@:00:00", dateDown, timeDown];
        [paramDic setObject:dateTimeDown forKey:@"condition3"];   // 时间下限
    }
    
    
    //    NSString *dateUp = self.dateEndLabel.text;  // 日期上线
    //    NSString *timeUp = self.timeEndLabel.text;  // 时间上线
    //    if ([timeUp intValue] < 10) {
    //        timeUp = [NSString stringWithFormat:@"0%@", timeUp];
    //    }
    //
    //    NSString *dateTimeUp = [NSString stringWithFormat:@"%@ %@:00:00", dateUp, timeUp];
    //    [paramDic setObject:dateTimeUp forKey:@"condition4"];   // 时间上限
    
    //    [paramDic setObject:[NSString stringWithFormat:@"%d", _sex] forKey:@"condition5"];   // 性别 1.男 2.女 0.不限
    
    
    [paramDic setObject:_subjectID forKey:@"condition6"];
    
    //    NSString *priceDown = self.priceLowTextField.text;
    //    if (priceDown) {
    //        [paramDic setObject:priceDown forKey:@"condition8"];   // 价格下限
    //    }
    //
    //    NSString *priceUp = self.priceHighTextField.text;
    //    if (priceUp) {
    //        [paramDic setObject:priceUp forKey:@"condition9"];   // 价格上限
    //    }
    //
    //    [paramDic setObject:_carTypeId forKey:@"condition10"];   // 车型ID  0.不限
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchCoachDict" object:paramDic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 时间选择操作
// 日期
- (IBAction)addDateClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        NSString *beginString = self.dateBeginLabel.text;
        NSDate *begin = [NSDate date];
        if([@"未选择" isEqualToString:beginString]){
            
            NSDate *selectedDate = begin;
            
            self.rightUpBtn.enabled = YES;
            self.leftUpBtn.enabled = NO;
            self.dateScreenBegin = selectedDate;
            NSString *selectedDateStr = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
            self.dateBeginLabel.text = selectedDateStr;
        }else{
            NSDate *begin = [CommonUtil getDateForString:beginString format:@"yyyy-MM-dd"];
            NSDate *selectedDate = [CommonUtil addDate2:begin year:0 month:0 day:1];
            self.leftUpBtn.enabled = YES;
            if (([selectedDate timeIntervalSinceDate:self.maxDate] > 0.0)) {
                self.rightUpBtn.enabled = NO;
            }else{
                self.rightUpBtn.enabled = YES;
            }
            
            
            self.dateScreenBegin = selectedDate;
            NSString *selectedDateStr = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
            self.dateBeginLabel.text = selectedDateStr;
        }
    }else if (button.tag == 1) {
        // 结束日期
        NSDate *selectedDate = [[NSDate date] initWithTimeInterval:24*60*60 sinceDate:self.dateScreenEnd];
        
        if (([selectedDate timeIntervalSinceDate:self.maxDate] > 0.0)) {
            self.rightDownBtn.enabled = NO;
            [self makeToast:@"只能预约30天后的课程"];
            return;
        }
        
        self.leftDownBtn.enabled = YES;
        self.dateScreenEnd = selectedDate;
        NSString *selectedDateStr = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
        self.dateEndLabel.text = selectedDateStr;
    }
}

- (IBAction)deleteDateClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        NSString *beginString = self.dateBeginLabel.text;
        NSDate *now = [NSDate date];
        if([@"未选择" isEqualToString:beginString]){
            return;
        }else{
            NSDate *begin = [CommonUtil getDateForString:beginString format:@"yyyy-MM-dd"];
            NSDate *selectedDate = [CommonUtil addDate2:begin year:0 month:0 day:-1];
            self.rightUpBtn.enabled = YES;
            if (([selectedDate timeIntervalSinceDate:now] < 0.0)) {
                self.leftUpBtn.enabled = NO;
            }else{
                self.leftUpBtn.enabled = YES;
            }
            
            self.dateScreenBegin = selectedDate;
            NSString *selectedDateStr = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
            self.dateBeginLabel.text = selectedDateStr;
        }
        
    }else{
        NSDate *selectedDate = [[NSDate date] initWithTimeInterval:-24*60*60 sinceDate:self.dateScreenEnd];
        
        if ([selectedDate timeIntervalSinceDate:self.dateScreenBegin] < 0.0) {
            self.leftDownBtn.enabled = NO;
            [self makeToast:@"结束时间不能早于开始时间"];
            return;
        }
        
        self.rightDownBtn.enabled = YES;
        self.dateScreenEnd = selectedDate;
        NSString *selectedDateStr = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
        self.dateEndLabel.text = selectedDateStr;
    }
}

- (BOOL)isDateRight
{
    if ([self.dateScreenBegin timeIntervalSinceDate:self.dateScreenEnd] < 0.0) {
        return YES;
    }
    return NO;
}

// 时间
- (IBAction)addTimeClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        timeScreenBegin++;
        if (timeScreenBegin > 23 || timeScreenBegin == 23) {
            timeScreenBegin = 23;
            button.enabled = NO;
        }
        if (timeScreenBegin > 5) {
            self.leftUpBtn2.enabled = YES;
        }
        self.timeBeginLabel.text = [NSString stringWithFormat:@"%d", timeScreenBegin];
        
    }else{
        timeScreenEnd++;
        if (timeScreenEnd > 23 || timeScreenEnd == 23) {
            timeScreenEnd = 23;
            button.enabled = NO;
        }
        if (timeScreenBegin > 5) {
            self.leftDownBtn2.enabled = YES;
        }
        self.timeEndLabel.text = [NSString stringWithFormat:@"%d", timeScreenEnd];
    }
}

- (IBAction)deleteTimeClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        timeScreenBegin--;
        if (timeScreenBegin < 5 || timeScreenBegin == 5) {
            timeScreenBegin = 5;
            self.leftUpBtn2.enabled = NO;
        }
        if (timeScreenBegin < 23) {
            self.rightUpBtn2.enabled = YES;
        }
        self.timeBeginLabel.text = [NSString stringWithFormat:@"%d", timeScreenBegin];
        
    }else{
        timeScreenEnd--;
        if (timeScreenEnd < 5 || timeScreenEnd == 5) {
            timeScreenEnd = 5;
            self.leftDownBtn2.enabled = NO;
        }
        if (timeScreenEnd < 23) {
            self.rightDownBtn2.enabled = YES;
        }
        timeScreenEnd = timeScreenEnd %24;
        self.timeEndLabel.text = [NSString stringWithFormat:@"%d", timeScreenEnd];
    }
}

#pragma mark - 监听
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect footViewRect = self.footView.frame;
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    if (self.nowTextField == nil) {
        return;
    }
    
    //获取这个textField在self.view中的位置， fromView为textField的父view
    CGRect textFrame = self.nowTextField.superview.frame;
    CGFloat textFieldY = textFrame.origin.y + CGRectGetHeight(textFrame);
    
    //将footview始终置于键盘上方
    footViewRect.origin.y = keyboardTop - footViewRect.size.height;
    
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    animationDuration += 0.1f;
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self.footView setFrame:footViewRect];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:NO];
    
    [UIView commitAnimations];
    
    if(textFieldY < keyboardTop) {
        //键盘没有挡住输入框
        return;
    }
    
    //键盘遮挡了输入框
    CGFloat _hight = textFieldY - keyboardTop;
    self.scrollView.contentOffset = CGPointMake(0, _hight+50);
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH - 110);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect footViewRect = self.footView.frame;
    footViewRect.origin.y = self.view.frame.size.height - footViewRect.size.height;
    
    // Get the duration of the animation.
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    animationDuration += 0.1f;
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self.footView setFrame:footViewRect];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:NO];
    
    [UIView commitAnimations];
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH - 110);
    self.nowTextField = nil;
}

#pragma mark - 输入框代理
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.nowTextField = textField;
    return YES;
}

#pragma mark - 接口请求
- (void)getAllTeachCarModel
{
    NSString *uri = @"/cmy?action=GetAllTeachCarModel";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:nil RequestMethod:Request_GET];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {
            // 添加按钮
            NSMutableArray *carList = [responseObject[@"teachcarlist"] mutableCopy];
            NSDictionary *otherDic = @{@"modelname":@"其它", @"modelid":@"-1"};
            [carList addObject:otherDic];
            //            self.carTypeView
            
            int _row = 0;
            CGFloat _x = 80+46+10;
            CGFloat _y = 20;
            
            for (int i = 0; i < carList.count; i++) {
                NSDictionary *carDic = carList[i];
                
                UIButton *carBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                NSString *carName = carDic[@"modelname"];
                NSString *carID= carDic[@"modelid"];
                
                // 计算字体宽度
                CGSize titleSize = [CommonUtil sizeWithString:carName fontSize:13 sizewidth:0 sizeheight:30];
                CGFloat _width = titleSize.width;
                
                if ((_x + _width + 10) > SCREEN_WIDTH) {
                    _row++;
                    _x = 80;
                }
                
                _y = 20 + _row*(30 + 10);
                carBtn.frame = CGRectMake(_x, _y, _width +20, 30);
                [self.carTypeView addSubview:carBtn];
                [carBtn setBackgroundColor:RGB(240, 243, 244)];
                [carBtn setTitle:carName forState:UIControlStateNormal];
                [carBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                carBtn.titleLabel.font = [UIFont systemFontOfSize:13];
                carBtn.tag = [carID intValue];
                carBtn.layer.cornerRadius = 3;
                carBtn.layer.masksToBounds = YES;
                [carBtn addTarget:self action:@selector(setTeacherCarTypeBtn:) forControlEvents:UIControlEventTouchUpInside];
                
                _x += _width + 20 + 10;
            }
            self.carViewHeight.constant = _y + 50;
            CGFloat _maxHeight = 540 + self.subjectView.frame.size.height + self.carTypeView.frame.size.height;
            
            self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH - 110);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [self makeToast:@"获取车型失败"];
        //        NSLog(@"获取车型失败");
    }];
    
}

- (void)getAllSubject
{
    NSString *uri = @"/cmy?action=GetAllSubject";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:nil RequestMethod:Request_GET];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {
            [DejalBezelActivityView removeViewAnimated:YES];
            // 添加按钮
            NSMutableArray *subjectList = [responseObject[@"subjectlist"] mutableCopy];
            
            int _row = 0;
            CGFloat _x = 80+46+10;
            CGFloat _y = 20;
            NSString *subjectid = nil;
            if(self.searchDic){
                subjectid = self.searchDic[@"condition6"];
            }
            
            UIButton *selectedButton = nil;
            for (int i = 0; i < subjectList.count; i++) {
                NSDictionary *subDic = subjectList[i];
                
                UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                NSString *subName = subDic[@"subjectname"];
                NSString *subID= subDic[@"subjectid"];
                
                // 计算字体宽度
                CGSize titleSize = [CommonUtil sizeWithString:subName fontSize:13 sizewidth:0 sizeheight:30];
                CGFloat _width = titleSize.width;
                
                if ((_x + _width + 10) > SCREEN_WIDTH) {
                    _row++;
                    _x = 80;
                }
                
                _y = 20 + _row*(30 + 10);
                subBtn.frame = CGRectMake(_x, _y, _width +20, 30);
                [self.selectSubjectView addSubview:subBtn];
                [subBtn setBackgroundColor:RGB(240, 243, 244)];
                [subBtn setTitle:subName forState:UIControlStateNormal];
                [subBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                subBtn.titleLabel.font = [UIFont systemFontOfSize:13];
                subBtn.tag = [subID intValue];
                subBtn.layer.cornerRadius = 3;
                subBtn.layer.masksToBounds = YES;
                [subBtn addTarget:self action:@selector(clickForSubjectNone:) forControlEvents:UIControlEventTouchUpInside];
                
                if(subjectid && [subjectid intValue] == [subID intValue]){
                    selectedButton = subBtn;
                    _subjectID = subID;
                }
                _x += _width + 20 + 10;
            }
            if(selectedButton){
                [self buttonClick:selectedButton];
            }
            
            self.selectSubjevtViewHeight.constant = _y + 50;
            //            CGFloat _maxHeight = 500 + self.carTypeView.frame.size.height + self.subjectView.frame.size.height;
            //
            //            self.scrollView.contentSize = CGSizeMake(0, MAX(SCREEN_HEIGHT, _maxHeight));
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [self makeToast:@"获取车型失败"];
        //        NSLog(@"获取车型失败");
    }];
    
}


- (IBAction)setTeacherCarTypeBtn:(UIButton *)button
{
    if (!button.selected) {
        // selected
        button.selected = YES;
        button.backgroundColor = RGB(80, 203, 140);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gou_selected"]];
        imageView.frame = CGRectMake(button.frame.origin.x-7, button.frame.origin.y-7, 14, 14);
        imageView.tag = button.tag;
        [button.superview addSubview:imageView];
        
        self.carTypeId = [NSString stringWithFormat:@"%ld", (long)button.tag];
        
        for (id objc in button.superview.subviews) {
            // 移除其他的button的选中效果
            if ([objc isKindOfClass:[UIButton class]]) {
                UIButton *button2 = (UIButton *)objc;
                if (button2.tag != button.tag) {
                    button2.selected = NO;
                    button2.backgroundColor = RGB(240, 243, 244);
                    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
            
            if ([objc isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView2 = (UIImageView *)objc;
                if (imageView2.tag != imageView.tag) {
                    [imageView2 removeFromSuperview];
                }
            }
        }
    }
    button.layer.cornerRadius = 3;
    
}

- (void)requestGetCoachList
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *searchStr = self.searchTextField.text;
    [paramDic setObject:searchStr forKey:@"condition1"];   // 搜索
    
    NSString *starLevel = nil;
    for (id objc in self.starLevelView.subviews) {
        if ([objc isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)objc;
            if (button.selected) {
                int tag = (int)button.tag;
                starLevel = [NSString stringWithFormat:@"%d", 5 - tag];
            }
        }
    }
    
    if (starLevel && ![starLevel isEqualToString:@"5"]) {
        [paramDic setObject:starLevel forKey:@"condition2"];   // 星级查询条件下限<根据这个字段查询星级在某个值以上的教练>
    }
    
    NSString *dateDown = self.dateBeginLabel.text;  // 日期下线
    
    //    NSString *dateDown = @"2015-01-31";  // 日期下线
    NSString *timeDown = self.timeBeginLabel.text;  // 时间下线
    if ([timeDown intValue] < 10) {
        timeDown = [NSString stringWithFormat:@"0%@", timeDown];
    }
    NSString *dateTimeDown = [NSString stringWithFormat:@"%@ %@:00:00", dateDown, timeDown];
    [paramDic setObject:dateTimeDown forKey:@"condition3"];   // 时间下限
    
    NSString *dateUp = self.dateEndLabel.text;  // 日期上线
    //    NSString *dateUp = @"2015-03-01";  // 日期上线
    NSString *timeUp = self.timeEndLabel.text;  // 时间上线
    if ([timeUp intValue] < 10) {
        timeUp = [NSString stringWithFormat:@"0%@", timeUp];
    }
    NSString *dateTimeUp = [NSString stringWithFormat:@"%@ %@:00:00", dateUp, timeUp];
    [paramDic setObject:dateTimeUp forKey:@"condition4"];   // 时间上限
    
    NSString *sex = @"0";
    [paramDic setObject:sex forKey:@"condition5"];   // 性别 1.男 2.女 0.不限
    
    NSString *priceDown = self.priceLowTextField.text;
    if (priceDown) {
        [paramDic setObject:priceDown forKey:@"condition8"];   // 价格下限
    }
    
    NSString *priceUp = self.priceHighTextField.text;
    if (priceUp) {
        [paramDic setObject:priceUp forKey:@"condition9"];   // 价格上限
    }
    
    NSString *carTypeId = @"0";
    [paramDic setObject:carTypeId forKey:@"condition10"];   // 车型ID  0.不限
    
    NSString *pageNum = @"0";
    [paramDic setObject:pageNum forKey:@"pagenum"];
    
    NSString *uri = @"/sbook?action=GetCoachList";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20;     // 网络超时时长设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            [CommonUtil saveObjectToUD:paramDic key:@"searchParamDic"];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            
            NSLog(@"code = %@",  responseObject[@"code"]);
            NSLog(@"message = %@", responseObject[@"message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"GetNearByCoach == %@", ERR_NETWORK);
        [self makeToast:ERR_NETWORK];
    }];
}

#pragma mark - PickerVIew
// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.0;
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([pickerView isEqual:self.datePicker]) {
        return 3;
    }
    else {
        return 0;
    }
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:self.datePicker]) {
        switch (component) { // component是栏目index，从0开始，后面的row也一样是从0开始
            case 0: { // 第一栏为年
                return self.myPickerDate.year.count;
            }
            case 1: // 第二栏为月份
                return self.myPickerDate.month.count;
            case 2: { // 第三栏为对应月份的天数
                int selectMonth = [_myMonth intValue];
                if (selectMonth == 1 || selectMonth == 3 || selectMonth == 5 || selectMonth == 7 || selectMonth == 8 || selectMonth == 10 || selectMonth == 12) {
                    return 31;
                }
                else if (selectMonth == 4 || selectMonth == 6 || selectMonth == 9 || selectMonth == 11) {
                    return 30;
                }
                else if (selectMonth == 2) {
                    int selectYear = [_myYear intValue];
                    if ((selectYear % 4 == 0 && selectYear % 100 != 0) || selectYear % 400 == 0) {
                        return 29;
                    }
                    else {
                        return 28;
                    }
                }
            }
            default:
                return 0;
        }
    }
    
    else {
        return 0;//如果不是就返回0
    }
}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    if ([pickerView isEqual:self.datePicker]) {
        
        UILabel *dateLabel = (UILabel *)view;
        if (!dateLabel) {
            dateLabel = [[UILabel alloc] init];
            [dateLabel setFont:[UIFont systemFontOfSize:21]];
            [dateLabel setTextColor:[UIColor whiteColor]];
            [dateLabel setBackgroundColor:[UIColor clearColor]];
        }
        
        switch (component) {
            case 0: {
                NSString *currentYear = self.myPickerDate.year[row];
                [dateLabel setText:currentYear];
                dateLabel.textAlignment = NSTextAlignmentRight;
                break;
            }
            case 1: {
                
                NSString *currentMonth = self.myPickerDate.month[row];
                //                [dateLabel setText:[NSString stringWithFormat:@"%@月",currentMonth]];
                [dateLabel setText:currentMonth];
                dateLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case 2: {
                NSString *currentDay = self.myPickerDate.day[row];
                [dateLabel setText:currentDay];
                dateLabel.textAlignment = NSTextAlignmentLeft;
                break;
            }
            default:
                break;
        }
        
        return dateLabel;
    }
    
    else {
        return myView;
    }
    
    //    return myView;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:self.datePicker]) {
        switch (component) {
            case 0: {
                _myYear = self.myPickerDate.year[row];
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:YES];
                [self pickerView:pickerView didSelectRow:0 inComponent:2];
                break;
            }
            case 1: {
                _myMonth = self.myPickerDate.month[row];
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:YES];
                [self pickerView:pickerView didSelectRow:0 inComponent:2];
                break;
            }
            case 2: {
                _myDay = self.myPickerDate.day[row];
                break;
            }
            default:
                break;
        }
        //        [pickerView reloadAllComponents];
    }
}

- (IBAction)clickForSubjectNone:(id)sender {
    UIButton *button = (UIButton*)sender;
    if (!button.selected) {
        // selected
        button.selected = YES;
        button.backgroundColor = RGB(80, 203, 140);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gou_selected"]];
        imageView.frame = CGRectMake(button.frame.origin.x-7, button.frame.origin.y-7, 14, 14);
        imageView.tag = button.tag;
        [button.superview addSubview:imageView];
        
        self.subjectID = [NSString stringWithFormat:@"%ld", (long)button.tag];
        
        for (id objc in button.superview.subviews) {
            // 移除其他的button的选中效果
            if ([objc isKindOfClass:[UIButton class]]) {
                UIButton *button2 = (UIButton *)objc;
                if (button2.tag != button.tag) {
                    button2.selected = NO;
                    button2.backgroundColor = RGB(240, 243, 244);
                    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
            
            if ([objc isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView2 = (UIImageView *)objc;
                if (imageView2.tag != imageView.tag) {
                    [imageView2 removeFromSuperview];
                }
            }
        }
    }
    button.layer.cornerRadius = 3;
}
@end
