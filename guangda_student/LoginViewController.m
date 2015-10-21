//
//  LoginViewController.m
//  guangda_student
//
//  Created by 吴筠秋 on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "RegistViewController.h"
#import "BindingViewController.h"
#import "AppDelegate.h"
#import "RegistVercodeViewController.h"
#import "WeiboSDK.h"
#import "LearnDriveInfoViewController.h"
#import "RecommendCodeViewController.h"
#import "UserBaseInfoViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>

#import "WXApi.h"

@interface LoginViewController ()<UITextFieldDelegate,TencentSessionDelegate,TencentLoginDelegate,WXApiDelegate,WeiboSDKDelegate>{
    CGRect scrollFrame;
}

// QQ登录
@property (nonatomic, retain) TencentOAuth *tencentOAuth;
@property (nonatomic, strong) NSArray *permissions;     // 获取用户资料的权限列表

@property (nonatomic, strong) NSString *openId;
@property (nonatomic, strong) NSString *accessToken;

@property (strong, nonatomic) IBOutlet UITextField *loginNameTextField; // 手机号
@property (strong, nonatomic) IBOutlet UITextField *passwordTexrField;  // 密码
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIButton *sinaBtn;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIView *loginView;

@property (strong, nonatomic) UITextField *nowTextField;

@property (strong, nonatomic) IBOutlet UIView *phoneUnderline;  // 手机号下划线
@property (strong, nonatomic) IBOutlet UIView *pwdUnderline;    // 密码下划线


@property (strong, nonatomic) IBOutlet UIView *footView;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelViewY;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *footViewY;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.loginNameTextField.delegate = self;
    self.passwordTexrField.delegate = self;
    
    self.loginButton.layer.cornerRadius = 4;
    self.loginButton.layer.masksToBounds = YES;
    
    //注册监听，防止键盘遮挡视图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
    
    //weixin监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinLogin:) name:WeixinLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weiboLogin:) name:WeiboLogin object:nil];
    
    
    // QQ登录
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kAppID_QQ andDelegate:self];
    self.permissions = [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
//    [_oauth authorize:_permissions];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardClick:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    
    self.vcodeButton.layer.cornerRadius = 3;
    
    [self.vcodeButton didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
        [self.vcodeButton setBackgroundColor:RGB(184, 184, 184)];
        NSString *title = [NSString stringWithFormat:@"%d\"后重获",second];
        return title;
    }];
    [self.vcodeButton didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        countDownButton.enabled = YES;
        [countDownButton setBackgroundColor:RGB(126, 207, 224)];
        return @"重获验证码";
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    float screenH = [UIScreen mainScreen].bounds.size.height;
    
    self.labelViewY.constant = screenH -64-140;
    self.footViewY.constant = screenH -64 - 120;
    
    if (screenH < 500) {
        self.labelViewY.constant = 500 -140;
        self.footViewY.constant = 500 - 120;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 请求登录接口
- (void)requestLoginInterfaceWithType:(NSString *)type andOpenid:(NSString *)openId
{
    NSString *phoneNum = self.loginNameTextField.text;
    NSString *pwdStr = self.passwordTexrField.text;
    
    if ([type intValue] == 1)
    {
        if (phoneNum.length == 0
            || pwdStr.length == 0)
        {
            [self makeToast:@"请输入账号/密码"];
            return;
        }
        
        if ([[phoneNum substringToIndex:1] intValue] != 1
            || phoneNum.length != 11)
        {
            [self makeToast:@"请输入正确的验证码"];
            return;
        }
    }
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:phoneNum forKey:@"phone"];
    [paramDic setObject:type forKey:@"type"];
    paramDic[@"devicetype"] = @"1"; // 设备类型
    paramDic[@"version"] = APP_VERSION; // 版本号
    paramDic[@"ostype"] = @"1"; // 操作平台
    if ([type isEqualToString:@"1"])
    {
        [paramDic setObject:[CommonUtil md5:pwdStr] forKey:@"password"];
    }else{
        [paramDic setObject:openId forKey:@"phone"];
    }
    
    NSString *uri = @"/suser?action=login";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            // 第三方登录 未绑定账号
            if ([[responseObject[@"isbind"] description] isEqualToString:@"0"])
            {
                
                BindingViewController *nextController = [[BindingViewController alloc] initWithNibName:@"BindingViewController" bundle:nil];
                nextController.openId = _openId;
                nextController.type = [NSString stringWithFormat:@"%d", ([type intValue] - 1)];
                [self.navigationController pushViewController:nextController animated:YES];
            }else{
                [self makeToast:@"登录成功"];
                    
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NSDictionary *user_info = [responseObject objectForKey:@"UserInfo"];
                delegate.userid = [[user_info objectForKey:@"studentid"] description];
                [CommonUtil saveObjectToUD:user_info key:@"UserInfo"];
                [CommonUtil saveObjectToUD:[paramDic objectForKey:@"phone"] key:@"loginusername"];
                [CommonUtil saveObjectToUD:pwdStr key:@"loginpassword"];
                [CommonUtil saveObjectToUD:type key:@"logintype"];
                
                if (![CommonUtil isEmpty:delegate.deviceToken]) {
                    [self uploadDeviceToken:delegate.deviceToken];
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
            // 将第三方登录的openID存在本地
            if ([type isEqualToString:@"2"]) {
                // QQ
                [CommonUtil saveObjectToUD:openId key:@"QQOpenid"];
            }else if ([type isEqualToString:@"3"]) {
                // 微信
                
                
            }else if ([type isEqualToString:@"4"]) {
                // 微博
                
                
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            
            NSLog(@"code = %@",  responseObject[@"code"]);
            NSLog(@"message = %@", responseObject[@"message"]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];

}

// 上传设备号
- (void)uploadDeviceToken:(NSString *)deviceToken
{
    NSMutableDictionary *userInfoDic = [[CommonUtil getObjectFromUD:@"UserInfo"] mutableCopy];
    NSString *userId = [userInfoDic objectForKey:@"studentid"];

    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    if (!userId) {
        return;
    }
    [paramDic setObject:userId forKey:@"userid"];
    [paramDic setObject:@"2" forKey:@"usertype"]; // 用户类型 1.教练  2 学员
    [paramDic setObject:@"1" forKey:@"devicetype"]; // 设备类型 0安卓  1IOS
    [paramDic setObject:deviceToken forKey:@"devicetoken"];

    NSString *uri = @"/system?action=UpdatePushInfo";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            NSLog(@"上传设备号成功");
        }else{
            NSString *message = responseObject[@"message"];
            NSLog(@"code = %@",  responseObject[@"code"]);
            NSLog(@"message = %@", message);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                [self makeToast:ERR_NETWORK];
    }];
}

#pragma mark - 监听
- (void)keyboardWillShow:(NSNotification *)notification {
//    scrollFrame = self.view.frame;
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.frame;
    
    if (self.nowTextField == nil) {
        return;
    }
    
    //获取这个textField在self.view中的位置， fromView为textField的父view
//    CGRect textFrame = self.nowTextField.superview.frame;
//    CGFloat textFieldY = textFrame.origin.y + CGRectGetHeight(textFrame);
    CGFloat loginViewY = self.loginView.frame.origin.y +self.loginView.frame.size.height;
    if(loginViewY < keyboardTop){
        //键盘没有挡住输入框
        return;
    }
    
    //键盘遮挡了输入框
    newTextViewFrame.origin.y = keyboardTop - loginViewY;
    
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    animationDuration += 0.1f;
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.frame = newTextViewFrame;
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:NO];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight([UIScreen mainScreen].bounds));
    [UIView commitAnimations];
}

