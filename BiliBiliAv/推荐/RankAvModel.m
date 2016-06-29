//
//  RankAvModel.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/15.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "RankAvModel.h"

@implementation RankAvModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"typeName" : @"typename",
             @"typeId" : @"typeid",
             @"descriptionStr" : @"description"};
}
@end
