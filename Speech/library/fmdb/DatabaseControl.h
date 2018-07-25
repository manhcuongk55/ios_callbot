//
//  DatabaseControl.h
//  sources
//
//  Created by Phu on 1/23/17.
//
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "MessageData.h"

@interface DatabaseControl : NSObject

+ (DatabaseControl*)instance;

@property (nonatomic, strong) FMDatabase *fmdb;

- (void) setUp;

- (void) openDB;

- (void) closeDB;

- (void) saveMessage: (MessageData *) msgData;
- (NSMutableArray *) getMessagesHistory: (long long) lastMsgId;
- (void) updateRateMsg: (MessageData *) msgData;
- (void) updateSendExpert: (MessageData *) msgData;
- (void) deleteAllMessage;
@end
