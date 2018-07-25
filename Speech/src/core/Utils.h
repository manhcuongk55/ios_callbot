//
//  Utils.h
//  sources
//
//  Created by Phu on 1/24/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "../../library/sdwebimage/SDWebImage.h"

typedef struct
{
    double h;       // angle in degrees [0 - 360]
    double s;       // percent [0 - 1]
    double v;       // percent [0 - 1]
} HSV;

@interface Utils : NSObject

+ (Utils*) instance;

@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, weak) UIWindow *weakWindow;
@property (nonatomic, assign) BOOL isPhoneX;
@property (nonatomic, assign) int iosVersionInt;

- (void) getScreenInfo: (UIWindow *) window;
- (void) updateScreenInfo: (NSNotification *) notify;

+ (UIAlertController *) showSystemUIAlertView: (NSString *) title withMessage: (NSString *) message handlerOk:(void (^)(UIAlertAction *action))handler inController: (UIViewController *) controller;

+ (UIAlertController *) showSystemUIAlertView: (NSString *) title withMessage: (NSString *) message handlerOk:(void (^)(UIAlertAction *action))handlerOk handlerCancel:(void (^)(UIAlertAction *action))handlerCancel inController: (UIViewController *) controller;

+ (UIViewController *) getRootViewController;

+ (void) showLoadingHUDInView: (UIView *) view withTitle: (NSString *) title;

+ (void) showLoadingHUDInView: (UIView *) view;

+ (void) hideLoadingHUDInView: (UIView *) view;

+ (void) showToastHUDInView: (UIView *) view withMessage: (NSString *) message;

+ (void) showToastHUDInView: (UIView *) view withMessage: (NSString *) message withOffset: (float) yOffset;

+ (float) getStatusBarHeight;

+ (float) getNavBarHeight;

+ (float) scrWi;

+ (float) scrHi;

+ (NSString *) convertJsonObjectToString: (NSDictionary *) jsonObj;

+ (NSDictionary *) convertStringToJsonObject: (NSString *) string;

+ (UIImage*) image: (UIImage *) img color: (UIColor *) color;

+ (NSString *) md5: (NSString *) md5;

+ (UIColor *)randomColor;

+ (UIColor *) randomColor: (NSString *) inputString;

+ (BOOL) isPortraitScreen: (BOOL) defaulValue;

+ (UIImage *) image:(UIImage *)img size:(CGSize) size;

+ (UIImage *) roundedImage: (UIImage *) img withSize: (CGSize) size withRadius: (float) radius;
+ (BOOL) IsIPadIdiom;
+ (NSString *) getIdentifierForVendor;
+ (NSString *) getDeviceName;
+ (NSString *) getDeviceModel;
+ (NSString *) getSystemName;
+ (NSString *) getSystemVersion;
+ (NSString *) getDetailModel;
+ (int) getIntSystemVersion;
+ (BOOL) isSameDay: (NSDate *) date1 andDate2: (NSDate *) date2;
+ (BOOL) isIphone4;
+ (NSString *) getDateStr: (NSDate *) date;
+ (BOOL) animationFadeImage: (UIImageView *) img withError: (NSError *) error withTypeCache:(SDImageCacheType) type;
+ (NSString *) getStringFromByte: (long long) byteCount;
+ (float) getCurrentYEndContent: (UIScrollView *) scrollView;
+ (void) scrollToYEndContent: (float) yEnd scrollView: (UIScrollView *) scrollView;
@end
