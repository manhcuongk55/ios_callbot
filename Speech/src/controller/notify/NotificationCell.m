//
//  NotificationCell.m
//  Speech
//
//  Created by Phu on 5/17/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "NotificationCell.h"
#import "Utils.h"
#import "Manager.h"

@interface NotificationCell () {
    ASImageNode *img;
    ASTextNode *from;
    ASTextNode *date;
    ASTextNode *question;
    ASDisplayNode *divi;
}

@end

@implementation NotificationCell

- (instancetype)initWithData: (NSDictionary *) data
{
    self = [super init];
    if (self) {
        //
        NSNumber *type = data[@"va_app_type"];
        NSString *userName = @"Noname";
        NSNumber *dateNb = @0;
        NSString *questionStr = @"Question";
        if (type.intValue == 1) {
            userName = data[@"username"];
            dateNb = data[@"createdTime"];
            questionStr = data[@"question"];
        }
        else if (type.intValue == 2) {
            userName = data[@"expertUsername"];
            dateNb = data[@"createdTime"];
            questionStr = data[@"question"];
        }
        //
        self.data = data;
        img = [ASImageNode new];
        img.image = [UIImage imageNamed:@"va_avatar_default"];
        [self addSubnode:img];
        //
        divi = [ASDisplayNode new];
        divi.backgroundColor = [UIColor lightGrayColor];
        [self addSubnode:divi];
        //
        from = [ASTextNode new];
        NSString *quesStr = [NSString stringWithFormat:@"From: %@", userName];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString: quesStr];
        [attrStr addAttributes:[self fromStyle1] range:NSMakeRange(0, 6)];
        [attrStr addAttributes:[self fromStyle] range:NSMakeRange(6, quesStr.length - 6)];
        from.attributedText = attrStr;
        [self addSubnode:from];
        //
        date = [ASTextNode new];
        date.attributedText = [[NSAttributedString alloc] initWithString:[Utils getDateStr:[NSDate dateWithTimeIntervalSince1970: dateNb.longLongValue/1000.0]] attributes:[self dateStyle]];
        [self addSubnode:date];
        //
        question = [ASTextNode new];
        question.maximumNumberOfLines = 1.0;
        question.truncationMode = NSLineBreakByTruncatingTail;
        question.attributedText = [[NSAttributedString alloc] initWithString: questionStr attributes:[self questionStyle]];
        [self addSubnode:question];
    }
    return self;
}
- (void) layout {
    [super layout];
    img.frame = CGRectMake(15, (self.bounds.size.height - 35)/2.0, 35, 35);
    divi.frame = CGRectMake(5, self.bounds.size.height - 0.5, self.bounds.size.width - 10, 0.5);
    
    CGSize size = [from calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    from.frame = CGRectMake(65, 8, size.width, size.height);
    
    float yT = from.frame.origin.y + from.frame.size.height + 5;
    size = [date calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    date.frame = CGRectMake(65, yT, size.width, size.height);
    
    yT = date.frame.origin.y + date.frame.size.height + 5;
    size = [question calculateSizeThatFits:CGSizeMake(self.bounds.size.width - 65 - 10, MAXFLOAT)];
    question.frame = CGRectMake(65, yT, size.width, size.height);
    
    yT = question.frame.origin.y + question.frame.size.height + 8;
    //NSLog(@"%f", yT);
}
- (NSDictionary *)fromStyle1 {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor blackColor],
             };
}
- (NSDictionary *)fromStyle {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor blackColor],
             };
}
- (NSDictionary *) dateStyle {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor grayColor],
             };
}
- (NSDictionary *) questionStyle {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [Manager instance].colorBubbleFromBot,
             };
}
@end
