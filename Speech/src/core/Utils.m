//
//  Utils.m
//  sources
//
//  Created by Phu on 1/24/17.
//
//

#import "Utils.h"
#import "../../library/mbprogresshud/MBProgressHUD.h"
#import "DeviceUID.h"
#import <sys/utsname.h>
#import "../../library/asyncdisplaykit/AsyncDisplayKit.h"
#import "Constants.h"

@implementation Utils

static Utils *inst = nil;

+ (Utils*) instance {
    @synchronized(self) {
        if (inst == nil)
            inst = [[self alloc] init];
    }
    return inst;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.iosVersionInt = - 1;
    }
    return self;
}
- (void) getScreenInfo: (UIWindow *) window {
    self.weakWindow = window;
    [self updateScreenInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScreenInfo:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) updateScreenInfo: (NSNotification *) notify {
    // -------- Xcode 9.2
    if (self.iosVersionInt == -1) {
        self.iosVersionInt = [Utils getIntSystemVersion];
    }
    if (self.iosVersionInt >= 11) {
        self.edgeInsets = self.weakWindow.safeAreaInsets;
    }
    else {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    self.isPhoneX = self.edgeInsets.top > 0 || self.edgeInsets.left > 0 || self.edgeInsets.bottom > 0 || self.edgeInsets.right > 0;
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (UIAlertController *) showSystemUIAlertView: (NSString *) title withMessage: (NSString *) message handlerOk:(void (^)(UIAlertAction *action))handler inController:(UIViewController *)controller {
    
    UIAlertController * alert =  [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: handler];
    [alert addAction:okAction];
    
    [controller presentViewController:alert animated:YES completion:nil];
    
    return alert;
}

+ (UIAlertController*) showSystemUIAlertView: (NSString *) title withMessage: (NSString *) message handlerOk:(void (^)(UIAlertAction *action))handlerOk handlerCancel:(void (^)(UIAlertAction *action))handlerCancel inController:(UIViewController *)controller {
    
    UIAlertController * alert =  [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler: handlerCancel];
    [alert addAction:cancelAction];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: handlerOk];
    [alert addAction:okAction];
    
    [controller presentViewController:alert animated:YES completion:nil];
    
    return alert;
}

+ (UIViewController *) getRootViewController {
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    return vc;
}

+ (void) showLoadingHUDInView:(UIView *)view {
    if (!view) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:view animated:YES];    
}

+ (void) showLoadingHUDInView: (UIView *) view withTitle: (NSString *) title {
    if (!view) {
        return;
    }
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hub.label.text = title;
}

+ (void) hideLoadingHUDInView:(UIView *)view {
    if (!view) {
        return;
    }
    [MBProgressHUD hideHUDForView:view animated:NO];
}

+ (void) showToastHUDInView:(UIView *)view withMessage:(NSString *)message {
    if (!view) {
        return;
    }
    [Utils showToastHUDInView:view withMessage:message withOffset:0];
}

+ (void) showToastHUDInView: (UIView *) view withMessage: (NSString *) message withOffset:(float)yOffset {
    if (!view) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.opaque = YES;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"";
    hud.detailsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    hud.detailsLabel.text = message;
    hud.margin = 15.f;
    hud.yOffset = yOffset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:NO afterDelay:2.0];
}

+ (float) getStatusBarHeight {
    return 20;
}

+ (float) getNavBarHeight {
    return 44;
}

