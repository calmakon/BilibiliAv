//
//  MineItemView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "MineItemView.h"

@interface MineItemView ()
@property (nonatomic,strong) UIImageView * iconImageView;
@property (nonatomic,strong) UILabel * titleLabel;
@end

@implementation MineItemView

-(instancetype)init
{
    if (self = [super init]) {
        CGFloat width = kScreenWidth/4;
        CGFloat height = width;
        self.size = CGSizeMake(width, height);

        [self layout];
    }
    return self;
}

-(void)layout
{
    UIView * topLine = [UIView new];
    topLine.backgroundColor = kBgColor;
    [self addSubview:topLine];
    
    UIView * rightLine = [UIView new];
    rightLine.backgroundColor = kBgColor;
    [self addSubview:rightLine];
    
    UIView * bottomLine = [UIView new];
    bottomLine.backgroundColor = kBgColor;
    [self addSubview:bottomLine];
    
    topLine.sd_layout.topEqualToView(self).leftEqualToView(self).rightEqualToView(self).heightIs(kCGFloatFromPixel(1));
    rightLine.sd_layout.topEqualToView(self).bottomEqualToView(self).rightEqualToView(self).widthIs(kCGFloatFromPixel(1));
    bottomLine.sd_layout.bottomEqualToView(self).leftEqualToView(self).rightEqualToView(self).heightIs(kCGFloatFromPixel(1));
    
    self.iconImageView.sd_layout.leftSpaceToView(self,30).rightSpaceToView(self,30).topSpaceToView(self,20).heightEqualToWidth();
    self.titleLabel.sd_layout.leftSpaceToView(self,5).rightSpaceToView(self,5).topSpaceToView(self.iconImageView,5).heightIs(20);
}

-(void)setItem:(MineItem *)item
{
    if (!item) return;
    self.iconImageView.image = [UIImage imageNamed:item.icon];
    self.titleLabel.text = item.title;
    
}

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
