//
//  ClipView.m
//  guangda_student
//
//  Created by Dino on 15/4/28.
//  Copyright (c) 2015年 daoshun. All rights reserved.
//

#import "ClipView.h"

@implementation ClipView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"clipView touch CGPoint: x == %f, y == %f", point.x, point.y);
    
    if (event.timestamp) {
//        event.type
        NSLog(@"点按");
    }
    NSLog(@"%@", event);
    
    UIView *resultView = [self pointInside:point withEvent:event] ? self.scrollView : nil;
    return resultView;
}


@end
