//
//  BangumiRecomCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiRecomCell.h"
#import "UIImageView+YYWebImage.h"

@interface BangumiRecomCell ()
@property (nonatomic,strong) UIView * recomContentView;
@property (nonatomic,strong) UIImageView * recomImageView;
@property (nonatomic,strong) UIImageView * tipImageView;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * subTitleLabel;
@end

@implementation BangumiRecomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self layout];
    }
    return self;
}

-(void)layout
{
    CALayer * topLayer = [CALayer layer];
    topLayer.backgroundColor = kBgColor.CGColor;
    [self.contentView.layer addSublayer:topLayer];
    topLayer.size = CGSizeMake(kScreenWidth, 8);
    
    UIView * contentView = self.contentView;
    
    UIView * topLine = [UIView new];
    topLine.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1];
    [self.recomContentView addSubview:topLine];
    
    UIView * bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1];
    [self.recomContentView addSubview:bottomLine];
    
    self.recomContentView.sd_layout.leftSpaceToView(contentView,0).topSpaceToView(contentView,8).rightSpaceToView(contentView,0).bottomSpaceToView(contentView,0);
    
    topLine.sd_layout.leftSpaceToView(self.recomContentView,0).topSpaceToView(self.recomContentView,0).rightSpaceToView(self.recomContentView,0).heightIs(CGFloatFromPixel(2));
    
    bottomLine.sd_layout.leftSpaceToView(self.recomContentView,0).bottomSpaceToView(self.recomContentView,0).rightSpaceToView(self.recomContentView,0).heightIs(CGFloatFromPixel(2));
    
    self.recomImageView.sd_layout.leftSpaceToView(self.recomContentView,10).topSpaceToView(self.recomContentView,8).rightSpaceToView(self.recomContentView,10).autoHeightRatio(0.3);
    self.titleLabel.sd_layout.leftEqualToView(self.recomImageView).topSpaceToView(self.recomImageView,5).heightIs(15);
    [self.titleLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    self.subTitleLabel.sd_layout.leftEqualToView(self.titleLabel).topSpaceToView(self.titleLabel,5).rightEqualToView(self.recomImageView).autoHeightRatio(0);
    
    [self.recomContentView setupAutoHeightWithBottomView:self.subTitleLabel bottomMargin:8];
    
    [self setupAutoHeightWithBottomView:self.subTitleLabel bottomMargin:16];
}

-(void)setRecom:(BangumiRecom *)recom
{
    if (!recom) return;
    _recom = recom;
    
    [self.recomImageView setImageWithURL:[NSURL URLWithString:recom.cover] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:^UIImage *(UIImage *image, NSURL *url) {
        return [image imageByRoundCornerRadius:5];
    } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        
    }];
    
    self.titleLabel.text = recom.title;
    self.subTitleLabel.text = recom.desc;
}

-(UIView *)recomContentView
{
    if (!_recomContentView) {
        _recomContentView = [UIView new];
        _recomContentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_recomContentView];
    }
    return _recomContentView;
}

-(UIImageView *)recomImageView
{
    if (!_recomImageView) {
        _recomImageView = [UIImageView new];
        [self.recomContentView addSubview:_recomImageView];
    }
    return _recomImageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        [self.recomContentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(UILabel *)subTitleLabel
{
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel new];
        _subTitleLabel.font = [UIFont systemFontOfSize:12];
        _subTitleLabel.textColor = [UIColor grayColor];
        [self.recomContentView addSubview:_subTitleLabel];
    }
    return _subTitleLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
