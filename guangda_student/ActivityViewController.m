//
//  ActivityViewController.m
//  guangda_student
//
//  Created by 冯彦 on 15/8/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ActivityViewController.h"
#import "LoginViewController.h"
#import "UIImageView+WebCache.h"

@interface ActivityViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *advImageView;

@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - 网络请求
// 获取活动弹窗信息
- (void)postGetActivityInfo {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    [params setObject:studentId forKey:@"studentid"];
    [params setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    params[@"model"] = @"1"; // 1:ios 2:安卓
    params[@"type"] = @"2"; // 1:教练 2:学员
    params[@"width"] = [NSString stringWithFormat:@"%d", (int)SCREEN_WIDTH * 2]; // 屏幕宽，单位：像素
    params[@"height"] = [NSString stringWithFormat:@"%d", (int)SCREEN_HEIGHT * 2]; // 屏幕高，单位：像素
    NSString *uri = @"/adver?action=GETADVERTISEMENT";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            NSString *advImageUrl = responseObject[@"s_img_ios"];
            [self.advImageView sd_setImageWithURL:[NSURL URLWithString:advImageUrl] placeholderImage:nil];
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

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

- (IBAction)advClick:(id)sender {
}

- (IBAction)closeClick:(id)sender {
}


@end
