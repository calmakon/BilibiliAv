//
//  LiveBannerCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/30.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveBannerCell.h"
#import "YYLabel.h"
#import "UIImageView+YYWebImage.h"
#import "ImageText.h"
#import "HYGTool.h"
@interface LiveBannerCell ()
@property (nonatomic,strong) UIImageView * bannerImageView;
@property (nonatomic,strong) UIImageView * bottomImageView;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UIImageView * onLineImageView;
@property (nonatomic,strong) UILabel * onLineLabel;
@property (nonatomic,strong) YYLabel * titleLabel;
@end

@implementation LiveBannerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = kBgColor;
    }
    return self;
}

-(void)setLiveData:(LiveItem *)liveData
{
    _liveData = liveData;
    if (!liveData) return;

    __weak typeof(self) weakSelf = self;
    [self.bannerImageView setImageWithURL:[NSURL URLWithString:liveData.cover.src] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } transform:^UIImage *(UIImage *image, NSURL *url) {
        return [image imageAddCornerWithRadius:6 andSize:CGSizeMake(weakSelf.bannerImageView.width, weakSelf.bannerImageView.height)];
    } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        
    }];
    
    self.nameLabel.text = liveData.owner.name;
    self.nameLabel.frame = CGRectMake(5, self.bannerImageView.bottom-25, stringWidth(liveData.owner.name, 10), 15);
    
    CGFloat onLineWidth = stringWidth(liveData.online, 10);
    self.onLineImageView.frame = CGRectMake(self.bannerImageView.width-onLineWidth-5-15, 0, 15, 13);
    self.onLineImageView.centerY = self.nameLabel.centerY;
    
    self.onLineLabel.text = [HYGUtility shortedNumberDesc:[liveData.online integerValue]];
    self.onLineLabel.frame = CGRectMake(self.onLineImageView.right+2, self.onLineImageView.top, onLineWidth, 18);
    self.onLineLabel.centerY = self.nameLabel.centerY;
    
    NSString * text = [NSString stringWithFormat:@"#%@# %@",liveData.area,liveData.title];
 
    self.titleLabel.attributedText = [ImageText _textWithTextString:text fontSize:12 textColor:[UIColor colorWithHexString:TextColor]];
    
    CGFloat labelHeight = 20;
    self.titleLabel.frame = CGRectMake(self.bannerImageView.left+5, self.bannerImageView.bottom+3, self.bannerImageView.width-10, labelHeight);
    self.height = self.titleLabel.bottom+10;
}

-(UIImageView *)bannerImageView
{
    if (!_bannerImageView) {
        _bannerImageView = [UIImageView new];
        _bannerImageView.userInteractionEnabled = YES;
        CGFloat height = ((kScreenWidth-10*3)/2)*0.6;
        _bannerImageView.frame = CGRectMake(10, 5, kScreenWidth-20, height);
        [self addSubview:_bannerImageView];
        
        self.bottomImageView.frame = CGRectMake(0, _bannerImageView.height-40,_bannerImageView.width, 40);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        [_bannerImageView addGestureRecognizer:tap];
    }
    return _bannerImageView;
}

-(void)click:(UITapGestureRecognizer *)tap
{
    if (self.clickBlock) {
        self.clickBlock(self.liveData);
    }
}

-(void)bannerClickWithBlock:(bannerClickBlock)block
{
    self.clickBlock = block;
}

-(UIImageView *)bottomImageView
{
    if (!_bottomImageView) {
        _bottomImageView = [UIImageView new];
        _bottomImageView.image = [[UIImage imageNamed:@"shadow_1_40_gradual_line"] imageAddCornerWithRadius:6 andSize:CGSizeMake(self.bannerImageView.width, 40)];
        [self.bannerImageView addSubview:_bottomImageView];
    }
    return _bottomImageView;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:10];
        _nameLabel.textColor = [UIColor whiteColor];
        [self.bannerImageView addSubview:_nameLabel];
    }
    return _nameLabel;
}

-(UIImageView *)onLineImageView
{
    if (!_onLineImageView) {
        _onLineImageView = [UIImageView new];
        _onLineImageView.image = [UIImage imageNamed:@"live_online_ico@2x"];
        [self.bannerImageView addSubview:_onLineImageView];
    }
    return _onLineImageView;
}

-(UILabel *)onLineLabel
{
    if (!_onLineLabel) {
        _onLineLabel = [UILabel new];
        _onLineLabel.textAlignment = NSTextAlignmentLeft;
        _onLineLabel.font = [UIFont systemFontOfSize:10];
        _onLineLabel.textColor = [UIColor whiteColor];
        [self.bannerImageView addSubview:_onLineLabel];
    }
    return _onLineLabel;
}

-(YYLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [YYLabel new];
        _titleLabel.textColor = [UIColor colorWithHexString:TextColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
