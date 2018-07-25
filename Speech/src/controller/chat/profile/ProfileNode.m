//
//  ProfileNode.m
//  Speech
//
//  Created by Phu on 5/16/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "ProfileNode.h"
#import "Manager.h"
#import "MenuProfileCell.h"
#import "LoginController.h"
#import "BaseNavigationController.h"
#import "DatabaseControl.h"

@import Firebase;

@interface ProfileNode () <ASTableDelegate, ASTableDataSource>{
    ASDisplayNode *bg;
    ASDisplayNode *content;
    ASImageNode *img;
    ASTextNode *name;
    ASTableNode *table;
    ASButtonNode *editBtn;
    float wiContent;
    NSArray *tableDatas;
}

@end

@implementation ProfileNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        wiContent = 276.0;
        bg = [ASDisplayNode new];
        [self addSubnode:bg];
        bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        content = [ASDisplayNode new];
        content.backgroundColor = [UIColor whiteColor];
        [self addSubnode:content];
        
        img = [ASImageNode new];
        img.image = [UIImage imageNamed:@"bg_avatar"];
        [content addSubnode:img];
        
        name = [ASTextNode new];
        name.attributedText = [[NSAttributedString alloc] initWithString: [Manager instance].myUser.username attributes:[self nameStyle]];
        [content addSubnode:name];
        
        NSString *userType = @"Người dùng";
        if ([[Manager instance].myUser.userType isEqualToString:@"Experts"]) {
            userType = @"Chuyên gia";
        }
        tableDatas = @[//@{@"title" : @"Status", @"des": @"Viettel Assistant"},
                       @{@"title" : @"Tài khoản", @"des": userType},
                       @{@"title" : @"Đăng xuất", @"des": @"Xóa lịch sử"}];
        table = [ASTableNode new];
        table.view.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.delegate = self;
        table.dataSource = self;
        [content addSubnode:table];
        
        editBtn = [ASButtonNode new];
        [editBtn setImage:[Utils image:[UIImage imageNamed:@"edit_profile_btn"] size:CGSizeMake(70, 70)] forState:ASControlStateNormal];
        [content addSubnode:editBtn];
        
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self.view addGestureRecognizer:gesture];
        
        UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [bg.view addGestureRecognizer:gesture2];
        self.hidden = YES;
    }
    return self;
}
- (NSDictionary *)nameStyle {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}
- (void) setShow: (BOOL) animated {
    bg.alpha = 0.0f;
    content.frame = CGRectMake(self.bounds.size.width, 0, wiContent, self.bounds.size.height);
    self.hidden = NO;
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
            bg.alpha = 1.0f;
            content.frame = CGRectMake(self.bounds.size.width - wiContent, 0, wiContent, self.bounds.size.height);
        } completion:nil];
    }
}
- (void) handlePanGesture: (UIPanGestureRecognizer *) gesture {
    CGPoint t = [gesture translationInView:gesture.view];
    [gesture setTranslation:CGPointZero inView:gesture.view];
    CGRect rect = content.frame;
    rect.origin.x += t.x;
    float xMin = self.bounds.size.width - wiContent;
    if (rect.origin.x < xMin) {
        rect.origin.x = xMin;
    }
    content.frame = rect;
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (content.frame.origin.x > xMin + 20) {
            [self closeProfile];
        }
    }
}
- (void) handleTapGesture: (UITapGestureRecognizer *) gesture {
    CGPoint t = [gesture locationInView:gesture.view];
    float xMin = self.bounds.size.width - wiContent;
    if (t.x < xMin) {
        [self closeProfile];
    }
}
- (void) closeProfile {
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        content.frame = CGRectMake(self.bounds.size.width, 0, wiContent, self.bounds.size.height);
        bg.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSupernode];
        [[Manager instance].currentChatVC setNeedsStatusBarAppearanceUpdate];
    }];
}
- (void) layout {
    [super layout];
    bg.frame = self.bounds;
    content.frame = CGRectMake(self.bounds.size.width - wiContent, 0, wiContent, self.bounds.size.height);
    img.frame = CGRectMake(0, 0, wiContent, 150);
    CGSize size = [name calculateSizeThatFits:CGSizeMake(wiContent - 20 - 15, MAXFLOAT)];
    name.frame = CGRectMake(20, img.frame.origin.y + img.frame.size.height - 15 - size.height, size.width, size.height);
    editBtn.frame = CGRectMake(img.frame.origin.x + img.frame.size.width - 15 - 70, img.frame.origin.y + img.frame.size.height - 30, 70, 70);
    float yT = editBtn.frame.origin.y + editBtn.frame.size.height;
    table.frame = CGRectMake(0, yT, wiContent, self.bounds.size.height - yT - [Utils instance].edgeInsets.bottom);
}
#pragma mark - table delegate & datasource
- (void)tableNode:(ASTableNode *)tableNode_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableNode_ deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 1) {
        
        UIAlertController * alert=[UIAlertController
                                   
                                   alertControllerWithTitle:@"Đăng xuất" message:@"Bạn có muốn đăng xuất và xoá dữ liệu?"preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        NSString *username = [GVUserDefaults standardUserDefaults].username;
                                        if (username && username.length > 0) {
                                            //
                                            [Manager instance].myUser.username = @"";
                                            [GVUserDefaults standardUserDefaults].username = @"";
                                            [GVUserDefaults standardUserDefaults].password = @"";
                                            [GVUserDefaults standardUserDefaults].jsonLogin = @"";
                                            [GVUserDefaults standardUserDefaults].sendTokenFirebaseSuccess = @"";
                                            [[Manager instance] stopTimerSendFirebaseToken];
                                            [[FIRMessaging messaging] unsubscribeFromTopic:@"experts"];
                                            //
                                            [[Manager instance].notificationVC cleanData];
                                            //
                                            LoginController *controller = [[LoginController alloc] init];
                                            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
                                            [[DatabaseControl instance] deleteAllMessage];
                                            nav.whiteStatusBar = YES;
                                            nav.navigationBar.hidden = YES;
                                            [[Utils instance].weakWindow setRootViewController: nav];
                                            [Manager instance].notificationVC = nil;
                                        }
                                    }];
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Hủy"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                   }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [[Manager instance].currentChatVC presentViewController:alert animated:YES completion:nil];
    }
}

- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(wiContent, 64));
}

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return 1;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return tableDatas.count;
}
- (ASCellNode *)tableNode:(ASTableNode *)tableNode nodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuProfileCell *cell = [[MenuProfileCell alloc] initWithData:tableDatas[indexPath.row]];
    return cell;
}
- (void) tableNode:(ASTableNode *)tableNode_ willDisplayRowWithNode:(ASCellNode *)node {
}
@end
