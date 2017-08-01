//
//  ItemConfig.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "ItemConfig.h"

static CGFloat itemWidth = 40;
static CGFloat padding = 10;
static CGFloat titleHeight = 20;
@interface ItemConfig ()

@end

@implementation ItemConfig
-(instancetype)init
{
    if (self = [super init]) {
        //[self items];
    }
    return self;
}

-(NSArray *)items
{
    NSArray * images;
    NSArray * titles;
    switch (self.type) {
        case Live:
            images = @[@"live_home_follow_ico",@"live_home_center_ico",@"live_home_search_ico",@"live_home_category_ico"];
            titles = @[@"关注直播",@"直播中心",@"搜索房间",@"全部分类"];
            break;
        case Bangumi:
            images = @[@"home_region_icon_33@2x",@"home_region_icon_32@2x",@"home_region_icon_153@2x",@"home_region_icon_152@2x"];
            titles = @[@"连载动画",@"完结动画",@"国产动画",@"官方延伸"];
            break;
        default:
            break;
    }
    
    NSMutableArray * array = [NSMutableArray array];
    for (int i=0; i<images.count; i++) {
        ItemModel * item = [ItemModel new];
        item.icon = images[i];
        item.title = titles[i];
        [array addObject:item];
    }
    return [NSArray arrayWithArray:array];
}

-(CGFloat)cellHeight
{
    NSInteger lineNum;
    if (self.items.count%4 == 0) {
        lineNum = self.items.count/4;
        return lineNum*(itemWidth+titleHeight)+padding*2;
    }else{
        lineNum = self.items.count/4+1;
        return lineNum*(itemWidth+titleHeight)+padding*2+10;
    }
}

@end

@implementation ItemModel

@end

