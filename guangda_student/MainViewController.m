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
#import "MyOrderDetailViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "AppDelegate.h"
#import "MyAnimatedAnnotationView.h"
#import "UIImageView+WebCache.h"
#import "AppointCoachViewController.h"
#import "CoachDetailViewController.h"
#import "TQStarRatingView.h"
#import "CoachScreenViewController.h"
#import "UserBaseInfoViewController.h"
@interface MainViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate,UIAlertViewDelegate>
{
    UITapGestureRecognizer *_tapGestureRec2;
    UISwipeGestureRecognizer *_swipGestureRecUp;
    UISwipeGestureRecognizer *_swipGestureRecDown;
    CGFloat _keyboardTop;
    
    BMKLocationService *_locService;
}

@property (strong, nonatomic) NSDictionary *coachDic;
@property (strong, nonatomic) TQStarRatingView *starView;

@property (strong, nonatomic) IBOutlet UIButton *allBtn;

@property (strong, nonatomic) UIImageView *selectedCarModelImageView;
@property (strong, nonatomic) UILabel *selectedCarModelLabel;
@property (strong, nonatomic) NSString *carModelId;
@property (assign, nonatomic) BOOL isGetData;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    int _bili = SCREEN_HEIGHT/568;
    self.shangXiaWu.constant = 20*_bili;
    self.shijiuShiliu.constant = 20*_bili;
    self.carModelLabelList = [NSMutableArray array];
    self.carModelImageViewList = [NSMutableArray array];
    self.isGetData = NO;
    
    _tapGestureRec2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDetailsView)];
    _tapGestureRec2.delegate=self;
    [self.view addGestureRecognizer:_tapGestureRec2];
    
    // 显示教练详情按钮 添加向上滑动手势
    _swipGestureRecUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showCoachDetailsViewClik:)];
    _swipGestureRecUp.delegate = self;
    _swipGestureRecUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.coachDetailShowBtn addGestureRecognizer:_swipGestureRecUp];
    
    // 隐藏教练详情按钮 添加向下滑动手势
    _swipGestureRecDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideCoachDetailsViewClick:)];
    _swipGestureRecDown.delegate = self;
    _swipGestureRecDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.coachDetailHideBtn addGestureRecognizer:_swipGestureRecDown];
    
    self.sureSubmitClick.layer.cornerRadius = 5;
    self.sureSubmitClick.layer.borderWidth = 1;
    self.sureSubmitClick.layer.borderColor = [[UIColor redColor] CGColor];
    
    self.appointResultContentView.layer.cornerRadius = 5;
    
    self.timeDetailsScrollView.contentSize = CGSizeMake(0, 310);
    self.timeDetailsView.frame = CGRectMake(0, 0, SCREEN_WIDTH, MAX(310, SCREEN_HEIGHT - 107 - 154));
    [self.timeDetailsScrollView addSubview:self.timeDetailsView];
    
    self.coachDetailWordView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 450);
    self.coachDetailWordScroll.contentSize = CGSizeMake(0, 450);
    [self.coachDetailWordScroll addSubview:self.coachDetailWordView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    self.mapContentView = mapView;
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    
    //设置地图缩放级别
    [_mapView setZoomLevel:12];
    _mapView.showMapScaleBar = YES;
    _mapView.mapScaleBarPosition = CGPointMake(10+43, SCREEN_HEIGHT-15-30-8);
    
    [self.mapContentView addSubview:_mapView];//初始化BMKLocationService
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMapLocation) name:@"setMapLocation" object:nil];
    
    self.annotationsList = [NSMutableArray array];
    
//     教练信息 星级View
    self.starView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 15, 87, 15)];
    [self.coachInfoView addSubview:_starView];
    
    self.userLogo.layer.cornerRadius = self.userLogo.bounds.size.width/2;
    self.userLogo.layer.masksToBounds = YES;
    
    // 筛选界面的观察者信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSearchCoachDict:) name:@"SearchCoachDict" object:nil];
    
//    self.filterButton.tag=0;//初始状态下没有使用过滤器
    
    //初始化查询的开始时间和结束时间
