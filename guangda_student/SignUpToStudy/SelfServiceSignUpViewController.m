//
//  SelfServiceSignUpViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/13.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SelfServiceSignUpViewController.h"
#import "MainViewController.h"
@interface SelfServiceSignUpViewController ()


@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIButton *readyButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UIButton *trainButton;
@property (strong, nonatomic) IBOutlet UIButton *footButton;

//弹框
@property (strong, nonatomic) IBOutlet UIView *alertView;
@property (strong, nonatomic) IBOutlet UIView *alertBoxView1;
@property (strong, nonatomic) IBOutlet UIView *alertBoxView2;
@property (strong, nonatomic) IBOutlet UIView *alertBoxView3;
@property (strong, nonatomic) IBOutlet UILabel *colorfulLabel;

- (IBAction)clickForReady:(id)sender;
- (IBAction)clickForSignUp:(id)sender;
- (IBAction)clickForTrain:(id)sender;
- (IBAction)clickForClose:(id)sender;

@end

@implementation SelfServiceSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //圆角
    self.alertBoxView1.layer.cornerRadius = 4;
    self.alertBoxView1.layer.masksToBounds = YES;
    self.alertBoxView2.layer.cornerRadius = 4;
    self.alertBoxView2.layer.masksToBounds = YES;
    self.alertBoxView3.layer.cornerRadius = 4;
    self.alertBoxView3.layer.masksToBounds = YES;
    
    self.footButton.layer.cornerRadius = 4;
    self.footButton.layer.masksToBounds = YES;
    
    NSString *str = @"（结业鉴定需考到85分以上，科目一考试90分通过）";
    NSString *labelStr = [NSString stringWithFormat:@"体检通过后按照“学员须知”上的要求，根据“理论培训预约单”上的时间安排参加理论课的培训，必须完成五次理论课程后参加结业鉴定。%@", str];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:labelStr];
    [string addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(labelStr.length-str.length,str.length)];
    self.colorfulLabel.attributedText = string;
    
    
    [self.readyButton setBackgroundImage:[UIImage imageNamed:@"流程图按钮-2"]  forState:UIControlStateHighlighted];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"流程图按钮-2"] forState:UIControlStateHighlighted];
    [self.trainButton setBackgroundImage:[UIImage imageNamed:@"流程图按钮-2"] forState:UIControlStateHighlighted];
    
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
    
}

#pragma mark - private
- (void)showMainView{
    //    scrollFrame = self.view.frame;
    
    CGRect frame = self.mainView.frame;
    frame.size.width = CGRectGetWidth(self.view.frame);
    self.mainView.frame = frame;
    
    [self.mainScrollView addSubview:self.mainView];
    self.mainScrollView.contentSize = CGSizeMake(0, self.footButton.frame.origin.y + CGRectGetHeight(self.footButton.frame) + 20);
}



- (IBAction)clickForReady:(id)sender {
    self.alertView.frame = self.view.frame;
    [self.view addSubview:self.alertView];
    self.alertBoxView1.hidden = NO;
    self.alertBoxView2.hidden = YES;
    self.alertBoxView3.hidden = YES;
}

- (IBAction)clickForSignUp:(id)sender {
    self.alertView.frame = self.view.frame;
    [self.view addSubview:self.alertView];
    self.alertBoxView1.hidden = YES;
    self.alertBoxView2.hidden = NO;
    self.alertBoxView3.hidden = YES;
}

- (IBAction)clickForTrain:(id)sender {
    self.alertView.frame = self.view.frame;
    [self.view addSubview:self.alertView];
    self.alertBoxView1.hidden = YES;
    self.alertBoxView2.hidden = YES;
    self.alertBoxView3.hidden = NO;
}

- (IBAction)clickForClose:(id)sender {
    [self.alertView removeFromSuperview];
}

- (IBAction)clickForOrder:(id)sender {
    
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
