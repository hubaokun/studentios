//
//  CoachDetailViewController.m
//  guangda_student
//
//  Created by Dino on 15/4/24.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "CoachDetailViewController.h"
#import "TQStarRatingView.h"
#import "CommentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "CommentListViewController.h"
#import "DSPullToRefreshManager.h"
#import "DSBottomPullToMoreManager.h"

#define COACH_DETAILVIEW_HEIGHT 291
@interface CoachDetailViewController ()<DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient> {
    int _curPage;
    int _searchPage;
}

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@property (strong, nonatomic) IBOutlet UITableView *tabelVIew;

@property (strong, nonatomic) IBOutlet UIView *detailsView;
@property (strong, nonatomic) TQStarRatingView *starView;

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *sex;
@property (strong, nonatomic) IBOutlet UILabel *age;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *idCardNum;
@property (strong, nonatomic) IBOutlet UILabel *coachCardNum;
@property (strong, nonatomic) IBOutlet UILabel *carType;
@property (strong, nonatomic) IBOutlet UILabel *carNum;
@property (strong, nonatomic) IBOutlet UILabel *driveSchool;
@property (strong, nonatomic) IBOutlet UILabel *coachLevel;
@property (strong, nonatomic) IBOutlet UILabel *selfComment;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selfCommentHeight;

@property (strong, nonatomic) IBOutlet UILabel *urgentPhone;    // 紧急联系人电话
@property (strong, nonatomic) IBOutlet UILabel *coachPhone;     // 教练电话
@property (assign, nonatomic) int studentNum; // 评论人数
@property (assign, nonatomic) int count; // 总条数
@property (strong, nonatomic) NSString *phone;//教练电话

// 页面数据
@property (strong, nonatomic) NSMutableArray *commentArray;

@end

@implementation CoachDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestGetCoachDetail];
    [self viewConfig];
    [self pullToRefreshTriggered:self.pullToRefresh];
}

- (void)viewConfig {
    self.detailsView.frame = CGRectMake(0, 0, SCREEN_WIDTH, COACH_DETAILVIEW_HEIGHT);
    self.tabelVIew.tableHeaderView = self.detailsView;
    
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(52, 107, 83, 15)];
    [self.detailsView addSubview:self.starView];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.tabelVIew withClient:self];
    
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.tabelVIew withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO]; //隐藏加载更多
}

#pragma mark - 接口请求
- (void)requestGetCoachDetail
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.coachId forKey:@"coachid"];
    
    NSString *uri = @"/sbook?action=GetCoachDetail";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;     // 网络超时时长设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            NSDictionary *coachInfo = responseObject[@"coachinfo"];
            self.name.text = [coachInfo[@"realname"] description];;
            switch ([[coachInfo[@"gender"] description] intValue]) {
                case 1:
                    self.sex.text = @"男";
                    break;
                
                case 2:
                    self.sex.text = @"女";
                    break;
                    
                default:
                    self.sex.text = @"未设置";
                    break;
            }
            
            NSString *age = [coachInfo[@"age"] description];
//            NSString *address = [coachInfo[@"address"] description];
//            NSString *id_cardnum = [coachInfo[@"id_cardnum"] description];
            NSString *coach_cardnum = [coachInfo[@"coach_cardnum"] description];
            NSString *drive_school = [coachInfo[@"drive_school"] description];
//            NSString *level = [coachInfo[@"level"] description];
            CGFloat score = [[coachInfo[@"score"] description] floatValue];
            
            NSArray *modelList = coachInfo[@"modellist"];
            NSString *carmodel = @"";
            for (NSDictionary *dic in modelList) {
                NSString *modelname = [dic[@"modelname"] description];
                if(carmodel.length == 0){
                    carmodel = modelname;
                }else{
                    carmodel = [NSString stringWithFormat:@"%@、%@", carmodel, modelname];
                }
            }