//    NSDate *nowDate = [NSDate date];
//    NSString *dateStr = [CommonUtil getStringForDate:nowDate format:@"yyyy-MM-dd"];
//    
//    NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:30*24*60*60];
//    NSString *dateStrEnd = [CommonUtil getStringForDate:endDate format:@"yyyy-MM-dd"];
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    
//    [dic setObject:[NSString stringWithFormat:@"%@ 05:00:00",dateStr] forKey:@"condition3"];   // 时间下限
//    
//    [dic setObject:[NSString stringWithFormat:@"%@ 23:00:00",dateStrEnd] forKey:@"condition4"];   // 时间上限
//    self.searchParamDic = dic;
    
    [self requestGetCarModelInterfaceWithId:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    
    [self mapView:_mapView regionDidChangeAnimated:YES];
    
    [self setMapLocation];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    //刷新数据
    CLLocationCoordinate2D zuobiao = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
    
    // 计算两点之间的距离
    CLLocationCoordinate2D c1;
    c1.latitude = zuobiao.latitude;
    c1.longitude = zuobiao.longitude;
    BMKMapPoint mp1 = BMKMapPointForCoordinate(c1);
    
    CLLocationCoordinate2D c2;  // 屏幕中心点
    c2.latitude = _mapView.centerCoordinate.latitude;
    c2.longitude = _mapView.centerCoordinate.longitude;
    BMKMapPoint mp2 = BMKMapPointForCoordinate(c2);
    
    CLLocationDistance dis = BMKMetersBetweenMapPoints(mp1, mp2);
    
    NSString *pointCenter = [NSString stringWithFormat:@"%f,%f", c2.longitude, c2.latitude];
    NSString *radius = [NSString stringWithFormat:@"%f", dis/1000];
    
    [self requestGetNearByCoachInterfaceWithPointcenter:pointCenter andRadius:radius  needLiadingShow:YES];

}

#pragma mark - actions
#pragma mark 小汽车 button 点击事件
// 旧需求的汽车点击事件
- (IBAction)carBtnClick:(id)sender
{
    [self removeCoachHeadControl];
    
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
    
    NSString *genderStr = nil;
    if (gender == 1) {
        genderStr = @"男";
    }else if (gender == 2)
    {
        genderStr = @"女";
    }else{
        genderStr = @"";
    }
    
    [self.userLogo sd_setImageWithURL:[NSURL URLWithString:avatarStr] placeholderImage:[UIImage imageNamed:@"user_logo_default"]];
    if(genderStr.length>0)//已设置性别
        self.coachNameLabel.text = [NSString stringWithFormat:@"%@(%@)", realName, genderStr];
    else//未设置性别则不显示性别
         self.coachNameLabel.text = [NSString stringWithFormat:@"%@", realName];

    self.coachAddressLabel.text =   address;
    [self.starView changeStarForegroundViewWithScore:starScore];
    
    self.coachId = [_coachDic[@"coachid"] description];
    
    self.coachInfoView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 122);
    [self.view addSubview:self.coachInfoView];
    
    [UIView animateWithDuration:0.5 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.coachInfoView.frame=CGRectMake(0, SCREEN_HEIGHT - 122, SCREEN_WIDTH, 122);
                         
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         //............
                     }];
    
    // 请求刷新教练日程安排接口
//    [self requestRefreshCoachSchedule];
//    [self.view bringSubviewToFront:self.filterButton];
}

- (void)closeDetailsView
{
//    for (id objc in self.view.subviews) {
//        if ([objc isEqual:self.chooseCoachTimeView]) {
    
            self.coachInfoView.frame=CGRectMake(0, SCREEN_HEIGHT - 122, SCREEN_WIDTH, 122);
            [UIView animateWithDuration:0.5 //时长
                                  delay:0 //延迟时间
                                options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                             animations:^{
                                 
                                 //动画设置区域
                                 self.coachInfoView.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 122);
                                 
                                 
                             } completion:^(BOOL finish){
                                 //动画结束时调用
                                 //............
                                 [self.coachInfoView removeFromSuperview];
                             }];
//        }
//    }
    self.selectedView.hidden = YES;
    [self removeCoachHeadControl];
    [[SliderViewController sharedSliderController] closeSideBar];
}

// 移除教练头像control
- (void)removeCoachHeadControl
{
    for (id objc in self.view.subviews)
    {
        if ([objc isKindOfClass:[UIControl class]])
        {
            UIControl *contro = (UIControl *)objc;
            
            // tag = 1 为教练头像control
            if (contro.tag == 1)
            {
                [contro removeFromSuperview];
            }
        }
    }
}

