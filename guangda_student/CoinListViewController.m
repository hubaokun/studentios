//
//  CoinListViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoinListViewController.h"
#import "CoinListTableViewCell.h"
#import "UseRuleViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import <CoreText/CoreText.h>

@interface CoinListViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient,DSBottomPullToMoreManagerClient> {
    int _curPage;
    int _searchPage;
}

@property (strong, nonatomic) IBOutlet UITableView *mainTableview;
@property (strong, nonatomic) IBOutlet UIView *headView;

@property (strong, nonatomic) IBOutlet UILabel *totalCoinLabel;

@property (strong, nonatomic) IBOutlet UILabel *coinCount1;
@property (strong, nonatomic) IBOutlet UILabel *coinCount2;
@property (strong, nonatomic) IBOutlet UILabel *coinCount3;
@property (strong, nonatomic) IBOutlet UILabel *coinName1;
@property (strong, nonatomic) IBOutlet UILabel *coinName2;
@property (strong, nonatomic) IBOutlet UILabel *coinName3;
@property (weak, nonatomic) IBOutlet UILabel *fCoinSumLabel;

// 页面数据
@property (strong, nonatomic) NSMutableArray *coinsArray;
@property (copy , nonatomic) NSString *coachName; // 限定使用教练的名字

@end

@implementation CoinListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self postGetCoinList];
    
    self.mainTableview.delegate = self;
    self.mainTableview.dataSource = self;
    
    CGRect viewRect = [[UIScreen mainScreen] bounds];
    [self.headView setFrame:CGRectMake(0, 64, viewRect.size.width, 144)];
//    self.mainTableview.tableHeaderView = self.headView;
    [self.view addSubview:self.headView];
    
    NSString *coinsum = self.coinSum;
    NSString *coinStr = [NSString stringWithFormat:@"%@ 个", coinsum];
    NSMutableAttributedString *string3 = [[NSMutableAttributedString alloc] initWithString:coinStr];
    [string3 addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:32] range:NSMakeRange(0,coinsum.length)];
    [string3 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0,coinsum.length)];
    self.totalCoinLabel.attributedText = string3;
    
    self.fCoinSumLabel.text = [NSString stringWithFormat:@"(冻结数额: %@个)", self.fCoinSum];;
}
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coinsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"CoinListTableViewCell";
    CoinListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"CoinListTableViewCell" bundle:nil] forCellReuseIdentifier:indentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.coin = self.coinsArray[indexPath.row];
    [cell loadData];
    return cell;
}

#pragma mark - 网络请求
// 获取小巴币列表
- (void)postGetCoinList {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
//    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    
    NSString *uri = @"/suser?action=GETSTUDENTCOINRECORDLIST";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            NSArray *coinsInfoList = responseObject[@"recordlist"];
            self.coinsArray = [XBCoin coinsWithArray:coinsInfoList];
            self.coachName = [responseObject[@"coachname"] description];

            [self.mainTableview reloadData];
        }else if(code == 95){
            
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

#pragma mark - Action
- (IBAction)useRule:(id)sender {
    UseRuleViewController *viewcontroller = [[UseRuleViewController alloc]initWithNibName:@"UseRuleViewController" bundle:nil];
    [self.navigationController pushViewController:viewcontroller animated:YES];
}


@end
