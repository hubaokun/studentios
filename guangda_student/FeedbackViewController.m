//
//  FeedbackViewController.m
//  guangda_student
//
//  Created by 吴筠秋 on 15/3/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CPTextViewPlaceholder.h"
#import "LoginViewController.h"

@interface FeedbackViewController () <UITextViewDelegate> {
    CGRect viewFrame;
}

@property (strong, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) IBOutlet UITextField *placeholderField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightCon;
@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.contentTextView.layer.borderColor = RGB(199, 199, 199).CGColor;
    self.contentTextView.layer.borderWidth = 1;
    
    // 点击背景退出键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backupgroupTap:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer: tapGestureRecognizer];   // 只需要点击非文字输入区域就会响应
    [tapGestureRecognizer setCancelsTouchesInView:NO];
}

-(void)backupgroupTap:(id)sender{
    [self.contentTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([UIScreen mainScreen].bounds.size.height > 480) {
        NSLog(@"height === %f",[UIScreen mainScreen].bounds.size.height);
        _contentViewHeightCon.constant = 206;
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.placeholderField.hidden = NO;
    }else{
        self.placeholderField.hidden = YES;
    }
}

#pragma mark - 接口方法
- (void)postFeedback {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    NSString *content = self.contentTextView.text;

    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    [paramDic setObject:content forKey:@"content"];
    [paramDic setObject:@"2" forKey:@"type"];
    
    NSString *uri = @"/sset?action=Feedback";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"提交成功"];
            [self.navigationController popViewControllerAnimated:YES];
            
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

#pragma mark - action
- (IBAction)clickForConfirm:(id)sender {
    if (self.contentTextView.text.length == 0) {
        [self makeToast:@"内容不能为空"];
        return;
    }
    else {
        [self postFeedback];
    }
}
@end
