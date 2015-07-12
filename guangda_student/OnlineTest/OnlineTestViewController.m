//
//  OnlineTestViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/11.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "OnlineTestViewController.h"
#import "AppDelegate.h"
@interface OnlineTestViewController ()

@property (strong, nonatomic) IBOutlet UIView *msgView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end

@implementation OnlineTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //显示主页面，延时执行是为了让自动布局先生效，再设置frame才有效果
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.1f];
}

//显示主页面
- (void)showMainView{
    CGRect frame = self.msgView.frame;
    frame.size.width = CGRectGetWidth(self.mainScrollView.frame);
    self.msgView.frame = frame;
    [self.mainScrollView addSubview:self.msgView];
    
    self.mainScrollView.contentSize = CGSizeMake(0, CGRectGetHeight(frame) + 40);
}

//预约考试
- (IBAction)clickForTest:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hzti.com:9004/drv_web/index.do"]];
    
}

// 预约模拟培训
- (IBAction)clickForMock:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://xqc.qc5qc.com/reservation"]];
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