#pragma mark - 输入框代理
// 点击返回按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.nowTextField = textField;
    
    // 修改下划线的颜色
    if (textField == self.loginNameTextField) {
        self.phoneUnderline.backgroundColor = [UIColor redColor];
    }
    if (textField == self.passwordTexrField) {
        self.pwdUnderline.backgroundColor = [UIColor redColor];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == self.loginNameTextField) {
        if (self.loginNameTextField.text.length == 0) {
            self.phoneUnderline.backgroundColor = RGB(206, 206, 206);
        }else{
            self.phoneUnderline.backgroundColor = [UIColor redColor];
        }
    }else if (textField == self.passwordTexrField) {
        
        if (self.passwordTexrField.text.length == 0) {
            self.pwdUnderline.backgroundColor = RGB(206, 206, 206);
        }else{
            self.pwdUnderline.backgroundColor = [UIColor redColor];
        }
    }
    return YES;
}

// 手机号不得超过11位
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{  //string就是此时输入的那个字符 textField就是此时正在输入的那个输入框 返回YES就是可以改变输入框的值 NO相反
    
    if (self.loginNameTextField == textField)
    {
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
        if ([toBeString length] > 11) { //如果输入框内容大于11则弹出警告
            [self makeToast:@"手机号不得超过11位"];
            return NO;
        }
    }
    return YES;
}

