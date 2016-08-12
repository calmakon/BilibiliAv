//
//  AvRecomCell.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "AvRecomCell.h"

@interface AvRecomCell ()
@property(nonatomic,strong) UIButton * leftBtn;
@property(nonatomic,strong) UIButton * rightBtn;
@end

@implementation AvRecomCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"home_bangumi_timeline"] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"home_bangumi_category"] forState:UIControlStateNormal];
    }
    return self;
}

-(CGFloat)cellHeight
{
   return 40+self.viewHeight*2+10*2+60;
}

-(UIButton *)leftBtn
{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(10, self.cellHeight-60, self.viewWidth, 40);
        _leftBtn.tag = 100;
        [self addSubview:_leftBtn];
        [_leftBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

-(UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(self.leftBtn.right+10, self.cellHeight-60, self.viewWidth, 40);
        [self addSubview:_rightBtn];
        _rightBtn.tag = 200;
        [_rightBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

-(void)btnClick
{
   
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
