//
//  MainViewController.m
//  guangda_student
//
//  Created by Dino on 15/3/25.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "MainViewController.h"
#import "SliderViewController.h"
#import "CoachListViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "AppDelegate.h"
#import "MyAnimatedAnnotationView.h"
#import "UIImageView+WebCache.h"
#import "AppointCoachViewController.h"
#import "CoachDetailViewController.h"
#import "TQStarRatingView.h"
#import "CoachScreenViewController.h"
#import "UserBaseInfoViewController.h"
#import "XiaobaServeViewController.h"
#import "ImproveInfoViewController.h"
#import "RecommendCodeViewController.h"
#import "SignUpViewController.h"
#import "XBSchool.h"

#define ZOOM_LEVEL 14.5 // 地图缩放级别

@interface MainViewController ()<UIGestureRecognizerDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate>
{
    BMKLocationService *_locService;
    int _actFlag; // 活动类型 0:不显示 1:跳转到url 2:内部功能
}

@property (strong, nonatomic) NSDictionary *coachDic;
@property (strong, nonatomic) TQStarRatingView *starView;

@property (strong, nonatomic) IBOutlet UIButton *allBtn;

@property (strong, nonatomic) UIImageView *selectedCarModelImageView;
@property (strong, nonatomic) UILabel *selectedCarModelLabel;
@property (strong, nonatomic) NSString *carModelId;
@property (assign, nonatomic) BOOL isGetData;

@property (strong, nonatomic) UIButton *closeDetailBtn; // 关闭底部教练信息窗口
@property (strong, nonatomic) MyAnimatedAnnotationView *selectedCar; // 选中的汽车

@property (strong, nonatomic) IBOutlet UIView *actView;
@property (weak, nonatomic) IBOutlet UIImageView *advImageView;
@property (copy, nonatomic) NSString *actUrl;

@end

@implementation MainViewController

+ (MainViewController *)sharedMainController
{
    static MainViewController *mainVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainVC = [[self alloc] init];
    });
    
    return mainVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self staticViewConfig];
    

    self.carModelLabelList = [NSMutableArray array];
    self.carModelImageViewList = [NSMutableArray array];
    self.annotationsList = [NSMutableArray array];
    self.isGetData = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMapLocation) name:@"setMapLocation" object:nil];
    // 筛选界面的观察者信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSearchCoachDict:) name:@"SearchCoachDict" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResetSearchCoachDict) name:@"ResetCoachDict" object:nil];
    
    [self requestGetCarModelInterfaceWithId:nil];
    // 配置百度地图
    [self mapConfig];
    [self setMapLocation];
    
    // 检查定位城市和用户设置的城市是否一致
    [self performSelector:@selector(searchCurrentCityName) withObject:nil afterDelay:5.0f];
    
    self.actView.frame = [UIScreen mainScreen].bounds;
    // 弹窗广告
    AppDelegate *app = APP_DELEGATE;
    if (![CommonUtil isEmpty:app.locateCity]) { // 如果app已取得用户定位城市
        [self postGetActivityInfo];
    }
    else { // 监视城市定位
        [app addObserver:self forKeyPath:@"locateCity" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
//    [self mapView:_mapView regionDidChangeAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

// 监视城市定位的回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"locateCity"]) {
        AppDelegate *app = APP_DELEGATE;
        if (![CommonUtil isEmpty:app.locateCity]) {
            [self postGetActivityInfo];
            [app removeObserver:self forKeyPath:@"locateCity"];
        }
    }
}

#pragma mark - ViewConfig
- (void)staticViewConfig {
    self.footView.hidden = YES;
    
    // 关闭底部教练信息的按钮
    self.closeDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeDetailBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 80);
    self.closeDetailBtn.backgroundColor = [UIColor blackColor];
    self.closeDetailBtn.alpha = 0;
    [self.closeDetailBtn addTarget:self action:@selector(closeDetailsView) forControlEvents:UIControlEventTouchUpInside];
    
    // 教练信息,星级View
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 15, 87, 15)];
    [self.coachInfoView addSubview:_starView];
    // 头像圆角
    self.userLogo.layer.cornerRadius = self.userLogo.bounds.size.width/2;
    self.userLogo.layer.masksToBounds = YES;

    // 创建百度地图
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.mapContentView addSubview:_mapView];//初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    _mapView.compassPosition = CGPointMake(8, 88);
    
    //设置地图缩放级别
    [_mapView setZoomLevel:ZOOM_LEVEL];
    _mapView.showMapScaleBar = YES;
    _mapView.mapScaleBarPosition = CGPointMake(10+43, SCREEN_HEIGHT-15-30-8);
}

