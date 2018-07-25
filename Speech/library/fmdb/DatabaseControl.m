//
//  DatabaseControl.m
//  sources
//
//  Created by Phu on 1/23/17.
//
//

#import "DatabaseControl.h"
#import "../filemanager/FileControl.h"
#import "Utils.h"
@interface DatabaseControl () {
    int dbVersion;
}
@end

@implementation DatabaseControl

static DatabaseControl *inst = nil;

+ (DatabaseControl*)instance {
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
    }
    return self;
}

- (void) setUp {
    NSString *dirToSaveDB = [[FileControl instance] genDirForFileInDocumentDir:@"database.db"];
    if ([[FileControl instance] checkFileExist:dirToSaveDB]) {
    }
    else {
        [[FileControl instance] copyFileInMainBundle:@"database.db" toDir:dirToSaveDB];
    }
    [[DatabaseControl instance] initWithDBFilePath:dirToSaveDB];
    [[DatabaseControl instance] openDB];
    [self checkUpdateDB];
}

- (void) initWithDBFilePath:(NSString *)dbFile {
    _fmdb = [FMDatabase databaseWithPath:dbFile];
}

- (void) openDB {
    if (![_fmdb open]) {
        _fmdb = nil;
    }
    else {
    }
}

- (void) checkUpdateDB {
    FMResultSet *s = [_fmdb executeQuery: @"SELECT * FROM DB_INFO"];
    if ([s next]) {
        dbVersion = [s intForColumnIndex:1];
        if (dbVersion == 1) {
            BOOL isSuccess;
            isSuccess = [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS \"MESSAGES\" ( \"ID\" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, \"local_id\" INTEGER NOT NULL UNIQUE, \"timestamp\" INTEGER, \"server_id\" TEXT, \"from_me\" INTEGER DEFAULT 0, \"data\" TEXT );"];
            isSuccess = [_fmdb executeUpdate:@"CREATE INDEX if not exists \"MESSAGES_INDEX\" on \"MESSAGES\" (\"local_id\");"];
            [_fmdb executeUpdate:@"UPDATE \"DB_INFO\" SET \"DB_VERSION\" = 2 WHERE \"ID\" = 1"];
            dbVersion = 2;
        }
        if (dbVersion == 2) {
            BOOL isSuccess;
            isSuccess = [_fmdb executeUpdate:@"ALTER TABLE MESSAGES ADD COLUMN rate_message INTEGER DEFAULT 0"];
            [_fmdb executeUpdate:@"UPDATE \"DB_INFO\" SET \"DB_VERSION\" = 3 WHERE \"ID\" = 1"];
            dbVersion = 3;
        }
        if (dbVersion == 3) {
            BOOL isSuccess;
            isSuccess = [_fmdb executeUpdate:@"ALTER TABLE MESSAGES ADD COLUMN send_expert INTEGER DEFAULT 0"];
            [_fmdb executeUpdate:@"UPDATE \"DB_INFO\" SET \"DB_VERSION\" = 4 WHERE \"ID\" = 1"];
            dbVersion = 4;
        }
    }
}
- (void) closeDB {
    if (_fmdb) {
        [_fmdb close];
        _fmdb = nil;
    }
}

- (void)dealloc
{
    [self closeDB];
}
- (void) saveMessage: (MessageData *) msgData {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"dbVersion"] = @(dbVersion);
    dic[@"type"] = @(msgData.type);
    if (msgData.fromMe) {
        dic[@"content"] = msgData.textMsg;
    }
    else {
        if (msgData.type == MessageTypeAnswerNotification) {
            dic[@"content"] = msgData.jsonNotification;
        }
        else if (msgData.type == MessageTypePhoto || msgData.type == MessageTypeWeather || msgData.type == MessageTypeMusic || msgData.type == MessageTypeWebView ) {
            dic[@"content"] = msgData.jsonResponse;
        }
        else if (msgData.type == MessageTypeText) {
            if (msgData.jsonResponse) {
                dic[@"content"] = msgData.jsonResponse;
            }
            else {
                dic[@"content"] = @{@"app_alert": @1, @"message": msgData.textMsg};
            }
        }
    }
    [_fmdb executeUpdate: @"INSERT INTO MESSAGES (local_id, timestamp, server_id, from_me, data) VALUES (?,?,?,?,?)",
     @(msgData.localId),
     @(msgData.timestamp),
     msgData.msgId,
     msgData.fromMe?@1:@0,
     [Utils convertJsonObjectToString:dic]
     ];
}
- (NSMutableArray *) getMessagesHistory: (long long) lastMsgId {
    NSMutableArray *list = [NSMutableArray new];
    FMResultSet *s;
    if (lastMsgId == -1) {
        s = [_fmdb executeQuery:@"SELECT * FROM MESSAGES ORDER BY local_id DESC LIMIT 20"];
    }
    else {
        s = [_fmdb executeQuery:@"SELECT * FROM MESSAGES WHERE local_id < ? ORDER BY local_id DESC LIMIT 20", @(lastMsgId)];
    }
    while ([s next]) {
        long long local_id = [s longLongIntForColumnIndex: 1];
        long long timestamp = [s longLongIntForColumnIndex: 2];
        NSString *server_id = [s stringForColumnIndex: 3];
        int from_me = [s intForColumnIndex: 4];
        NSString *data = [s stringForColumnIndex: 5];
        
        MessageData *msg = [[MessageData alloc] init];
        msg.localId = local_id;
        msg.timestamp = timestamp;
        msg.msgId = server_id;
        msg.fromMe = from_me == 1;
        msg.rateMessage = [s intForColumnIndex: 6];
        msg.sendExpertState = [s intForColumnIndex: 7];
        NSDictionary *dic = [Utils convertStringToJsonObject:data];
        NSNumber *type = dic[@"type"];
        
        if (msg.fromMe) {
            msg.type = MessageTypeText;
            msg.textMsg = dic[@"content"];
        }
        else {
            NSDictionary *dicContent = dic[@"content"];
            if (type.intValue == 3) {
                msg.type = MessageTypeAnswerNotification;
                msg.jsonNotification = dicContent;
                msg.msgId = dicContent[@"answerId"];
            }
            else if (type.intValue == MessageTypePhoto || type.intValue == MessageTypeWeather || type.intValue == MessageTypeMusic || type.intValue == MessageTypeWebView ) {
                msg.type = type.intValue;
                msg.jsonResponse = dicContent;
                [MessageData readDataAnswerV1:msg.jsonResponse forMsg:msg];
            }
            else if (type.intValue == 1) {
                msg.type = MessageTypeText;
                NSNumber *isAppAlert = dicContent[@"app_alert"];
                if (isAppAlert && isAppAlert.intValue == 1) {
                    msg.textMsg = dicContent[@"message"];
                }
                else {
                    [MessageData readDataAnswerV1:dicContent forMsg:msg];
                }
            }
        }
        [list addObject:msg];
    }
    return list;
}
- (void) updateRateMsg: (MessageData *) msgData {
    [_fmdb executeUpdate: @"UPDATE MESSAGES SET rate_message = ? WHERE local_id = ?",
     @(msgData.rateMessage),
     @(msgData.localId)
     ];
}
- (void) updateSendExpert: (MessageData *) msgData {
    [_fmdb executeUpdate: @"UPDATE MESSAGES SET send_expert = ? WHERE local_id = ?",
     @(msgData.sendExpertState),
     @(msgData.localId)
     ];
}
- (void) deleteAllMessage {
    [_fmdb executeUpdate:@"DELETE FROM MESSAGES"];
}
@end
