//
//  CoachScreenViewController.m
//  guangda_student
//
//  Created by Dino on 15/4/24.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachScreenViewController.h"
#import "CommonUtil+Date.h"
#import "AppDelegate.h"
#import "XBSchool.h"

@interface CoachScreenViewController ()
<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    CGFloat _keyboardY;     // 键盘弹出时的y坐标
    BOOL _upOrDown;         // yes == up / no == down
    BOOL _dateOrTime;       // yes == date / no == time
    
    int timeScreenBegin;    // 开始时间
    int timeScreenEnd;
    
    int _sex;
    
    BOOL _pickerIsShown;
}

// 学校选择器
@property (weak, nonatomic) IBOutlet UIControl *showSchoolView;
@property (weak, nonatomic) IBOutlet UITextField *schoolNameInputField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerBoxBottomSpaceCon;

@property (weak, nonatomic) IBOutlet UIPickerView *schoolPicker;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (strong, nonatomic) XBSchool *selectSchool;


// 页面数据
@property (strong, nonatomic) NSDate *maxDate;
@property (strong, nonatomic) NSMutableArray *schoolArray;
@property (strong, nonatomic) NSMutableArray *matchedSchoolArray;

@end

@implementation CoachScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self staticViewConfig];
    
    // 缺省参数
    self.myPickerDate = [[MyDate alloc] initWithMaxDayFromNow:29];
    self.maxDate = [CommonUtil addDate2:[NSDate date] year:0 month:0 day:29];
    NSInteger year = [CommonUtil getYearOfDate:self.maxDate];
    NSInteger yue = [CommonUtil getMonthOfDate:self.maxDate];
    NSInteger ri = [CommonUtil getdayOfDate:self.maxDate];
    self.maxDate = [CommonUtil getDateForString:[NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",(long)year,(long)yue,(long)ri] format:nil];
    
    _sex = 0;
    self.carTypeId = @"0";
    self.subjectID = @"0";
    
    [self initWithDic];
    
    [self getAllSubject];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH - 110);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_searchTextField resignFirstResponder];
}

#pragma mark - ViewConfig
- (void)staticViewConfig {
    self.selectContentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 110);
    [self.scrollView addSubview:self.selectContentView];
    self.scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT - 110);
    
    self.btnGoSearch.layer.cornerRadius = 3;
    self.btnReset.layer.cornerRadius = 3;
    self.btnReset.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnReset.layer.borderWidth = 1;
    //    self.subjectNoneButton.layer.cornerRadius = 3;
    
    // 驾校选择
    self.showSchoolView.layer.cornerRadius = 3;
    self.showSchoolView.layer.borderWidth = 0.7;
    self.showSchoolView.layer.borderColor = RGB(211, 212, 215).CGColor;
    self.selectView.frame = [UIScreen mainScreen].bounds;
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardClick:)];
    tapGestureRecognizer1.numberOfTapsRequired = 1;
    [self.selectContentView addGestureRecognizer: tapGestureRecognizer1];
    [tapGestureRecognizer1 setCancelsTouchesInView:NO];
    
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardClick:)];
    tapGestureRecognizer2.numberOfTapsRequired = 1;
    [self.selectView addGestureRecognizer:tapGestureRecognizer2];
    
    
    
    
    
    // 监听驾校搜索输入框
    [self.schoolNameInputField addTarget:self action:@selector(inputSchoolNameChanged:) forControlEvents:UIControlEventEditingChanged];
}

//根据已有的条件初始化
- (void) initWithDic{
    if(self.searchDic){
        // 日期
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
            
            
            
            
        }else{
            self.dateBeginLabel.text = @"不限";
        }
        
        // 驾校
        NSString *schoolName = self.searchDic[@"driveschoolname"];
        if ([CommonUtil isEmpty:schoolName]) {
            self.schoolLabel.text = @"不限驾校";
            self.selectSchool = nil;
        } else {
            XBSchool *school = [[XBSchool alloc] init];
            school.ID = self.searchDic[@"driverschoolid"];
            school.name = schoolName;
            self.selectSchool = school;
            self.schoolLabel.text = schoolName;
        }
        
    }else{
        self.dateBeginLabel.text = @"不限";
        self.schoolLabel.text = @"不限驾校";
    }
}

