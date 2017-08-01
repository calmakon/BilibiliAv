//
//  LiveListItem.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/21.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveListItem.h"
#import "NSAttributedString+YYText.h"
@implementation LiveListItem
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"lives" : [LiveItem class],
             @"partition" : [Partition class],
             @"banner_data" : [LiveItem class]};
}

-(YYTextLayout *)moreText
{
    YYTextLayout * textLayout;
    NSMutableAttributedString * text;
    text = [[NSMutableAttributedString alloc] initWithString:@"当前个直播，进去看看"];
    text.font = [UIFont systemFontOfSize:14];
    text.color = [UIColor lightGrayColor];
    [text insertString:self.partition.count atIndex:2];
    [text setColor:[UIColor colorWithRed:0.95 green:0.59 blue:0.71 alpha:1] range:NSMakeRange(2, self.partition.count.length)];
    text.alignment = NSTextAlignmentRight;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kScreenWidth-150, 9999)];
    container.maximumNumberOfRows = 1;
    textLayout = [YYTextLayout layoutWithContainer:container text:text];
    return textLayout;
}

@end

@implementation Partition
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"sub_icon" : [Sub_icon class]};
}

-(NSString *)reFreshUrl
{
    NSString * url;
    if ([self.area isEqualToString:@"draw"]) {
        //绘画展区
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=draw&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=52457ff22c3d08dca967dbbfbf5561b3&ts=1480836413";
    }else if ([self.area isEqualToString:@"mobile"]){
        //手机直播
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=mobile&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=fa5fbebcb2c8d7b3a5f081c7d6dac4d1&ts=1480836485";
    }else if ([self.area isEqualToString:@"sing-dance"]){
        //唱见舞见
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=sing-dance&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=a3b7869e778be4933ee9553ee5b9e114&ts=1480836523";
    }else if ([self.area isEqualToString:@"mobile-game"]){
        //手游直播
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=mobile-game&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=aa37f621dc8bbc614f0dc2932e0398f2&ts=1480836554";
    }else if ([self.area isEqualToString:@"single"]){
        //单机联机
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=single&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=265d44c5aee2169665e81d03586a9c29&ts=1480836592";
    }else if ([self.area isEqualToString:@"online"]){
        //网络游戏
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=online&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=e34b7459a21ec907e147e0ebd0ecf63f&ts=1480836620";
    }else if ([self.area isEqualToString:@"e-sports"]){
        //电子竞技
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=e-sports&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=9784f777500b7e9aacaf5b9ec1e751b8&ts=1480836651";
    }else if ([self.area isEqualToString:@"otaku"]){
        //御宅文化
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=otaku&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=75432d5c42b5fab464aac57b0178754b&ts=1480836683";
    }else if ([self.area isEqualToString:@"movie"]){
        //放映厅
        url = @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=movie&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=d64599d4fadff01854fedc0524550a0d&ts=1480836713";
    }
    return url;
}

@end

@implementation Sub_icon

@end


