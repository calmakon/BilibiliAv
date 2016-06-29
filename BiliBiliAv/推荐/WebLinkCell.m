//
//  WebLinkCell.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "WebLinkCell.h"
#import "UIImageView+YYWebImage.h"

@interface WebLinkCell ()
@property(nonatomic,strong) UIImageView * infoImageView;
@end

@implementation WebLinkCell

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    }
    return self;
}

-(void)setBodys:(NSArray *)bodys
{
    _bodys = bodys;
    if (bodys && bodys.count>0) {
        for (int i=0; i<bodys.count; i++) {
            AVModelBody * body = bodys[0];
            [self.infoImageView setImageWithURL:[NSURL URLWithString:body.cover] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                
            }];
        }
    }
}

-(UIImageView *)infoImageView
{
    if (!_infoImageView) {
        _infoImageView = [UIImageView new];
        _infoImageView.frame = CGRectMake(10, 10, kScreenWidth-20, 100);
        _infoImageView.userInteractionEnabled = YES;
        [self addSubview:_infoImageView];
        
        UIColor *dark = [UIColor colorWithWhite:0 alpha:0.4];
        UIColor *dark2 = [UIColor colorWithWhite:0 alpha:0.7];
        UIColor *clear = [UIColor colorWithWhite:0 alpha:0];
        NSArray * colors = @[(id)clear.CGColor,(id)dark.CGColor, (id)dark2.CGColor];
        NSArray * locations = @[@0.2, @0.5, @0.8];
        CAGradientLayer * bottomLayer = [CAGradientLayer layer];
        bottomLayer.colors = colors;
        bottomLayer.locations = locations;
        bottomLayer.startPoint = CGPointMake(0, 0);
        bottomLayer.endPoint = CGPointMake(0, 1);
        bottomLayer.size = CGSizeMake(_infoImageView.width, 20);
        bottomLayer.bottom = _infoImageView.height;
        [_infoImageView.layer addSublayer:bottomLayer];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avClick:)];
        [_infoImageView addGestureRecognizer:tap];
    }
    return _infoImageView;
}

-(void)avClick:(UITapGestureRecognizer *)tap
{
    if (self.block) {
        self.block(self.bodys[0]);
    }
}

-(void)cellClickWithBlock:(cellClickBlock)block
{
    self.block = block;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    // Configure the view for the selected state
}

@end
