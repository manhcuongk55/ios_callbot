//
//  InputAnswerView.h
//  Speech
//
//  Created by Phu on 5/17/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"

@interface InputAnswerView : ASDisplayNode

- (void) setShow: (BOOL) animated;
- (void) updateWithData: (NSDictionary *) data;
- (void) updateKeyboardHeight: (float) keyboardHi;
- (void) close;
@end
