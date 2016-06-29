//
//  BangumiDeatail.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/7.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiDeatail.h"

@implementation BangumiDeatail
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"actor" : [Actor class],
             @"episodes" : [BangumiAvBody class],
             @"seasons" : [Season class],
             @"rank" : [Rank class],
             @"tags" : [Tag class]};
}
@end

@implementation Actor

@end

@implementation BangumiAvBody

@end

@implementation Rank
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [RankBody class]};
}
@end

@implementation RankBody

@end

@implementation Season

@end

@implementation Tag

@end