#pragma mark 教练列表按钮点击事件 (筛选)
- (IBAction)coachListClick:(id)sender
{
    CoachListViewController *viewController = [[CoachListViewController alloc] initWithNibName:@"CoachListViewController" bundle:nil];
    viewController.searchParamDic = self.searchParamDic;
    [[SliderViewController sharedSliderController].navigationController pushViewController:viewController animated:YES];
}

// 筛选按钮点击事件
- (IBAction)selectedBtnClick:(id)sender
{
//    if (self.filterButton.tag==1) {
//        [self.filterButton setImage:[UIImage imageNamed:@"icon_time_selection"] forState:UIControlStateNormal];
//        self.filterButton.tag=0;
//    }
//    else
//    {
    //跳转至筛选
    CoachScreenViewController *nextController = [[CoachScreenViewController alloc] initWithNibName:@"CoachScreenViewController" bundle:nil];
    nextController.searchDic = self.searchParamDic;
    [self presentViewController:nextController animated:YES completion:nil];
    
}

// 精确、模糊 筛选点击事件
- (IBAction)checkBtnClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    // 调整button的背景色
    if (button.tag == 0)
    {   // 精确
        self.accurateBtnOutlet.selected = YES;
        self.fuzzyBtnOutlet.selected = NO;
        self.datePicker.datePickerMode = UIDatePickerModeTime;
    }else{
        // 模糊
        self.fuzzyBtnOutlet.selected = YES;
        self.accurateBtnOutlet.selected = NO;
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    }
    
    self.pickerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.pickerView];
//    self.selectedView.hidden = YES;
}
- (IBAction)removePickerView:(id)sender {
    [self.pickerView removeFromSuperview];
}

#pragma mark 展开选择教练时间段详情页
- (IBAction)showCoachTimeClick:(id)sender
{
    self.chooseCoachTimeView.frame = CGRectMake(0, SCREEN_HEIGHT-92, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.chooseCoachTimeView];
    
    [UIView animateWithDuration:0.5 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.chooseCoachTimeView.frame=CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT);
                         self.remainTimeView.alpha = 0;
                         [self.showHideTimeDetailsBtn setImage:[UIImage imageNamed:@"btn_hide"] forState:UIControlStateNormal];
                         [self.showHideTimeDetailsBtn removeTarget:self action:@selector(showCoachTimeClick:) forControlEvents:UIControlEventTouchUpInside];
                         [self.showHideTimeDetailsBtn addTarget:self action:@selector(hideCoachTimeDetailsView:) forControlEvents:UIControlEventTouchUpInside];
                         
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         //............
//                         self.chooseCoachTimeView.superview.userInteractionEnabled = NO;
                         _tapGestureRec2.enabled = NO;
                     }];
    
//    self.chooseCoachTimeView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    [self.view addSubview:self.chooseCoachTimeView];
    self.timeScrollView.contentSize = CGSizeMake(600, 0);
    [self.timeScrollView addSubview:self.timeListView];
}

#pragma mark 教练时间选择action
- (IBAction)timeButonClick:(id)sender
{
    // 移除所有的选择标记
    for (id objc in self.timeDetailsContentView.subviews)
    {
        if ([objc isKindOfClass:[UIImageView class]])
        {
            UIImageView *imageView = (UIImageView *)objc;
            [imageView removeFromSuperview];
        }
    }
    
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    BOOL _isHaveSelected;   // 是否有时间呗选择
    _isHaveSelected = NO;
    
    int _hourNum;    // 选择的时长
    _hourNum = 0;
    
    int _perHourPrice = 80; // 单价
    
    // 遍历view中得button，如果为被选中状态，添加标记
    for (id objc in self.timeDetailsContentView.subviews)
    {
        if ([objc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)objc;
            if (btn.selected)
            {
                _isHaveSelected = YES;
                _hourNum++;
                
                CGFloat _x = btn.frame.origin.x;
                CGFloat _y = btn.frame.origin.y;

                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_selected"]];
                imageView.frame = CGRectMake(_x+22-10.5, _y+44-10.5, 21, 21);
                [self.timeDetailsContentView addSubview:imageView];
            }
        }
    }
    
    if (_isHaveSelected) {
        self.perPriceView.hidden = YES;
        self.sureAppointBtn.enabled = YES;
    }else{
        self.perPriceView.hidden = NO;
        self.perPriceLabel.text = [NSString stringWithFormat:@"单价 %.1d元/小时", _perHourPrice];
        self.sureAppointBtn.enabled = NO;
    }
    self.priceAndHourLabel.text = [NSString stringWithFormat:@"%d元/小时*%d", _perHourPrice, _hourNum];
    self.allPriceLabel.text = [NSString stringWithFormat:@"合计%d元", _perHourPrice * _hourNum];
}

