//
//  HostRecommendCell.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "HostRecommendCell.h"

@interface HostRecommendCell ()
@property(nonatomic,strong) UIButton * refreshBtn;
@property (nonatomic,strong) NSTimer * timer;
@end

@implementation HostRecommendCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self refreshBtn];
        
    }
    return self;
}

-(UIButton *)refreshBtn
{
    if (!_refreshBtn) {
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshBtn.frame = CGRectMake(60, self.bgView.height-44, [UIScreen mainScreen].bounds.size.width-120, 34);
        [_refreshBtn setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1]];
        [_refreshBtn setTitleColor:[UIColor colorWithHexString:TextColor] forState:UIControlStateNormal];
        [_refreshBtn setImage:[UIImage imageNamed:@"home_refresh"] forState:UIControlStateNormal];
        _refreshBtn.imageEdgeInsets = UIEdgeInsetsMake(0, _refreshBtn.width-34, 0, 10);
        _refreshBtn.layer.cornerRadius = 17;
        [_refreshBtn setTitle:@"换一波推荐" forState:UIControlStateNormal];
        _refreshBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.bgView addSubview:_refreshBtn];
        
        [_refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

-(void)refreshBtnClick
{
    if (self.refresh) {
        self.refresh(self);
    }
}

-(void)animaiton
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = INT_MAX;
    
    [self.refreshBtn.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)stopAnimation
{
    [self.refreshBtn.imageView.layer removeAnimationForKey:@"rotationAnimation"];
}

-(void)refreshCurrentCellWithBlock:(refreshBlock)blcok
{
    self.refresh = blcok;
}

@end
