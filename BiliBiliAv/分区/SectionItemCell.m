//
//  SectionItemCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "SectionItemCell.h"

@interface SectionItemCell ()

@property (nonatomic,strong) UIImageView * bgImageView;
@property (nonatomic,strong) UIImageView * contenImageView;
@property (nonatomic,strong) UILabel * nameLable;

@end

@implementation SectionItemCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIView * view = [UIView new];
        view.frame = self.bounds;
        view.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:0.9];
        self.selectedBackgroundView = view;
        [self layout];
    }
    return self;
}

-(void)layout
{
    UIView * contentView = self.contentView;
    self.bgImageView.sd_layout.leftSpaceToView(contentView,10).topSpaceToView(contentView,3).rightSpaceToView(contentView,10).autoHeightRatio(1);
    self.contenImageView.sd_layout.leftSpaceToView(self.bgImageView,20).topSpaceToView(self.bgImageView,20).rightSpaceToView(self.bgImageView,20).autoHeightRatio(1);
    self.nameLable.sd_layout.leftEqualToView(self.bgImageView).topSpaceToView(self.bgImageView,0).rightEqualToView(self.bgImageView).heightIs(20);
}

-(void)setItem:(SectionItem *)item
{
    if (!item) return;
    self.contenImageView.image = [UIImage imageNamed:item.icon];
    self.nameLable.text = item.name;
}

-(UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        _bgImageView.image = [UIImage imageNamed:@"home_region_border"];
        [self.contentView addSubview:_bgImageView];
    }
    return _bgImageView;
}

-(UIImageView *)contenImageView
{
    if (!_contenImageView) {
        _contenImageView = [UIImageView new];
        [self.bgImageView addSubview:_contenImageView];
    }
    return _contenImageView;
}

-(UILabel *)nameLable
{
    if (!_nameLable) {
        _nameLable = [UILabel new];
        _nameLable.font = [UIFont systemFontOfSize:14];
        _nameLable.textColor = [UIColor grayColor];
        _nameLable.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLable];
    }
    return _nameLable;
}

@end
