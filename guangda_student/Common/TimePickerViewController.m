//
//  TimePickerViewController.m
//  wedding
//
//  Created by Jianyong Duan on 14/12/1.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import "TimePickerViewController.h"

@interface TimePickerViewController ()

@property (nonatomic, strong) NSArray *listTime;

@end

@implementation TimePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.listTime = @[@"10:00", @"10:30", @"11:00", @"11:30", @"12:00", @"12:30", @"13:00", @"13:30", @"14:00", @"15:00", @"15:30", @"16:00", @"16:30", @"17:00"];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.buttonOK.backgroundColor = [UIColor clearColor];
    UIImage *image2 = [[UIImage imageNamed:@"button_backgroup2"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *image2h = [[UIImage imageNamed:@"button_backgroup2_h"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.buttonOK setBackgroundImage:image2 forState:UIControlStateNormal];
    [self.buttonOK setBackgroundImage:image2h forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonOKClick:(id)sender {
    
    NSString *selectTime = [_listTime objectAtIndex:[_pickerView selectedRowInComponent:0]];
    
    if (_delegate && [_delegate respondsToSelector:@selector(datePicker:selectedTime:)]) {
        [_delegate datePicker:self selectedTime:selectTime];
    }
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.listTime.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(pickerView.frame), 32)];
    
    label.textColor = RGB(51, 51, 51);
    label.font = [UIFont systemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = self.listTime[row];
    return label;
}


@end
