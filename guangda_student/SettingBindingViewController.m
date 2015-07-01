//
//  SettingBindingViewController.m
//  guangda_student
//
//  Created by 吴筠秋 on 15/3/31.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SettingBindingViewController.h"
#import "BindingViewController.h"
#import "AppDelegate.h"

@interface SettingBindingViewController ()
@property (strong, nonatomic) IBOutlet UILabel *qqLabel;
@property (strong, nonatomic) IBOutlet UILabel *weixinLabel;
@property (strong, nonatomic) IBOutlet UILabel *weiboLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIView *msgView;
@end

@implementation SettingBindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //显示主页面，延时执行是为了让自动布局先生效，再设置frame才有效果
    [self performSelector:@selector(showMainView) withObject:nil afterDelay:0.1f];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//显示页面
- (void)showMainView{
    CGRect frame = self.msgView.frame;
    frame.size.width = CGRectGetWidth(self.mainScrollView.frame);
    self.msgView.frame = frame;
    [self.mainScrollView addSubview:self.msgView];
    
    self.mainScrollView.contentSize = CGSizeMake(0, CGRectGetHeight(self.msgView.frame) + 20);
    
}

// qq 1
- (IBAction)qqBindUserAccount:(id)sender
{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    NSString *userId = appdelegate.userid;
    NSString *openId = [CommonUtil getObjectFromUD:@"QQOpenid"];
    
    [self bindAccountWithUserID:userId openID:openId type:@"1"];
    
}

// 微信 2
- (IBAction)wxBindUserAccount:(id)sender
{
    
    
    
    
}

// 微博 3
- (IBAction)wbBindUserAccount:(id)sender
{
    
    
    
}

// 请求绑定第三方账号接口
- (void)bindAccountWithUserID:(NSString *)userId openID:(NSString *)openId type:(NSString *)type
{
    if (userId.length == 0 || openId.length == 0) {
        return;
    }
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:userId forKey:@"userid"];
    [paramDic setObject:openId forKey:@"openid"];
    [paramDic setObject:type forKey:@"type"];
    
    NSString *uri = @"";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    [DejalBezelActivityView activityViewForView:self.view];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        if ([responseObject[@"code"] integerValue] == 1) {
            [self makeToast:@"绑定成功"];
            
            // 修改本地的是否绑定第三方登录的信息
            switch ([type intValue]) {
                case 1:
                    // QQ
                    [CommonUtil saveObjectToUD:@"yes" key:@"isBindQQ"];
                    break;
                    
                case 2:
                    // wx
                    [CommonUtil saveObjectToUD:@"yes" key:@"isBindWX"];
                    break;
                    
                case 3:
                    // wb
                    [CommonUtil saveObjectToUD:@"yes" key:@"isBindWB"];
                    break;
                    
                default:
                    break;
            }

        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            
            NSLog(@"code = %@",  responseObject[@"code"]);
            NSLog(@"message = %@", responseObject[@"message"]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

- (void)refreshBindInfo
{
    NSString *isBindQQ = [CommonUtil getObjectFromUD:@"isBindQQ"];
    NSString *isBindWX = [CommonUtil getObjectFromUD:@"isBindWX"];
    NSString *isBindWB = [CommonUtil getObjectFromUD:@"isBindWB"];
    
    if ([isBindQQ isEqualToString:@"yes"]) {
        self.qqLabel.text = @"已绑定";
    }else{
        self.qqLabel.text = @"未绑定";
    }
    
    if ([isBindWX isEqualToString:@"yes"]) {
        self.weixinLabel.text = @"已绑定";
    }else{
        self.weixinLabel.text = @"未绑定";
    }
    
    if ([isBindWB isEqualToString:@"yes"]) {
        self.weiboLabel.text = @"已绑定";
    }else{
        self.weiboLabel.text = @"未绑定";
    }
}


@end
