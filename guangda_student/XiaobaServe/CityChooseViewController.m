//
//  CityChooseViewController.m
//  guangda_student
//
//  Created by 冯彦 on 15/11/17.
//  Copyright © 2015年 daoshun. All rights reserved.
//

#import "CityChooseViewController.h"
#import "CityChooseTableViewCell.h"
#import "XBProvince.h"

@interface CityChooseViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView; // 省表
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *selectedCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationCityLabel;
@property (weak, nonatomic) IBOutlet UIView *hotCityView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hotCityViewHeightCon;

@property (strong, nonatomic) UITableView *cityTableView; // 市表
@property (strong, nonatomic) UIButton *closeCityTableBtn; // 关闭城市列表按钮
@property (strong, nonatomic) XBProvince *selectedProvince;

// 页面数据
@property (strong, nonatomic) NSArray *provinceArray;
@property (strong, nonatomic) NSArray *hotCityArray;

@end

@implementation CityChooseViewController

- (NSArray *)provinceArray {
    if (_provinceArray == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"china.plist" ofType:nil];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray *array = dict[@"china"];
        _provinceArray = [XBProvince provincesWithArray:array];
    }
    return _provinceArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedProvince = self.provinceArray[0];
    [self viewConfig];
    [self postGetHotCity];
}

