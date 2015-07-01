//
//  CommentListViewController.m
//  guangda_student
//
//  Created by guok on 15/5/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CommentListViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "CommentTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface CommentListViewController ()<DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient>
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger pageNum;
@property (strong, nonatomic) NSMutableArray *commentsList;
@property (assign, nonatomic) int count;//总条数
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _pageNum = 0;
    self.commentsList = [NSMutableArray array];
    
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.tableView withClient:self];
    
    //加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.tableView withClient:self];
    
    [self pullToRefreshTriggered:self.pullToRefresh];
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


#pragma mark - DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pullToRefresh tableViewScrolled];
    
    [_pullToMore relocatePullToMoreView];    // 重置加载更多控件位置
    [_pullToMore tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pullToRefresh tableViewReleased];
    [_pullToMore tableViewReleased];
}

/* 刷新处理 */
- (void)pullToRefreshTriggered:(DSPullToRefreshManager *)manager {
    _pageNum = 0;
    [self getComments];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    _pageNum = _pageNum + 1;
    [self getComments];
}

-(void) getComments{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.coachid forKey:@"coachid"];
    [paramDic setObject:[NSString stringWithFormat:@"%ld",(long)_pageNum] forKey:@"pagenum"];
    
    NSString *uri = @"/sbook?action=GetCoachComments";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;     // 网络超时时长设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        NSString *message = responseObject[@"message"];
        if (code == 1)
        {
            
            if(_pageNum == 0){
                [self.commentsList removeAllObjects];
            }
            
            [self.commentsList addObjectsFromArray:responseObject[@"evalist"]];
            self.count = [responseObject[@"count"] intValue];
            
            if(self.count > 0){
                self.titleLabel.text = [NSString stringWithFormat:@"评论(%d)",self.count];
            }
            
            if (self.count == self.commentsList.count) {
                [_pullToMore setPullToMoreViewVisible:NO];
            } else {
                [_pullToMore setPullToMoreViewVisible:YES];
                [_pullToMore relocatePullToMoreView];
            }
            
            [self.tableView reloadData];
        }else{
            [self makeToast:message];
        }
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        [_pullToMore tableViewReloadFinished];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        [_pullToMore tableViewReloadFinished];
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.commentsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indefinder = @"CommentTableViewCell";
    
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indefinder];
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:indefinder];
        cell = [tableView dequeueReusableCellWithIdentifier:indefinder];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.avatar.layer.cornerRadius = 12.5;
    cell.avatar.layer.masksToBounds = YES;
    
    NSDictionary *dic = self.commentsList[indexPath.row];
    
    NSString *avatarUrl = dic[@"avatarUrl"];
    if(![CommonUtil isEmpty:avatarUrl]){
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    }
    
    NSString *nickname = dic[@"nickname"];
    if(![CommonUtil isEmpty:nickname]){
        cell.nick.text = nickname;
    }else{
        cell.nick.text = @"";
    }
    
    NSString *content = dic[@"content"];
    if(![CommonUtil isEmpty:content]){
        cell.content.text = content;
    }else{
        cell.content.text = @"";
    }
    
    NSString *addtime = dic[@"addtime"];
    if(![CommonUtil isEmpty:addtime]){
        cell.time.text = [CommonUtil intervalSinceNow:addtime];
    }else{
        cell.time.text = @"";
    }
    
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72.0;
}

@end
