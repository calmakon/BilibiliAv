//
//  TvView.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "TvView.h"

@implementation TvView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //self.frame = frame;
    }
    return self;
}

-(void)setDataBody:(AVModelBody *)dataBody
{
    if (dataBody) {
        [self.imageView setImageWithURL:[NSURL URLWithString:dataBody.cover] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } transform:^UIImage *(UIImage *image, NSURL *url) {
            return [image imageByRoundCornerRadius:5];
        } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
            
        }];
        self.titleLabel.text = dataBody.title;
        self.upDateTvLabel.text = dataBody.desc1;
    }
}

-(UIImageView *)imageView
{
    CGFloat width = ([UIScreen mainScreen].bounds.size.width-30)/2.5;
    CGFloat height = width*1.4;
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.frame = CGRectMake(0, 0, self.width, height);
        [self addSubview:_imageView];
    }
    return _imageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = [UIColor colorWithHexString:TextColor];
        _titleLabel.frame = CGRectMake(0, self.imageView.bottom+3, self.width, 15);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(UILabel *)upDateTvLabel
{
    if (!_upDateTvLabel) {
        _upDateTvLabel = [UILabel new];
        _upDateTvLabel.backgroundColor = [UIColor whiteColor];
        _upDateTvLabel.frame = CGRectMake(0, self.titleLabel.bottom+3, self.width, 12);
        _upDateTvLabel.textAlignment = NSTextAlignmentCenter;
        _upDateTvLabel.textColor = [UIColor grayColor];
        _upDateTvLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_upDateTvLabel];
    }
    return _upDateTvLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
