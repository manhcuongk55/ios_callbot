//
//  AppDelegate.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "LoginController.h"
#import "Utils.h"
#import "HTTPNetworkControl.h"
#import "Speech-Swift.h"
#import "DatabaseControl.h"
#import "GVUserDefaults+Properties.h"
#import "Manager.h"
#import "TtsVTCCControl.h"
#import "TtsStreamingVTCCControl.h"

@import Firebase;
@import UserNotifications;

@interface AppDelegate () <UNUserNotificationCenterDelegate> {
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[Utils instance] getScreenInfo:self.window];
    [[DatabaseControl instance] setUp];
    [[Manager instance] loadJsonAnswerIdNotifi];
    //
    //[[TtsVTCCControl instance] vocalize: @"Chiếc đồng hồ thông minh Mi Band 3"];
    // -----------------------------------------------------------------------------------------
    [FIRApp configure];
    
    if ([UNUserNotificationCenter class] != nil) {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
             // ...
         }];
    } else {
        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    [application registerForRemoteNotifications];
    // -----------------------------------------------------------------------------------------
    NSString *username = [GVUserDefaults standardUserDefaults].username;
    if (username && username.length > 0) {
        [Manager instance].myUser = [UserData new];
        [Manager instance].myUser.username = username;
        //
        NSDictionary *response = [Utils convertStringToJsonObject: [GVUserDefaults standardUserDefaults].jsonLogin];
        NSString *token = response[@"token"];
        NSString *userType = response[@"user_type"];
        NSNumber *userId = response[@"userId"];
        //
        [Manager instance].myUser.token = token;
        [Manager instance].myUser.userType = userType;
        [Manager instance].myUser.userId = userId.intValue;
        //
        ChatController *controller = [[ChatController alloc] init];
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
        nav.whiteStatusBar = NO;
        nav.navigationBar.hidden = YES;
        [self.window setRootViewController:nav];
        //
    }
    else {
        //
        LoginController *controller = [[LoginController alloc] init];
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
        nav.whiteStatusBar = YES;
        nav.navigationBar.hidden = YES;
        [self.window setRootViewController:nav];
    }
    //NSLog(@"token fcm %@", [FIRInstanceID instanceID].token);
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.    
    [[Manager instance] sendFirebaseToken];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[TTSVocalizer sharedInstance] vocalize: @""];
    });
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// -----------------------------------------------------------------------------------------

NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    // Print full message.
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    [[Manager instance].notificationVC refreshData];
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionAlert);
}
// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Did tapped Message ID: %@", userInfo[kGCMMessageIDKey]);
        [[Manager instance].listTappedNotifications addObject:userInfo];
        [[Manager instance].currentChatVC processTappedNoti];
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    completionHandler();
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
}

- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
}
@end
