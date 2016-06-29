//
//  ReplyList.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/5.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "ReplyList.h"

@implementation ReplyList
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"hots" : [ReplyListModel class],
             @"page":[Pagee class],
             @"replies":[ReplyListModel class]
             };
}
@end

@implementation Pagee

@end

