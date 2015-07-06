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

@interface CoachDetailViewController ()
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
@property (strong, nonatomic) NSMutableArray *commentsList;
@property (assign, nonatomic) int count;//总条数
@property (strong, nonatomic) NSString *telphone;//教练电话

@end

@implementation CoachDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self requestGetCoachDetail];
    self.detailsView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 320);
    
    self.tabelVIew.tableHeaderView = self.detailsView;
    
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(52, 107, 87, 15)];
    [self.detailsView addSubview:self.starView];
    
    _commentsList = [NSMutableArray array];
    [self getComments];
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
- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)phoneCallClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *phoneNum = nil;
    
    if (button.tag == 0) {
        if (self.telphone.length > 3) {
            phoneNum = [NSString stringWithFormat:@"telprompt:%@", self.telphone];
        }else{
            [self makeToast:@"该教练暂无电话"];
            return;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
    }else{
        if (self.telphone.length > 3) {
            phoneNum = [NSString stringWithFormat:@"sms://%@", self.telphone];
        }else{
            [self makeToast:@"该教练暂无电话"];
            return;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
    }
    
    
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
            
            NSString *urgentStr = [coachInfo[@"telphone"] description];
            NSString *coachPhoneStr = [coachInfo[@"telphone"] description];
            urgentStr = [urgentStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            coachPhoneStr = [coachPhoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            self.telphone = urgentStr;
            
            CGSize size = [CommonUtil sizeWithString:coachInfoStr fontSize:15.0 sizewidth:(SCREEN_WIDTH - 20) sizeheight:CGFLOAT_MAX];
            self.selfCommentHeight.constant = size.height;
            
            self.urgentPhone.text = [self isEmpty:@"电话"];
            self.coachPhone.text = [self isEmpty:@"短信"];
    
            self.detailsView.frame = CGRectMake(0, 0, SCREEN_WIDTH, size.height - 20 + 320);
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

- (NSString *)isEmpty:(NSString *)string
{
    if (string.length == 0) {
        return @"暂无";
    }
    return string;
}

-(void) getComments{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:self.coachId forKey:@"coachid"];
    [paramDic setObject:@"0" forKey:@"pagenum"];
    
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
            [self.commentsList addObjectsFromArray:responseObject[@"evalist"]];
            self.count = [responseObject[@"count"] intValue];
            [self.tabelVIew reloadData];
        }else{
            [self makeToast:message];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.commentsList.count > 5){
        return 5;
    }else{
        return  self.commentsList.count;
    }
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
    }else{
        cell.avatar.image = [UIImage imageNamed:@"user_logo_default"];
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
        CGSize size = [CommonUtil sizeWithString:content fontSize:14.0 sizewidth:(SCREEN_WIDTH - 55) sizeheight:CGFLOAT_MAX];
        cell.contentHeight.constant = size.height;
    }else{
        cell.content.text = @"";
        cell.contentHeight.constant = 25;
    }
    
    NSString *addtime = dic[@"addtime"];
    if(![CommonUtil isEmpty:addtime]){
        cell.time.text = [CommonUtil intervalSinceNow:addtime];
    }else{
        cell.time.text = @"";
    }
    
    
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
    
    if(self.commentsList.count == 0){
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
        label1.text = @"学员评论";
        [headerView.contentView addSubview:label1];
        
        //箭头
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 21, 20, 11, 20)];
        arrow.image = [UIImage imageNamed:@"comment_arrow"];
        [headerView.contentView addSubview:arrow];        
    }
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    //点击的次数
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    
    //给self.view添加一个手势监测；
    
    [headerView addGestureRecognizer:singleRecognizer];
    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.commentsList[indexPath.row];
    NSString *content = dic[@"content"];
    if(![CommonUtil isEmpty:content]){
        CGSize size = [CommonUtil sizeWithString:content fontSize:14.0 sizewidth:(SCREEN_WIDTH - 55) sizeheight:CGFLOAT_MAX];
        return size.height + 45.0;
    }else{
        return 72.0;
    }
    
}

-(void)SingleTap:(UITapGestureRecognizer*)recognizer
{
    CommentListViewController *nextController = [[CommentListViewController alloc] initWithNibName:@"CommentListViewController" bundle:nil];
    nextController.coachid = self.coachId;
    [self.navigationController pushViewController:nextController animated:YES];
}

@end
