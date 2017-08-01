//
//  LiveToolView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/12/2.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveToolView.h"

@interface LiveToolView ()
{
    BOOL _isShow;
}
@property (nonatomic,strong) UIButton * popBackBtn;
@property (nonatomic,strong) UIButton * pauseBtn;
@property (nonatomic,strong) UIButton * allScreenBtn;
@property (nonatomic,strong) UIButton * moreBtn;
@property (nonatomic,strong) UIImageView * topBarView;
@property (nonatomic,strong) UIImageView * bottomBarView;

@end

@implementation LiveToolView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self layout];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolBarStatus:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)toolBarStatus:(UITapGestureRecognizer *)tap
{
    if (_isShow) {
        [self hidden];
    }else{
        [self showBarView];
    }
}

-(void)layout
{
    [self.topBarView addSubview:self.popBackBtn];
    [self.topBarView addSubview:self.moreBtn];
    [self.bottomBarView addSubview:self.pauseBtn];
    [self.bottomBarView addSubview:self.allScreenBtn];
    
    self.topBarView.sd_layout.leftEqualToView(self).topEqualToView(self).rightEqualToView(self).heightIs(40);
    self.bottomBarView.sd_layout.leftEqualToView(self).bottomEqualToView(self).rightEqualToView(self).heightIs(40);
    
    self.popBackBtn.sd_layout.leftSpaceToView(self.topBarView,15).topSpaceToView(self.topBarView,25).widthIs(20).heightIs(22);
    self.moreBtn.sd_layout.rightSpaceToView(self.topBarView,15).topEqualToView(self.popBackBtn).widthIs(20).heightIs(22);
    
    self.pauseBtn.sd_layout.leftSpaceToView(self.bottomBarView,15).bottomSpaceToView(self.bottomBarView,10).widthIs(15).heightIs(18);
    self.allScreenBtn.sd_layout.rightSpaceToView(self.bottomBarView,15).bottomEqualToView(self.pauseBtn).widthIs(15).heightIs(18);
    
}

-(void)showBarView
{
   [UIView animateWithDuration:0.5 animations:^{
       self.topBarView.alpha = 1;
       self.bottomBarView.alpha = 1;
   } completion:^(BOOL finished) {
       [self performSelector:@selector(hidden) withObject:nil afterDelay:3];
       _isShow = YES;
   }];
}

-(void)hidden
{
    if (!_isShow) return;
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = 0;
        self.bottomBarView.alpha = 0;
        _isShow = NO;
    }];
}

-(void)clickWithType:(UIButton *)sender
{
    if (self.clickBlock) {
        BtnType type = sender.tag;
        if (sender.tag == Pause) {
            sender.selected = !sender.selected;
        }
        self.clickBlock(type);
    }
}

-(void)toolBarBtnClickWithBlock:(ToolBarClickBlock)block
{
    self.clickBlock = block;
}

-(UIImageView *)topBarView
{
    if (!_topBarView) {
        _topBarView = [UIImageView new];
        _topBarView.image = [UIImage imageNamed:@"live_player_vtop_bg@2x~iphone"];
        [self addSubview:_topBarView];
        _topBarView.userInteractionEnabled = YES;
    }
    return _topBarView;
}

-(UIImageView *)bottomBarView
{
    if (!_bottomBarView) {
        _bottomBarView = [UIImageView new];
        _bottomBarView.image = [UIImage imageNamed:@"live_player_vbottom_bg@2x~iphone"];
        [self addSubview:_bottomBarView];
        _bottomBarView.userInteractionEnabled = YES;
    }
    return _bottomBarView;
}

-(UIButton *)popBackBtn
{
    if (!_popBackBtn) {
        _popBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_popBackBtn setBackgroundImage:[UIImage imageNamed:@"live_back_ico@2x"] forState:UIControlStateNormal];
        [_popBackBtn addTarget:self action:@selector(clickWithType:) forControlEvents:UIControlEventTouchUpInside];
        _popBackBtn.tag = PopBack;
    }
    return _popBackBtn;
}

-(UIButton *)pauseBtn
{
    if (!_pauseBtn) {
        _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseBtn setImage:[UIImage imageNamed:@"player_pause_bottom_window@2x"] forState:UIControlStateNormal];
        [_pauseBtn setImage:[UIImage imageNamed:@"player_play_bottom_window@2x"] forState:UIControlStateSelected];
        [_pauseBtn addTarget:self action:@selector(clickWithType:) forControlEvents:UIControlEventTouchUpInside];
        _pauseBtn.tag = Pause;
    }
    return _pauseBtn;
}

-(UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setBackgroundImage:[UIImage imageNamed:@"live_more_normal_portrait@2x"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(clickWithType:) forControlEvents:UIControlEventTouchUpInside];
        _moreBtn.tag = More;
    }
    return _moreBtn;
}

-(UIButton *)allScreenBtn
{
    if (!_allScreenBtn) {
        _allScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_allScreenBtn setImage:[UIImage imageNamed:@"player_fullScreen_iphone@2x"] forState:UIControlStateNormal];
        [_allScreenBtn addTarget:self action:@selector(clickWithType:) forControlEvents:UIControlEventTouchUpInside];
        _allScreenBtn.tag = AllScreen;
    }
    return _allScreenBtn;
}

@end
