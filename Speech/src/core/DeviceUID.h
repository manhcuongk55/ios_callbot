//
//  DeviceUID.h
//  sources
//
//  Created by Phu on 5/19/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceUID : NSObject

+ (NSString *)uid;

+ (OSStatus)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service;

+ (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service;

@end
