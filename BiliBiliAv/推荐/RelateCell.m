//
//  RelateCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "RelateCell.h"
#import "UIImageView+YYWebImage.h"

@interface RelateCell ()
@property (nonatomic,strong) UIImageView * iconImageView;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * upserLabel;
@property (nonatomic,strong) UILabel * playLabel;
@property (nonatomic,strong) UILabel * danmukuLabel;
@end

@implementation RelateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
        
        [self layout];
    }
    return self;
}

-(void)layout
{
    self.iconImageView.sd_layout.leftSpaceToView(self.contentView,10).topSpaceToView(self.contentView,10).widthIs(100).autoHeightRatio(0.7);
    self.titleLabel.sd_layout.topEqualToView(self.iconImageView).leftSpaceToView(self.iconImageView,10).rightSpaceToView(self.contentView,10).autoHeightRatio(0);
    self.upserLabel.sd_layout.leftEqualToView(self.titleLabel).topSpaceToView(self.titleLabel,8).heightIs(15);
    [self.upserLabel setSingleLineAutoResizeWithMaxWidth:220];
    self.playLabel.sd_layout.leftEqualToView(self.titleLabel).topSpaceToView(self.upserLabel,8).heightIs(15);
    [self.playLabel setSingleLineAutoResizeWithMaxWidth:100];
    self.danmukuLabel.sd_layout.topEqualToView(self.playLabel).rightSpaceToView(self.contentView,10).heightIs(15);
    [self.danmukuLabel setSingleLineAutoResizeWithMaxWidth:120];
    
    [self setupAutoHeightWithBottomViewsArray:@[self.iconImageView,self.danmukuLabel] bottomMargin:10];
}

-(void)setRelate:(RelateModel *)relate
{
    if (!relate) return;
    _relate = relate;
    @weakify(self);
    [self.iconImageView setImageWithURL:[NSURL URLWithString:relate.pic] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } transform:^UIImage *(UIImage *image, NSURL *url) {
        return [image imageAddCornerWithRadius:10 andSize:CGSizeMake(weak_self.iconImageView.width, weak_self.iconImageView.height)];
    } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        
    }];
    
    self.titleLabel.text = relate.title;
    self.upserLabel.text = [NSString stringWithFormat:@"UP主：%@",relate.owner.name];
    self.playLabel.text = [NSString stringWithFormat:@"播放：%@",relate.stat.view];
    self.danmukuLabel.text = [NSString stringWithFormat:@"弹幕：%@",relate.stat.danmaku];
}

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
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

-(UILabel *)upserLabel
{
    if (!_upserLabel) {
        _upserLabel = [UILabel new];
        _upserLabel.font = [UIFont systemFontOfSize:12];
        _upserLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_upserLabel];
    }
    return _upserLabel;
}

-(UILabel *)playLabel
{
    if (!_playLabel) {
        _playLabel = [UILabel new];
        _playLabel.font = [UIFont systemFontOfSize:12];
        _playLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_playLabel];
    }
    return _playLabel;
}

-(UILabel *)danmukuLabel
{
    if (!_danmukuLabel) {
        _danmukuLabel = [UILabel new];
        _danmukuLabel.font = [UIFont systemFontOfSize:12];
        _danmukuLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_danmukuLabel];
    }
    return _danmukuLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
