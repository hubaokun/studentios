//
//  UseRuleViewController.m
//  guangda_student
//
//  Created by Ray on 15/7/21.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "UseRuleViewController.h"
#import "UserRuleTableViewCell.h"
@interface UseRuleViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *mainTableview;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;

@end

@implementation UseRuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.mainTableview.delegate = self;
//    self.mainTableview.dataSource = self;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://note.youdao.com/share/?id=ea7e70b4495c2a0c35aebb3950c839b8&type=note"]];
    [self.contentWebView loadRequest:request];
}
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"UserRuleTableViewCell";
    UserRuleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"UserRuleTableViewCell" bundle:nil] forCellReuseIdentifier:indentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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
