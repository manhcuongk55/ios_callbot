//
//  HTTPNetworkControl.m
//  sources
//
//  Created by Phu on 1/23/17.
//
//
#import <Foundation/Foundation.h>
#import "HTTPNetworkControl.h"
#import "../gvuserdefaults/GVUserDefaults+Properties.h"

@interface HTTPNetworkControl () {
    AFHTTPSessionManager *manager;
}
@end

@implementation HTTPNetworkControl

static HTTPNetworkControl *inst = nil;

+ (HTTPNetworkControl*)instance {
    @synchronized(self) {
        if (inst == nil) {
            inst = [[self alloc] init];
        }
    }
    return inst;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initNetworking];
    }
    return self;
}
- (NSString *) getBaseUrl {
    return @"http://203.113.130.136:9696/";
}
- (NSString *) getBaseUrlMedia {
    return @"";
}
- (NSString *) getBaseUrlTest {
    return @"";
}
- (void) setupAllUrl {
    self.URL_LOGIN = @"va/login";
    self.URL_SEND_MESSAGE = @"va/send-message";
    self.URL_GET_ANSWER = @"va/get-answer";
    self.URL_RATE_ANSWER = @"va/rate-message";
    self.URL_SEND_EXPERT = @"va/consult-experts";
    self.URL_GET_NOTIFI_QUESTIONS = @"va/get-experts-question";
    self.URL_PUSH_ANSWER = @"va/put-experts-answer";
    self.URL_GET_NOTIFI_ANSWERS = @"va/get-experts-answer";
    self.URL_PUSH_FIRE_BASE_TOKEN = @"va/put-firebase-token";
    self.URL_TEXT_TO_SPEECH_API = @"http://10.30.154.10/tts-hmm/syn";
}
- (void) initNetworking {
    [self setupAllUrl];
    manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self getBaseUrl]] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:5.0];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/json"];
}

- (void) requestGET: (NSString *) url params: (NSDictionary *) params success:(void (^)(NSURLSessionDataTask * task, id responseObj))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure {
}

- (void) requestPOST: (NSString *) url params: (NSDictionary *) params success:(void (^)(NSURLSessionDataTask * task, id responseObj))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure {
    [manager POST:url parameters:params progress: nil success: success failure: failure];
}

- (void) downloadFileFromUrl: (NSString *) url toLocalFileName: (NSString *) localFileName completionHandler: (void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {

    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSFileManager *fmngr = [[NSFileManager alloc] init];

        NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:localFileName];
        
        if (![fmngr fileExistsAtPath:[documentsDirectoryURL path]]) {
        }
        else {
            [fmngr removeItemAtPath:[documentsDirectoryURL path] error:nil];
        }
        
        return documentsDirectoryURL;
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completionHandler(response, filePath, error);
    }];
    [downloadTask resume];
}
- (AFHTTPSessionManager*) getManager {
    return manager;
}
@end
