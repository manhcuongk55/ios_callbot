//
//  ChatBox.h
//  Speech
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"

@protocol ChatBoxDelegate <NSObject>

- (void) didSendTextMsg: (NSString *) text;

- (void) updateFrameChatBox;

@end

@interface ChatBox : ASDisplayNode

- (void) resignChatBox;

@property (nonatomic, weak) id<ChatBoxDelegate> delegate;

@property (nonatomic, assign) float hiContent;

- (void) updateTranscript: (NSString *) transcript;

@end
