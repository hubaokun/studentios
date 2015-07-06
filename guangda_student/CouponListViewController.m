//
//  CouponListViewController.m
//  guangda_student
//
//  Created by guok on 15/6/2.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CouponListViewController.h"
#import "CouponTableViewCell.h"
#import "LoginViewController.h"

@interface CouponListViewController ()<UITabBarDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *titleImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLeftLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleRightLabel;
- (IBAction)clickForTitleLeft:(id)sender;
- (IBAction)clickForTitleRight:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *couponTableView;


@end

@implementation CouponListViewController{
    NSInteger selectIndex;
    NSArray *couponList;
    NSArray *couponHisList;
    BOOL getDateSuccess;
    BOOL getHisDateSuccess;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    selectIndex = 1;
    couponList = [NSArray array];
    couponHisList = [NSArray array];
    getDateSuccess = NO;
    getHisDateSuccess = YES;
    
    [self getCouponDate];
    [self getHisCouponDate];
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

- (void) getCouponDate{
    
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    NSString *uri = @"/sbook?action=GetCouponList";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"studentid"] forKey:@"studentid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    
    NSLog(@"getCouponDate : %@",paramDic);
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        getDateSuccess = YES;
        if(getDateSuccess && getHisDateSuccess)
            [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            couponList = responseObject[@"couponlist"];
//            NSLog(@"count:%d",couponList.count);
            if(selectIndex == 1)
                [self.couponTableView reloadData];
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
        getDateSuccess = YES;
        if(getDateSuccess && getHisDateSuccess)
            [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
    
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

- (void) getHisCouponDate{
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    
    NSString *uri = @"/sbook?action=GetHisCouponList";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:user_info[@"studentid"] forKey:@"studentid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_GET];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        getHisDateSuccess = YES;
        if(getDateSuccess && getHisDateSuccess)
            [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            couponHisList = responseObject[@"couponlist"];
        if(selectIndex == 2)
            [self.couponTableView reloadData];
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
        getHisDateSuccess = YES;
        if(getDateSuccess && getHisDateSuccess)
            [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(selectIndex == 1){
        return couponList.count;
    }else{
        return couponHisList.count;
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"CouponTableViewCell";
    CouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"CouponTableViewCell" bundle:nil] forCellReuseIdentifier:indentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    }
    
    cell.couponTipView.layer.cornerRadius = 3;
    cell.couponTipView.layer.masksToBounds = YES;
    
    NSDictionary *dic;
    if(selectIndex == 1){
        dic = couponList[indexPath.row];
    }else{
        dic = couponHisList[indexPath.row];
    }
    int value = [dic[@"value"] intValue];
    int coupontype = [dic[@"coupontype"] intValue];
    NSString *end_time = dic[@"end_time"];
    int state = [dic[@"state"] intValue];
    
    NSString *title = dic[@"title"];
    
    if(coupontype == 1){
        cell.couponTitleLabel.text = @"小巴券－学时券";
        cell.labeltitle2.text = [NSString stringWithFormat:@"本券可以抵用%d学时学费",value];
    }else{
        cell.couponTitleLabel.text = @"小巴券－抵价券";
        cell.labeltitle2.text = [NSString stringWithFormat:@"本券可以抵用学费%d元",value];
    }
    
    
    cell.couponPublishLabel.text = title;
    
    if(![CommonUtil isEmpty:end_time]){
        NSDate *date = [CommonUtil getDateForString:end_time format:nil];
        end_time = [CommonUtil getStringForDate:date format:@"yyyy年MM月dd日"];
        cell.couponEndTime.text = [NSString stringWithFormat:@"有效期:%@",end_time];
    }else{
        cell.couponEndTime.text = @"";
    }
    
    if(selectIndex == 1){
        cell.couponTipView.hidden = YES;
    }else{
        cell.couponTipView.hidden = NO;
        if(state == 0){
            cell.couponStateLabel.text = @"已过期";
        }else{
            cell.couponStateLabel.text = @"已使用";
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (IBAction)clickForTitleLeft:(id)sender {
    if(selectIndex == 1)
        return;
    self.titleImageView.image = [UIImage imageNamed:@"coupon_left_selected"];
    self.titleLeftLabel.textColor = RGB(255, 255, 255);
    self.titleRightLabel.textColor = RGB(184, 184, 184);
    selectIndex = 1;
    [self.couponTableView reloadData];
}

- (IBAction)clickForTitleRight:(id)sender {
    if(selectIndex == 2)
        return;
    self.titleImageView.image = [UIImage imageNamed:@"coupon_right_selected"];
    self.titleLeftLabel.textColor = RGB(184, 184, 184);
    self.titleRightLabel.textColor = RGB(255, 255, 255);
    selectIndex = 2;
    [self.couponTableView reloadData];
}

@end
