//
//  MineItemModel.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "MineItemModel.h"

@implementation MineItemModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"mine" : [MineItem class],@"message" : [MineItem class]};
}

-(CGFloat)mineCellHeight
{
    CGFloat height = kScreenWidth/4;
    NSInteger num;
    if (self.mine.count%4 == 0) {
        num = self.mine.count/4;
    }else{
        num = self.mine.count/4+1;
    }
    return num*height;
}

-(CGFloat)messageCellHeight
{
    CGFloat height = kScreenWidth/4;
    NSInteger num;
    if (self.message.count%4 == 0) {
        num = self.message.count/4;
    }else{
        num = self.message.count/4+1;
    }
    return num*height;
}

@end
