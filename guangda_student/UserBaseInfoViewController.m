//
//  UserBaseInfoViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

// 账号信息
#import "UserBaseInfoViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "LoginViewController.h"
#import "XBProvince.h"

@interface UserBaseInfoViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSString    *previousTextFieldContent;
    UITextRange *previousSelection;
}
@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;


// 城市选择

@property (strong, nonatomic) IBOutlet UITextField *cityField;
@property (strong, nonatomic) IBOutlet UIView *selectView;
@property (strong, nonatomic) IBOutlet UIView *cityView;
@property (strong, nonatomic) IBOutlet UIPickerView *cityPicker;
@property (strong, nonatomic) IBOutlet UIButton *cityConfirmBtn;
// 城市选择器数据
@property (strong, nonatomic) NSArray *provinces;
@property (strong, nonatomic) XBProvince *curProvince;
@property (strong, nonatomic) XBCity *curCity;
@property (strong, nonatomic) XBArea *curArea;
@property (copy, nonatomic) NSString *selectProvinceID;
@property (copy, nonatomic) NSString *selectCityID;
@property (copy, nonatomic) NSString *selectAreaID;
@property (copy, nonatomic) NSString *city;

- (IBAction)clickForCommit:(id)sender;

@end

@implementation UserBaseInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mainScrollView contentSizeToFit];
    [self settingView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showData];
}

#pragma mark - 页面设置
- (void)settingView {
    // 从报名页面跳转过来
    if (self.comeFrom == 1) {
        self.backBtn.hidden = YES;
    }
    
    self.phoneField.delegate = self;
    self.nameField.delegate = self;
    [self.phoneField addTarget:self action:@selector(formatPhoneNumber:) forControlEvents:UIControlEventEditingChanged];
    
    // 电话输入框右侧内边距
    UIView *rightPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 37, 20)];
    self.nameField.rightView = rightPaddingView;
    self.nameField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    // 点击背景退出键盘
    [self keyboardHiddenFun];
    
    // 选择器
    self.selectView.frame = [UIScreen mainScreen].bounds;
    self.cityPicker.delegate = self;
    self.cityPicker.dataSource = self;
    
    self.cityConfirmBtn.layer.borderWidth = 1;
    self.cityConfirmBtn.layer.borderColor = [RGB(248, 99, 95) CGColor];
    self.cityConfirmBtn.layer.cornerRadius = 4;
    
    [self initCityData];
}

// 显示数据
- (void)showData {
    [self loadLocalData];
    self.nameField.text = _realName;
    
    // 电话号码以3-4-4格式显示
    if (![CommonUtil isEmpty:_phone]) {
        NSMutableString *phone = [[NSMutableString alloc] initWithString:_phone];
        [phone insertString:@" " atIndex:3];
        [phone insertString:@" " atIndex:8];
        self.phoneField.text = phone;
    }
    
    self.cityField.text = _city;
}

#pragma mark - PickerVIew
// 数据
- (void)initCityData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"china.plist" ofType:nil];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *array = dict[@"china"];
    self.provinces = [XBProvince provincesWithArray:array];
    
    self.curProvince = self.provinces[0];
    self.curCity = self.curProvince.citiesArray[0];
    self.curArea = self.curCity.areasArray[0];
}

// 行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.0;
}

// 组数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

// 每组行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // 省
    if (component == 0) {
        return self.provinces.count;
    }
    // 市
    else if (component == 1) {
        return self.curProvince.citiesArray.count;
    }
    // 区
    else {
        return self.curCity.areasArray.count;
    }
}

// 自定义每行的view
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 45)];
    myView.font = [UIFont systemFontOfSize:18];         //用label来设置字体大小
    myView.textColor = [UIColor whiteColor];
    myView.backgroundColor = [UIColor clearColor];
    myView.textAlignment = NSTextAlignmentCenter;
    
    // 省
    if (component == 0) {
        XBProvince *province = [self.provinces objectAtIndex:row];
        myView.text = province.provinceName;
    }
    // 市
    else if (component == 1) {
        XBCity *city = self.curProvince.citiesArray[row];
        myView.text = city.cityName;
    }
    // 区
    else {
        XBArea *area = self.curCity.areasArray[row];
        myView.text = area.areaName;
    }
    return myView;
}

// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // 省
    if (component == 0) {
        self.curProvince = self.provinces[row];
        self.curCity = self.curProvince.citiesArray[0];
        self.curArea = self.curCity.areasArray[0];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        
    }
    // 市
    else if (component == 1) {
        self.curCity = self.curProvince.citiesArray[row];
        self.curArea = self.curCity.areasArray[0];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
    // 区
    else {
        self.curArea = self.curCity.areasArray[row];
    }
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
    [self.phoneField resignFirstResponder];
    [self.nameField resignFirstResponder];
}

