//
//  CoinListViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoinListViewController.h"
#import "CoinListTableViewCell.h"
@interface CoinListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *mainTableview;
@property (strong, nonatomic) IBOutlet UIView *headView;

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
    return cell;
}

- (IBAction)useRule:(id)sender {
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
