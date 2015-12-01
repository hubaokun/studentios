//
//  UserInfoHomeViewController.m
//  guangda
//
//  Created by duanjycc on 15/3/26.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "UserInfoHomeViewController.h"
#import "UserBaseInfoViewController.h"
#import "LearnDriveInfoViewController.h"
#import "ImproveInfoViewController.h"
#import "CZPhotoPickerController.h"
#import "UIImageView+WebCache.h"
#import "TQStarRatingView.h"
#import "LoginViewController.h"

@interface UserInfoHomeViewController () <UIImagePickerControllerDelegate, StarRatingViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) TQStarRatingView *userStarView;

// 拍照，相册
@property (strong, nonatomic) IBOutlet UIView *photoView;
@property (nonatomic, strong) CZPhotoPickerController *pickPhotoController;
@property (strong, nonatomic) UIImageView *clickImageView;//需要显示图片的imageview

- (IBAction)clickForChangePortrait:(id)sender;
- (IBAction)clickForCancelPortraitChange:(id)sender;
- (IBAction)clickForCamera:(id)sender; // 相机
- (IBAction)clickForAlbum:(id)sender; // 相册

- (IBAction)clickToUserBaseInfoView:(id)sender;
- (IBAction)clickToLearnDriveInfoView:(id)sender;
- (IBAction)clickToImproveUserInfoView:(id)sender;

@end

@implementation UserInfoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showData];
}

#pragma mark - 页面设置
- (void)settingView {
    self.clickImageView = [[UIImageView alloc] init];

    // 设置头像为圆形
    self.portraitImageView.layer.cornerRadius = self.portraitImageView.bounds.size.height/2;
    self.portraitImageView.layer.masksToBounds = YES;
    
    // 学员评分
    self.userStarView = [[TQStarRatingView alloc] initWithFrame:CGRectMake(82, 46, 93, 17) numberOfStar:5];
    self.userStarView.couldClick = NO;
    self.userStarView.delegate = self;
    [self.userView addSubview:self.userStarView];
}

// 显示数据
- (void)showData {
    [self loadLocalData];
    self.nameField.text = _realname;
    [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:_avatar] placeholderImage:[UIImage imageNamed:@"login_icon"]];
     [self.userStarView changeStarForegroundViewWithScore:self.score];
}

#pragma mark - photo
- (CZPhotoPickerController *)photoController
{
    __weak typeof(self) weakSelf = self;
    
    return [[CZPhotoPickerController alloc] initWithPresentingViewController:self withCompletionBlock:^(UIImagePickerController *imagePickerController, NSDictionary *imageInfoDict) {
        
        [weakSelf.pickPhotoController dismissAnimated:YES];
        weakSelf.pickPhotoController = nil;
        
        if (imagePickerController == nil || imageInfoDict == nil) {
            return;
        }
        UIImage *image = imageInfoDict[UIImagePickerControllerEditedImage];
        if(!image)
            image = imageInfoDict[UIImagePickerControllerOriginalImage];
        image = [CommonUtil scaleImage:image minLength:1200];
        
        [self postChangeAvatar:image];
        
        self.photoView.hidden = YES;
    }];
}

