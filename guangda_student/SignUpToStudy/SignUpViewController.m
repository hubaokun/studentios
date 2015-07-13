//
//  SignUpViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/13.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SignUpViewController.h"
#import "SelfServiceSignUpViewController.h"
@interface SignUpViewController ()<UITextFieldDelegate>



@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumField;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UIView *signUpView;
@property (strong, nonatomic) IBOutlet UIView *nameUnderLine;
@property (strong, nonatomic) IBOutlet UIView *phoneNumUnderLine;
@property (strong, nonatomic) IBOutlet UILabel *footLabel;

//弹框
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UIView *alertBoxView;
@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

- (IBAction)clickForSelfService:(id)sender;
- (IBAction)clickForSignUp:(id)sender;
- (IBAction)clickForClose:(id)sender;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.nameField.delegate = self;
    self.phoneNumField.delegate = self;
    
    self.signUpButton.layer.cornerRadius = 4;
    self.signUpButton.layer.masksToBounds = YES;
    
    //圆角
    self.alertBoxView.layer.cornerRadius = 4;
    self.alertBoxView.layer.masksToBounds = YES;
    
    self.sureBtn.layer.cornerRadius = 4;
    self.sureBtn.layer.masksToBounds = YES;
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *phoneNum = [user_info[@"phone"] description];
    NSString *realName = [user_info[@"realname"] description];
    
    if (realName.length > 0) {
        self.nameField.text = realName;
    }
    if (phoneNum.length > 0) {
        self.phoneNumField.text = phoneNum;
    }
    
    //注册监听，防止键盘遮挡视图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardClick:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [self.mainScrollView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    
//    if (self.nowTextField == nil) {
//        return;
//    }
    
    //获取这个textField在self.view中的位置， fromView为textField的父view
    //    CGRect textFrame = self.nowTextField.superview.frame;
    //    CGFloat textFieldY = textFrame.origin.y + CGRectGetHeight(textFrame);
    CGFloat signUpViewY = self.signUpView.frame.origin.y +self.signUpView.frame.size.height;
    if(signUpViewY < keyboardTop){
        //键盘没有挡住输入框
        return;
    }
    
    //键盘遮挡了输入框
    newTextViewFrame.origin.y = keyboardTop - signUpViewY;
    
    
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
#pragma mark 点击返回按钮
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    self.nowTextField = textField;
    
    // 修改下划线的颜色
    if (textField == self.nameField) {
        self.nameUnderLine.backgroundColor = [UIColor redColor];
    }
    if (textField == self.phoneNumField) {
        self.phoneNumUnderLine.backgroundColor = [UIColor redColor];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == self.nameField) {
        if (self.nameField.text.length == 0) {
            self.nameUnderLine.backgroundColor = RGB(206, 206, 206);
        }else{
            self.nameUnderLine.backgroundColor = [UIColor redColor];
        }
    }else if (textField == self.phoneNumField) {
        
        if (self.phoneNumField.text.length == 0) {
            self.phoneNumUnderLine.backgroundColor = RGB(206, 206, 206);
        }else{
            self.phoneNumUnderLine.backgroundColor = [UIColor redColor];
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
    self.mainScrollView.contentSize = CGSizeMake(0, self.footLabel.frame.origin.y + CGRectGetHeight(self.footLabel.frame) + 20);
}

#pragma mark - action
- (IBAction)hideKeyboardClick:(id)sender {
    [self.nameField resignFirstResponder];
    [self.phoneNumField resignFirstResponder];
}

- (IBAction)clickForClose:(id)sender
{
    [self.alertView removeFromSuperview];
}

- (IBAction)clickForSelfService:(id)sender {
    SelfServiceSignUpViewController *nextController = [[SelfServiceSignUpViewController alloc] initWithNibName:@"SelfServiceSignUpViewController" bundle:nil];
    [self.navigationController pushViewController:nextController animated:YES];
}

- (IBAction)clickForSignUp:(id)sender {
    self.alertView.frame = self.view.frame;
    [self.view addSubview:self.alertView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
