//
//  TimePickerViewController.h
//  wedding
//
//  Created by Jianyong Duan on 14/12/1.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimePickerViewControllerDelegate;

@interface TimePickerViewController : UIViewController

@property (weak, nonatomic) id<TimePickerViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *buttonOK;

- (IBAction)buttonOKClick:(id)sender;

@end

@protocol TimePickerViewControllerDelegate <NSObject>

@optional

- (void)datePicker:(TimePickerViewController *)viewController selectedTime:(NSString *)selectedTime;

@end