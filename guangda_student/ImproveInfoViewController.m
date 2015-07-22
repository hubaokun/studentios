//
//  ImproveInfoViewController.m
//  guangda_student
//
//  Created by duanjycc on 15/3/27.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

// 个人信息
#import "ImproveInfoViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MyDate.h"
#import "LoginViewController.h"

#define MYDATE

@interface ImproveInfoViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    NSString    *previousTextFieldContent;
    UITextRange *previousSelection;
    int j;
}
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView  *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;

// 日期选择器数据
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDateComponents *selectedDateComponets;

@property (strong, nonatomic) MyDate *myPickerDate;
@property (strong, nonatomic) NSString *myYear;
@property (strong, nonatomic) NSString *myMonth;
@property (strong, nonatomic) NSString *myDay;

// 地址选择器数据
@property (strong, nonatomic) NSDictionary *stateZips;//省市
@property (strong, nonatomic) NSArray *cityArray;
@property (strong, nonatomic) NSArray *provinceArray;
@property (nonatomic, strong) NSString *selectCity;
@property (nonatomic, strong) NSString *selectPro;
@property (strong, nonatomic) NSMutableDictionary *selectDic;

@end

@implementation ImproveInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
    
    // 日期选择
#ifdef TEST
    [self testDateSetting];
#endif
    
#ifdef MYDATE
    self.myPickerDate = [[MyDate alloc] initWithEndYear:@"2015"];
#endif
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showLocalData];
}

