//
//  HTTPNetworkControl.h
//  sources
//
//  Created by Phu on 1/23/17.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFURLSessionManager.h"

@interface HTTPNetworkControl : NSObject

@property (nonatomic, strong) NSString *URL_LOGIN;

@property (nonatomic, strong) NSString *URL_SEND_MESSAGE;

@property (nonatomic, strong) NSString *URL_GET_ANSWER;

@property (nonatomic, strong) NSString *URL_RATE_ANSWER;

@property (nonatomic, strong) NSString *URL_SEND_EXPERT;

@property (nonatomic, strong) NSString *URL_GET_NOTIFI_QUESTIONS;

@property (nonatomic, strong) NSString *URL_PUSH_ANSWER;

@property (nonatomic, strong) NSString *URL_GET_NOTIFI_ANSWERS;

@property (nonatomic, strong) NSString *URL_PUSH_FIRE_BASE_TOKEN;

@property (nonatomic, strong) NSString *URL_TEXT_TO_SPEECH_API;

+ (HTTPNetworkControl*)instance;

- (void) requestGET: (NSString *) url params: (NSDictionary *) params success:(void (^)(NSURLSessionDataTask * task, id responseObj))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

- (void) requestPOST: (NSString *) url params: (NSDictionary *) params success:(void (^)(NSURLSessionDataTask * task, id responseObj))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

- (void) downloadFileFromUrl: (NSString *) url toLocalFileName: (NSString *) localFileName completionHandler: (void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

- (void) setupAllUrl;

- (AFHTTPSessionManager*) getManager;

@end
