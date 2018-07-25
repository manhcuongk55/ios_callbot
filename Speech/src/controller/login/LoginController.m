//
//  LoginController.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "LoginController.h"
#import "LoginTextBox.h"
#import "LoginButton.h"
#import "ChatController.h"
#import "BaseNavigationController.h"
#import "Utils.h"
#import "CheckBoxRememberLogin.h"
#import "HTTPNetworkControl.h"
#import "Manager.h"
#import "NSAttributedString+DDHTML.h"
#import <MessageUI/MessageUI.h>
#import "TtsStreamingVTCCControl.h"

@import Firebase;

@interface LoginController () <UITextFieldDelegate> {
    
    CAGradientLayer *bgGradientLayer;
    ASScrollNode *scrollNode;
    ASImageNode *logo;
    
    ASTextNode *titleNode;
    LoginTextBox *tbUsername;
    LoginTextBox *tbPass;
    CheckBoxRememberLogin *checkbox;
    LoginButton *loginBtn;
    
    float keyboardHi;
}

@end


@implementation LoginController

- (instancetype)init
{
    self = [super initWithNode:[ASDisplayNode new]];
    if (self) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[ (__bridge id)[UIColor colorWithRed:2.0/255.0 green:200.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:2.0/255.0 green:168.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:0.0/255.0 green:179.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor];
        gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        //
        
        bgGradientLayer = gradientLayer;
        [self.node.layer insertSublayer:bgGradientLayer atIndex:0];
        //
        scrollNode = [ASScrollNode new];
        if ([Utils getIntSystemVersion] >= 11) {
            scrollNode.view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            scrollNode.view.insetsLayoutMarginsFromSafeArea = NO;
        }
        [self.node addSubnode:scrollNode];
        scrollNode.view.showsVerticalScrollIndicator = NO;
        //
        logo = [ASImageNode new];
        logo.image = [UIImage imageNamed:@"logo_login"];
        [scrollNode addSubnode:logo];
        
        //
        titleNode = [ASTextNode new];
        titleNode.attributedText = [[NSAttributedString alloc] initWithString:@"TRỢ LÝ ẢO VIETTEL" attributes:[self titleStyle]];
        [scrollNode addSubnode:titleNode];
        //
        tbUsername = [[LoginTextBox alloc] initWithType: 1];
        tbUsername.tf.delegate = self;
        [scrollNode addSubnode:tbUsername];
        //
        tbPass = [[LoginTextBox alloc] initWithType: 2];
        tbPass.tf.delegate = self;
        [scrollNode addSubnode:tbPass];
        //
        checkbox = [CheckBoxRememberLogin new];
        [scrollNode addSubnode:checkbox];
        //
        loginBtn = [LoginButton new];
        [scrollNode addSubnode:loginBtn];
        //
        [loginBtn addTarget:self action:@selector(loginBtnClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        // Listen for keyboard appearances and disappearances
        keyboardHi = 0.0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        //
        //tbUsername.tf.text = @"hungpv39"; //@"normal_user";
        //tbPass.tf.text = @"Chuonggio213@!";
    }
    return self;
}
- (NSDictionary *)titleStyle {
    UIFont *font = [UIFont boldSystemFontOfSize:20.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self calculateFrame];
}
- (void) calculateFrame {
    bgGradientLayer.frame = self.node.bounds;
    //
    float yCurrent = [Utils getCurrentYEndContent:scrollNode.view];
    //
    CGRect rectContent = [self getContentRect];
    if (keyboardHi > 0) {
        rectContent.size.height = self.node.bounds.size.height - keyboardHi;
    }
    scrollNode.frame = rectContent;
    [Utils scrollToYEndContent:yCurrent scrollView:scrollNode.view];
    //
    rectContent = [self getContentRect];
    //
    CGSize sizeT = CGSizeMake(300, 261);
    float xT = rectContent.origin.x + (rectContent.size.width - sizeT.width)/2.0;
    float yT = 0;
    logo.frame = CGRectMake( xT, yT, sizeT.width, sizeT.height);
    //
    sizeT = [titleNode calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    xT = rectContent.origin.x + (rectContent.size.width - sizeT.width)/2.0;
    yT = logo.frame.origin.y + logo.frame.size.height + 15;
    titleNode.frame = CGRectMake( xT, yT, sizeT.width, sizeT.height);
    //
    sizeT = CGSizeMake(290, 44);
    xT = rectContent.origin.x + (rectContent.size.width - sizeT.width)/2.0;
    yT = titleNode.frame.origin.y + titleNode.frame.size.height + 15;
    tbUsername.frame = CGRectMake( xT, yT, sizeT.width, sizeT.height);
    //
    sizeT = CGSizeMake(290, 44);
    xT = rectContent.origin.x + (rectContent.size.width - sizeT.width)/2.0;
    yT = tbUsername.frame.origin.y + tbUsername.frame.size.height + 15;
    tbPass.frame = CGRectMake( xT, yT, sizeT.width, sizeT.height);
    //
    sizeT = CGSizeMake(290, 44);
    xT = rectContent.origin.x + (rectContent.size.width - sizeT.width)/2.0;
    yT = tbPass.frame.origin.y + tbPass.frame.size.height + 25;
    checkbox.frame = CGRectMake( xT, yT, sizeT.width, sizeT.height);
    //
    sizeT = CGSizeMake(290, 44);
    xT = rectContent.origin.x + (rectContent.size.width - sizeT.width)/2.0;
    yT = checkbox.frame.origin.y + checkbox.frame.size.height + 25;
    loginBtn.frame = CGRectMake( xT, yT, sizeT.width, sizeT.height);
    //
    scrollNode.view.contentSize = CGSizeMake(rectContent.size.width, loginBtn.frame.origin.y + loginBtn.frame.size.height + 44 + [Utils instance].edgeInsets.bottom);
    //
}
- (void) loginBtnClicked {
    //
//    [[TtsStreamingVTCCControl instance] vocalize:@"Để bảo đảm quá trình chuẩn bị, triển khai đúng quy định, chặt chẽ, hiệu quả, Thủ tướng Chính phủ giao Ban Cán sự Đảng Bộ Văn hóa, Thể thao và Du lịch có tờ trình, báo cáo Bộ Chính trị trong tháng 7 để xin ý kiến về chủ trương đăng cai tổ chức Sea Games 31 và Para Games 11 năm 2021 tại thành phố Hà Nội, trên cơ sở đó thông báo chính thức tới Liên đoàn Thể thao Đông Nam Á. Sau khi Bộ Chính trị đồng ý về chủ trương, UBND thành phố Hà Nội chủ trì, phối hợp chặt chẽ với Bộ Văn hóa, Thể thao và Du lịch và các bộ, cơ quan, địa phương liên quan xây dựng Đề án tổ chức Sea Games 31 và Para Games 11 trên tinh thần tiết kiệm, an toàn, hiệu quả, thành công; chủ động rà soát, hoàn thiện phương án chi tiết về cơ sở vật chất theo hướng tận dụng tối đa cơ sở vật chất sẵn có, hạn chế xây dựng và mua sắm mới, tăng cường mạnh mẽ xã hội hóa nguồn lực. Ngành thể dục, thể thao chủ động, tích cực chuẩn bị lực lượng vận động viên, huấn luyện viên và các điều kiện cần thiết để Đoàn thể thao Việt Nam đạt thành tích tốt nhất tại Sea Games 31 và Para Games 11 năm 2021. Thời gian qua, ngành thể dục, thể thao và các địa phương liên quan đã thể hiện quyết tâm cao, có sự chuẩn bị nghiêm túc để sẵn sàng nhận đăng cai tổ chức Sea Games 31 và Para Games 11 năm 2021. Đây vừa là trách nhiệm, vừa là vinh dự của Việt Nam, góp phần thúc đẩy phong trào thể thao trong nước, quảng bá hình ảnh đất nước, con người Việt Nam với bạn bè quốc tế."];
//    return;
    //
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"va_tts.wav"];
//
//    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
//    picker.mailComposeDelegate = self;
//    NSMutableData *fileData = [NSMutableData dataWithContentsOfFile:filePath];
//    [picker addAttachmentData:fileData mimeType:@"application/octet-stream" fileName:@"test_bloomfilter"];
//    [self.navigationController presentViewController:picker animated:YES completion:nil];
//
//    return;
    //
    [tbPass.tf resignFirstResponder];
    [tbUsername.tf resignFirstResponder];
    //
    NSString *username = tbUsername.tf.text;
    NSString *password = tbPass.tf.text;
    //
    username = [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    password = [password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (username && username.length == 0) {
        [Utils showToastHUDInView:self.node.view withMessage:@"Bạn chưa nhập tên đăng nhập!"];
        return;
    }
    if (password && password.length == 0) {
        [Utils showToastHUDInView:self.node.view withMessage:@"Bạn chưa nhập mật khẩu!"];
        return;
    }
    //
    [Utils showLoadingHUDInView:self.view];
    NSDictionary *params = @{@"username" : username,
                             @"password" : password};
    [[HTTPNetworkControl instance] requestPOST:[HTTPNetworkControl instance].URL_LOGIN params:params success:^(NSURLSessionDataTask *task, id responseObj) {
        
        [Utils hideLoadingHUDInView:self.view];
        
        NSDictionary *response = responseObj;
        NSNumber *status = response[@"status"];
        
        if (status && status.intValue == 200) {
            //
            [Manager instance].myUser = [UserData new];
            NSString *token = response[@"token"];
            NSString *userType = response[@"user_type"];
            NSNumber *userId = response[@"userId"];
            //
            [Manager instance].myUser.username = username;
            [Manager instance].myUser.token = token;
            [Manager instance].myUser.userType = userType;
            [Manager instance].myUser.userId = userId.intValue;
            if ([userType isEqualToString:@"Experts"]) {
                [[FIRMessaging messaging] subscribeToTopic:@"experts"];
            }
            else {
                [[FIRMessaging messaging] unsubscribeFromTopic:@"experts"];
            }
            //
            ChatController *controller = [[ChatController alloc] init];
            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
            nav.whiteStatusBar = NO;
            nav.navigationBar.hidden = YES;
            [self presentViewController:nav animated:YES completion: nil];
            //
            [GVUserDefaults standardUserDefaults].username = username;
            [GVUserDefaults standardUserDefaults].password = password;
            [GVUserDefaults standardUserDefaults].jsonLogin = [Utils convertJsonObjectToString:response];
            //
        }
        else {
            NSString *error = response[@"error"];
            if (error && error.length > 0) {} else {error = @"Có lỗi xảy ra!";}
            [Utils showToastHUDInView:self.view withMessage: error];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [Utils hideLoadingHUDInView:self.view];
        [Utils showToastHUDInView:self.view withMessage:@"Có lỗi xảy ra!"];
        
    }];
    //
}
// Keyboard show/hide
- (void)keyboardDidShow: (NSNotification *) notif {
    
    CGFloat duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0 options:curve animations:^{
        keyboardHi = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        [self calculateFrame];
    } completion:nil];
}

- (void)keyboardDidHide: (NSNotification *) notif {
    keyboardHi = 0.0;
    [self calculateFrame];
}
// UITextfield Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