- (void)viewConfig
{
    self.selectedCityLabel.text = self.cityName;
    self.locationCityLabel.text = self.locationCityName;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeCityTableBtn = closeBtn;
    CGFloat closeBtnW = SCREEN_WIDTH / 3;;
    CGFloat closeBtnH = SCREEN_HEIGHT - 64;
    CGFloat closeBtnX = 0;
    CGFloat closeBtnY = 64;
    closeBtn.frame = CGRectMake(closeBtnX, closeBtnY, closeBtnW, closeBtnH);
    closeBtn.backgroundColor = [UIColor blackColor];
    closeBtn.alpha = 0;
    [closeBtn addTarget:self action:@selector(cityTableDismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UITableView *tableView = [[UITableView alloc] init];
    self.cityTableView = tableView;
    tableView.width = SCREEN_WIDTH * 2/3;
    tableView.height = SCREEN_HEIGHT - 64;
    tableView.x = SCREEN_WIDTH;
    tableView.y = 64;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
}

- (void)hotCityViewConfig
{
    if (self.hotCityArray.count > 0) {
        CGFloat gap = 10.0;
        
        UIView *tabsView = [[UIView alloc] init];
        [self.hotCityView addSubview:tabsView];
        CGFloat tabsViewW = SCREEN_WIDTH - gap * 2;
        CGFloat tabsViewH = 30;
        CGFloat tabsViewX = 10;
        CGFloat tabsViewY = 42;
        tabsView.frame = CGRectMake(tabsViewX, tabsViewY, tabsViewW, tabsViewH);
        tabsView.backgroundColor = [UIColor clearColor];
        
        // 添加标签
        int row = 0;
        int column = 0;
        for (int i = 0; i < self.hotCityArray.count; i++) {
            UIButton *cityTab = [self hotCityTabCreate:i];
            cityTab.x = (cityTab.width + gap) * column;
            cityTab.y = (cityTab.height + gap) * row;
            [tabsView addSubview:cityTab];
            column ++;
            if ((tabsViewW - cityTab.right) < (cityTab.width + gap)) { // 换行
                row ++;
                column = 0;
            }
            if (i == self.hotCityArray.count - 1) { // 最后一个标签
                tabsViewH = cityTab.bottom;
            }
        }
        
        tabsView.height = tabsViewH;
        self.hotCityViewHeightCon.constant = 89 - 30 + tabsView.height;
        self.headView.height = 273 - 89 + self.hotCityViewHeightCon.constant;
    } else {
        self.hotCityView.hidden = YES;
        self.hotCityViewHeightCon.constant = 0;
        self.headView.height = 273 - 89;
    }
    self.mainTableView.tableHeaderView = self.headView;
}

- (UIButton *)hotCityTabCreate:(NSUInteger)index
{
    NSDictionary *cityDict = self.hotCityArray[index];
    NSString *cityName = cityDict[@"cityname"];
    
    UIButton *tab = [UIButton buttonWithType:UIButtonTypeCustom];
    tab.width = 64;
    tab.height = 30;
    tab.tag = index;
    tab.backgroundColor = [UIColor whiteColor];
    [tab setTitle:cityName forState:UIControlStateNormal];
    [tab setTitleColor:RGB(61, 61, 61) forState:UIControlStateNormal];
    tab.titleLabel.font = [UIFont systemFontOfSize:12];
    [tab addTarget:self action:@selector(hotCityClick:) forControlEvents:UIControlEventTouchUpInside];
    tab.layer.borderWidth = 0.5;
    tab.layer.borderColor = RGB(232, 232, 232).CGColor;
    tab.layer.cornerRadius = 2;
    tab.layer.masksToBounds = YES;
    
    return tab;
}

#pragma mark - 网络请求
- (void)postGetHotCity
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSString *uri = @"/location?action=getHotCity";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    [DejalBezelActivityView activityViewForView:self.view];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            self.hotCityArray = responseObject[@"city"];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        [self hotCityViewConfig];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"连接失败");
        [self makeToast:ERR_NETWORK];
        [self hotCityViewConfig];
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.mainTableView]) {
        return  self.provinceArray.count;
    } else {
        return  self.selectedProvince.citiesArray.count;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.mainTableView]) {
        static NSString *identifier = @"ProvinceTableViewCellIdentifier";
        CityChooseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"CityChooseTableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        }
        XBProvince *province = self.provinceArray[indexPath.row];
        cell.province = province;
        return cell;
    }
    else {
        static NSString *identifier = @"CityTableViewCellIdentifier";
        CityChooseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:@"CityChooseTableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        }
        XBCity *city = self.selectedProvince.citiesArray[indexPath.row];
        cell.city = city;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([tableView isEqual:self.mainTableView]) {
        XBProvince *province = self.provinceArray[indexPath.row];
        if (province.citiesArray.count > 1) {
            self.selectedProvince = province;
            [self cityTableShow];
        }
        // 特别行政区
        else if (province.citiesArray.count == 0) {
            [self makeToast:@"暂不支持该城市"];
        }
        // 直辖市
        else {
            self.cityName = province.provinceName;
            XBCity *city = province.citiesArray[0];
            self.cityID = city.cityID;
            [self backClick:nil];
        }
    }
    if ([tableView isEqual:self.cityTableView]) {
        XBCity *city = self.selectedProvince.citiesArray[indexPath.row];
        self.selectedCityLabel.text = city.cityName;
        self.cityName = city.cityName;
        self.cityID = city.cityID;
//        [self cityTableDismiss];
        [self backClick:nil];
    }
    
}

#pragma mark - Private
- (void)cityTableShow
{
    [self.view addSubview:self.closeCityTableBtn];
    [self.cityTableView reloadData];
    self.titleLabel.text = self.selectedProvince.provinceName;
    [UIView animateWithDuration:0.25 animations:^{
        self.closeCityTableBtn.alpha = 0.4;
        self.cityTableView.x = SCREEN_WIDTH / 3;
    }];
}

- (void)cityTableDismiss
{
    self.titleLabel.text = @"选择城市";
    [UIView animateWithDuration:0.25 animations:^{
        self.closeCityTableBtn.alpha = 0;
        self.cityTableView.x = SCREEN_WIDTH;
    } completion:^(BOOL finished) {
        [self.closeCityTableBtn removeFromSuperview];
    }];
}

#pragma mark - Actions
- (void)hotCityClick:(UIButton *)sender {
    NSDictionary *cityDict = self.hotCityArray[sender.tag];
    self.cityName = cityDict[@"cityname"];
    self.cityID = cityDict[@"cityid"];
    [self backClick:nil];
}

- (IBAction)backClick:(id)sender {
    if (self.backBlock) {
        self.backBlock(self.cityName, self.cityID);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