//            carmodel = [carmodel substringFromIndex:1];
            
            self.age.text = [self isEmpty:age];
            self.coachCardNum.text = [self isEmpty:coach_cardnum];
            self.carType.text = [self isEmpty:carmodel];
            self.driveSchool.text = [self isEmpty:drive_school];
            [self.starView changeStarForegroundViewWithScore:score];
            
            NSString *coachInfoStr = [coachInfo[@"selfeval"] description];
            if (coachInfoStr.length == 0) {
                coachInfoStr = @"暂无";
            }
            self.selfComment.text = coachInfoStr;
            
            NSString *urgentStr = [coachInfo[@"phone"] description];
            NSString *coachPhoneStr = [coachInfo[@"phone"] description];
            urgentStr = [urgentStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            coachPhoneStr = [coachPhoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            self.phone = urgentStr;
            
            CGSize size = [CommonUtil sizeWithString:coachInfoStr fontSize:15.0 sizewidth:(SCREEN_WIDTH - 92) sizeheight:CGFLOAT_MAX];
            self.selfCommentHeight.constant = size.height;
            
            self.urgentPhone.text = [self isEmpty:@"电话"];
            self.coachPhone.text = [self isEmpty:@"短信"];
    
            self.detailsView.frame = CGRectMake(0, 0, SCREEN_WIDTH, size.height - 20 + COACH_DETAILVIEW_HEIGHT);
            self.tabelVIew.tableHeaderView = self.detailsView;
            
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

// 获取评论列表
-(void) getComments{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.coachId forKey:@"coachid"];
    [paramDic setObject:[NSString stringWithFormat:@"%d", _searchPage] forKey:@"pagenum"];
    [paramDic setObject:@"1" forKey:@"type"]; // 过滤重复的学员
    
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
                self.studentNum = [responseObject[@"studentnum"] intValue];
                self.commentArray = [XBComment gatherCommentsWithArray:commentDictArray];
            }
            
            // 加载更多
            else {
                NSMutableArray *moreCommentArray = [XBComment gatherCommentsWithArray:commentDictArray];
                [self.commentArray addObjectsFromArray:moreCommentArray];
                _curPage = _searchPage;
            }
            
            // 是否还有更多
            if ([responseObject[@"hasmore"] intValue] == 0) {
                [_pullToMore setPullToMoreViewVisible:NO];
            } else {
                [_pullToMore setPullToMoreViewVisible:YES];
                [_pullToMore relocatePullToMoreView];
            }
            
            [self.tabelVIew reloadData];
        }else{
            [self makeToast:message];
        }
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        [_pullToMore tableViewReloadFinished];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [_pullToRefresh tableViewReloadFinishedAnimated:YES];
        [_pullToMore tableViewReloadFinished];
        [self makeToast:ERR_NETWORK];
    }];
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
    [self getComments];
}

/* 加载更多 */
- (void)bottomPullToMoreTriggered:(DSBottomPullToMoreManager *)manager {
    _searchPage = _curPage + 1;
    [self getComments];
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentArray.count;
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
    cell.type = CommentCellTypeNewest;
    [cell loadData];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60.0)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    topLine.backgroundColor = RGB(219.0, 220.0, 223.0);
    [headerView.contentView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 59.0, SCREEN_WIDTH, 1)];
    bottomLine.backgroundColor = RGB(219.0, 220.0, 223.0);
    [headerView.contentView addSubview:bottomLine];
    
    if(self.commentArray.count == 0){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60.0)];
        label.font = [UIFont systemFontOfSize:18.0];
        label.textColor = RGB(60, 60, 60);
        label.text = @"该教练暂无评评价～";
        label.textAlignment = NSTextAlignmentCenter;
        [headerView.contentView addSubview:label];
    }else{
        CGSize size = [CommonUtil sizeWithString:[NSString stringWithFormat:@"共%d条",self.count] fontSize:15.0 sizewidth:CGFLOAT_MAX sizeheight:25.0];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, size.width, 20.0)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = RGB(60, 60, 60);
        label.text = [NSString stringWithFormat:@"共%d条",self.count];
        [headerView.contentView addSubview:label];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 15.0)];
        label1.font = [UIFont systemFontOfSize:11.0];
        label1.textColor = RGB(60, 60, 60);
        label1.text = [NSString stringWithFormat:@"%d名学员评论", self.studentNum];
        [headerView.contentView addSubview:label1];
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 21, 20, 11, 20)];
        arrow.image = [UIImage imageNamed:@"comment_arrow"];
        [headerView.contentView addSubview:arrow];        
    }
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [headerView addGestureRecognizer:singleRecognizer];
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XBComment *comment = self.commentArray[indexPath.row];
    return [CommentTableViewCell calculateHeight:comment];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XBComment *comment = self.commentArray[indexPath.row];
    CommentListViewController *nextController = [[CommentListViewController alloc] initWithNibName:@"CommentListViewController" bundle:nil];
    nextController.coachid = self.coachId;
    nextController.studentID = comment.studentID;
    nextController.studentName = comment.studentName;
    nextController.type = 2;
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark - private
- (NSString *)isEmpty:(NSString *)string
{
    if (string.length == 0) {
        return @"暂无";
    }
    return string;
}

#pragma mark - 点击事件
- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)phoneCallClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *phoneNum = nil;
    
    if (button.tag == 0) {
        if (self.phone.length > 3) {
            phoneNum = [NSString stringWithFormat:@"telprompt:%@", self.phone];
        }else{
            [self makeToast:@"该教练暂无电话"];
            return;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
    }else{
        if (self.phone.length > 3) {
            phoneNum = [NSString stringWithFormat:@"sms://%@", self.phone];
        }else{
            [self makeToast:@"该教练暂无电话"];
            return;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
    }
    
    
}
-(void)SingleTap:(UITapGestureRecognizer*)recognizer
{
    CommentListViewController *nextController = [[CommentListViewController alloc] initWithNibName:@"CommentListViewController" bundle:nil];
    nextController.coachid = self.coachId;
    nextController.type = 1;
    [self.navigationController pushViewController:nextController animated:YES];
}

@end