#pragma mark - 页面设置
- (void)settingView {
    [self.mainScrollView contentSizeToFit];

    self.addrField.delegate = self;
    self.emergentPersonField.delegate = self;
    self.emergentPhoneField.delegate = self;
    
    [self.sexSelectBtn addTarget:self action:@selector(clickForSexSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.citySelectBtn addTarget:self action:@selector(clickForCitySelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.birthdaySelectBtn addTarget:self action:@selector(clickForDateSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.emergentPhoneField addTarget:self action:@selector(formatPhoneNumber:) forControlEvents:UIControlEventEditingChanged];
    
    // 选择器
    self.selectView.frame = [UIScreen mainScreen].bounds;
    
    self.sexPicker.delegate = self;
    self.sexPicker.dataSource = self;
    self.cityPicker.delegate = self;
    self.cityPicker.dataSource = self;
    self.datePicker.delegate = self;
    self.datePicker.dataSource = self;
    
    self.sexConfirmBtn.layer.borderWidth = 1;
    self.sexConfirmBtn.layer.borderColor = [RGB(248, 99, 95) CGColor];
    self.sexConfirmBtn.layer.cornerRadius = 4;
    
    self.cityConfirmBtn.layer.borderWidth = 1;
    self.cityConfirmBtn.layer.borderColor = [RGB(248, 99, 95) CGColor];
    self.cityConfirmBtn.layer.cornerRadius = 4;
    
    self.dateConfirmBtn.layer.borderWidth = 1;
    self.dateConfirmBtn.layer.borderColor = [RGB(248, 99, 95) CGColor];
    self.dateConfirmBtn.layer.cornerRadius = 4;
    
    [self initSexData];
    [self initCityData];
    
    // 点击背景退出键盘
    [self keyboardHiddenFun];
}

// 显示本地数据
- (void)showLocalData {
    [self loadLocalData];
    NSString *genderStr = (_gender == 2)? @"女" : @"男";
    self.sexField.text = genderStr;
    self.birthdayField.text = _birthday;
    self.cityField.text = _city;
    self.addrField.text = _address;
    self.emergentPersonField.text = _urgentPerson;
    
    // 电话号码以3-4-4格式显示
    if (![CommonUtil isEmpty:_urgentPhone]) {
//        NSMutableString *phone = [[NSMutableString alloc] initWithString:_urgentPhone];
//        [phone insertString:@" " atIndex:3];
//        [phone insertString:@" " atIndex:8];
        self.emergentPhoneField.text = _urgentPhone;
    }
}

- (void)testDateSetting {
    self.calendar = [NSCalendar currentCalendar];
    self.startDate = [NSDate dateWithTimeIntervalSince1970:0];
    self.endDate = [NSDate dateWithTimeIntervalSinceNow:0];
    self.selectedDateComponets = [[NSDateComponents alloc] init];
}

#pragma mark - 页面特性
// 点击背景退出键盘
- (void)keyboardHiddenFun {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}
-(void)backupgroupTap:(id)sender{
    [self.addrField resignFirstResponder];
    [self.emergentPersonField resignFirstResponder];
    [self.emergentPhoneField resignFirstResponder];
}

// 开始编辑，铅笔变红
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIImage *image = [UIImage imageNamed:@"icon_redpencil_userbaseinfo"];
    
    if ([textField isEqual:self.addrField]) {
        [self.addrPencilImage setImage:image];
    }
    
    else if ([textField isEqual:self.emergentPersonField]) {
        [self.emergentPersonPencilImage setImage:image];
    }
    
    else if ([textField isEqual:self.emergentPhoneField]) {
        [self.emergentPhonePencilImage setImage:image];
    }
}

// 结束编辑，铅笔变灰
- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIImage *image = [UIImage imageNamed:@"icon_pencil_userinfocell"];
    
    if ([textField isEqual:self.addrField]) {
        [self.addrPencilImage setImage:image];
    }
    
    else if ([textField isEqual:self.emergentPersonField]) {
        [self.emergentPersonPencilImage setImage:image];
    }
    
    else if ([textField isEqual:self.emergentPhoneField]) {
        [self.emergentPhonePencilImage setImage:image];
    }
}

// 手机号码3-4-4格式
- (void)formatPhoneNumber:(UITextField*)textField
{
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    //    NSLog(@"targetCursorPosition:%li", (long)targetCursorPosition);
    // nStr表示不带空格的号码
    NSString* nStr = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* preTxt = [previousTextFieldContent stringByReplacingOccurrencesOfString:@" "
                                                                           withString:@""];
    
    char editFlag = 0;// 正在执行删除操作时为0，否则为1
    
    if (nStr.length <= preTxt.length) {
        editFlag = 0;
    }
    else {
        editFlag = 1;
    }
    
    // textField设置text
    if (nStr.length > 11)
    {
        textField.text = previousTextFieldContent;
        textField.selectedTextRange = previousSelection;
        return;
    }
    
    // 空格
    NSString* spaceStr = @" ";
    
    NSMutableString* mStrTemp = [NSMutableString new];
    int spaceCount = 0;
    if (nStr.length < 3 && nStr.length > -1)
    {
        spaceCount = 0;
    }else if (nStr.length < 7 && nStr.length >2)
    {
        spaceCount = 1;
        
    }else if (nStr.length < 12 && nStr.length > 6)
    {
        spaceCount = 2;
    }
    
    for (int i = 0; i < spaceCount; i++)
    {
        if (i == 0) {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(0, 3)], spaceStr];
        }else if (i == 1)
        {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(3, 4)], spaceStr];
        }else if (i == 2)
        {
            [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
        }
    }
    
    if (nStr.length == 11)
    {
        [mStrTemp appendFormat:@"%@%@", [nStr substringWithRange:NSMakeRange(7, 4)], spaceStr];
    }
    
    if (nStr.length < 4)
    {
        [mStrTemp appendString:[nStr substringWithRange:NSMakeRange(nStr.length-nStr.length % 3,
                                                                    nStr.length % 3)]];
    }else if(nStr.length > 3)
    {
        NSString *str = [nStr substringFromIndex:3];
        [mStrTemp appendString:[str substringWithRange:NSMakeRange(str.length-str.length % 4,
                                                                   str.length % 4)]];
        if (nStr.length == 11)
        {
            [mStrTemp deleteCharactersInRange:NSMakeRange(13, 1)];
        }
    }
    //    NSLog(@"=======mstrTemp=%@",mStrTemp);
    
    textField.text = mStrTemp;
    // textField设置selectedTextRange
    NSUInteger curTargetCursorPosition = targetCursorPosition;// 当前光标的偏移位置
    if (editFlag == 0)
    {
        //删除
        if (targetCursorPosition == 9 || targetCursorPosition == 4)
        {
            curTargetCursorPosition = targetCursorPosition - 1;
        }
    }
    else {
        //添加
        if (nStr.length == 8 || nStr.length == 3)
        {
            curTargetCursorPosition = targetCursorPosition + 1;
        }
    }
    
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument]
                                                              offset:curTargetCursorPosition];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition
                                                         toPosition :targetPosition]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    previousTextFieldContent = textField.text;
    previousSelection = textField.selectedTextRange;
    
    return YES;
}

#pragma mark - PickerVIew
// 数据
- (void)initSexData {
    _sexArray = [NSArray arrayWithObjects:@"男", @"女", nil];
}

