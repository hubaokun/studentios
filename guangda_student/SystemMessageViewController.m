//
//  SystemMessageViewController.m
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SystemMessageViewController.h"
#import "MessageTableViewCell.h"
#import "MessageDetailsViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"
#import "LoginViewController.h"

@interface SystemMessageViewController ()<UITableViewDataSource, UITableViewDelegate, DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient> {
    int _pagenum;
}
@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *messageHeightArray
;
- (IBAction)backButtonClick:(id)sender;

@end

@implementation SystemMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataList = [NSMutableArray array];
    _messageHeightArray = [NSMutableArray array];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    //加载更多
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFreshData];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count * 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2 == 0) {
        return 42 + [_messageHeightArray[indexPath.row / 2] floatValue];
    } else {
        return 8;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0)
    {
        static NSString *cellIndentifer = @"messageCell";
        MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
        if (!cell) {
//            cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifer];
                [tableView registerNib:[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil] forCellReuseIdentifier:cellIndentifer];
                cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
        }
        
        // 取得数据
        NSDictionary *dataDic = _dataList[indexPath.row / 2];
        NSString *category = dataDic[@"category"];
        NSString *content = dataDic[@"content"];
        NSString *addtime = [dataDic[@"addtime"] substringToIndex:10];
        int readstate = [dataDic[@"readstate"] intValue];
        
        // 加载数据
        if (readstate == 1) {
            cell.redPoint.hidden = YES;
            cell.leftJuli.constant = 10;
        } else {
            cell.redPoint.hidden = NO;
            cell.leftJuli.constant = 24;
        }
        
        cell.titleLabel.text = category;
        cell.dateLabel.text = addtime;
        cell.contentLabel.text = content;
        cell.contentLabelHeightCon.constant = [_messageHeightArray[indexPath.row / 2] floatValue];
        
        return cell;
    }
    
    else {
        
        static NSString *cellIndentifer = @"emptyMessagecell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifer];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifer];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取得数据
    NSDictionary *dataDic = _dataList[indexPath.row / 2];
    NSString *category = dataDic[@"category"];
    NSString *content = dataDic[@"content"];
    NSString *addtime = [dataDic[@"addtime"] substringToIndex:10];
    NSString *noticeid = [NSString stringWithFormat:@"%d",[dataDic[@"noticeid"] intValue]];
    int readstate = [dataDic[@"readstate"] intValue];
    
    MessageDetailsViewController *viewController = [[MessageDetailsViewController alloc] initWithNibName:@"MessageDetailsViewController" bundle:nil];
    viewController.titleStr = category;
    viewController.contentStr = content;
    viewController.dateStr = addtime;
    viewController.noticeId = noticeid;
    viewController.readState = readstate;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self postDelNotice:indexPath];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
//    [self.tableView reloadData];
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
//        
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:new.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    });

}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
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
    _pagenum = 0;
    [self getFreshData];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    _pagenum = (int)_dataList.count / 10;
    [self getMoreData];
}

#pragma mark - 网络请求
// 获取最新数据
- (void)getFreshData {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    NSString *pagenum =  [NSString stringWithFormat:@"%d", _pagenum];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:pagenum forKey:@"pagenum"];
    
    NSString *uri = @"/sset?action=GetNotices";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self.dataList removeAllObjects];
            NSArray *array = responseObject[@"datalist"];
            [self.dataList addObjectsFromArray:array];
            if (self.dataList.count == 0) {
                self.mainTableView .hidden = YES;
                self.noDataImageView.hidden = NO;
            } else {
                self.mainTableView.hidden = NO;
                self.noDataImageView.hidden = YES;
            }
            
            [self calculateMessageHeight];
            [self.mainTableView reloadData];
            
            if ([responseObject[@"hasmore"] intValue] == 0) {
                [_pullToMore setPullToMoreViewVisible:NO];
            } else {
                [_pullToMore setPullToMoreViewVisible:YES];
                [_pullToMore relocatePullToMoreView];
            }
            
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
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
    }];
}

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

// 上拉加载更多
- (void)getMoreData {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    NSString *pagenum =  [NSString stringWithFormat:@"%d", _pagenum];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:pagenum forKey:@"pagenum"];
    
    NSString *uri = @"/sset?action=GetNotices";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            NSArray *array = responseObject[@"datalist"];
            [self.dataList addObjectsFromArray:array];
            if (self.dataList.count == 0) {
                self.mainTableView .hidden = YES;
                self.noDataImageView.hidden = NO;
            } else {
                self.mainTableView.hidden = NO;
                self.noDataImageView.hidden = YES;
            }
            
            [self calculateMessageHeight];
            [self.mainTableView reloadData];
            if ([responseObject[@"hasmore"] intValue] == 0) {
                [_pullToMore setPullToMoreViewVisible:NO];
            } else {
                [_pullToMore setPullToMoreViewVisible:YES];
                [_pullToMore relocatePullToMoreView];
            }
            
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
        [_pullToMore tableViewReloadFinished];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
        [_pullToMore tableViewReloadFinished];
    }];
}

// 删除消息
- (void)postDelNotice:(NSIndexPath *)indexPath {
    NSDictionary *dataDic = _dataList[indexPath.row / 2];
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    NSString *noticeId = [NSString stringWithFormat:@"%d",[dataDic[@"noticeid"] intValue]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:noticeId forKey:@"noticeid"];
    
    NSString *uri = @"/sset?action=DelNotice";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataList removeObjectAtIndex:indexPath.row/2];
                // Delete the row from the data source.
                [self.mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexPath.row/2 inSection:0]
                                                            , [NSIndexPath indexPathForRow:(indexPath.row/2 + 1) inSection:0], nil]
                                          withRowAnimation:UITableViewRowAnimationFade];
                [self.mainTableView reloadData];
            });
            
            [self makeToast:@"删除成功"];
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
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
}

#pragma mark - 数据处理
// 计算message文字高度
- (void)calculateMessageHeight {
    CGFloat mesWidth = 0;
    for (int i = 0; i < _dataList.count; i++) {
        NSDictionary *dataDic = _dataList[i];
        NSString *mesStr = dataDic[@"content"];
        int readstate = [dataDic[@"readstate"] intValue];
        if (readstate == 1) {
            mesWidth = _screenWidth - 32;
        } else {
            mesWidth = _screenWidth - 18;
        }
        CGSize mesSize = [CommonUtil sizeWithString:mesStr fontSize:14 sizewidth:mesWidth sizeheight:0];
        [_messageHeightArray addObject:[NSNumber numberWithFloat:mesSize.height]];
    }
}

- (IBAction)backButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //通知更新小红点显示
    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveMessageNoRead" object:self];
}
@end
