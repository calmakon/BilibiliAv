//
//  BottomView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BottomView.h"
#import "UIImageView+YYWebImage.h"
@interface BottomView ()
@property (nonatomic,strong) UIImageView * bannerView;
@end

@implementation BottomView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        if (frame.size.height == 0) {
            frame.size = CGSizeMake(kScreenWidth, 120);
            self.backgroundColor = [UIColor whiteColor];
            self.frame = frame;
            [self bannerView];
        }
    }
    return self;
}

-(void)setBanner:(TopPicModel *)banner
{
    _banner = banner;
    [self.bannerView setImageWithURL:[NSURL URLWithString:banner.image] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:nil transform:^UIImage *(UIImage *image, NSURL *url) {
        return image;
    } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        
    }];
}

-(UIImageView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [UIImageView new];
        _bannerView.frame = CGRectMake(0, 7, self.width, 106);
        [self addSubview:_bannerView];
        
        _bannerView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
        [tap addTarget:self action:@selector(imageClick)];
        [_bannerView addGestureRecognizer:tap];
    }
    return _bannerView;
}

-(void)imageClick
{
    if (self.block) {
        self.block(self.banner.uri);
    }
}

-(void)bannerClickWithBlock:(bannerClickBlock)block
{
    self.block = block;
}

@end