// 开始编辑，铅笔变红
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIImage *image = [UIImage imageNamed:@"icon_redpencil_userbaseinfo"];
    
    if ([textField isEqual:self.phoneField]) {
        [self.phonePencilImage setImage:image];
    }
    
    else if ([textField isEqual:self.nameField]) {
        [self.namePencilImage setImage:image];
    }
}

// 结束编辑，铅笔变灰
- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIImage *image = [UIImage imageNamed:@"icon_pencil_userinfocell"];
    
    if ([textField isEqual:self.phoneField]) {
        [self.phonePencilImage setImage:image];
    }
    
    else if ([textField isEqual:self.nameField]) {
        [self.namePencilImage setImage:image];
    }
}

// 手机号码3-4-4格式
- (void)formatPhoneNumber:(UITextField*)textField
{
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                       toPosition:textField.selectedTextRange.start];
    
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

#pragma mark - 网络请求
// 提交账号信息
- (void)postPerfectAccountInfo {
    [self catchInputData];
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    if (_phone.length != 0 && _phone.length != 11) {
        [self makeToast:@"请输入正确格式的手机号"];
        return;
    }
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:_realName forKey:@"realname"];
    [paramDic setObject:_phone forKey:@"phone"];
    if (![CommonUtil isEmpty:self.selectProvinceID]) {
        [paramDic setObject:self.selectProvinceID forKey:@"provinceid"];
    }
    if (![CommonUtil isEmpty:self.selectCityID]) {
        [paramDic setObject:self.selectCityID forKey:@"cityid"];
    }
    if (![CommonUtil isEmpty:self.selectAreaID]) {
        [paramDic setObject:self.selectAreaID forKey:@"areaid"];
    }
    NSString *uri = @"/suser?action=PerfectAccountInfo";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"提交成功"];
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
// 取得输入数据
- (void)catchInputData {
    _realName = self.nameField.text;
    _phone = [self.phoneField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    _city = self.cityField.text;
}

// 数据本地化
- (void)locateData {
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSMutableDictionary *new_user_info = [NSMutableDictionary dictionaryWithDictionary:user_info];
    [new_user_info setObject:_realName forKey:@"realname"];
    [new_user_info setObject:_phone forKey:@"phone"];
    [new_user_info setObject:_city forKey:@"locationname"];
    if (![CommonUtil isEmpty:_selectProvinceID]) {
        [new_user_info setObject:_selectProvinceID forKey:@"provinceid"];
    }
    if (![CommonUtil isEmpty:_selectCityID]) {
        [new_user_info setObject:_selectCityID forKey:@"cityid"];
    }
    if (![CommonUtil isEmpty:_selectAreaID]) {
        [new_user_info setObject:_selectAreaID forKey:@"areaid"];
    }
    [CommonUtil saveObjectToUD:new_user_info key:@"UserInfo"];
}

// 加载本地数据
- (void)loadLocalData {
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    _realName = [user_info objectForKey:@"realname"];
    _phone = [user_info objectForKey:@"phone"];
    _city = [user_info objectForKey:@"locationname"];
    _selectProvinceID = user_info[@"provinceid"];
    _selectCityID = user_info[@"cityid"];
    _selectAreaID = user_info[@"areaid"];
}

#pragma mark - 点击事件
- (IBAction)clickForCommit:(id)sender {
    [self catchInputData];
    if ([CommonUtil isEmpty:_phone]) {
        [self makeToast:@"请输入联系电话"];
        return;
    } else {
        if (![CommonUtil checkPhonenum:_phone]) {
            [self makeToast:@"请检查您的手机号是否正确"];
            return;
        }
    }
    if ([CommonUtil isEmpty:_realName]) {
        [self makeToast:@"请输入您的真实姓名"];
        return;
    }
    if ([CommonUtil isEmpty:_city]) {
        [self makeToast:@"请选择您的驾考城市"];
        return;
    }
    [self postPerfectAccountInfo];
}

// 开启城市选择
- (IBAction)clickForCitySelect:(UIButton *)sender {
    self.cityView.hidden = NO;
    [self.view addSubview:self.selectView];
}

// 完成城市选择
- (IBAction)clickForCityDone:(id)sender {
    NSString *addrStr = nil;
    NSString *areaStr = [self.curArea.areaName stringByReplacingOccurrencesOfString:@"  " withString:@""];
    addrStr =  [NSString stringWithFormat:@"%@-%@-%@", self.curProvince.provinceName, self.curCity.cityName, areaStr];
    self.cityField.text = addrStr;
    self.selectProvinceID = self.curProvince.provinceID;
    self.selectCityID = self.curCity.cityID;
    self.selectAreaID = self.curArea.areaID;
    
    [self.selectView removeFromSuperview];
}

// 关闭选择页面
- (IBAction)clickForCancelSelect:(id)sender {
    [self.selectView removeFromSuperview];
}

- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

//跳过
- (void)clickForJump
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