#pragma mark - BaiduMap
// 地图配置
- (void)mapConfig {
    //设定地图View能否支持旋转
    _mapView.rotateEnabled = NO;
    
    //设定地图View能否支持用户缩放(双击或双指单击)
    _mapView.zoomEnabledWithTap = YES;
    
    //设定地图View能否支持俯仰角
    _mapView.overlookEnabled = NO;
}

// 设置定位圆点属性
-(void)setUserImage
{
    //用户位置类
    BMKLocationViewDisplayParam* param = [[BMKLocationViewDisplayParam alloc] init];
    param.locationViewOffsetY = 0;//偏移量
    param.locationViewOffsetX = 0;
    param.isAccuracyCircleShow = YES;//设置是否显示定位的那个精度圈
    param.isRotateAngleValid = YES;
//    param.locationViewImgName = @"icon_improveinfo_contactaddr";
    [_mapView updateLocationViewWithParam:param];
}

- (void)setMapLocation
{
    /*
     *在打开定位服务前设置
     *指定定位的最小更新距离(米)，默认：kCLDistanceFilterNone
     */
//    [BMKLocationService setLocationDistanceFilter:100];
//    + (void)setLocationDistanceFilter:(CLLocationDistance) distanceFilter;
    
    //地图初始位置设定
    [_locService startUserLocationService];
    AppDelegate *appDelegate = APP_DELEGATE;
    [_mapView setCenterCoordinate:appDelegate.userCoordinate animated:NO];
    
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    //    [self setUserImage];
    [_mapView updateLocationData:appDelegate.userLocation];
    NSLog(@"开启初始位置设定");
}
//罗盘态
-(IBAction)startFollowHeading:(id)sender
{
    NSLog(@"进入罗盘态");
    
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    _mapView.showsUserLocation = YES;
    
}
//跟随态
-(IBAction)startFollowing:(id)sender
{
    NSLog(@"进入跟随态");
    
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    _mapView.showsUserLocation = YES;
    
}

