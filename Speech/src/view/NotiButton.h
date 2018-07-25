//
//  NotiButton.h
//  Speech
//
//  Created by Phu on 5/18/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"

@interface NotiButton : ASButtonNode
- (void) addRedNode: (CGPoint) offset;
- (void) showRedNode: (BOOL) show;
@end
