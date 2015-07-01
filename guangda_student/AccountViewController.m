//
//  AccountViewController.m
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AccountViewController.h"
#import "AccountTableViewCell.h"
#import "TypeinNumberViewController.h"
#import "AppDelegate.h"
#import "AccountManagerViewController.h"
#import "LoginViewController.h"

@interface AccountViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *currentMoneyLabel;  // 当前金额
@property (strong, nonatomic) IBOutlet UILabel *frozenMoneyLabel;   // 冻结金额
@property (strong, nonatomic) NSArray *recordList;

@property (strong, nonatomic) IBOutlet UIView *moneyView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIButton *rechargeBtn;       // 充值
@property (strong, nonatomic) IBOutlet UIButton *getCashBtn;        // 提现

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topLineHeight;

- (IBAction)clickForAccountManager:(id)sender;


@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.rechargeBtn.layer.cornerRadius = 5;
    self.getCashBtn.layer.cornerRadius = 5;
    
    self.moneyView.layer.cornerRadius = 5;
    self.moneyView.layer.borderColor = [RGB(199, 199, 199) CGColor];
    self.moneyView.layer.borderWidth = .5;
    
    self.topLineHeight.constant = .5;
    self.bottomLineHeight.constant = .5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestAccountRemainMoneyInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 充值
- (IBAction)rechargeClick:(id)sender {
    TypeinNumberViewController *viewController = [[TypeinNumberViewController alloc] initWithNibName:@"TypeinNumberViewController" bundle:nil];
    viewController.status = @"1";
    [self.navigationController pushViewController:viewController animated:YES];
}

// 提现
- (IBAction)getCashClick:(id)sender {
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSString *aliaccount = user_info[@"alipay_account"];
    if([CommonUtil isEmpty:aliaccount]){
        [self makeToast:@"您还未设置支付宝账户,请先去账户管理页面设置您的支付宝账户"];
        return;
    }
    
    TypeinNumberViewController *viewController = [[TypeinNumberViewController alloc] initWithNibName:@"TypeinNumberViewController" bundle:nil];
    viewController.status = @"2";
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)requestAccountRemainMoneyInterface
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *userId = [delegate.userid description];
    if (!userId &&  userId.length == 0) {
        return;
    }
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    [paramDic setObject:userId forKey:@"studentid"];
    [paramDic setObject:user_info[@"token"] forKey:@"token"];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    NSString *uri = @"/suser?action=GetMyBalanceInfo";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {

            self.currentMoneyLabel.text = [NSString stringWithFormat:@"%.0f", [responseObject[@"balance"] doubleValue]];
            self.frozenMoneyLabel.text = [NSString stringWithFormat:@"(冻结金额: %@元)", responseObject[@"fmoney"]];
            self.recordList = responseObject[@"recordlist"];
            [self.tableView reloadData];
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
        [self makeToast:ERR_NETWORK];
    }];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recordList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"accountCell";
    AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"AccountTableViewCell" bundle:nil] forCellReuseIdentifier:indentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    }
    
    NSDictionary *recordDic = self.recordList[indexPath.row];
    int type = [recordDic[@"type"] intValue];
    switch (type) {
        case 2:
        case 3:
            cell.inOrOut.text = @"支出";
            cell.moneyNum.textColor = [UIColor greenColor];
            cell.moneyNum.text = [NSString stringWithFormat:@"-%@",[recordDic[@"amount"] description]];
            break;
        case 1:
            cell.inOrOut.text = @"充值";
            cell.moneyNum.textColor = [UIColor redColor];
            cell.moneyNum.text = [NSString stringWithFormat:@"+%@",[recordDic[@"amount"] description]];
            break;
        case 0:
            cell.inOrOut.text = @"提现";
            cell.moneyNum.textColor = [UIColor greenColor];
            break;
            
        default:
            break;
    }
    cell.dateTimeLabel.text = [recordDic[@"addtime"] description];
    cell.lineHeight.constant = 0.5;
    return cell;
}

- (IBAction)clickForAccountManager:(id)sender {
    AccountManagerViewController *nextViewController = [[AccountManagerViewController alloc] initWithNibName:@"AccountManagerViewController" bundle:nil];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
@end