- (void)initCityData {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"statedictionary" ofType:@"plist"];
    NSDictionary *dictionary = [[NSDictionary alloc ] initWithContentsOfFile :plistPath];
    
    self.stateZips = dictionary;
    NSArray *components = [self.stateZips allKeys];
    NSArray *sorted = [components sortedArrayUsingSelector: @selector (compare:)];
    self.provinceArray = [sorted mutableCopy];
    
    NSString *selectedState = [self.provinceArray objectAtIndex :0 ];
    
    NSArray *array = [[NSArray alloc] initWithArray:(NSArray *)[self.stateZips objectForKey:selectedState]];
    self.cityArray = array;
}

// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.0;
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([pickerView isEqual:self.sexPicker]) {
        return 1;
    }
    else if ([pickerView isEqual:self.cityPicker]) {
        return 2;
    }
    else if ([pickerView isEqual:self.datePicker]) {
        return 3;
    }
    else {
        return 0;
    }
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if ([pickerView isEqual:self.sexPicker]) {
        return _sexArray.count;
    }
    
    else if ([pickerView isEqual:self.cityPicker]) {
        if (component == 0) {
            return _provinceArray.count;
        } else {
            return _cityArray.count;
        }
    }
    
#ifdef TEST
    else if ([pickerView isEqual:self.datePicker]) {
        switch (component) { // component是栏目index，从0开始，后面的row也一样是从0开始
            case 0: { // 第一栏为年，这里startDate和endDate为起始时间和截止时间，请自行指定
                NSDateComponents *startCpts = [self.calendar components:NSYearCalendarUnit
                                                               fromDate:self.startDate];
                NSDateComponents *endCpts = [self.calendar components:NSYearCalendarUnit
                                                             fromDate:self.endDate];
                return [endCpts year] - [startCpts year] + 1;
            }
            case 1: // 第二栏为月份
                return 12;
            case 2: { // 第三栏为对应月份的天数
                NSRange dayRange = [self.calendar rangeOfUnit:NSDayCalendarUnit
                                                       inUnit:NSMonthCalendarUnit
                                                      forDate:self.selectedDate];
//                DLog(@"current month: %d, day number: %d", [[self.calendar components:NSMonthCalendarUnit fromDate:self.selectedDate] month], dayRange.length);
                NSLog(@"selecedday === %@",self.selectedDate);
                return dayRange.length;
            }
            default:
                return 0;
        }
    }
#endif
    
#ifdef MYDATE
    else if ([pickerView isEqual:self.datePicker]) {
        switch (component) { // component是栏目index，从0开始，后面的row也一样是从0开始
            case 0: { // 第一栏为年
                return self.myPickerDate.year.count;
            }
            case 1: // 第二栏为月份
                return 12;
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
#endif
    
    else {
        return 0;//如果不是就返回0
    }
}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    
    // 性别选择器
    if ([pickerView isEqual:self.sexPicker]) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 45)];
        
        myView.textAlignment = NSTextAlignmentCenter;
        
        myView.text = [_sexArray objectAtIndex:row];
        
        myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
        
        myView.textColor = [UIColor whiteColor];
        
        myView.backgroundColor = [UIColor clearColor];
        
        return myView;
    }
    
    // 城市选择器
    else if ([pickerView isEqual:self.cityPicker]) {
        
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 45)];
        
        myView.textAlignment = NSTextAlignmentCenter;
        
        if (component == 0) {
            NSString *state = [self.provinceArray objectAtIndex:row];
            state = [state substringFromIndex:2];
            myView.text = state;
        } else {
            myView.text = [_cityArray objectAtIndex:row];
        }

        myView.font = [UIFont systemFontOfSize:21];         //用label来设置字体大小
        
        myView.textColor = [UIColor whiteColor];
        
        myView.backgroundColor = [UIColor clearColor];
        
        return myView;
    }
    
    // 日期选择器