// 设置各个选项的默认值
- (IBAction)setSectionStatus:(id)sender
{
    self.dateBeginLabel.text = @"不限";
    self.subjectID = @"0";
    self.schoolLabel.text = @"不限驾校";
    self.selectSchool = nil;
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
    if([@"不限" isEqualToString:dateString]){
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

// 改变科目选中按钮的状态
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

- (void)hideKeyboardClick:(id)sender
{
    if (_pickerIsShown) {
        [_schoolNameInputField resignFirstResponder];
    } else {
        [_searchTextField resignFirstResponder];
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
    CGFloat keyboardHeight = keyboardRect.size.height;
//    if (self.nowTextField == nil) {
//        return;
//    }
    
    //获取这个textField在self.view中的位置， fromView为textField的父view
//    CGRect textFrame = self.nowTextField.superview.frame;
//    CGFloat textFieldY = textFrame.origin.y + CGRectGetHeight(textFrame);
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    if (_pickerIsShown == NO) {
        //将footview始终置于键盘上方
//        footViewRect.origin.y = keyboardTop - footViewRect.size.height;
        [UIView animateWithDuration:animationDuration animations:^{
//            self.footView.frame = footViewRect;
            self.footViewBottomSpaceCon.constant = keyboardHeight;
            [self.view layoutIfNeeded];
        }];
    } else {
        // 上移picherView
        [UIView animateWithDuration:animationDuration animations:^{
            self.pickerBoxBottomSpaceCon.constant = SCREEN_HEIGHT - 64 - 240;
            [self.view layoutIfNeeded];
        }];
    }
    
//    if(textFieldY < keyboardTop) {
//        //键盘没有挡住输入框
//        return;
//    }
    
    //键盘遮挡了输入框
//    CGFloat _hight = textFieldY - keyboardTop;
//    self.scrollView.contentOffset = CGPointMake(0, _hight+50);
//    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH - 110);
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
    
    if (_pickerIsShown == NO) {
        [UIView animateWithDuration:animationDuration animations:^{
//            self.footView.frame = footViewRect;
            self.footViewBottomSpaceCon.constant = 0;
            [self.view layoutIfNeeded];
        }];
    } else {
        // 下移picherView
        [UIView animateWithDuration:animationDuration animations:^{
            self.pickerBoxBottomSpaceCon.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH - 110);
//    self.nowTextField = nil;
}

#pragma mark - 输入框代理
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.nowTextField = textField;
    return YES;
}

// 显示输入名字匹配的驾校
- (void)inputSchoolNameChanged:(UITextField *)textField {
    [self.matchedSchoolArray removeAllObjects];
    NSString *matchName = textField.text;
    if (matchName.length == 0) {
        [self.matchedSchoolArray addObjectsFromArray:self.schoolArray];
    }
    else {
        for (XBSchool *school in self.schoolArray) {
            NSRange range = [school.name rangeOfString:matchName];
            if (range.length > 0) {
                [self.matchedSchoolArray addObject:school];
            }
        }
    }
    [self.schoolPicker reloadAllComponents];
}

#pragma mark - 接口请求
// 获取驾校列表
- (void)postGetSchollList
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    // 定位城市名
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSString *locateCityName = delegate.locationResult.addressDetail.city;
    locateCityName = [locateCityName stringByReplacingOccurrencesOfString:@"市" withString:@""]; // 去掉城市名里的“市”
    if (![CommonUtil isEmpty:locateCityName]) {
        paramDic[@"cityname"] = locateCityName;
    }
    
    NSString *uri = @"/sbook?action=GETDRIVERSCHOOLBYCITYNAME";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            NSArray *schools = responseObject[@"dslist"];
            if (schools == nil || schools.count == 0) {
                [self makeToast:@"抱歉，没有可选的驾校"];
                return;
            }
            self.schoolArray = [XBSchool schoolsWithArray:responseObject[@"dslist"]];
            self.matchedSchoolArray = [NSMutableArray arrayWithArray:self.schoolArray];
            [self chooseSchoolClick:nil];
        } else {
            [self makeToast:responseObject[@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self makeToast:ERR_NETWORK];
    }];
    
}

// 获取所有科目类型
- (void)getAllSubject
{
    NSString *uri = @"/cmy?action=GetAllSubject";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:nil RequestMethod:Request_GET];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            
            // 添加按钮
            NSMutableArray *subjectList = [responseObject[@"subjectlist"] mutableCopy];
            [self addSubjectBtn:subjectList];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self makeToast:ERR_NETWORK];
    }];
    
}

