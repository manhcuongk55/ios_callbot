//
//  NetworkUtils.h
//  sources
//
//  Created by Phu on 3/8/17.
//
//

#import <Foundation/Foundation.h>
#import "../../library/afnetworking/AFNetworkReachabilityManager.h"

@interface NetworkUtils : NSObject

+ (NetworkUtils*) instance;

- (BOOL) isNetworkAvailable;
- (BOOL) is3GConnection;
- (BOOL) isWifiConnection;

@end