#ifdef TEST
    else if ([pickerView isEqual:self.datePicker]) {
        
        UILabel *dateLabel = (UILabel *)view;
        if (!dateLabel) {
            dateLabel = [[UILabel alloc] init];
            [dateLabel setFont:[UIFont systemFontOfSize:21]];
            [dateLabel setTextColor:[UIColor whiteColor]];
            [dateLabel setBackgroundColor:[UIColor clearColor]];
        }
        
        switch (component) {
            case 0: {
                NSDateComponents *components = [self.calendar components:NSYearCalendarUnit
                                                                fromDate:self.startDate];
                NSString *currentYear = [NSString stringWithFormat:@"%ld年", [components year] + row];
                [dateLabel setText:currentYear];
                dateLabel.textAlignment = NSTextAlignmentRight;
                break;
            }
            case 1: { // 返回月份可以用DateFormatter，这样可以支持本地化
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
                NSArray *monthSymbols = [formatter monthSymbols];
                [dateLabel setText:[monthSymbols objectAtIndex:row]];
                dateLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case 2: {
                NSRange dateRange = [self.calendar rangeOfUnit:NSDayCalendarUnit
                                                        inUnit:NSMonthCalendarUnit
                                                       forDate:self.selectedDate];
                NSString *currentDay = [NSString stringWithFormat:@"%02lu", (row + 1) % (dateRange.length + 1)];
                [dateLabel setText:currentDay];
                dateLabel.textAlignment = NSTextAlignmentLeft;
                break;
            }
            default:
                break;
        }
        
        return dateLabel;
    }
#endif
    
#ifdef MYDATE
    else if ([pickerView isEqual:self.datePicker]) {
        
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
                [dateLabel setText:[NSString stringWithFormat:@"%@月",currentMonth]];
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
#endif
    
    else {
        return myView;
    }
    
//    return myView;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
#ifdef TEST
    if ([pickerView isEqual:self.datePicker]) {
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        switch (component) {
            case 0: {
//                [pickerView selectRow:0 inComponent:2 animated:YES];
                
                NSDateComponents *indicatorComponents = [self.calendar components:NSYearCalendarUnit
                                                                         fromDate:self.startDate];
                NSInteger year = [indicatorComponents year] + row;
                NSDateComponents *targetComponents = [self.calendar components:unitFlags
                                                                      fromDate:self.selectedDate];
                [targetComponents setYear:year];
                
//                self.selectedDateComponets = targetComponents;
                [self.selectedDateComponets setYear:year];
                
//                self.selectedDate = [self.calendar dateFromComponents:targetComponents]; // 获得当前选定年
//                NSLog(@"year === %@",self.selectedDate);
                break;
            }
            case 1: {
//                [pickerView selectRow:0 inComponent:2 animated:YES];
                
                NSDateComponents *targetComponents = [self.calendar components:unitFlags
                                                                      fromDate:self.selectedDate];
                [targetComponents setMonth:row + 1];
                
//                self.selectedDateComponets = targetComponents;
                [self.selectedDateComponets setMonth:row + 1];
                
//                self.selectedDate = [self.calendar dateFromComponents:targetComponents]; // 获得当前选定月
//                NSLog(@"month === %@",self.selectedDate);
                
                break;
            }
            case 2: {
                NSDateComponents *targetComponents = [self.calendar components:unitFlags
                                                                      fromDate:self.selectedDate];
                [targetComponents setDay:row + 1];
                
//                self.selectedDateComponets = targetComponents;
                [self.selectedDateComponets setDay:row + 1];
                
//                self.selectedDate = [self.calendar dateFromComponents:targetComponents]; // 获得当前选定日
//                NSLog(@"day === %@",self.selectedDate);

                break;
            }
            default:
                break;
        }
        
        self.selectedDate = [self.calendar dateFromComponents:self.selectedDateComponets]; // 获得当前选定日期

        
        [pickerView reloadAllComponents];
    }
#endif
    
#ifdef MYDATE
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
#endif
    
    if ([pickerView isEqual:self.cityPicker]) {
        if (component == 0) {
            //省
            NSString *pro = [self.provinceArray objectAtIndex:row];
            self.selectPro = [pro substringFromIndex:2];
            
            //获取对应的市
            NSString *selectedState = [_provinceArray objectAtIndex:row];
            NSArray *array = [self.stateZips objectForKey:selectedState];
            
            self.cityArray = array;
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            if (array.count > 0){
                NSString *city = [_cityArray objectAtIndex:0];
                self.selectCity = city;
            }
            
        }else{
            //市
            NSString *city = [_cityArray objectAtIndex:row];
            self.selectCity = city;
        }
//        [pickerView reloadComponent:0];
    }
}

#pragma mark - 网络请求
// 提交账号信息
- (void)postPerfectPersonInfo {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    [self catchInputData];
    NSString *genderStr = (_gender == 1)? @"1" : @"2";
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:genderStr forKey:@"gender"];
    [paramDic setObject:_birthday forKey:@"birthday"];
    [paramDic setObject:_city forKey:@"city"];
//    [paramDic setObject:_address forKey:@"address"];
//    [paramDic setObject:_urgentPerson forKey:@"urgentperson"];
//    [paramDic setObject:_urgentPhone forKey:@"urgentphone"];
    
    NSString *uri = @"/suser?action=PerfectPersonInfo";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"提交成功"];
            // 本地化
            [self locateData];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(backLogin)
                                           userInfo:nil
                                            repeats:NO];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - 数据处理