+ (float) scrWi {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (float) scrHi {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (NSString *) convertJsonObjectToString:(NSDictionary *)jsonObj {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
+ (NSDictionary *) convertStringToJsonObject:(NSString *)string {
    NSError *error;
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    return json;

}

+ (UIImage *) image:(UIImage *)source color:(UIColor *)color {
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}
+ (NSString *) md5:(NSString *)input {
    const char * pointer = [input UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return string;
}
+ (UIColor *) randomColor: (NSString *) inputString {
    return [self randomColor];
}

+ (UIColor *)randomColor {
    
    srand48(arc4random());
    
    float red = 0.0;
    while (red < 0.1 || red > 0.84) {
        red = drand48();
    }
    
    float green = 0.0;
    while (green < 0.1 || green > 0.84) {
        green = drand48();
    }
    
    float blue = 0.0;
    while (blue < 0.1 || blue > 0.84) {
        blue = drand48();
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}
+ (BOOL) isPortraitScreen: (BOOL) defaulValue {
    UIDevice *device = [UIDevice currentDevice];
    UIDeviceOrientation currentOrientation = device.orientation;
    
    if (currentOrientation == UIDeviceOrientationPortrait) {
        return YES;
    }
    else if (currentOrientation == UIDeviceOrientationPortraitUpsideDown) {
        return YES;
    }
    else if (currentOrientation == UIDeviceOrientationLandscapeLeft) {
        return NO;
    }
    else if (currentOrientation == UIDeviceOrientationLandscapeRight) {
        return NO;
    }
    else {
        return defaulValue;
    }
}
+ (UIImage *) image:(UIImage *)img size:(CGSize)size {
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [img drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
    
+ (UIImage *) roundedImage:(UIImage *)image withSize:(CGSize)size withRadius:(float)radius {
    
    float scale = [UIScreen mainScreen].scale;
    float wiRow = size.width*scale;
    float hiRow = size.width * (image.size.height/image.size.width)*scale;
    
    if (hiRow > size.height*scale) {
        hiRow = size.height*scale;
        wiRow = size.height * (image.size.width/image.size.height)*scale;
    }
    radius *= scale;
    CGSize sizeImg = CGSizeMake(wiRow, hiRow);
    CGRect bounds = CGRectMake(0, 0, wiRow, hiRow);
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(sizeImg, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius: radius] addClip];
    // Draw your image
    [image drawInRect:bounds];
    
    // Get the image, here setting the UIImageView image
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return img;
}
+ (BOOL) IsIPadIdiom {
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    // ThirdPartyAppAPI
    return idiom == UIUserInterfaceIdiomPad;
}
+ (NSString *) getIdentifierForVendor {
    NSString *str = [DeviceUID uid];//[[UIDevice currentDevice] identifierForVendor].UUIDString;
    return str;
}
+ (NSString *) getDeviceName {
    NSString *str = [[UIDevice currentDevice] name];
    return str;
}
+ (NSString *) getDeviceModel {
    NSString *str = [[UIDevice currentDevice] model];
    return str;
}
+ (NSString *) getDetailModel {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    return code;
}
+ (NSString *) getSystemName {
    NSString *str = [[UIDevice currentDevice] systemName];
    return str;
}
+ (NSString *) getSystemVersion {
    NSString *str = [[UIDevice currentDevice] systemVersion];
    return str;
}
+ (int) getIntSystemVersion {
    NSString *str = [[UIDevice currentDevice] systemVersion];
    NSArray *childs = [str componentsSeparatedByString:@"."];
    if (childs && childs.count > 0) {
        NSString *firstChild = childs[0];
        return firstChild.intValue;
    }
    return 9;
}
+ (BOOL) isSameDay: (NSDate *) date1 andDate2: (NSDate *) date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate: date1];
    NSDateComponents *date2Components = [calendar components:comps
                                                    fromDate: date2];
    date1 = [calendar dateFromComponents:date1Components];
    date2 = [calendar dateFromComponents:date2Components];
    
    NSComparisonResult result = [date1 compare:date2];
    if (result == NSOrderedAscending) {
    } else if (result == NSOrderedDescending) {
    }  else {
        return YES;
    }
    return NO;
}
+ (BOOL) isIphone4 {
    if ([Utils scrHi] == 320 || [Utils scrWi] == 320) {
        return YES;
    }
    return NO;
}
+ (NSString *) getDateStr: (NSDate *) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm - dd/MM/yyyy"];
    
    return [formatter stringFromDate:date];
}
+ (BOOL) animationFadeImage: (UIImageView *) weakImg withError: (NSError *) error withTypeCache:(SDImageCacheType) cacheType {
    return NO;
}
+ (NSString *) getStringFromByte: (long long) byteCount {
    double bytes = byteCount;
    double kb = bytes/1024.0;
    double mb = kb/1024.0;
    double gb = mb/1024.0;
    double tb = gb/1024.0;
    if (kb>1.0) {
        if (mb > 1.0) {
            if (gb > 1.0) {
                if (tb > 1.0) {
                    return [NSString stringWithFormat:@"%.2f TB", tb];
                }
                else {
                    return [NSString stringWithFormat:@"%.2f GB", gb];
                }
            }
            else {
                return [NSString stringWithFormat:@"%.2f MB", mb];
            }
        }
        else {
            return [NSString stringWithFormat:@"%.2f KB", kb];
        }
    }
    else {
        return [NSString stringWithFormat:@"%.2f Bytes", bytes];
    }
}
+ (float) getCurrentYEndContent: (UIScrollView *) scrollView {
    float yCurrent = -1;
    if (scrollView.bounds.size.height > 0) {
        yCurrent = scrollView.contentOffset.y + scrollView.bounds.size.height;
        float yMax = scrollView.contentSize.height + scrollView.contentInset.bottom;
        if (yCurrent > yMax) {
            yCurrent = yMax;
        }
        if (yCurrent < 0) {
            yCurrent = 0;
        }
    }
    return yCurrent;
}
+ (void) scrollToYEndContent: (float) yEnd scrollView: (UIScrollView *) scrollView {
    if (yEnd > 0) {
        float yNew = yEnd - scrollView.bounds.size.height;
        float yMax = scrollView.contentSize.height + scrollView.contentInset.bottom;
        if (yNew + scrollView.bounds.size.height > yMax) {
            yNew = yMax - scrollView.bounds.size.height;
        }
        if (yNew < 0) {
            yNew = 0;
        }
        [scrollView setContentOffset:CGPointMake(0, yNew) animated:NO];
    }
}
@end
