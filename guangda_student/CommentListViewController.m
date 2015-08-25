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
#import "XBComment.h"

@interface CommentListViewController ()<DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient> {
    int _curPage;
    int _searchPage;
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *commentArray;
@property (assign, nonatomic) int count;//总条数
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.tableView withClient:self];
    
    //加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.tableView withClient:self];
    
    [self pullToRefreshTriggered:self.pullToRefresh];
}

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
    _curPage = 0;
    _searchPage = 0;
    if (self.type == 1) {
        [self getAllComments];
    }
    else {
        [self getOneStudentComments];
    }
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    _searchPage = _curPage + 1;
    if (self.type == 1) {
        [self getAllComments];
    }
    else {
        [self getOneStudentComments];
    }
}

#pragma mark - 网络请求
// 获取所有评论
-(void) getAllComments{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.coachid forKey:@"coachid"];
    [paramDic setObject:[NSString stringWithFormat:@"%d", _searchPage] forKey:@"pagenum"];
    [paramDic setObject:@"2" forKey:@"type"];
    
    NSString *uri = @"/sbook?action=GETCOACHCOMMENTS";
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
            NSArray *commentDictArray = responseObject[@"evalist"];
            
            // 刷新数据
            if (_searchPage == 0) {
                self.count = [responseObject[@"count"] intValue];
                self.commentArray = [XBComment commentsWithArray:commentDictArray];
            }
            
            // 加载更多
            else {
                NSMutableArray *moreCommentArray = [XBComment commentsWithArray:commentDictArray];
                [self.commentArray addObjectsFromArray:moreCommentArray];
                _curPage = _searchPage;
            }
            
            // 评论数
            self.count = [responseObject[@"count"] intValue];
            if(self.count > 0){
                self.titleLabel.text = [NSString stringWithFormat:@"评论(%d)",self.count];
            }
            
            // 是否还有更多
            if ([responseObject[@"hasmore"] intValue] == 0) {
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

// 获取单学员所有评论
-(void) getOneStudentComments{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.coachid forKey:@"coachid"];
    [paramDic setObject:[NSString stringWithFormat:@"%d", _searchPage] forKey:@"pagenum"];
    [paramDic setObject:self.studentID forKey:@"studentid"];
    
    NSString *uri = @"/sbook?action=GETCOMMENTSFORSTUDENT";
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
            NSArray *commentDictArray = responseObject[@"evalist"];
            
            // 刷新数据
            if (_searchPage == 0) {
                self.count = [responseObject[@"count"] intValue];
                self.commentArray = [XBComment commentsWithArray:commentDictArray];
            }
            
            // 加载更多
            else {
                NSMutableArray *moreCommentArray = [XBComment commentsWithArray:commentDictArray];
                [self.commentArray addObjectsFromArray:moreCommentArray];
                _curPage = _searchPage;
            }
            
            // 评论数
            self.count = [responseObject[@"count"] intValue];
            self.titleLabel.text = [NSString stringWithFormat:@"%@评论(%d)", self.studentName, self.count];
            
            // 是否还有更多
            if ([responseObject[@"hasmore"] intValue] == 0) {
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

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.commentArray.count;
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
    
    XBComment *comment = self.commentArray[indexPath.row];
    cell.comment = comment;
    if (self.type == 1) {
        cell.type = CommentCellTypeUniversal;
    } else {
        cell.type = CommentCellTypePersonal;
    }
    [cell loadData];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XBComment *comment = self.commentArray[indexPath.row];
    return [CommentTableViewCell calculateHeight:comment];
}

@end
