//
//  WebViewController.m
//  wedding
//
//  Created by duanjycc on 14/11/17.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.urlTitle) {
        self.labelTitle.text = self.urlTitle;
    } else {
        self.webView.delegate = self;
    }
    
    if ([self.urlString hasPrefix:@"/"]) {
        
    } else {
        self.urlString = [NSString stringWithFormat:@"/%@", _urlString];
    }
    
    NSString *str=[RequestHelper getRequestUrlWithURI:_urlString Parameters:nil RequestMethod:@"GET"];
    
    NSURL *url = [[NSURL alloc] initWithString:str];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *docTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (docTitle && !_urlTitle) {
        self.labelTitle.text = docTitle;
    }
}

-(IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