#pragma mark - private
- (void)showMainView{
//    scrollFrame = self.view.frame;
    
    CGRect frame = self.mainView.frame;
    frame.size.width = CGRectGetWidth(self.view.frame);
    self.mainView.frame = frame;
    
    [self.mainScrollView addSubview:self.mainView];
//    self.mainScrollView.contentSize = CGSizeMake(0, self.loginButton.frame.origin.y + CGRectGetHeight(self.loginButton.frame) + 20);
    self.mainScrollView.contentSize = CGSizeMake(0, 500);
}

#pragma mark - action
- (IBAction)hideKeyboardClick:(id)sender {
    [self.loginNameTextField resignFirstResponder];
    [self.passwordTexrField resignFirstResponder];
}
#pragma mark 登录注册
- (IBAction)clickForLoginRegist:(id)sender {
    NSString *vcode = [self.passwordTexrField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *phone = [self.loginNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([CommonUtil isEmpty:phone]){
        [self makeToast:@"请输入您的手机号码"];
        return;
    }
    
    if(![CommonUtil checkPhonenum:phone]){
        [self makeToast:@"手机号码输入有误,请重新输入"];
        return;
    }
    
    if([CommonUtil isEmpty:vcode]){
        [self makeToast:@"请输入您的验证码"];
        return;
    }
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:phone forKey:@"phone"];
    [paramDic setObject:vcode forKey:@"password"];
    paramDic[@"devicetype"] = @"1"; // 设备类型
    paramDic[@"version"] = APP_VERSION; // 版本号
    paramDic[@"ostype"] = @"1"; // 操作平台
    
    NSString *uri = @"/suser?action=login";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            
            [self makeToast:@"登录成功"];
            
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSDictionary *user_info = [responseObject objectForKey:@"UserInfo"];
            delegate.userid = [[user_info objectForKey:@"studentid"] description];
            [CommonUtil saveObjectToUD:user_info key:@"UserInfo"];
            [CommonUtil saveObjectToUD:[paramDic objectForKey:@"phone"] key:@"loginusername"];
            [CommonUtil saveObjectToUD:vcode key:@"loginpassword"];
            [CommonUtil saveObjectToUD:@"1" key:@"logintype"];
            
            //环信登录
            [[EMIMHelper defaultHelper] loginEasemobSDK];
            
            int isregister = [[responseObject objectForKey:@"isregister"] intValue];
            delegate.isregister = [NSString stringWithFormat:@"%d",isregister];
            int isInvited = [[responseObject objectForKey:@"isInvited"] intValue];
            delegate.isInvited = [NSString stringWithFormat:@"%d",isInvited];
            
            if (![CommonUtil isEmpty:delegate.deviceToken]) {
                [self uploadDeviceToken:delegate.deviceToken];
            }
            
//            if (isInvited == 1) {    //1代表未被邀请，0代表已被邀请
//                RecommendCodeViewController *nextController = [[RecommendCodeViewController alloc] initWithNibName:@"RecommendCodeViewController" bundle:nil];
//                if (self.comeFrom == 1) {
//                    nextController.popType = 1;
//                    [self.navigationController popViewControllerAnimated:NO];
//                }
                
//                [self.navigationController pushViewController:nextController animated:YES];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
//                return;
//            }
            
            if(isregister == 0){
                if (self.comeFrom == 1) {
                    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
                } else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }else{
                [self.navigationController popToRootViewControllerAnimated:YES];
                
//                LearnDriveInfoViewController *nextController = [[LearnDriveInfoViewController alloc] initWithNibName:@"LearnDriveInfoViewController" bundle:nil];
//                nextController.isSkip = @"1";
//                [self.navigationController pushViewController:nextController animated:YES];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
    
}

// 忘记密码
- (IBAction)clickForForgetPwd:(id)sender {
    RegistVercodeViewController *nextController = [[RegistVercodeViewController alloc] initWithNibName:@"RegistVercodeViewController" bundle:nil];
    nextController.vercodeType = @"4";
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark 第三方登录
- (IBAction)clickForThirdLogin:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == 1) {
        //QQ
//        [_tencentOAuth authorize:_permissions inSafari:NO];
            self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:kAppID_QQ andDelegate:self];
            //    NSArray * array =  [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
            NSArray * array1 = [NSArray arrayWithObjects:
                                kOPEN_PERMISSION_GET_USER_INFO,
                                kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                kOPEN_PERMISSION_ADD_ALBUM,
                                kOPEN_PERMISSION_ADD_IDOL,
                                kOPEN_PERMISSION_ADD_ONE_BLOG,
                                kOPEN_PERMISSION_ADD_PIC_T,
                                kOPEN_PERMISSION_ADD_SHARE,
                                kOPEN_PERMISSION_ADD_TOPIC,
                                kOPEN_PERMISSION_CHECK_PAGE_FANS,
                                kOPEN_PERMISSION_DEL_IDOL,
                                kOPEN_PERMISSION_DEL_T,
                                kOPEN_PERMISSION_GET_FANSLIST,
                                kOPEN_PERMISSION_GET_IDOLLIST,
                                kOPEN_PERMISSION_GET_INFO,
                                kOPEN_PERMISSION_GET_OTHER_INFO,
                                kOPEN_PERMISSION_GET_REPOST_LIST,
                                kOPEN_PERMISSION_LIST_ALBUM,
                                kOPEN_PERMISSION_UPLOAD_PIC,
                                kOPEN_PERMISSION_GET_VIP_INFO,
                                kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                                kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                                kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                                nil];
            [self.tencentOAuth authorize:array1 inSafari:NO];

    }else if (button.tag == 2){
        //微信
        
        SendAuthReq* req =[[SendAuthReq alloc ] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"123" ;
        req.openID = kAppID_Weixin;// @"wxa508cf6ae267e0a8";
            //第三方向微信终端发送一个SendAuthReq消息结构
        //    [WXApi sendReq:req];
        
        
            [WXApi sendAuthReq:req viewController:self delegate:self];
        
    }else if (button.tag == 3){
        //新浪微博
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = kRedirectURI_Weibo;
        request.scope = @"all";
        request.userInfo = @{@"SSO_From": @"LoginViewController",
                             @"Other_Info_1": [NSNumber numberWithInt:123],
                             @"Other_Info_2": @[@"obj1", @"obj2"],
                             @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
        [WeiboSDK sendRequest:request];
        
    }
    
//    BindingViewController *nextController = [[BindingViewController alloc] initWithNibName:@"BindingViewController" bundle:nil];
//    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark 第三方登录回调
// QQ登录
- (void)tencentDidLogin
{
//    _labelTitle.text = @"登录完成";
    
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        // 登录成功
        // 记录登录用户的OpenID、Token以及过期时间
//        _labelAccessToken.text = _tencentOAuth.accessToken;
        _accessToken =  _tencentOAuth.accessToken;
        _openId = _tencentOAuth.openId;
        NSDate *expirationDate = _tencentOAuth.expirationDate;
        NSLog(@"accessToken == %@", _accessToken);
        NSLog(@"openID == %@", _openId);
        NSLog(@"expirationDate == %@", expirationDate);
        
        // 请求登录接口  type = 2
//        [self requestLoginInterfaceWithType:@"2" andOpenid:_openId];
    }
    else
    {
//        _labelAccessToken.text = @"登录不成功 没有获取accesstoken";
        NSLog(@"登录不成功 没有获取accesstoken");
    }
}

-(void)weixinLogin:(NSNotification *)notification{
    SendAuthResp * authResp = (SendAuthResp *) notification.object;
    
    NSString * url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=56ba2549a60c5d5ffaf6eeb036d26f5f&code=%@&grant_type=authorization_code",kAppID_Weixin,authResp.code];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * operation, id responseObject) {
        NSDictionary *photo = [NSJSONSerialization
                               
                               JSONObjectWithData:responseObject
                               
                               options:NSJSONReadingMutableLeaves
                               
                               error:nil];
        NSString *str1 = [photo objectForKey:@"openid"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"openid" message:str1 delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alertView show];
        
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
        //        UIImage *img = [UIImage imageWithData:responseObject];
        //        [_codeImageView setImage:img];
        //        [ProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"内部服务器错误" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        //        [alertView show];
        //        [ProgressHUD dismiss];
    }];
}

-(void)weiboLogin:(NSNotification *)notification{
    NSString * userid = (NSString *) notification.object;
    NSLog(@"%@",userid);
}

- (IBAction)backClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 点击获取验证码
- (IBAction)clickForVcodeButton:(id)sender {
    NSString *phone = [self.loginNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([CommonUtil isEmpty:phone]){
        [self makeToast:@"请输入您的手机号码"];
        return;
    }
    
    if(![CommonUtil checkPhonenum:phone]){
        [self makeToast:@"手机号码输入有误,请重新输入"];
        return;
    }
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:phone forKey:@"phone"];
    [paramDic setObject:@"2" forKey:@"type"];
    
    NSString *uri = @"/suser?action=GetVerCode";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"发送验证码成功"];
            self.vcodeButton.enabled = NO;
            [self.vcodeButton startWithSecond:60];
            
        }else{
            NSString *message = responseObject[@"message"];
            if ([CommonUtil isEmpty:message]) {
                
                [self makeToast:ERR_NETWORK];
            } else {
                
                [self makeToast:message];
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}
@end
