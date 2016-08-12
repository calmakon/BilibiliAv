//
//  RecomHeadView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "RecomHeadView.h"

@implementation RecomHeadView

-(instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        
        CALayer * topLayer = [CALayer layer];
        topLayer.backgroundColor = kBgColor.CGColor;
        [self.layer addSublayer:topLayer];
        topLayer.size = CGSizeMake(kScreenWidth, 8);
        
        UIImageView * imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"home_bangumi_tableHead_bangumiRecommend@2x~iphone"];
        [self addSubview:imageView];
        
        UILabel * label = [UILabel new];
        label.font = [UIFont systemFontOfSize:13];
        label.text = @"番剧推荐";
        [self addSubview:label];
        
        imageView.sd_layout.leftSpaceToView(self,10).topSpaceToView(self,18).widthIs(20).heightEqualToWidth();
        label.sd_layout.leftSpaceToView(imageView,5).topEqualToView(imageView).heightIs(20);
        [label setSingleLineAutoResizeWithMaxWidth:100];
        
        [self setupAutoHeightWithBottomView:imageView bottomMargin:8];
        
        CALayer * topLine = [CALayer layer];
        topLine.size = CGSizeMake(kScreenWidth, CGFloatFromPixel(2));
        topLine.top = 8;
        topLine.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1].CGColor;
        [self.layer addSublayer:topLine];
    }
    return self;
}

@end
