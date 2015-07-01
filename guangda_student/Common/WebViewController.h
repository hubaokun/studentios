//
//  WebViewController.h
//  wedding
//
//  Created by duanjycc on 14/11/17.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, copy) NSString *urlTitle;
@property (nonatomic, copy) NSString *urlString;

-(IBAction)back:(id)sender;

@end