#pragma mark BaiduMapDelegate
/**
 *用户  更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
//    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    
    NSLog(@"didUpdateBMKUserLocation");
//    [self makeToast:@"didUpdateBMKUserLocation"];
    
    // 更新存储的用户位置
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userCoordinate = userLocation.location.coordinate;
}

// 滑动结束后回调
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self nearCoachRequest:NO];
}

// 添加标注
- (void)addAnnotationAtLongitude:(NSString *)longitude latitude:(NSString *)latitude andTag:(NSString *)tag
{
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
    
    CLLocationCoordinate2D coor;
    
    coor.latitude = [latitude floatValue];
    coor.longitude = [longitude floatValue];
    annotation.coordinate = coor;
    annotation.title = tag;
    [_mapView addAnnotation:annotation];
    [self.annotationsList addObject:annotation];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"biaozhu";
    
    // 检查是否有重用的缓存
    MyAnimatedAnnotationView *annotationView = nil;
    if (annotationView == nil)
    {
        annotationView = [[MyAnimatedAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
//    NSMutableArray *images = [NSMutableArray array];
//    for (int i = 1; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"ico_cargr"]];
//    }
    annotationView.annotationImageView.image = image;
    annotationView.annotationButton.tag = [annotation.title intValue];
    [annotationView.annotationButton addTarget:self action:@selector(carBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return annotationView;
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (error == BMK_SEARCH_NO_ERROR) {
        // 取得定位城市
        NSString *cityName = result.addressDetail.city;
        if (![CommonUtil isEmpty:cityName]) {
            self.cityName = [cityName stringByReplacingOccurrencesOfString:@"市" withString:@""];
            [self compareCityName];
        }
    }
}

// 获取当前所在城市名字
- (void)searchCurrentCityName {
    CommonUtil *commonUtil = [CommonUtil currentUtil];
    if ([commonUtil isLogin:NO]) {
        //发起反向地理编码检索
        BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[ BMKReverseGeoCodeOption alloc] init];
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        reverseGeoCodeSearchOption.reverseGeoPoint = delegate.userCoordinate;
        
        BMKGeoCodeSearch *_geoSearcher = [[BMKGeoCodeSearch alloc] init];
        _geoSearcher.delegate = self;
        BOOL flag = [_geoSearcher reverseGeoCode:reverseGeoCodeSearchOption];
        if (flag) {
            NSLog(@"地理编码检索");
        } else {
            NSLog(@"地理编码检索失败");
        }
    }
}

- (void)compareCityName {
    // 取得用户设置的城市
    NSString *position = [USERDICT objectForKey:@"locationname"];
    NSArray *subStrArray = [position componentsSeparatedByString:@"-"];
    NSString *cityName = @"";
    if (subStrArray.count > 1) {
        cityName = subStrArray[1];
        cityName = [cityName stringByReplacingOccurrencesOfString:@"市" withString:@""];
    }
    
    if ([CommonUtil isEmpty:cityName]) {
        [self makeToast:@"注意：您还未设置驾考城市，请前往基本信息页面设置。" duration:5.0 position:@"bottom"];
        return;
    }
    
    // 城市名不相等
    if (![cityName isEqualToString:self.cityName]) {
//        UIView *cityAlertView = [self createTopAlertView];
//        [self.view addSubview:cityAlertView];
//        [UIView animateWithDuration:0.35 animations:^{
//            cityAlertView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
//        }];
        [self makeToast:@"注意：您设置的驾考城市不是当前城市，可前往基本信息页面修改。" duration:6.0 position:@"bottom"];
    }
}



#pragma mark - Map Action
// 设置用户位置为屏幕中心
- (IBAction)setUserLocationToMid:(id)sender
{
    //地图初始位置设定
    AppDelegate *appDelegate = APP_DELEGATE;
    
    [_mapView setCenterCoordinate:appDelegate.userCoordinate animated:NO];
    [_mapView setZoomLevel:ZOOM_LEVEL];
    
    [self nearCoachRequest:YES];
}

#pragma mark - 网络请求
// 获取活动弹窗信息
- (void)postGetActivityInfo {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    [params setObject:studentId forKey:@"studentid"];
    [params setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    params[@"model"] = @"1"; // 1:ios 2:安卓
    params[@"type"] = @"2"; // 1:教练 2:学员
    params[@"width"] = [NSString stringWithFormat:@"%d", (int)SCREEN_WIDTH * 2]; // 屏幕宽，单位：像素
    params[@"height"] = [NSString stringWithFormat:@"%d", (int)SCREEN_HEIGHT * 2]; // 屏幕高，单位：像素
    AppDelegate *app = APP_DELEGATE;
    params[@"cityname"] = app.locateCity; // 定位城市
    NSString *uri = @"/adver?action=GETADVERTISEMENT";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:params RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            _actFlag = [responseObject[@"s_flag"] intValue];
            if (_actFlag != 0) {
                NSString *advImageUrl = responseObject[@"s_img_ios"];
                self.actUrl = responseObject[@"s_url"];
                // 显示广告图片
                [self.advImageView sd_setImageWithURL:[NSURL URLWithString:advImageUrl] placeholderImage:[UIImage imageNamed:@"im_adverro"]];
                [self.view addSubview:self.actView];
            }
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

// 请求获取周边教练接口 (中心点坐标 半径 筛选的条件)
- (void)requestGetNearByCoachInterfaceWithPointcenter:(NSString *)pointcenter
                                            andRadius:(NSString *)radius needLiadingShow:(BOOL) need
{
    if(self.isGetData)
        return;
    self.isGetData = YES;
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    paramDic = [self.searchParamDic mutableCopy];
    if (!paramDic) {
        paramDic = [NSMutableDictionary dictionary];
    }
    
    [paramDic setObject:pointcenter forKey:@"pointcenter"];
    [paramDic setObject:radius forKey:@"radius"];
    
    // 测试账号studentID
    AppDelegate *deleget = [UIApplication sharedApplication].delegate;
    if (![CommonUtil isEmpty:deleget.userid]) {
        if ([deleget.userid isEqualToString:@"18"]) {
            paramDic[@"studentid"] = deleget.userid;
        }
    }
    
    // 城市id
    NSString *cityID = [USERDICT[@"cityid"] description];
    if (![CommonUtil isEmpty:cityID]) {
        paramDic[@"cityid"] = cityID;
    }
    
    // app版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [paramDic setObject:app_Version forKey:@"version"];
    
    if (![CommonUtil isEmpty:self.carModelId]) {
        [paramDic setObject:self.carModelId forKey:@"condition11"];
    }
    
    NSString *uri = @"/sbook?action=GetNearByCoach";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    if(need)
        [DejalBezelActivityView activityViewForView:self.view];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20;     // 网络超时时长设置
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(need){
            [DejalBezelActivityView removeViewAnimated:YES];
        }
        self.isGetData = NO;
        if ([responseObject[@"code"] integerValue] == 1)
        {
            self.coachList = responseObject[@"coachlist"];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.coachList];
            for (int i= 0; i<self.coachList.count; i++) {
                NSDictionary *coachDic =self.coachList[i];
                NSString *string = coachDic[@"phone"];
                if ([string isEqualToString:@"18888888888"]) {
                    [array removeObjectAtIndex:i];
                }
            }
            NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
            if (user_info) {
                if ([[user_info[@"phone"] description] isEqualToString:@"18888888888"]) {
                    
                }else{
                    self.coachList = array;
                }
            }else{
               self.coachList = array;
            }
//            self.coachList = array;     //屏蔽特殊教练
            
            // 移除所有标注
            [_mapView removeAnnotations:_annotationsList];
            // 重新添加标注
            for (int i = 0; i < self.coachList.count; i++)
            {
                NSDictionary *coachDic = self.coachList[i];
                NSString *longitude = coachDic[@"longitude"];
                NSString *latitude = coachDic[@"latitude"];
                [self addAnnotationAtLongitude:longitude latitude:latitude andTag:[NSString stringWithFormat:@"%d", i]];
            }
            
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        NSLog(@"getnearbycoach err");
        [self makeToast:ERR_NETWORK];
        self.isGetData = NO;
    }];

}

// 获取准教车型
- (void)requestGetCarModelInterfaceWithId:(NSString *)carModelId
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    if (carModelId.length > 0) {
        [paramDic setObject:carModelId forKey:@"modelid"];
    }else{
        paramDic = nil;
    }
    
    NSString *uri = @"/cuser?action=GetCarModel";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            self.footView.hidden = NO;
            NSArray *modellist = responseObject[@"modellist"];
            [self addCarModelWithList:modellist];
        }else{
            NSString *message = responseObject[@"message"];
            self.footView.hidden = YES;
            [self makeToast:message];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

// 添加底部车型选择条
- (void)addCarModelWithList:(NSArray *)modellist
{
    int num = (int)modellist.count;
    if (num*50 < SCREEN_WIDTH) {
        // 按钮数量没有超出屏幕宽度
        CGFloat _width = SCREEN_WIDTH/num;
        CGFloat _height = 80;
        
        DSButton *firstButton = nil;
        for (int i = 0; i < num; i++) {
            NSDictionary *dataDic = modellist[i];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * _width, 0, _width, _height)];
            [self.carModelScrollView addSubview:view];
            
            DSButton *button = [DSButton buttonWithType:UIButtonTypeCustom];
            button.frame = view.bounds;
            [button addTarget:self action:@selector(carModelClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            button.value = [dataDic[@"modelid"] description];
            [view addSubview:button];
            
            //默认选中第一个
            if(i == 0){
                firstButton = button;
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((_width-31)/2, 16, 31, 31)];
            imageView.image = [UIImage imageNamed:@"bg_home_circle"];
            imageView.contentMode = UIViewContentModeCenter;
            [view addSubview:imageView];
            [self.carModelImageViewList addObject:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 114/2, _width, 16)];
            label.text = [dataDic[@"searchname"] description];
            label.font = [UIFont systemFontOfSize:14.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = RGB(172, 175, 181);
            [view addSubview:label];
            [self.carModelLabelList addObject:label];
        }
        
        if(firstButton)
            [self carModelClick:firstButton];
    }else{
        // 按钮数量超出屏幕宽度
        CGFloat _width = 50;
        CGFloat _height = 80;
        
        DSButton *firstButton = nil;
        for (int i = 0; i < num; i++) {
            NSDictionary *dataDic = modellist[i];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * _width, 0, _width, _height)];
            [self.carModelScrollView addSubview:view];
            
            DSButton *button = [DSButton buttonWithType:UIButtonTypeCustom];
            button.frame = view.bounds;
            [button addTarget:self action:@selector(carModelClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            button.value = [dataDic[@"modelid"] description];
            [view addSubview:button];
            
            //默认选中第一个
            if(i == 0){
                firstButton = button;
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((_width-31)/2, 16, 31, 31)];
            imageView.image = [UIImage imageNamed:@"bg_home_circle"];
            imageView.contentMode = UIViewContentModeCenter;
            [view addSubview:imageView];
            [self.carModelImageViewList addObject:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 114/2, _width, 10)];
            label.text = [dataDic[@"searchname"] description];
            label.font = [UIFont systemFontOfSize:10];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = RGB(172, 175, 181);
            [view addSubview:label];
            [self.carModelLabelList addObject:label];
        }
        
        if(firstButton)
            [self carModelClick:firstButton];
        
        self.carModelScrollView.contentSize = CGSizeMake(50*num, 0);
    }
}

- (void)carModelClick:(DSButton *)sender
{
    self.selectedCarModelImageView.image = [UIImage imageNamed:@"bg_home_circle"];
    self.selectedCarModelLabel.textColor = RGB(172, 175, 181);
    
    UIImageView *imageView = self.carModelImageViewList[sender.tag];
    imageView.image = nil;
    imageView.image = [UIImage imageNamed:@"bg_home_circle_car"];
    
    UILabel *label = self.carModelLabelList[sender.tag];
    label.textColor = [UIColor blackColor];
    
    self.selectedCarModelImageView = imageView;
    self.selectedCarModelLabel = label;
    
    self.carModelId = sender.value;
    [self nearCoachRequest:YES];
}

// 取屏幕中点经纬度，取半径值并调用接口取附近教练
- (void)nearCoachRequest:(BOOL)needLiadingShow {
//    CLLocationCoordinate2D zuobiao = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
    
    
    // 计算两点之间的距离
//    CLLocationCoordinate2D c1;
//    c1.latitude = zuobiao.latitude;
//    c1.longitude = zuobiao.longitude;
//    BMKMapPoint mp1 = BMKMapPointForCoordinate(c1);
    
    // 屏幕顶部中点
    CLLocationCoordinate2D screenTop = [_mapView convertPoint:CGPointMake((SCREEN_WIDTH/2), 0) toCoordinateFromView:_mapView];
    CLLocationCoordinate2D c1;
    c1.latitude = screenTop.latitude;
    c1.longitude = screenTop.longitude;
    BMKMapPoint mp1 = BMKMapPointForCoordinate(c1);
    
//    CLLocationCoordinate2D c2;  // 屏幕中心点
//    c2.latitude = _mapView.centerCoordinate.latitude;
//    c2.longitude = _mapView.centerCoordinate.longitude;
//    BMKMapPoint mp2 = BMKMapPointForCoordinate(c2);
    
    // 地图view中心点
    CLLocationCoordinate2D c2;
    c2.latitude = _mapView.centerCoordinate.latitude;
    c2.longitude = _mapView.centerCoordinate.longitude;
    BMKMapPoint mp2 = BMKMapPointForCoordinate(c2);
    
    CLLocationDistance dis = BMKMetersBetweenMapPoints(mp1, mp2);
    
    NSString *pointCenter = [NSString stringWithFormat:@"%f,%f", c2.longitude, c2.latitude];
    NSString *radius = [NSString stringWithFormat:@"%f", dis/1000];
    
    self.isGetData = NO;
    [self requestGetNearByCoachInterfaceWithPointcenter:pointCenter andRadius:radius needLiadingShow:needLiadingShow];
}

#pragma mark - Custom
// 设置筛选信息
- (void)setSearchCoachDict:(id)dictionary
{
    
    if (dictionary == nil) {
        self.allBtn.hidden = YES;
        return;
    }
    
    if ([dictionary isKindOfClass:[NSNotification class]])
    {
        NSNotification *notification = (NSNotification *)dictionary;
        if ([CommonUtil isEmpty:notification.object])
        {
            self.allBtn.hidden = YES;
            self.searchParamDic = nil;
            return;
        }
        self.searchParamDic = [NSMutableDictionary dictionaryWithDictionary:notification.object];
    } else {
        self.searchParamDic = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    }
    
    NSString *condition3 = self.searchParamDic[@"condition3"];
    NSString *condition6 = self.searchParamDic[@"condition6"];
    if([CommonUtil isEmpty:condition3] && [CommonUtil isEmpty:condition6]){
        self.allBtn.hidden = YES;
    }else{
        self.allBtn.hidden = NO;
    }
    
    
    NSString *comeFrom = self.searchParamDic[@"comefrom"];
    if ([comeFrom isEqualToString:@"2"]) { // 来自教练列表的消息
        [self nearCoachRequest:NO];
    } else {
        [self nearCoachRequest:YES];
    }
    
}

- (void)ResetSearchCoachDict {
    [self clickForAllData:nil];
}

#pragma mark - Actions
// 打开、关闭侧边栏
- (IBAction)leftItemClick:(id)sender
{
    BOOL _isShow = [SliderViewController sharedSliderController].isLeftViewShow;
    if (_isShow) {
        [SliderViewController sharedSliderController].isLeftViewShow = NO;
        [[SliderViewController sharedSliderController] closeSideBar];
    }else{
        [SliderViewController sharedSliderController].isLeftViewShow = YES;
        [[SliderViewController sharedSliderController] leftItemClick];
        //通知更新小红点显示
        [[NSNotificationCenter defaultCenter] postNotificationName:@"haveMessageNoRead" object:self];
    }
}

- (IBAction)coachListClick:(id)sender
{
    CoachListViewController *viewController = [[CoachListViewController alloc] initWithNibName:@"CoachListViewController" bundle:nil];
    viewController.searchParamDic = self.searchParamDic;
    [[SliderViewController sharedSliderController].navigationController pushViewController:viewController animated:YES];
}

// 筛选按钮点击事件
- (IBAction)selectedBtnClick:(id)sender
{
    //跳转至筛选
    CoachScreenViewController *nextController = [[CoachScreenViewController alloc] initWithNibName:@"CoachScreenViewController" bundle:nil];
    nextController.searchDic = self.searchParamDic;
    nextController.comeFrom = @"1";
    [self presentViewController:nextController animated:YES completion:nil];
    
}

// 在线报名、预约考试等服务
- (IBAction)clickForServe:(id)sender {
    if ([[CommonUtil currentUtil] isLogin]) {
        XiaobaServeViewController *viewController = [[XiaobaServeViewController alloc] initWithNibName:@"XiaobaServeViewController" bundle:nil];
        [[SliderViewController sharedSliderController].navigationController pushViewController:viewController animated:YES];
    }
}

// 汽车点击事件：教练信息
- (void)carBtnClick:(id)sender
{
//    [self removeCoachHeadControl];
    
    // 添加底部的教练信息栏
    UIButton *button = (UIButton *)sender;
    
    // get coach dic
    int tag = (int)button.tag;
    if (_coachList != nil && _coachList.count != 0) {
        self.coachDic = _coachList[tag];
    }
    NSString *avatarStr = [_coachDic[@"avatarurl"] description];
    NSString *realName = [_coachDic[@"realname"] description];
    NSMutableString *address = [[NSMutableString alloc] initWithString:@"练车地点:"] ;//[_coachDic[@"detail"] description];
    [address appendString:[_coachDic[@"detail"] description]];
    CGFloat starScore = [_coachDic[@"score"] floatValue];
    int gender = [_coachDic[@"gender"] intValue];
    
    
    
    // 教练头像
    [self.userLogo sd_setImageWithURL:[NSURL URLWithString:avatarStr] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    
    // 教练名
    self.coachNameLabel.text = [NSString stringWithFormat:@"%@", realName];
    // 设置教练名label长度
    CGFloat realNameStrWidth = [CommonUtil sizeWithString:realName fontSize:17 sizewidth:68 sizeheight:22].width;
    self.coachNameLabelWidthCon.constant = realNameStrWidth;
    
    // 教练性别
    NSString *genderStr = nil;
    if (gender == 1) {
        genderStr = @"男";
        [self.coachGenderIcon setImage:[UIImage imageNamed:@"icon_male"]];
    }else if (gender == 2)
    {
        genderStr = @"女";
        [self.coachGenderIcon setImage:[UIImage imageNamed:@"icon_female"]];
    }else{
        genderStr = @"";
        [self.coachGenderIcon setImage:[UIImage imageNamed:@"icon_male"]];
    }
    
    // 教练总单数
    NSString *sumnum = [_coachDic[@"sumnum"] description];
    if (sumnum) {
        self.orderCountLabel.hidden = NO;
        NSString *sumnumStr = [NSString stringWithFormat:@"总单数:%@",sumnum];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:sumnumStr];
        [string addAttribute:NSForegroundColorAttributeName value:RGB(32, 180, 120) range:NSMakeRange(4,sumnum.length)];
        self.orderCountLabel.attributedText = string;
        CGFloat sumnumStrWidth = [CommonUtil sizeWithString:sumnumStr fontSize:12 sizewidth:320 sizeheight:15].width;
        self.orderCountLabelWidthCon.constant = sumnumStrWidth;
    } else {
        self.orderCountLabel.hidden = YES;
    }
    
    self.coachAddressLabel.text = address;
    [self.starView changeStarForegroundViewWithScore:starScore];
    
    self.coachId = [_coachDic[@"coachid"] description];
    
    self.coachInfoView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 122);
    [self.view addSubview:self.closeDetailBtn];
    [self.view addSubview:self.coachInfoView];
    
    [UIView animateWithDuration:0.35 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.coachInfoView.frame=CGRectMake(0, SCREEN_HEIGHT - 122, SCREEN_WIDTH, 122);
                         self.closeDetailBtn.alpha = 0.5;
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         //............
                     }];
    
    // 请求刷新教练日程安排接口
    //    [self requestRefreshCoachSchedule];
    //    [self.view bringSubviewToFront:self.filterButton];
    
    // 改变汽车图标状态
    MyAnimatedAnnotationView *carView = (MyAnimatedAnnotationView *)button.superview;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_carselected"]];
    carView.annotationImageView.image = image;
    self.selectedCar = carView;
}

// 关闭教练信息
- (void)closeDetailsView
{
    self.coachInfoView.frame=CGRectMake(0, SCREEN_HEIGHT - 122, SCREEN_WIDTH, 122);
    [UIView animateWithDuration:0.35 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.coachInfoView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 122);
                         self.closeDetailBtn.alpha = 0;
                         
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         //............
                         [self.coachInfoView removeFromSuperview];
                         [self.closeDetailBtn removeFromSuperview];
                     }];

//    [self removeCoachHeadControl];
    [[SliderViewController sharedSliderController] closeSideBar];
    
    // 改变汽车图标状态
    if (self.selectedCar) {
        UIImage *originImage = [UIImage imageNamed:[NSString stringWithFormat:@"ico_cargr"]];
        self.selectedCar.annotationImageView.image = originImage;
    }
}

// 显示全部教练
- (IBAction)clickForAllData:(id)sender {
    self.searchParamDic = nil;
    self.allBtn.hidden = YES;
    
    [self nearCoachRequest:YES];
}

// 教练详情
- (IBAction)coachDetailsClick:(id)sender
{
    CoachDetailViewController *nextController = [[CoachDetailViewController alloc] initWithNibName:@"CoachDetailViewController" bundle:nil];
    nextController.coachId = self.coachId;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

// 预约教练
- (IBAction)appointCoachClick:(id)sender
{
    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
    nextController.coachInfoDic = self.coachDic;
    nextController.coachId = self.coachId;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
    
    
}

// 关闭弹窗广告
- (IBAction)closeAdvClick:(id)sender {
    [self.actView removeFromSuperview];
    self.actView = nil;
}

// 弹窗广告跳转
- (IBAction)advClick:(id)sender {
    [self closeAdvClick:nil];
    if (_actFlag == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.actUrl]];
    } else {
        SignUpViewController *nextVC = [[SignUpViewController alloc] init];
        nextVC.comeFrom = 2;
        [[SliderViewController sharedSliderController].navigationController pushViewController:nextVC animated:YES];
    }
}

@end
