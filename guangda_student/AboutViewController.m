//
//  AboutViewController.m
//  guangda_student
//
//  Created by 吴筠秋 on 15/3/30.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (strong, nonatomic) IBOutlet UIButton *tipBtn;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tipBtn.layer.cornerRadius = 3;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