// 添加车型选择按钮
- (void)addSubjectBtn:(NSMutableArray *)subjectList {
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
    
    self.selectSubjevtViewHeight.constant = _y + 50;
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
    else if ([pickerView isEqual:self.schoolPicker]) {
        return 1;
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
    
    else if ([pickerView isEqual:self.schoolPicker]) {
        return self.matchedSchoolArray.count;
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
    
    // 驾校选择器
    else if ([pickerView isEqual:self.schoolPicker]) {
        UILabel *schoolLabel = (UILabel *)view;
        if (!schoolLabel) {
            schoolLabel = [[UILabel alloc] init];
            [schoolLabel setFont:[UIFont systemFontOfSize:16]];
            [schoolLabel setTextColor:[UIColor whiteColor]];
            [schoolLabel setBackgroundColor:[UIColor clearColor]];
            schoolLabel.textAlignment = NSTextAlignmentCenter;
        }
        XBSchool *school = self.matchedSchoolArray[row];
        schoolLabel.text = school.name;
        return schoolLabel;
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

#pragma mark - 生成查询条件字典
- (NSMutableDictionary *)searchDictCreate {
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *searchStr = self.searchTextField.text;
    if (searchStr.length > 0) {
        [paramDic setObject:searchStr forKey:@"condition1"];   // 搜索文字
    }
    
//    NSString *dateDown = self.dateBeginLabel.text;  // 日期下线
//    if(![@"不限" isEqualToString:dateDown]){
//        NSDate *date = [NSDate date];
//        NSInteger year = [CommonUtil getYearOfDate:date];
//        NSInteger month = [CommonUtil getMonthOfDate:date];
//        NSInteger day = [CommonUtil getdayOfDate:date];
//        
//        NSDate *date1 = [CommonUtil getDateForString:dateDown format:@"yyyy-MM-dd"];
//        NSInteger year1 = [CommonUtil getYearOfDate:date1];
//        NSInteger month1 = [CommonUtil getMonthOfDate:date1];
//        NSInteger day1 = [CommonUtil getdayOfDate:date1];
//        
//        NSInteger hour;
//        if(year == year1 && month == month1 && day == day1){
//            hour  = [CommonUtil getHourOfDate:[NSDate date]];
//        }else{
//            hour = 5;
//        }
    
//        NSString *timeDown = [NSString stringWithFormat:@"%ld",(long)hour];  // 时间下线
//        if ([timeDown intValue] < 10) {
//            timeDown = [NSString stringWithFormat:@"0%@", timeDown];
//        }
//        NSString *dateTimeDown = [NSString stringWithFormat:@"%@ %@:00:00", dateDown, timeDown];
//        [paramDic setObject:dateTimeDown forKey:@"condition3"];   // 时间下限
//    }
    
    [paramDic setObject:_subjectID forKey:@"condition6"];
    
    // 驾校
    if (self.selectSchool) {
        paramDic[@"driverschoolid"] = self.selectSchool.ID;
        paramDic[@"driveschoolname"] = self.selectSchool.name;
    }
    
    paramDic[@"comefrom"] = self.comeFrom;

    return paramDic;
}


#pragma mark - Action
// 重置筛选条件
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

// 去筛选
- (IBAction)goSearchClick:(id)sender
{
    [self.searchTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SearchCoachDict" object:[self searchDictCreate]];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender
{
    [self.selectView removeFromSuperview];
    _pickerIsShown = NO;
}

// 完成日期选择
//- (IBAction)clickForDateDone:(id)sender
//{
//    
//    NSString *selectedDateStr = [NSString stringWithFormat:@"%@-%@-%@", _myYear, _myMonth, _myDay];
//    NSDate *selectedDate = [CommonUtil getDateForString:selectedDateStr format:@"yyyy-MM-dd"];
//    NSInteger year = [CommonUtil getYearOfDate:selectedDate];
//    NSInteger day = [CommonUtil getdayOfDate:selectedDate];
//    NSInteger month = [CommonUtil getMonthOfDate:selectedDate];
//    
//    NSDate *now = [NSDate date];
//    NSInteger yearNow = [CommonUtil getYearOfDate:now];
//    NSInteger dayNow = [CommonUtil getdayOfDate:now];
//    NSInteger monthNow = [CommonUtil getMonthOfDate:now];
//    
//    if(year < yearNow){
//        [self makeToast:@"开始日期不能早于当前日期"];
//        return;
//    }else if(month < monthNow){
//        [self makeToast:@"开始日期不能早于当前日期"];
//        return;
//    }else if(year == yearNow && month == monthNow && day < dayNow){
//        [self makeToast:@"开始日期不能早于当前日期"];
//        return;
//    }
//    
//    if(([selectedDate timeIntervalSinceDate:self.maxDate] > 0.0)){
//        [self makeToast:@"最多只能筛选30天的数据"];
//        return;
//    }
//    
//    self.dateScreenBegin = selectedDate;
//    self.dateBeginLabel.text = selectedDateStr;
//    
//    if (([selectedDate timeIntervalSinceDate:self.maxDate] >= 0.0)) {
//        self.rightUpBtn.enabled = NO;
//    }else{
//        self.rightUpBtn.enabled = YES;
//    }
//    
//    if(([selectedDate timeIntervalSinceDate:[NSDate date]] <= 0.0)){
//        self.leftUpBtn.enabled = NO;
//    }else{
//        self.leftUpBtn.enabled = YES;
//    }
//    
//    [self.selectView removeFromSuperview];
//}



// 日期
- (IBAction)addDateClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        NSString *beginString = self.dateBeginLabel.text;
        NSDate *begin = [NSDate date];
        if([@"不限" isEqualToString:beginString]){
            
            NSDate *selectedDate = begin;
            
            self.rightUpBtn.enabled = YES;
            self.leftUpBtn.enabled = NO;
            self.dateScreenBegin = selectedDate;
            NSString *selectedDateStr = [CommonUtil getStringForDate:selectedDate format:@"yyyy-MM-dd"];
            self.dateBeginLabel.text = selectedDateStr;
        }else{
            NSDate *begin = [CommonUtil getDateForString:[NSString stringWithFormat:@"%@ 00:00:00",beginString] format:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *selectedDate = [CommonUtil addDate2:begin year:0 month:0 day:1];
            self.leftUpBtn.enabled = YES;
            if ([selectedDate timeIntervalSinceDate:self.maxDate] >= 0.0) {
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
            [self makeToast:@"只能预约30天后的课程"];
            return;
        }
        
        self.dateScreenEnd = selectedDate;
    }
}

- (IBAction)deleteDateClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        NSString *beginString = self.dateBeginLabel.text;
        NSDate *now = [NSDate date];
        if([@"不限" isEqualToString:beginString]){
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
            [self makeToast:@"结束时间不能早于开始时间"];
            return;
        }
        
        self.dateScreenEnd = selectedDate;
    }
}

- (IBAction)dismissSelfView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)chooseSchoolClick:(id)sender {
    if (self.schoolArray) {
        [self.schoolPicker reloadAllComponents];
        [self.view addSubview:self.selectView];
        _pickerIsShown = YES;
    } else {
        [self postGetSchollList];
    }
}

// 完成驾校选择
- (IBAction)selectDoneClick:(id)sender {
    NSInteger index = [self.schoolPicker selectedRowInComponent:0];
    XBSchool *school = self.matchedSchoolArray[index];
    self.schoolLabel.text = school.name;
    self.selectSchool = school;
    [self.selectView removeFromSuperview];
    _pickerIsShown = NO;
}

@end
