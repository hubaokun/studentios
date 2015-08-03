//
//  XiaobaServeViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "XiaobaServeViewController.h"
#import "SignUpViewController.h"

@interface XiaobaServeViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;
@end

@implementation XiaobaServeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.3f];
}

#pragma mark - private
- (void)showMainView{
    //    scrollFrame = self.view.frame;
    
    CGRect frame = self.mainView.frame;
    frame.size.width = CGRectGetWidth(self.view.frame);
    self.mainView.frame = frame;
    
    [self.mainScrollView addSubview:self.mainView];
    self.mainScrollView.contentSize = CGSizeMake(0, self.footView.frame.origin.y + CGRectGetHeight(self.footView.frame) + 20);
}
//在线报名
- (IBAction)clickForSign:(id)sender {
    if ([[CommonUtil currentUtil] isLogin]) {
        SignUpViewController *nextViewController = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}
//预约考试
- (IBAction)clickForTest:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.hzti.com:9004/drv_web/index.do"]];
}

//预约培训
- (IBAction)clickForTrain:(id)sender {
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
