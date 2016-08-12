//
//  MineHeadView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "MineHeadView.h"
#define kSetBtnTop 25
#define kHeadBgTop 50
#define kHeadWidth 80
//#define kHeadViewHeight 140
@interface MineHeadView ()
@property (nonatomic,strong) UIImageView * headBgView;
@property (nonatomic,strong) UIImageView * headView;
@property (nonatomic,strong) UILabel * userNameLabel;
@property (nonatomic,strong) UIImageView * lvImageView;
@property (nonatomic,strong) UIImageView * sexImageView;
@property (nonatomic,strong) UILabel * typeLabel;
@property (nonatomic,strong) UILabel * coinsLabel;
@property (nonatomic,strong) UIImageView * infoImageView;
@property (nonatomic,strong) UIButton * setBtn;
@end

@implementation MineHeadView

-(instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = kStyleColor;
        [self layout];
    }
    return self;
}

-(void)layout
{
    [self setBtn];
    [self headView];
    [self headBgView];
    [self userNameLabel];
    [self lvImageView];
    [self sexImageView];
    [self typeLabel];
    [self coinsLabel];
    [self infoImageView];
    
    self.setBtn.sd_layout.topSpaceToView(self,kSetBtnTop).rightSpaceToView(self,10).widthIs(20).heightIs(20);
    
    self.headView.sd_layout.leftSpaceToView(self,10+15).topSpaceToView(self,kHeadBgTop+15).widthIs(kHeadWidth-30).heightEqualToWidth();
    self.headView.sd_cornerRadius = @(self.headView.height/2);
    self.headBgView.sd_layout.leftSpaceToView(self,10).topSpaceToView(self,kHeadBgTop).widthIs(kHeadWidth).heightEqualToWidth();
    
    self.userNameLabel.sd_layout.leftSpaceToView(self.headBgView,10).topSpaceToView(self,kHeadBgTop+5).heightIs(20);
    [self.userNameLabel setSingleLineAutoResizeWithMaxWidth:200];
    
    self.lvImageView.sd_layout.leftSpaceToView(self.userNameLabel,5).centerYEqualToView(self.userNameLabel).heightIs(10).widthIs(15);
    
    self.sexImageView.sd_layout.leftSpaceToView(self.lvImageView,5).topEqualToView(self.lvImageView).heightIs(10).widthIs(10);
    
    self.typeLabel.sd_layout.leftEqualToView(self.userNameLabel).topSpaceToView(self.userNameLabel,5).heightIs(15);
    [self.typeLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    self.coinsLabel.sd_layout.leftEqualToView(self.userNameLabel).topSpaceToView(self.typeLabel,5).heightIs(15);
    [self.coinsLabel setSingleLineAutoResizeWithMaxWidth:120];
    
    self.infoImageView.sd_layout.centerYEqualToView(self.headBgView).rightSpaceToView(self,10).widthIs(10).heightIs(15);
    [self setupAutoHeightWithBottomView:self.headBgView bottomMargin:10];
}

-(void)setUser:(UserModel *)user
{
    if (!user) return;
    [self.headView setImage:[UIImage imageNamed:@"头像01"]];
    self.userNameLabel.text = user.userName;
    self.typeLabel.text = [NSString stringWithFormat:@"%@",user.type?@"正式会员":@"普通观众"];
    self.typeLabel.layer.borderWidth = 1;
    self.typeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.typeLabel.layer.cornerRadius = 3;
    self.typeLabel.layer.masksToBounds = YES;
    
    
    self.coinsLabel.text = [NSString stringWithFormat:@"硬币：%@",user.coins];
    
    [self.lvImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"misc_level_whiteLv%ld",[user.lv integerValue]]]];
    
    if (user.sex && [user.sex integerValue] == 0) {
        self.sexImageView.image = [UIImage imageNamed:@"misc_sex_male"];
    }else if ([user.sex integerValue] == 1){
        self.sexImageView.image = [UIImage imageNamed:@"misc_sex_female"];
    }else{
        self.sexImageView.image = [UIImage imageNamed:@"misc_sex_sox"];
    }
}

-(UIImageView *)headBgView
{
    if (!_headBgView) {
        _headBgView = [UIImageView new];
        _headBgView.image = [UIImage imageNamed:@"mine_bg_avatar@2x~iphone"];
        [self addSubview:_headBgView];
    }
    return _headBgView;
}

-(UIImageView *)headView
{
    if (!_headView) {
        _headView = [UIImageView new];
        [self addSubview:_headView];
    }
    return _headView;
}

-(UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [UILabel new];
        _userNameLabel.font = [UIFont systemFontOfSize:15];
        _userNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:_userNameLabel];
    }
    return _userNameLabel;
}

-(UIImageView *)lvImageView
{
    if (!_lvImageView) {
        _lvImageView = [UIImageView new];
        [self addSubview:_lvImageView];
    }
    return _lvImageView;
}

-(UIImageView *)sexImageView
{
    if (!_sexImageView) {
        _sexImageView = [UIImageView new];
        [self addSubview:_sexImageView];
    }
    return _sexImageView;
}

-(UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [UILabel new];
        _typeLabel.font = [UIFont systemFontOfSize:10];
        _typeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_typeLabel];
    }
    return _typeLabel;
}

-(UILabel *)coinsLabel
{
    if (!_coinsLabel) {
        _coinsLabel = [UILabel new];
        _coinsLabel.font = [UIFont systemFontOfSize:12];
        _coinsLabel.textColor = [UIColor whiteColor];
        [self addSubview:_coinsLabel];
    }
    return _coinsLabel;
}

-(UIImageView *)infoImageView
{
    if (!_infoImageView) {
        _infoImageView = [UIImageView new];
        _infoImageView.image = [UIImage imageNamed:@"player_input_color_more_icon"];
        [self addSubview:_infoImageView];
    }
    return _infoImageView;
}

-(UIButton *)setBtn
{
    if (!_setBtn) {
        _setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setBtn setBackgroundImage:[UIImage imageNamed:@"mine_settings@2x~iphone"] forState:UIControlStateNormal];
        [_setBtn addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_setBtn];
    }
    return _setBtn;
}

-(void)setClick
{
   
}

@end
