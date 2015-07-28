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
#import <CoreText/CoreText.h>
@interface CoinListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *mainTableview;
@property (strong, nonatomic) IBOutlet UIView *headView;

@property (strong, nonatomic) IBOutlet UILabel *totalCoinLabel;

@property (strong, nonatomic) IBOutlet UILabel *coinCount1;
@property (strong, nonatomic) IBOutlet UILabel *coinCount2;
@property (strong, nonatomic) IBOutlet UILabel *coinCount3;
@property (strong, nonatomic) IBOutlet UILabel *coinName1;
@property (strong, nonatomic) IBOutlet UILabel *coinName2;
@property (strong, nonatomic) IBOutlet UILabel *coinName3;

@end

@implementation CoinListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mainTableview.delegate = self;
    self.mainTableview.dataSource = self;
    
    CGRect viewRect = [[UIScreen mainScreen] bounds];
    [self.headView setFrame:CGRectMake(0, 0, viewRect.size.width, 305)];
    self.mainTableview.tableHeaderView = self.headView;
    
    NSString *coinsum = @"2323";
    NSString *coinStr = [NSString stringWithFormat:@"%@ 个", coinsum];
    NSMutableAttributedString *string3 = [[NSMutableAttributedString alloc] initWithString:coinStr];
    [string3 addAttribute:(NSString *)kCTFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0,coinsum.length)];
    [string3 addAttribute:NSForegroundColorAttributeName value:RGB(246, 102, 93) range:NSMakeRange(0,coinsum.length)];
    self.totalCoinLabel.attributedText = string3;
    
    
}
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
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
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (IBAction)useRule:(id)sender {
    UseRuleViewController *viewcontroller = [[UseRuleViewController alloc]initWithNibName:@"UseRuleViewController" bundle:nil];
    [self.navigationController pushViewController:viewcontroller animated:YES];
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
