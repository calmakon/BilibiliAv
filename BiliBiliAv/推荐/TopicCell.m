//
//  TopicCell.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "TopicCell.h"
#import "UIImageView+YYWebImage.h"
@interface TopicCell ()
@property(nonatomic,strong) UIView * bgView;
@property(nonatomic,strong) UIImageView * tipImageView;
@property(nonatomic,strong) UILabel * typeLabel;
@property(nonatomic,strong) UIImageView * infoImageView;
@property(nonatomic,strong) UILabel * titleLabel;
@end

@implementation TopicCell

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CALayer * bgLayer = [CALayer layer];
        bgLayer.size = CGSizeMake(kScreenWidth, 8);
        bgLayer.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1].CGColor;
        [self.layer addSublayer:bgLayer];
        
        self.tipImageView.frame = CGRectMake(10, 10, 17, 17);
        self.typeLabel.frame = CGRectMake(self.tipImageView.right+5, self.tipImageView.top, 0, 15);
    }
    return self;
}

-(void)setBodys:(NSArray *)bodys
{
    _bodys = bodys;
    if (bodys && bodys.count>0) {
        for (int i=0; i<bodys.count; i++) {
            AVModelBody * body = bodys[0];
            [self.infoImageView setImageWithURL:[NSURL URLWithString:body.cover] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:^UIImage *(UIImage *image, NSURL *url) {
                return [image imageByRoundCornerRadius:5];
            } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                
            }];
            self.titleLabel.text = body.title;
        }
    }
}

-(void)setList:(TuiJianList *)list
{
    _list = list;
    if (list.head) {
        self.typeLabel.text = list.head.title;
        self.typeLabel.frame = CGRectMake(self.tipImageView.right+5, self.tipImageView.top, stringWidth(list.head.title, 14), 15);
    }
    if (list.tipImageName) {
        self.tipImageView.image = [UIImage imageNamed:list.tipImageName];
    }
}

-(void)imageClick
{
    if (self.block) {
        AVModelBody * body = self.bodys[0];
        self.block(body.param);
    }
}

-(void)cellClickWithBlock:(topicCellClickBlock)block
{
    self.block = block;
}

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.size = CGSizeMake(kScreenWidth, 168);
        _bgView.top = 8;
        _bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bgView];
    }
    return _bgView;
}

-(UIImageView *)tipImageView
{
    if (!_tipImageView) {
        _tipImageView = [UIImageView new];
        [self.bgView addSubview:_tipImageView];
    }
    return _tipImageView;
}

-(UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [UILabel new];
        _typeLabel.backgroundColor = [UIColor whiteColor];
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.font = [UIFont systemFontOfSize:14];
        [self.bgView addSubview:_typeLabel];
    }
    return _typeLabel;
}

-(UIImageView *)infoImageView
{
    if (!_infoImageView) {
        _infoImageView = [UIImageView new];
        _infoImageView.frame = CGRectMake(10, 40, kScreenWidth-20, 100);
        [self.bgView addSubview:_infoImageView];
        
        _infoImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
        [tap addTarget:self action:@selector(imageClick)];
        [_infoImageView addGestureRecognizer:tap];
    }
    return _infoImageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.frame = CGRectMake(10, self.infoImageView.bottom+5, self.infoImageView.width, 18);
        _titleLabel.textColor = [UIColor colorWithHexString:TextColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.bgView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
