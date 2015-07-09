//
//  SelectOtherCouponViewController.m
//  guangda_student
//
//  Created by guok on 15/6/3.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "SelectOtherCouponViewController.h"
#import "SelectCouponTableViewCell.h"

@interface SelectOtherCouponViewController ()<UITabBarDelegate,UITableViewDataSource>
{
    NSArray *timeArray;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelectOtherCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    timeArray = self.selectedOrderList[@"times"];

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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_couponArray)
        return  _couponArray.count;
    return 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indentifier = @"SelectCouponTableViewCell";
    SelectCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"SelectCouponTableViewCell" bundle:nil] forCellReuseIdentifier:indentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic = _couponArray[indexPath.row];
    int recordid = [dic[@"recordid"] intValue];
    NSString *end_time = dic[@"end_time"];
    int coupontype = [dic[@"coupontype"] intValue];
    int value = [dic[@"value"] intValue];
    NSString *title = dic[@"title"];
    
    if(coupontype == 1){
        cell.couponTitleLabel.text = @"小巴券－学时券";
        cell.labeltitle2.text = [NSString stringWithFormat:@"本券可以抵用%d学时学费",value];
    }else{
        cell.couponTitleLabel.text = @"小巴券－抵价券";
        cell.labeltitle2.text = [NSString stringWithFormat:@"本券可以抵用学费%d元",value];
    }
    
    cell.couponPublishLabel.text = title;

    
    if(![CommonUtil isEmpty:end_time]){
        NSDate *date = [CommonUtil getDateForString:end_time format:nil];
        end_time = [CommonUtil getStringForDate:date format:@"yyyy年MM月dd日"];
        cell.couponEndTime.text = [NSString stringWithFormat:@"有效期:%@",end_time];
    }else{
        cell.couponEndTime.text = @"";
    }

    if(self.selectedCoupon && self.selectedCoupon.count > 0){
        BOOL selected = NO;
        for (int i = 0; i < self.selectedCoupon.count; i++) {
            if(recordid == [[self.selectedCoupon[i] objectForKey:@"recordid"] intValue]){
               selected = YES;
                break;
            }
        }
        if(selected)
            cell.selectButton.selected = YES;
        else
            cell.selectButton.selected = NO;
    }else{
        cell.selectButton.selected = NO;
    }
    
    cell.selectButton.tag = indexPath.row;
    
    [cell.selectButton addTarget:self action:@selector(changeCouponSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (void) changeCouponSelected:(UIButton *) sender{
    NSInteger tag = sender.tag;
    
    NSMutableDictionary *dic = [_couponArray[tag] mutableCopy];
    int used = [dic[@"used"] intValue];
    if(used == 0){
        if (self.selectedCoupon && self.selectedCoupon.count + 1 > timeArray.count) {
            [self makeToast:[NSString stringWithFormat:@"所选优惠券不能超过订单上限哦."]];
            return;
        }
        
        //选中
        if(self.selectedCoupon && self.selectedCoupon.count + 1 > self.canUsedMaxCouponCount){
            [self makeToast:[NSString stringWithFormat:@"一个订单最多使用%d张优惠券哦.",_canUsedMaxCouponCount]];
            return;
        }
        
        if(self.canUseDiffCoupon == 1 && self.canUsedMaxCouponCount > 1){
            if(self.selectedCoupon && self.selectedCoupon.count > 0){
                NSDictionary *selected = self.selectedCoupon[0];
                int coupontype = [selected[@"coupontype"] intValue];
                int coupontype1 = [dic[@"coupontype"] intValue];
                if(coupontype != coupontype1){
                    [self makeToast:@"一个订单只能使用同种类型的优惠券哦."];
                    return;
                }
            }
        }
        
        [dic setObject:@"1" forKey:@"used"];
        if(!self.selectedCoupon)
            self.selectedCoupon = [NSMutableArray array];
        [self.selectedCoupon addObject:dic];
    }else{
        //未选中
        [dic setObject:@"0" forKey:@"used"];
        for (int i = 0; i < self.selectedCoupon.count; i++) {
            NSDictionary *selected = self.selectedCoupon[i];
            int recordid = [selected[@"recordid"] intValue];
            int recordid1 = [dic[@"recordid"] intValue];
            if(recordid == recordid1){
                if(!self.selectedCoupon)
                    self.selectedCoupon = [NSMutableArray array];
                [self.selectedCoupon removeObjectAtIndex:i];
            }
        }
    }
    
     [_couponArray replaceObjectAtIndex:tag withObject:dic];
    [self.tableView reloadData];
}

- (IBAction)clickForSubmit:(id)sender {
    //关闭画面, 发送广播
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if(_couponArray){
        [result setObject:_couponArray forKey:@"couponArray"];
    }
    
    if(_selectedCoupon)
        [result setObject:_selectedCoupon forKey:@"selectedCoupon"];
    [result setObject:self.orderIndex forKey:@"orderIndex"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSelectCoupon" object:result];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
