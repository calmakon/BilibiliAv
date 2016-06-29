//
//  BangumiRecom.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiRecom.h"

@implementation BangumiRecom

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"ID" : @"id"};
}

-(NSString *)seasonId
{
    NSArray * array = [self.link componentsSeparatedByString:@"/"];
    return array.lastObject;
}

@end
