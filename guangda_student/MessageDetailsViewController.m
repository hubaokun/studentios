//
//  MessageDetailsViewController.m
//  guangda_student
//
//  Created by Dino on 15/4/1.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MessageDetailsViewController.h"

@interface MessageDetailsViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation MessageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
    if (_readState == 0) {
        [self postReadNotice];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(0, self.contentView.frame.size.height);
}

#pragma mark - 页面设置
- (void)settingView {
    self.titleLabel.text = _titleStr;
    self.dateLabel.text = _dateStr;
    self.contentLabel.text = _contentStr;
    
    // 计算contentLabel高度
    CGSize contentSize = [CommonUtil sizeWithString:_contentStr fontSize:15 sizewidth:_screenWidth - 30 sizeheight:MAXFLOAT];
    _contentLabelHeightCon.constant = contentSize.height;
    
    self.contentView.frame = CGRectMake(0, 0, _screenWidth, 114 - 36 + contentSize.height);
    [self.scrollView addSubview:self.contentView];
}

#pragma mark - 网络请求
// 设置消息为已读
- (void)postReadNotice {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:_noticeId forKey:@"noticeid"];
    
    NSString *uri = @"/sset?action=ReadNotice";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            
        }else {
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
    }];
}

@end