#pragma mark - 网络请求
// 上传头像
- (void)postChangeAvatar:(UIImage *)image {
    NSString *studentId = [CommonUtil stringForID:USERDICT[@"studentid"]];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:studentId forKey:@"studentid"];
    [paramDic setObject:[CommonUtil stringForID:USERDICT[@"token"]] forKey:@"token"];
    
    NSString *uri = @"/suser?action=ChangeAvatar";
    NSDictionary *parameters = [RequestHelper getParamsWithURI:uri Parameters:paramDic RequestMethod:Request_POST];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [DejalBezelActivityView activityViewForView:self.view];
    [manager POST:[RequestHelper getFullUrl:uri] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.75) name:@"avatar" fileName:@"image.jpg" mimeType:@"image/jpeg"];
    }success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DejalBezelActivityView removeViewAnimated:YES];
        
        int code = [responseObject[@"code"] intValue];
        if (code == 1) {
            [self makeToast:@"提交成功"];
            _avatar = responseObject[@"avatarurl"];
            if (![_avatar isKindOfClass:[NSString class]]) {
                _avatar = @"";
            }
            if (![CommonUtil isEmpty:_avatar]) {
                [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:_avatar] placeholderImage:nil];
            }
            [self locateData];
        }else if(code == 95){
            NSString *message = responseObject[@"message"];
            [self makeToast:message];
            [CommonUtil logout];
            [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(backLogin)
                                           userInfo:nil
                                            repeats:NO];
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

- (void) backLogin{
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *nextViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark - 数据处理
// 取得输入数据
- (void)catchInputData {
}

// 数据本地化
- (void)locateData {
    [self emptyDataFun];
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    NSMutableDictionary *new_user_info = [NSMutableDictionary dictionaryWithDictionary:user_info];
    [new_user_info setObject:_avatar forKey:@"avatarurl"];
    [CommonUtil saveObjectToUD:new_user_info key:@"UserInfo"];
}

// 加载本地数据
- (void)loadLocalData {
    NSDictionary *user_info = [CommonUtil getObjectFromUD:@"UserInfo"];
    _avatar = [user_info objectForKey:@"avatarurl"];
    _realname = [user_info objectForKey:@"realname"];
    self.score = [[user_info objectForKey:@"score"] floatValue];
}

// 空数据处理
- (void)emptyDataFun {
    if ([CommonUtil isEmpty:_avatar]) {
        _avatar = @"";
    }
}

#pragma mark - 点击事件
- (IBAction)clickForChangePortrait:(id)sender {
    self.photoView.hidden = NO;
}

- (IBAction)clickForCancelPortraitChange:(id)sender {
    self.photoView.hidden = YES;
}

// 拍照
- (IBAction)clickForCamera:(id)sender {
    self.photoView.hidden = YES;
    self.pickPhotoController = [self photoController];
    self.pickPhotoController.allowsEditing = YES;
    self.pickPhotoController.saveToCameraRoll = NO;
    if ([CZPhotoPickerController canTakePhoto]) {
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }
}

// 相册
- (IBAction)clickForAlbum:(id)sender {
    self.photoView.hidden = YES;
    self.pickPhotoController = [self photoController];
    self.pickPhotoController.saveToCameraRoll = NO;
    self.pickPhotoController.allowsEditing = YES;
    if ([CZPhotoPickerController canTakePhoto]) {
        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

//上传图片
//- (IBAction)clickForImage:(id)sender {
//    
//    UIButton *button = (UIButton *)sender;
//    
//    self.pickPhotoController = [self photoController];
//    self.pickPhotoController.tag = 0;
//    
//    if (button.tag == 0 && [CZPhotoPickerController canTakePhoto]) {
//        //拍照
//        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
//    } else {
//        //相册
//        [self.pickPhotoController showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//    }
//}

- (IBAction)clickToUserBaseInfoView:(id)sender {
    UserBaseInfoViewController *targetViewController = [[UserBaseInfoViewController alloc] initWithNibName:@"UserBaseInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (IBAction)clickToLearnDriveInfoView:(id)sender {
    LearnDriveInfoViewController *targetViewController = [[LearnDriveInfoViewController alloc] initWithNibName:@"LearnDriveInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (IBAction)clickToImproveUserInfoView:(id)sender {
    ImproveInfoViewController *targetViewController = [[ImproveInfoViewController alloc] initWithNibName:@"ImproveInfoViewController" bundle:nil];
    [self.navigationController pushViewController:targetViewController animated:YES];
}

- (void)dealloc {
    NSLog(@"UserInfoHomeView  dealloc");
}

@end
