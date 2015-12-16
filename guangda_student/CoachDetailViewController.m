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
#import "GuangdaCoach.h"
#import "MainViewController.h"
#import "AppointCoachViewController.h"

#define COACH_DETAILVIEW_HEIGHT 358
@interface CoachDetailViewController ()<DSPullToRefreshManagerClient, DSBottomPullToMoreManagerClient> {
    int _curPage;
    int _searchPage;
}

@property (strong, nonatomic) DSPullToRefreshManager *pullToRefresh;    // 下拉刷新
@property (strong, nonatomic) DSBottomPullToMoreManager *pullToMore;    // 上拉加载

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@property (strong, nonatomic) IBOutlet UIView *detailsView;
@property (weak, nonatomic) IBOutlet UIView *coachInfoView;
@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameWidthCon;
@property (weak, nonatomic) IBOutlet UIView *genderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *genderViewWidthCon;
@property (weak, nonatomic) IBOutlet UIImageView *genderIcon;
@property (weak, nonatomic) IBOutlet UIImageView *starcoachIcon;
@property (strong, nonatomic) TQStarRatingView *starView;
@property (strong, nonatomic) UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *countDesLabel;
@property (weak, nonatomic) IBOutlet UIButton *appointBtn;
/* courseView内部控件的屏幕适配 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *con4;

@property (weak, nonatomic) IBOutlet UIView *freeCourseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *courseViewHeightCon;
@property (weak, nonatomic) IBOutlet UILabel *age;
@property (weak, nonatomic) IBOutlet UILabel *carType;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *commentSelfLabel;
@property (assign, nonatomic) int studentNum; // 评论人数
@property (assign, nonatomic) int count; // 总条数
@property (strong, nonatomic) NSString *phone;//教练电话

// 页面数据
@property (strong, nonatomic) NSDictionary *coachInfoDict;
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
    self.mainTableView.tableHeaderView = self.detailsView;
    self.appointBtn.layer.cornerRadius = 3;
    self.genderView.layer.cornerRadius = 2;
    
    // 头像
    self.portrait.layer.cornerRadius = self.portrait.width/2;
    self.portrait.layer.masksToBounds = YES;
    
    // 星级
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(self.name.x, 40, 58, 10)];
    [self.coachInfoView addSubview:self.starView];
    
    // 评分
    UILabel *scoreLabel = [[UILabel alloc] init];
    self.scoreLabel = scoreLabel;
    [self.coachInfoView addSubview:scoreLabel];
    scoreLabel.width = 30;
    scoreLabel.height = 12;
    scoreLabel.x = self.starView.right + 6;
    scoreLabel.centerY = self.starView.centerY;
    scoreLabel.font = [UIFont systemFontOfSize:10];
    scoreLabel.textColor = RGB(102, 102, 102);
    
    // 体验课
    UIView *freeCourseIcon = [GuangdaCoach createFreeCourseIcon];
    freeCourseIcon.x = 13;
    freeCourseIcon.centerY = self.freeCourseView.height / 2;
    [self.freeCourseView addSubview:freeCourseIcon];
    
    //刷新加载
    self.pullToRefresh = [[DSPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0 tableView:self.mainTableView withClient:self];
    
    self.pullToMore = [[DSBottomPullToMoreManager alloc] initWithPullToMoreViewHeight:60.0 tableView:self.mainTableView withClient:self];
    [self.pullToMore setPullToMoreViewVisible:NO]; //隐藏加载更多
    
    // 屏幕适配
    NSLog(@"screnn_width === %f", SCREEN_WIDTH);
    CGFloat ratio = SCREEN_WIDTH / 320.0;
    self.con1.constant *= ratio;
    self.con2.constant *= ratio;
    self.con3.constant *= ratio;
    self.con4.constant *= ratio;
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
            self.coachInfoDict = responseObject[@"coachinfo"];
            [self showData:self.coachInfoDict];
            
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
            
            [self.mainTableView reloadData];
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
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34.0)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    
//    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
//    topLine.backgroundColor = RGB(219.0, 220.0, 223.0);
//    [headerView.contentView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 33.0, SCREEN_WIDTH, 1)];
    bottomLine.backgroundColor = RGB(223, 223, 223);
    [headerView.contentView addSubview:bottomLine];
    
    if(self.commentArray.count == 0){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, SCREEN_WIDTH, headerView.height)];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = RGB(153, 153, 153);
        label.text = @"该教练暂无评价～";
        [headerView.contentView addSubview:label];
    }
    else {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 0, 45, headerView.height)];
        [headerView addSubview:titleLabel];
        titleLabel.font = [UIFont systemFontOfSize:11];
        titleLabel.textColor = RGB(153, 153, 153);
        titleLabel.text = @"学员评价";
        
        // 人数
        UILabel *countLabel = [[UILabel alloc] init];
        [headerView addSubview:countLabel];
        countLabel.width = 100;
        countLabel.height = headerView.height;
        countLabel.x = titleLabel.right + 3;
        countLabel.y = 0;
        countLabel.font = [UIFont systemFontOfSize:10];
        countLabel.textColor = RGB(170, 170, 170);
        countLabel.text = [NSString stringWithFormat:@"(%d人评论)", self.studentNum];
        
        // 箭头
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 20, 12, 5.5, 9)];
        arrow.image = [UIImage imageNamed:@"ic_arrow_right"];
        [headerView.contentView addSubview:arrow];
        
        // 共几条
        CGSize size = [CommonUtil sizeWithString:[NSString stringWithFormat:@"共%d条",self.count] fontSize:10.0 sizewidth:CGFLOAT_MAX sizeheight:25.0];
        UILabel *label = [[UILabel alloc] init];
        label.width = size.width;
        label.height = 12;
        label.right = arrow.left - 10;
        label.centerY = headerView.height / 2;
        label.font = [UIFont systemFontOfSize:10.0];
        label.textColor = RGB(170, 170, 170);
        label.text = [NSString stringWithFormat:@"共%d条",self.count];
        [headerView.contentView addSubview:label];
    }
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [headerView addGestureRecognizer:singleRecognizer];
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 34.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    XBComment *comment = self.commentArray[indexPath.row];
    return [CommentTableViewCell calculateHeight:comment];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    XBComment *comment = self.commentArray[indexPath.row];
//    CommentListViewController *nextController = [[CommentListViewController alloc] initWithNibName:@"CommentListViewController" bundle:nil];
//    nextController.coachid = self.coachId;
//    nextController.studentID = comment.studentID;
//    nextController.studentName = comment.studentName;
//    nextController.type = 2;
//    [self.navigationController pushViewController:nextController animated:YES];
//}

#pragma mark - private
- (void)showData:(NSDictionary *)coachInfo
{
    // 头像
    NSString *avatarStr = [coachInfo[@"avatarurl"] description];
    [self.portrait sd_setImageWithURL:[NSURL URLWithString:avatarStr] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    
    // 姓名
    NSString *nameStr = [coachInfo[@"realname"] description];
    self.name.text = nameStr;
    CGFloat nameStrWidth = [CommonUtil sizeWithString:nameStr fontSize:16 sizewidth:150 sizeheight:20].width;
    self.nameWidthCon.constant = nameStrWidth;
    
    // 性别
    switch ([[coachInfo[@"gender"] description] intValue]) {
        case 1:
            self.genderView.backgroundColor = RGB(120, 190, 245);
            self.genderIcon.image = [UIImage imageNamed:@"ic_male"];
            break;
            
        case 2:
            self.genderView.backgroundColor = RGB(245, 135, 176);
            self.genderIcon.image = [UIImage imageNamed:@"ic_female"];
            break;
            
        default:
            self.genderView.backgroundColor = RGB(120, 190, 245);
            self.genderIcon.image = [UIImage imageNamed:@"ic_male"];
            break;
    }
    
    // 年龄
    NSString *age = [coachInfo[@"age"] description];
    if ([CommonUtil isEmpty:age] || age.intValue < 1) {
        self.age.hidden = YES;
        self.genderViewWidthCon.constant = 12;
    } else {
        self.age.text = age;
        self.age.hidden = NO;
        self.genderViewWidthCon.constant = 26;
    }
    
    // 明星教练
    int signState = [coachInfo[@"signstate"] intValue];
    if (signState == 1) {
        self.starcoachIcon.hidden = NO;
    } else {
        self.starcoachIcon.hidden = YES;
    }
    if ([self.carModelID isEqualToString:@"19"]) { // 陪驾
        self.starcoachIcon.hidden = YES;
    }
    
    // 评分
    CGFloat score = [coachInfo[@"score"] floatValue];
    [self.starView changeStarForegroundViewWithScore:score];
    self.scoreLabel.text = [NSString stringWithFormat:@"%.1f", score];
    
    // 预约次数
    NSString *count = nil;
    if ([[MainViewController readCarModelID] isEqualToString:@"19"]) { // 陪驾
        count = [coachInfo[@"accompanynum"] description];
        if ([CommonUtil isEmpty:count]) {
            count = @"0";
        }
        self.countLabel.text = [NSString stringWithFormat:@"%@", count];
        self.countDesLabel.text = @"陪驾次数";
    } else {
        count = [coachInfo[@"sumnum"] description];
        if ([CommonUtil isEmpty:count]) {
            count = @"0";
        }
        self.countLabel.text = [NSString stringWithFormat:@"%@", count];
        self.countDesLabel.text = @"预约次数";
    }
    
    // 准教车型
    NSArray *modelList = coachInfo[@"modellist"];
    NSString *carmodel = @"";
    for (NSDictionary *dic in modelList) {
        NSString *modelname = [dic[@"modelname"] description];
        if(carmodel.length == 0){
            carmodel = modelname;
        }else{
            carmodel = [NSString stringWithFormat:@"%@ 丨 %@", carmodel, modelname];
        }
    }
    self.carType.text = [NSString stringWithFormat:@"准教车型：%@", carmodel];
    
    // 体验课
    int freeCourseState = [coachInfo[@"freecoursestate"] intValue];
    if (freeCourseState && (![self.carModelID isEqualToString:@"19"])) {
        self.freeCourseView.hidden = NO;
        self.courseViewHeightCon.constant = 99;
        self.detailsView.height = COACH_DETAILVIEW_HEIGHT;
    } else {
        self.freeCourseView.hidden = YES;
        self.courseViewHeightCon.constant = 69;
        self.detailsView.height = COACH_DETAILVIEW_HEIGHT - 30;
    }
    
    // 电话
    NSString *phoneStr = [coachInfo[@"phone"] description];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.phone = phoneStr;
    
    // 练车地址
    NSString *addrStr = [coachInfo[@"detail"] description];
    self.address.text = addrStr;
    
    // 自我评价
    NSString *coachInfoStr = [coachInfo[@"selfeval"] description];
    if ([CommonUtil isEmpty:coachInfoStr]) {
        coachInfoStr = @"暂无评价~";
    }
    self.commentSelfLabel.text = coachInfoStr;
    
    self.mainTableView.tableHeaderView = self.detailsView;
}

- (NSString *)isEmpty:(NSString *)string
{
    if ([CommonUtil isEmpty:string]) {
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

- (IBAction)appointClick:(id)sender {
    NSLog(@"预约");
    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
    nextController.coachInfoDic = self.coachInfoDict;
    NSString *coachID = [self.coachInfoDict[@"coachid"] description];
    nextController.coachId = coachID;
    nextController.carModelID = [MainViewController readCarModelID];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)singleTap:(UITapGestureRecognizer*)recognizer
{
    CommentListViewController *nextController = [[CommentListViewController alloc] initWithNibName:@"CommentListViewController" bundle:nil];
    nextController.coachid = self.coachId;
    nextController.type = 1;
    [self.navigationController pushViewController:nextController animated:YES];
}

@end
