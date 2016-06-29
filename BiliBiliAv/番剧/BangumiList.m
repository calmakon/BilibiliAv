//
//  BangumiList.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiList.h"
#import "NSAttributedString+YYText.h"
#import "YYTextRunDelegate.h"
#import "TopPicModel.h"
static CGFloat const kPaddingHeight = 10;//通用控件之间间隔
static CGFloat const kCellPaddingHeight = 8;//cell之间间隔
static CGFloat const kTitleImagePaddingHeight = 3;//视频图片和标题之间间隔
static CGFloat const kTitleHeight = 30;//标题高度
static CGFloat const kImagePlayNumPaddingHeight = 5;//标题和播放量label间隔
static CGFloat const kTitleViewHeight = 40;//各版块标题view的高度
static CGFloat const kAvListImageHeightScole = 0.6;//视频图片的宽高比
static CGFloat const kEndBanumiListImageHeightScole = 1.4;//完结番剧图片宽高比
@implementation BangumiList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"banners" : [TopPicModel class],
             @"ends" : [BangumiBody class],
             @"latestUpdate" : [BangumiLatestUpdate class]};
}

-(YYTextLayout *)gotoInfoText
{
    YYTextLayout * textLayout;
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:@"今日更新"];
    text.font = [UIFont systemFontOfSize:14];
    text.color = [UIColor lightGrayColor];
    [text insertString:self.latestUpdate.updateCount atIndex:4];
    [text setColor:[UIColor colorWithRed:0.95 green:0.59 blue:0.71 alpha:1] range:NSMakeRange(4, self.latestUpdate.updateCount.length)];
    
    text.alignment = NSTextAlignmentRight;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kScreenWidth-150, 9999)];
    container.maximumNumberOfRows = 1;
    textLayout = [YYTextLayout layoutWithContainer:container text:text];
    return textLayout;
}

-(CGFloat)cellHeight
{
    CGFloat width = (kScreenWidth-(kPaddingHeight*3))/2;
    CGFloat height = width*kAvListImageHeightScole+kTitleHeight+kTitleImagePaddingHeight+kImagePlayNumPaddingHeight+kPaddingHeight;
    return kTitleViewHeight+height*3+kPaddingHeight*2+10+kCellPaddingHeight;
}

-(CGFloat)endCellHeight
{
    CGFloat width = (kScreenWidth-30)/2.5;
    CGFloat height = width*kEndBanumiListImageHeightScole;
    return height+kTitleViewHeight+40+kPaddingHeight+kCellPaddingHeight;
}

@end

@implementation BangumiLatestUpdate

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [BangumiBody class]};
}

@end

@implementation BangumiBanner

@end


