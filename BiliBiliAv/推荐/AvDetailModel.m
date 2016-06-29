//
//  AvDetailModel.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/22.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "AvDetailModel.h"

@implementation AvDetailModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"owner" : [Owner class],@"stat":[Stat class],@"relates":[RelateModel class],@"pages":[Page class]};
}

@end

@implementation RelateModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"owner" : [Owner class],@"stat":[Stat class]};
}
@end

@implementation Owner

@end

@implementation Stat
-(void)setView:(NSString *)view
{
   _view = [self shortedNumberDesc:[view integerValue]];
}

-(void)setDanmaku:(NSString *)danmaku
{
    _danmaku = [self shortedNumberDesc:[danmaku integerValue]];
}

-(void)setCoin:(NSString *)coin
{
   _coin = [self shortedNumberDesc:[coin integerValue]];
}

-(void)setFavorite:(NSString *)favorite
{
   _favorite = [self shortedNumberDesc:[favorite integerValue]];
}

-(void)setShare:(NSString *)share
{
   _share = [self shortedNumberDesc:[share integerValue]];
}

- (NSString *)shortedNumberDesc:(NSInteger)number {
    // should be localized
    if (number <= 9999) return [NSString stringWithFormat:@"%d", (int)number];
    if (number <= 9999999) return [NSString stringWithFormat:@"%d万", (int)(number / 10000)];
    return [NSString stringWithFormat:@"%d千万", (int)(number / 10000000)];
}

@end

@implementation Page

@end