- (NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
}

// 取得页面数据
- (void)catchInputData {
    _gender = [self.sexField.text isEqualToString:@"男"]? 1 : 2;
    _birthday = self.birthdayField.text;
    _city = self.cityField.text;
    _address = self.addrField.text;
    _urgentPerson = self.emergentPersonField.text;
    _urgentPhone = [self.emergentPhoneField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

// 页面数据本地化
- (void)locateData {
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSMutableDictionary *new_user_info = [NSMutableDictionary dictionaryWithDictionary:user_info];
    [new_user_info setObject:[NSNumber numberWithInt:_gender] forKey:@"gender"];
    [new_user_info setObject:_birthday forKey:@"birthday"];
    [new_user_info setObject:_city forKey:@"city"];
    [new_user_info setObject:_address forKey:@"address"];
    [new_user_info setObject:_urgentPerson forKey:@"urgent_person"];
    [new_user_info setObject:_urgentPhone forKey:@"urgent_phone"];
    [CommonUtil saveObjectToUD:new_user_info key:@"UserInfo"];
}

// 加载本地数据
- (void)loadLocalData {
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    _gender = [[user_info objectForKey:@"gender"] intValue];
    _birthday = [user_info objectForKey:@"birthday"];
    _city = [user_info objectForKey:@"city"];
    _address = [user_info objectForKey:@"address"];
    _urgentPerson = [user_info objectForKey:@"urgent_person"];
    _urgentPhone = [user_info objectForKey:@"urgent_phone"];
}

#pragma mark - 点击事件
- (IBAction)clickForCommit:(id)sender {
    [self postPerfectPersonInfo];
}

// 开启性别选择
- (void)clickForSexSelect:(UIButton *)sender {
    self.sexView.hidden = NO;
    self.cityView.hidden = YES;
    self.dateView.hidden = YES;
    [self.view addSubview:self.selectView];
}

// 完成性别选择
- (IBAction)clickForSexDone:(id)sender {
    NSInteger row = [self.sexPicker selectedRowInComponent:0];
    self.sexField.text = _sexArray[row];
    [self.selectView removeFromSuperview];
}

// 开启城市选择
- (void)clickForCitySelect:(UIButton *)sender {
    self.sexView.hidden = YES;
    self.cityView.hidden = NO;
    self.dateView.hidden = YES;
    [self.view addSubview:self.selectView];
}

// 完成城市选择
- (IBAction)clickForCityDone:(id)sender {
    if (_selectPro == nil){
        NSString *pro = [self.provinceArray objectAtIndex:0];
        self.selectPro = [pro substringFromIndex:2];
        NSArray *array = [self.stateZips objectForKey:pro];
        self.cityArray = array;
        _selectCity = array[0];
    }
    self.cityField.text = [NSString stringWithFormat:@"%@ %@", _selectPro, _selectCity];
    [self.selectView removeFromSuperview];
}

// 开启日期选择
- (void)clickForDateSelect:(UIButton *)sender {
    self.sexView.hidden = YES;
    self.cityView.hidden = YES;
    self.dateView.hidden = NO;
#ifdef TEST
    self.selectedDate = [NSDate dateWithTimeIntervalSince1970:0];
#endif
    
#ifdef MYDATE
    _myYear = @"1975";
    _myMonth = @"01";
    _myDay = @"01";
    [self.datePicker selectRow:45 inComponent:0 animated:YES];
    [self.datePicker selectRow:0 inComponent:1 animated:YES];
    [self.datePicker selectRow:0 inComponent:2 animated:YES];
    
#endif
    
    [self.view addSubview:self.selectView];
}

// 完成日期选择
- (IBAction)clickForDateDone:(id)sender {
#ifdef TEST
    self.birthdayField.text = [self stringFromDate:self.selectedDate];
#endif
    
#ifdef MYDATE
    self.birthdayField.text = [NSString stringWithFormat:@"%@-%@-%@",_myYear,_myMonth,_myDay];
#endif
    
    [self.selectView removeFromSuperview];
}

// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}



@end
