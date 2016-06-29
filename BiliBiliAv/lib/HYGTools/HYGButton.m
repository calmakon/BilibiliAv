//
//  HYGButton.m
//  SDLayoutTest
//
//  Created by 胡亚刚 on 16/4/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "HYGButton.h"

@implementation HYGButton

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(self.bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}
@end
