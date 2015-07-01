//
//  UserBaseInfoViewController.h
//  guangda
//
//  Created by duanjycc on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "GreyTopViewController.h"

@interface UserBaseInfoViewController : GreyTopViewController

// 手机号码
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UIImageView *phonePencilImage;
@property (copy, nonatomic) NSString *phone;

// 真实姓名
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UIImageView *namePencilImage;
@property (copy, nonatomic) NSString *realName;

@end