- (IBAction)hideCoachTimeDetailsView:(id)sender
{
    [UIView animateWithDuration:0.5 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.remainTimeView.alpha = 1;
                         self.chooseCoachTimeView.frame=CGRectMake(0, SCREEN_HEIGHT - 92, SCREEN_WIDTH, SCREEN_HEIGHT);
                         [self.showHideTimeDetailsBtn removeTarget:self action:@selector(hideCoachTimeDetailsView:) forControlEvents:UIControlEventTouchUpInside];
                         [self.showHideTimeDetailsBtn addTarget:self action:@selector(showCoachTimeClick:) forControlEvents:UIControlEventTouchUpInside];
                         [self.showHideTimeDetailsBtn setImage:[UIImage imageNamed:@"btn_show"] forState:UIControlStateNormal];
                         
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         //............
//                         [self.chooseCoachTimeView removeFromSuperview];
                         _tapGestureRec2.enabled = YES;
                     }];
}

#pragma mark 点击预约
- (IBAction)appointClick:(id)sender {
    self.checkNumView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    [self.view addSubview:self.checkNumView];
//    [self makeToast:@"预约成功"];
    
//    [self requestBookCoachInterface];
}

- (IBAction)hideAppointResultView:(id)sender {
    [self.appointResultView removeFromSuperview];
}

#pragma mark 显示教练详细信息view
- (IBAction)showCoachDetailsViewClik:(id)sender
{
    [self requestGetCoachDetailInterface];
    
    self.coachDetailsViewAll.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-145);
    [self.view addSubview:self.coachDetailsViewAll];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         self.coachDetailsViewAll.frame = CGRectMake(0, 145, SCREEN_WIDTH, SCREEN_HEIGHT - 145);
                     }completion:^(BOOL finished) {
                         self.showHideTimeDetailsBtn.enabled = NO;
                     }];
}

- (IBAction)hideCoachDetailsViewClick:(id)sender
{
    self.coachDetailsViewAll.frame = CGRectMake(0, 145, SCREEN_WIDTH, SCREEN_HEIGHT - 145);
    [self.view addSubview:self.coachDetailsViewAll];
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         self.coachDetailsViewAll.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-145);
                     }completion:^(BOOL finished) {
                         [self.coachDetailsViewAll removeFromSuperview];
                         self.showHideTimeDetailsBtn.enabled = YES;
                     }];
}

// 动画显示效果
- (void)animationOfBlock
{
    self.coachDetailsView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [UIView animateWithDuration:1 //时长
                          delay:0 //延迟时间
                        options:UIViewAnimationOptionTransitionFlipFromLeft//动画效果
                     animations:^{
                         
                         //动画设置区域
                         self.coachDetailsView.frame=CGRectMake(50, 50,SCREEN_WIDTH, SCREEN_HEIGHT);
                         
                     } completion:^(BOOL finish){
                         //动画结束时调用
                         //............
                     }];
    
}

#pragma mark 打电话
- (IBAction)phoneCallClick:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *phoneNum = nil;
    
    if (button.tag == 0) {
        phoneNum = @"telprompt:0517-82664711";
    }else{
        phoneNum = @"telprompt:18006784207";
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
}

#pragma mark 确认提交
- (IBAction)sureSubmitClick:(id)sender
{
    [self.checkNumView removeFromSuperview];
    self.appointResultView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.appointResultView];
//    [self.appointResultView removeFromSuperview];
}

#pragma mark - 教练详情
- (IBAction)coachDetailsClick:(id)sender
{
    CoachDetailViewController *nextController = [[CoachDetailViewController alloc] initWithNibName:@"CoachDetailViewController" bundle:nil];
    nextController.coachId = self.coachId;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)appointCoachClick:(id)sender
{
    AppointCoachViewController *nextController = [[AppointCoachViewController alloc] initWithNibName:@"AppointCoachViewController" bundle:nil];
    nextController.coachInfoDic = self.coachDic;
    nextController.coachId = self.coachId;
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:nextController];
    navigationController.navigationBarHidden = YES;
    [self presentViewController:navigationController animated:YES completion:nil];
    
    
}


