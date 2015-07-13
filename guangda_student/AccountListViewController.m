//
//  AccountListViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/13.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AccountListViewController.h"
#import "AccountViewController.h"
#import "CouponListViewController.h"
@interface AccountListViewController ()

@property (strong, nonatomic) IBOutlet UIView *msgView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutlet UILabel *couponLabel;

- (IBAction)clickForAccount:(id)sender;
- (IBAction)clickForCoupon:(id)sender;

@end

@implementation AccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.1f];
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    NSString *money = [user_info[@"money"] description];
    NSString *moneyStr = [NSString stringWithFormat:@"%@ 元", money];
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:moneyStr];
    [string1 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0,money.length)];
    self.moneyLabel.attributedText = string1;
    
    NSString *coupon = @"3";
    NSString *couponStr = [NSString stringWithFormat:@"%@ 张", coupon];
    NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:couponStr];
    [string2 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0,coupon.length)];
    self.couponLabel.attributedText = string2;

}

//显示主页面
- (void)showMainView{
    CGRect frame = self.msgView.frame;
    frame.size.width = CGRectGetWidth(self.mainScrollView.frame);
    self.msgView.frame = frame;
    [self.mainScrollView addSubview:self.msgView];
    
    self.mainScrollView.contentSize = CGSizeMake(0, CGRectGetHeight(frame) + 40);
}

- (IBAction)clickForAccount:(id)sender {
    if ([[CommonUtil currentUtil] isLogin]) {
        AccountViewController *viewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (IBAction)clickForCoupon:(id)sender {
    if ([[CommonUtil currentUtil] isLogin]) {
        CouponListViewController *viewController = [[CouponListViewController alloc] initWithNibName:@"CouponListViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
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
