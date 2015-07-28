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
#import "CoinListViewController.h"
@interface AccountListViewController ()
{
    NSString *couponsum;
    NSString *coinsum;
}
@property (strong, nonatomic) IBOutlet UIView *msgView;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutlet UILabel *couponLabel;
@property (strong, nonatomic) IBOutlet UILabel *coinLabel;
@property (strong, nonatomic) IBOutlet UIView *coinView;

- (IBAction)clickForAccount:(id)sender;
- (IBAction)clickForCoupon:(id)sender;
- (IBAction)clickForCoin:(id)sender;


@end

@implementation AccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.1f];
    [self GETWALLETINFO];
//    self.coinView.hidden = YES;

}

//显示主页面
- (void)showMainView{
    CGRect frame = self.msgView.frame;
    frame.size.width = CGRectGetWidth(self.mainScrollView.frame);
    self.msgView.frame = frame;
    [self.mainScrollView addSubview:self.msgView];
    
    self.mainScrollView.contentSize = CGSizeMake(0, CGRectGetHeight(frame) + 40);
}
//账户余额
- (IBAction)clickForAccount:(id)sender {
    if ([[CommonUtil currentUtil] isLogin]) {
        AccountViewController *viewController = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
//小巴券
- (IBAction)clickForCoupon:(id)sender {
    if ([[CommonUtil currentUtil] isLogin]) {
        CouponListViewController *viewController = [[CouponListViewController alloc] initWithNibName:@"CouponListViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}
//小巴币
- (IBAction)clickForCoin:(id)sender {
    if ([[CommonUtil currentUtil] isLogin]) {
        CoinListViewController *viewController = [[CoinListViewController alloc] initWithNibName:@"CoinListViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - 接口方法
// 提交用户信息一键报名
- (void)GETWALLETINFO {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    NSString *uri = @"/suser?action=GETSTUDENTWALLETINFO";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            NSLog(@"message ===== %@", responseObject[@"message"]);
            coinsum = [responseObject[@"coinsum"] description];
            couponsum = [responseObject[@"couponsum"] description];
//            self.alertView.frame = self.view.frame;
//            [self.view addSubview:self.alertView];
//            [self.navigationController popViewControllerAnimated:YES];
            [self setLabel];
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

- (void)setLabel
{
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    NSString *money = [user_info[@"money"] description];
    NSString *moneyStr = [NSString stringWithFormat:@"%@ 元", money];
    NSMutableAttributedString *string1 = [[NSMutableAttributedString alloc] initWithString:moneyStr];
    [string1 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0,money.length)];
    self.moneyLabel.attributedText = string1;
    
    NSString *couponStr = [NSString stringWithFormat:@"%@ 张", couponsum];
    NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:couponStr];
    [string2 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0,couponsum.length)];
    self.couponLabel.attributedText = string2;
    
    couponsum = @"0";
    NSString *coinStr = [NSString stringWithFormat:@"%@ 个", couponsum];
    NSMutableAttributedString *string3 = [[NSMutableAttributedString alloc] initWithString:coinStr];
    [string3 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0,coinsum.length)];
    self.coinLabel.attributedText = string3;
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