#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    _keyboardTop = keyboardRect.size.height;
    
    self.checkNumView.frame = CGRectMake(0, -_keyboardTop, SCREEN_WIDTH, SCREEN_HEIGHT);
    NSLog(@"keyboardWillShow");
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.checkNumView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (IBAction)hideKeyboardClick:(id)sender {
    [self.driveNumLabel resignFirstResponder];
    [self.studentNumLabel resignFirstResponder];
}

// 阻挡点击响应传递到底层
- (IBAction)ignoreNextTouch:(id)sender {
    
}

- (IBAction)orderDetailsClick:(id)sender {
    MyOrderDetailViewController *viewController = [[MyOrderDetailViewController alloc] initWithNibName:@"MyOrderDetailViewController" bundle:nil];
    [[SliderViewController sharedSliderController].navigationController pushViewController:viewController animated:YES];
    [self.appointResultView removeFromSuperview];
}

#pragma mark - BaiduMap
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
    NSLog(@"setUserImage");
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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
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

    CLLocationCoordinate2D zuobiao = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
    
    // 计算两点之间的距离
    CLLocationCoordinate2D c1;
    c1.latitude = zuobiao.latitude;
    c1.longitude = zuobiao.longitude;
    BMKMapPoint mp1 = BMKMapPointForCoordinate(c1);
    
    CLLocationCoordinate2D c2;  // 屏幕中心点
    c2.latitude = _mapView.centerCoordinate.latitude;
    c2.longitude = _mapView.centerCoordinate.longitude;
    BMKMapPoint mp2 = BMKMapPointForCoordinate(c2);
    
    CLLocationDistance dis = BMKMetersBetweenMapPoints(mp1, mp2);
    
    NSString *pointCenter = [NSString stringWithFormat:@"%f,%f", c2.longitude, c2.latitude];
    NSString *radius = [NSString stringWithFormat:@"%f", dis/1000];
    
    [self requestGetNearByCoachInterfaceWithPointcenter:pointCenter andRadius:radius  needLiadingShow:NO];

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
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_car_btn"]];
//    }
    annotationView.annotationImageView.image = image;
    annotationView.annotationButton.tag = [annotation.title intValue];
    [annotationView.annotationButton addTarget:self action:@selector(carBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return annotationView;
}

#pragma mark - Map Action
// 设置用户位置为屏幕中心
- (IBAction)setUserLocationToMid:(id)sender
{
    //地图初始位置设定
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [_mapView setCenterCoordinate:appDelegate.userCoordinate animated:YES];
    [_mapView setZoomLevel:12];

    
    CLLocationCoordinate2D zuobiao = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
    
    // 计算两点之间的距离
    CLLocationCoordinate2D c1;
    c1.latitude = zuobiao.latitude;
    c1.longitude = zuobiao.longitude;
    BMKMapPoint mp1 = BMKMapPointForCoordinate(c1);
    
    CLLocationCoordinate2D c2;  // 屏幕中心点
    c2.latitude = _mapView.centerCoordinate.latitude;
    c2.longitude = _mapView.centerCoordinate.longitude;
    BMKMapPoint mp2 = BMKMapPointForCoordinate(c2);
    
    CLLocationDistance dis = BMKMetersBetweenMapPoints(mp1, mp2);
    
    NSString *pointCenter = [NSString stringWithFormat:@"%f,%f", c2.longitude, c2.latitude];
    NSString *radius = [NSString stringWithFormat:@"%f", dis/1000];
    
    [self requestGetNearByCoachInterfaceWithPointcenter:pointCenter andRadius:radius needLiadingShow:YES];
}

#pragma mark - 请求接口
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
        
        [DejalBezelActivityView removeViewAnimated:YES];
        self.isGetData = NO;
        if ([responseObject[@"code"] integerValue] == 1)
        {
            self.coachList = responseObject[@"coachlist"];
            
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
        [self makeToast:ERR_NETWORK];
        self.isGetData = NO;
    }];

}

