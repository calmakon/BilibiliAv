//
//  PlayerLaodStatusView.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/23.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "PlayerLaodStatusView.h"

@interface PlayerLaodStatusView ()

@property(nonatomic,copy) NSArray * loadingImages;
@property(nonatomic,strong) UIImageView * loadingImageView;
@property (nonatomic,strong) UIButton * popBtn;
@property (nonatomic,copy) NSMutableArray * stastuss;
@end

@implementation PlayerLaodStatusView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self loadingImages];
        [self loadingImageView];
    }
    return self;
}

-(NSMutableArray *)stastuss
{
    if (!_stastuss) {
        _stastuss = [NSMutableArray array];
    }
    return _stastuss;
}

-(void)layoutSubviews
{
    self.popBtn.left = 10;
    self.popBtn.top = 20;
    self.popBtn.size = CGSizeMake(20, 20);
    
   self.loadingImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

-(void)setLoadingStatus:(NSString *)loadingStatus
{
    if (!loadingStatus) return;
    
    [self addStatusWithStr:loadingStatus];
}

-(void)addStatusWithStr:(NSString *)status
{
    UILabel * statusLabel = [UILabel new];
    statusLabel.font = [UIFont systemFontOfSize:14];
    statusLabel.textColor = [UIColor lightGrayColor];
    statusLabel.text = status;
    [self addSubview:statusLabel];
    
    [self.stastuss addObject:statusLabel];
    
    [self reSetStatusFrame];
}

-(void)resetLoadingView
{
    [self.stastuss removeAllObjects];
    [self removeAllSubviews];
    [self removeFromSuperview];
}

-(void)reSetStatusFrame
{
    NSInteger num=0;
    for (NSInteger i=self.stastuss.count-1; i>=0; i--) {
        num++;
        UILabel * statusLabel = self.stastuss[i];
        statusLabel.frame = CGRectMake(0, self.height-num* 20, [statusLabel.text widthForFont:statusLabel.font], 20);
    }
}

-(UIImageView *)loadingImageView
{
    if (!_loadingImageView) {
        _loadingImageView = [UIImageView new];
        _loadingImageView.size = CGSizeMake(80, 80);
        _loadingImageView.animationImages = self.loadingImages;
        _loadingImageView.animationDuration = 0.5;
        _loadingImageView.animationRepeatCount = -1;
        [_loadingImageView startAnimating];
        [self addSubview:_loadingImageView];
    }
    return _loadingImageView;
}

-(UIButton *)popBtn
{
    if (!_popBtn) {
        _popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_popBtn setImage:[UIImage imageNamed:@"icnav_back_dark"] forState:UIControlStateNormal];
        [self addSubview:_popBtn];
    }
    return _popBtn;
}

-(NSArray *)loadingImages
{
    if (!_loadingImages) {
        _loadingImages = @[[UIImage imageNamed:@"ani_loading_1"],[UIImage imageNamed:@"ani_loading_2"],[UIImage imageNamed:@"ani_loading_3"],[UIImage imageNamed:@"ani_loading_4"],[UIImage imageNamed:@"ani_loading_5"]];
    }
    return _loadingImages;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
