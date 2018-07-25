//
//  NetworkUtils.m
//  sources
//
//  Created by Phu on 3/8/17.
//
//

#import "NetworkUtils.h"
@interface NetworkUtils() {
    int stateNetwork;
    BOOL isSkipFirst;
}

@end

@implementation NetworkUtils

static NetworkUtils *inst = nil;

+ (NetworkUtils*)instance {
    @synchronized(self) {
        if (inst == nil)
            inst = [[self alloc] init];
    }
    return inst;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        isSkipFirst = YES;
        stateNetwork = -1;
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            int prevStateNetwork = stateNetwork;
            
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    // -- Reachable -- //
                    stateNetwork = 2;
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    stateNetwork = 1;
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    // -- Not reachable -- //
                    stateNetwork = 0;
                    break;
            }
        }];
    }
    return self;
}
- (void) dealloc {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (BOOL) is3GConnection {
    return stateNetwork == 1;
}
- (BOOL) isNetworkAvailable {
    return stateNetwork >= 1;
}
- (BOOL) isWifiConnection {
    return stateNetwork == 2;
}
@end
