//
//  LiveItem.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/20.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveItem.h"

@implementation LiveItem
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"cover" : [Cover class],
             @"owner" : [Owner class]};
}

+(CGFloat)cellHeight
{
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-10*3)/2;
    CGFloat height = width*0.6;
    
    return height+5+30+10;
}

@end


@implementation Cover

@end