// 请求教练详情
- (void)requestGetCoachDetailInterface
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:_coachId forKey:@"coachid"];
    
    if (_coachId.length == 0) return;
    
    
    NSString *uri = @"/sbook?action=GetCoachDetail";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"code"] integerValue] == 1)
        {
            
            NSDictionary *coachinfo = responseObject[@"coachinfo"];
            self.detailsCoachName.text = [coachinfo[@"realname"] description];
            int sex = [coachinfo[@"gender"] intValue];
            switch (sex) {
                case 0:
                    self.detailsSex.text = @"未设置";
                    break;
                case 1:
                    self.detailsSex.text = @"男";
                    break;
                case 2:
                    self.detailsSex.text = @"女";
                    break;
                    
                default:
                    break;
            }
            self.detailsAge.text = [coachinfo[@"age"] description];
            self.detailsAddress.text = [coachinfo[@"address"] description];
            self.detailsCardnum.text = [coachinfo[@"id_cardnum"] description];
            self.detailsCoachCardnum.text = [coachinfo[@"coach_cardnum"] description];
            self.detailsCarType.text = [coachinfo[@""] description];
            self.detailsCarNum.text = [coachinfo[@""] description];
            self.detailsCoachSchool.text = [coachinfo[@"drive_school"] description];
            self.detailsCoachLevel.text = [coachinfo[@""] description];
            self.detailsCocahComment.text = [NSString stringWithFormat:@"自我评价：%@", [coachinfo[@"selfeval"] description]];
        }else{
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
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
            NSArray *modellist = responseObject[@"modellist"];
            [self addCarModelWithList:modellist];
        }else{
            NSString *message = responseObject[@"message"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [DejalBezelActivityView removeViewAnimated:YES];
        [self makeToast:ERR_NETWORK];
    }];
}

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
    
    CLLocationCoordinate2D zuobiao = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];

    // 计算两点之间的距离
    CLLocationCoordinate2D c1;
    c1.latitude = zuobiao.latitude;
    c1.longitude = zuobiao.longitude;
    BMKMapPoint mp1 = BMKMapPointForCoordinate(c1);

    CLLocationCoordinate2D c2;  // 屏幕中心点
    c2.latitude = _mapView.centerCoordinate.latitude;
    c2.longitude = _mapView.centerCoordinate.longitude;
    BMKMapPoint mp2 = BMKMapPointForCoordinate(c2);

    CLLocationDistance dis = BMKMetersBetweenMapPoints(mp1, mp2);

    NSString *pointCenter = [NSString stringWithFormat:@"%f,%f", c2.longitude, c2.latitude];
    NSString *radius = [NSString stringWithFormat:@"%f", dis/1000];
    
    self.carModelId = sender.value;
    self.isGetData = NO;
    [self requestGetNearByCoachInterfaceWithPointcenter:pointCenter andRadius:radius needLiadingShow:YES];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == _timeScrollView)
    {
        int n = _timeScrollView.contentOffset.x / 73;
        if (_timeScrollView.contentOffset.x > (50 + 73*n)) n++;
        [_timeScrollView setContentOffset:CGPointMake(13+73*n, 0) animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _timeScrollView)
    {
        int n = _timeScrollView.contentOffset.x / 73;
        if (_timeScrollView.contentOffset.x > (50 + 73*n)) n++;
        [_timeScrollView setContentOffset:CGPointMake(13+73*n, 0) animated:YES];
    }
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView == _timeScrollView)
//    {
//        int x = _timeScrollView.contentOffset.x;
//        NSLog(@".contentOffset.x == %d", x);
//    }
//    
//}

+ (MainViewController *)sharedMainController
{
    static MainViewController *mainVC;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainVC = [[self alloc] init];
    });
    
    return mainVC;
}

- (IBAction)clickForAllData:(id)sender {
    self.searchParamDic = nil;
    self.allBtn.hidden = YES;
    
    //刷新数据
    CLLocationCoordinate2D zuobiao = [_mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:_mapView];
    
    // 计算两点之间的距离
    CLLocationCoordinate2D c1;
    c1.latitude = zuobiao.latitude;
    c1.longitude = zuobiao.longitude;
    BMKMapPoint mp1 = BMKMapPointForCoordinate(c1);
    
    CLLocationCoordinate2D c2;  // 屏幕中心点
    c2.latitude = _mapView.centerCoordinate.latitude;
    c2.longitude = _mapView.centerCoordinate.longitude;
    BMKMapPoint mp2 = BMKMapPointForCoordinate(c2);
    
    CLLocationDistance dis = BMKMetersBetweenMapPoints(mp1, mp2);
    
    NSString *pointCenter = [NSString stringWithFormat:@"%f,%f", c2.longitude, c2.latitude];
    NSString *radius = [NSString stringWithFormat:@"%f", dis/1000];
    
    [self requestGetNearByCoachInterfaceWithPointcenter:pointCenter andRadius:radius needLiadingShow:YES];
}
@end
