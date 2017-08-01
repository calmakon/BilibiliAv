//
//  LiveHeadView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/24.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveHeadView.h"
#import "YYLabel.h"
#import "UIImageView+YYWebImage.h"
@interface LiveHeadView ()
@property(nonatomic,strong) UIImageView * tipImageView;
@property(nonatomic,strong) UILabel * typeLabel;
@property(nonatomic,strong) YYLabel * moreLabel;
@property(nonatomic,strong) UIButton * moreBtn;
@end

@implementation LiveHeadView

-(instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, kScreenWidth, 40);
        self.backgroundColor = kBgColor;
    }
    return self;
}

-(void)setItem:(LiveListItem *)item
{
    if (item) {
        
        self.typeLabel.text = item.partition.name;
        self.typeLabel.frame = CGRectMake(self.tipImageView.right+5, self.tipImageView.top, stringWidth(item.partition.name, 14), 20);
        
        [self.tipImageView setImageWithURL:[NSURL URLWithString:item.partition.sub_icon.src] options:YYWebImageOptionUseNSURLCache];
        
        if (item.moreText) {
            self.moreLabel.size = CGSizeMake(kScreenWidth-150, 20);
            self.moreLabel.right = self.moreBtn.left-10;
            self.moreLabel.top = self.typeLabel.top;
            self.moreLabel.textLayout = item.moreText;
        }
    }
}


-(UIImageView *)tipImageView
{
    if (!_tipImageView) {
        _tipImageView = [UIImageView new];
        _tipImageView.frame = CGRectMake(10, 8, 17, 17);
        [self addSubview:_tipImageView];
    }
    return _tipImageView;
}

-(UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [UILabel new];
        _typeLabel.textColor = [UIColor colorWithHexString:TextColor];
        _typeLabel.backgroundColor = kBgColor;
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_typeLabel];
    }
    return _typeLabel;
}

-(YYLabel *)moreLabel
{
    if (!_moreLabel) {
        _moreLabel = [YYLabel new];
        _moreLabel.backgroundColor = kBgColor;
        _moreLabel.font = [UIFont systemFontOfSize:14];
        _moreLabel.displaysAsynchronously = YES;
        _moreLabel.ignoreCommonProperties = YES;
        _moreLabel.fadeOnAsynchronouslyDisplay = NO;
        _moreLabel.numberOfLines = 1;
        [self addSubview:_moreLabel];
    }
    return _moreLabel;
}

-(UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.frame = CGRectMake(kScreenWidth-30, 8, 20, 20);
        _moreBtn.backgroundColor = [UIColor lightGrayColor];
        _moreBtn.layer.cornerRadius = _moreBtn.width/2;
        [_moreBtn setImage:[UIImage imageNamed:@"player_input_color_more_icon"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_moreBtn];
    }
    return _moreBtn;
}

-(void)moreBtnClick
{
    if (self.moreBlock) {
        self.moreBlock();
    }
}

-(void)moreClickWithBlock:(moreClickBlock)block
{
    self.moreBlock = block;
}


@end
