//
//  AvListCell.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/3.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "AvListCell.h"
@interface AvListCell ()
{
    NSInteger _configNum;
}
@property(nonatomic,strong) UIButton * moreBtn;
@property(nonatomic,strong) UILabel * refreshLabel;
@property(nonatomic,strong) UIButton * refreshBtn;

@end

@implementation AvListCell

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _configNum = 20;
        self.refreshBtn.sd_layout.topEqualToView(self.moreBtn).rightSpaceToView(self.bgView,10).widthIs(self.viewWidth).heightIs(self.moreBtn.height);
        self.refreshBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.refreshBtn.width-24, 0, 0);
    }
    return self;
}

-(void)setTypeName:(NSString *)typeName
{
    [self.moreBtn setTitle:[NSString stringWithFormat:@"更多%@",typeName] forState:UIControlStateNormal];
//    [self.refreshBtn setTitle:[NSString stringWithFormat:@"%ld条动态，点击刷新",_configNum+=arc4random()%15] forState:UIControlStateNormal];
}

-(UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.frame = CGRectMake(10, self.bgView.height-44, self.viewWidth-20, 34);
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _moreBtn.layer.borderWidth = 1;
        _moreBtn.layer.borderColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1].CGColor;
        _moreBtn.layer.cornerRadius = 5;
    
        [_moreBtn addTarget:self action:@selector(moreBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:_moreBtn];
    }
    return _moreBtn;
}

-(UIButton *)refreshBtn
{
    if (!_refreshBtn) {
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshBtn setTitleColor:[UIColor colorWithHexString:TextColor] forState:UIControlStateNormal];
        [_refreshBtn setImage:[UIImage imageNamed:@"home_refresh"] forState:UIControlStateNormal];
        [_refreshBtn setTitle:@"" forState:UIControlStateNormal];
        _refreshBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.bgView addSubview:_refreshBtn];
        
        [_refreshBtn setTitle:[NSString stringWithFormat:@"%ld条动态，点击刷新",arc4random()%_configNum] forState:UIControlStateNormal];
        
        [_refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

-(void)moreBtnClick
{
    NSLog(@"更多");
}

-(void)refreshBtnClick
{
    if (self.refresh) {
        self.refresh(self);
    }
}

-(void)refreshCurrentCellWithBlock:(refreshListBlock)blcok
{
    self.refresh = blcok;
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
