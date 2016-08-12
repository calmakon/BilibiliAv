//
//  RankAvCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/15.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "RankAvCell.h"
#import "UIImageView+YYWebImage.h"
#import "UIImage+ImageRoundedCorner.h"
#import "HYGUtility.h"

@interface RankAvCell ()
@property (nonatomic,strong) UIImageView * iconImageView;
@property (nonatomic,strong) UIView * rankView;
@property (nonatomic,strong) UILabel * rankLabel;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * upLabel;
@property (nonatomic,strong) UILabel * playNumLabel;
@property (nonatomic,strong) UILabel * danmuNumLabel;
@end

@implementation RankAvCell

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
    self.iconImageView.sd_layout.leftSpaceToView(self.contentView,10).topSpaceToView(self.contentView,10).widthIs(100).autoHeightRatio(0.7);
    self.iconImageView.clipsToBounds = YES;
    
    self.rankView.sd_layout.rightSpaceToView(self.iconImageView,-10).bottomSpaceToView(self.iconImageView,-10).widthIs(30).heightIs(28);
    self.rankView.sd_cornerRadius = @4;
    
    self.rankLabel.sd_layout.leftEqualToView(self.rankView).topEqualToView(self.rankView).widthIs(20).heightIs(18);
    
    self.titleLabel.sd_layout.topEqualToView(self.iconImageView).leftSpaceToView(self.iconImageView,10).rightSpaceToView(self.contentView,10).autoHeightRatio(0);
    self.upLabel.sd_layout.leftEqualToView(self.titleLabel).topSpaceToView(self.titleLabel,8).heightIs(15);
    [self.upLabel setSingleLineAutoResizeWithMaxWidth:220];
    self.playNumLabel.sd_layout.leftEqualToView(self.titleLabel).topSpaceToView(self.upLabel,8).heightIs(15);
    [self.playNumLabel setSingleLineAutoResizeWithMaxWidth:100];
    self.danmuNumLabel.sd_layout.topEqualToView(self.playNumLabel).rightSpaceToView(self.contentView,10).heightIs(15);
    [self.danmuNumLabel setSingleLineAutoResizeWithMaxWidth:120];
    
    [self setupAutoHeightWithBottomViewsArray:@[self.iconImageView,self.danmuNumLabel] bottomMargin:10];
}

-(void)setModel:(RankAvModel *)model
{
    if (!model) return;
    _model = model;
    @weakify(self);
    [self.iconImageView setImageWithURL:[NSURL URLWithString:model.pic] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } transform:^UIImage *(UIImage *image, NSURL *url) {
        return [image imageAddCornerWithRadius:7 andSize:CGSizeMake(weak_self.iconImageView.width, weak_self.iconImageView.height)];
    } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        
    }];
    
    self.rankLabel.text = [NSString stringWithFormat:@"%ld",[model.rank integerValue]+1];
    if ([model.rank integerValue] == 0) {
        self.rankView.backgroundColor = [UIColor colorWithRed:0.87 green:0.10 blue:0.13 alpha:1];
    }else if ([model.rank integerValue] == 1){
        self.rankView.backgroundColor = [UIColor colorWithRed:0.92 green:0.47 blue:0.15 alpha:1];
    }else if ([model.rank integerValue] == 2){
        self.rankView.backgroundColor = [UIColor colorWithRed:1 green:0.76 blue:0.26 alpha:1];
    }else{
        self.rankView.backgroundColor = [UIColor lightGrayColor];
    }
    self.titleLabel.text = model.title;
    self.upLabel.text = [NSString stringWithFormat:@"UP主：%@",model.author];
    self.playNumLabel.text = [NSString stringWithFormat:@"播放：%@",[HYGUtility shortedNumberDesc:[model.play integerValue]]];
    self.danmuNumLabel.text = [NSString stringWithFormat:@"弹幕：%@",[HYGUtility shortedNumberDesc:[model.video_review integerValue]]];
}

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

-(UIView *)rankView
{
    if (!_rankView) {
        _rankView = [UIView new];
        [self.iconImageView addSubview:_rankView];
    }
    return _rankView;
}

-(UILabel *)rankLabel
{
    if (!_rankLabel) {
        _rankLabel = [UILabel new];
        _rankLabel.font = [UIFont systemFontOfSize:10];
        _rankLabel.textColor = [UIColor whiteColor];
        _rankLabel.textAlignment = NSTextAlignmentCenter;
        [self.rankView addSubview:_rankLabel];
    }
    return _rankLabel;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(UILabel *)upLabel
{
    if (!_upLabel) {
        _upLabel = [UILabel new];
        _upLabel.font = [UIFont systemFontOfSize:12];
        _upLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_upLabel];
    }
    return _upLabel;
}

-(UILabel *)playNumLabel
{
    if (!_playNumLabel) {
        _playNumLabel = [UILabel new];
        _playNumLabel.font = [UIFont systemFontOfSize:12];
        _playNumLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_playNumLabel];
    }
    return _playNumLabel;
}

-(UILabel *)danmuNumLabel
{
    if (!_danmuNumLabel) {
        _danmuNumLabel = [UILabel new];
        _danmuNumLabel.font = [UIFont systemFontOfSize:12];
        _danmuNumLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_danmuNumLabel];
    }
    return _danmuNumLabel;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
