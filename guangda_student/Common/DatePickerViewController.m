//
//  DatePickerViewController.m
//  wedding
//
//  Created by Jianyong Duan on 14/11/24.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import "DatePickerViewController.h"
#import <CoreText/CoreText.h>

@interface DatePickerViewController () {
    NSDateComponents *components;

}

@property (nonatomic, strong) NSDate *selectDate;

@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    
    self.buttonOK.backgroundColor = [UIColor clearColor];
    UIImage *image2 = [[UIImage imageNamed:@"button_backgroup2"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *image2h = [[UIImage imageNamed:@"button_backgroup2_h"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.buttonOK setBackgroundImage:image2 forState:UIControlStateNormal];
    [self.buttonOK setBackgroundImage:image2h forState:UIControlStateHighlighted];
    
    self.selectDate = [[NSDate alloc] initWithTimeIntervalSinceNow:24*60*60];
    components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month= [components month];
//    NSInteger year= [components year];

    [_pickerView selectRow:15 inComponent:0 animated:NO];
    [_pickerView selectRow:month - 1 inComponent:2 animated:NO];
    [_pickerView selectRow:day inComponent:4 animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonOKClick:(id)sender {
    NSString *dateString = [NSString stringWithFormat:@"%d-%d-%d"
                            ,[components year] - 15 + [_pickerView selectedRowInComponent:0]
                            ,[_pickerView selectedRowInComponent:2] + 1
                            ,[_pickerView selectedRowInComponent:4] + 1];
    self.selectDate = [CommonUtil getDateForString:dateString format:@"yyyy-M-d"];
    
    if ([_selectDate compare:[NSDate date]] == NSOrderedAscending) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(datePicker:selectedDate:)]) {
        [_delegate datePicker:self selectedDate:_selectDate];
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
    CGRect rect = self.lineImageView1.frame;
    rect.origin.x = CGRectGetWidth(pickerView.frame) / 2 - 44;
    self.lineImageView1.frame = rect;
    
    rect = self.lineImageView2.frame;
    rect.origin.x = CGRectGetWidth(pickerView.frame) / 2  + 40;
    self.lineImageView2.frame = rect;
    
    return 6;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 30;
    } else if (component == 1 || component == 3 || component == 5) {
        return 1;
    } else if (component == 2) {
        return 12;
    } else {

        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:_selectDate];
        
        NSUInteger numberOfDaysInMonth = range.length;
        return numberOfDaysInMonth;
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 1 || component == 3) {
        return 22;
    } else if (component == 2 || component == 4) {
        return 50;
    } else {
        return CGRectGetWidth(pickerView.frame) / 2 - 72;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if(component==0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(pickerView.frame) / 2 - 72, 32)];
        
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentRight;
        NSInteger year = [components year] - 15 + row;
        if (year < [components year]) {
            label.textColor = RGB(201, 201, 201);
        } else {
            label.textColor = RGB(224, 32, 32);
        }
        
        label.text = [NSString stringWithFormat:@"%d", year];
        return label;
    } else if (component == 1) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 32)];
        label.textColor = RGB(224, 32, 32);
        label.font = [UIFont systemFontOfSize:11];
        label.text = @"年";
        return label;

    } else if (component == 2) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 25, 32)];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%d", row + 1];
        
        NSInteger row0 = [pickerView selectedRowInComponent:0];
        if (row0 > 15 || (row0 == 15 && row >=  [components month] - 1)) {
            label.textColor = RGB(224, 32, 32);
        } else {
            label.textColor = RGB(201, 201, 201);
        }
        
        [view addSubview:label];
        return view;
        
    } else if (component == 3) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 22, 32)];
        label.textColor = RGB(224, 32, 32);
        label.font = [UIFont systemFontOfSize:11];
        label.text = @"月";
        return label;
        
    } else if (component == 4) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 25, 32)];
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%d", row + 1];
        
        NSInteger row0 = [pickerView selectedRowInComponent:0];
        NSInteger row2 = [pickerView selectedRowInComponent:2];
        if (row0 > 15 || (row0 == 15 && row2 >  [components month] - 1)
            || (row0 == 15 && row2 == [components month] - 1 && row >=  [components day])) {
            label.textColor = RGB(224, 32, 32);
        } else {
            label.textColor = RGB(201, 201, 201);
        }
        
        [view addSubview:label];
        return view;
        
    } else {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(pickerView.frame) / 2 - 72, 32)];
        label.textColor = RGB(224, 32, 32);
        label.font = [UIFont systemFontOfSize:11];
        label.text = @"日";
        return label;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *dateString = [NSString stringWithFormat:@"%d-%d-1"
                            ,[components year] - 15 + [_pickerView selectedRowInComponent:0]
                            ,[_pickerView selectedRowInComponent:2] + 1];
    self.selectDate = [CommonUtil getDateForString:dateString format:@"yyyy-M-d"];
    
    if (component == 0) {
        [pickerView reloadComponent:2];
        [pickerView reloadComponent:4];
    } else if (component == 2) {
        [pickerView reloadComponent:4];
    }
}

@end
