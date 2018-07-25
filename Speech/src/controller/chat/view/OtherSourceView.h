//
//  OtherSourceView.h
//  Speech
//
//  Created by Phu on 5/15/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"

@protocol OtherSourceViewDelegate <NSObject>

- (void) didSelectSourceAtIdx: (int) idx;

@end

@interface OtherSourceButton : ASButtonNode
@property (nonatomic, assign) CGSize sizeContent;

@end

@interface OtherSourceView : ASScrollNode
- (instancetype)initWithData: (NSArray *) listDatas_ andSelectIdx: (int) idx;
@property (nonatomic, weak) id<OtherSourceViewDelegate> delegate;

@end
