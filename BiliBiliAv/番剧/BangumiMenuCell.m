//
//  BangumiMenuCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiMenuCell.h"

@interface BangumiMenuCell ()
@property (nonatomic,strong) UIButton * leftBtn;
@property (nonatomic,strong) UIButton * midBtn;
@property (nonatomic,strong) UIButton * rightBtn;
@end

@implementation BangumiMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)layout
{
    UIView * contenView = self.contentView;
    self.contentView.sd_equalWidthSubviews = @[self.leftBtn,self.midBtn,self.rightBtn];
    self.leftBtn.sd_layout.leftSpaceToView(contenView,10).topSpaceToView(contenView,10).autoHeightRatio(0.4);
    self.midBtn.sd_layout.leftSpaceToView(self.leftBtn,8).topEqualToView(self.leftBtn).autoHeightRatio(0.4);
    self.rightBtn.sd_layout.leftSpaceToView(self.leftBtn,8).topEqualToView(self.leftBtn).rightSpaceToView(contenView,10).autoHeightRatio(0.4);
    
    [self setupAutoHeightWithBottomView:self.leftBtn bottomMargin:10];
}

-(void)btnClick:(UIButton *)btn
{
   
}

-(UIButton *)leftBtn
{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_leftBtn];
        
        [_leftBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

-(UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_rightBtn];
        
        [_rightBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

-(UIButton *)midBtn
{
    if (!_midBtn) {
        _midBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_midBtn];
        
        [_midBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_midBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _midBtn;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
