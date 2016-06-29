//
//  TvCell.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "TvCell.h"
#import "TvView.h"
@interface TvCell ()
@property(nonatomic,strong) UIView * bgView;
@property(nonatomic,copy) NSMutableArray * viewArray;
@property(nonatomic,strong) UIImageView * tipImageView;
@property(nonatomic,strong) UILabel * typeLabel;
@property(nonatomic,strong) UILabel * goInfoLabel;
@property (nonatomic,strong) UIButton * goInfoBtn;
@property(nonatomic,strong) UIScrollView * scrollView;
@end

@implementation TvCell

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CALayer * bgLayer = [CALayer layer];
        bgLayer.size = CGSizeMake(kScreenWidth, 8);
        bgLayer.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1].CGColor;
        [self.layer addSublayer:bgLayer];
        
        self.tipImageView.frame = CGRectMake(10, 10, 14, 14);
        self.typeLabel.frame = CGRectMake(self.tipImageView.right+5, self.tipImageView.top, 0, 15);
        [self scrollView];
        [self goInfoBtn];
        [self goInfoLabel];
    }
    return self;
}

-(void)setBodys:(NSArray *)bodys
{
    if (bodys && bodys.count>0) {
        for (int i=0; i<bodys.count; i++) {
            TvView * tvView = self.viewArray[i];
            tvView.dataBody = bodys[i];
        }
    }
}

-(void)setList:(TuiJianList *)list
{
    if (list.head) {
        self.typeLabel.text = list.head.title;
        self.typeLabel.frame = CGRectMake(self.tipImageView.right+5, self.tipImageView.top, stringWidth(list.head.title, 14), 15);
    }
    if (list.tipImageName) {
        self.tipImageView.image = [UIImage imageNamed:list.tipImageName];
    }
}

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.size = CGSizeMake(kScreenWidth, 168);
        _bgView.top = 8;
        _bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bgView];
    }
    return _bgView;
}

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self.bgView addSubview:_scrollView];
        _scrollView.exclusiveTouch = YES;
        CGFloat width = ([UIScreen mainScreen].bounds.size.width-30)/2.5;
        CGFloat height = width*1.4;
        for (int i=0; i<6; i++) {
            TvView * tvView = [[TvView alloc] initWithFrame:CGRectMake(10+i*(10+width), 0, width, height+40)];
            [_scrollView addSubview:tvView];
            [self.viewArray addObject:tvView];
        }
        _scrollView.frame = CGRectMake(0, 40, self.bgView.width, height+40);
        _scrollView.contentSize = CGSizeMake(width*6+7*10, 0);
    }
    return _scrollView;
}

-(UIImageView *)tipImageView
{
    if (!_tipImageView) {
        _tipImageView = [UIImageView new];
        [self.bgView addSubview:_tipImageView];
    }
    return _tipImageView;
}

-(UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [UILabel new];
        _typeLabel.textColor = [UIColor colorWithHexString:TextColor];
        _typeLabel.backgroundColor = [UIColor whiteColor];
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.font = [UIFont systemFontOfSize:14];
        [self.bgView addSubview:_typeLabel];
    }
    return _typeLabel;
}

-(UILabel *)goInfoLabel
{
    if (!_goInfoLabel) {
        _goInfoLabel = [UILabel new];
        _goInfoLabel.textColor = [UIColor colorWithHexString:TextColor];
        _goInfoLabel.backgroundColor = [UIColor whiteColor];
        _goInfoLabel.textAlignment = NSTextAlignmentLeft;
        _goInfoLabel.font = [UIFont systemFontOfSize:14];
        _goInfoLabel.text = @"进去看看";
        _goInfoLabel.frame = CGRectMake(kScreenWidth-30-[_goInfoLabel.text widthForFont:_goInfoLabel.font]-10, 8, [_goInfoLabel.text widthForFont:_goInfoLabel.font], 20);
        [self.bgView addSubview:_goInfoLabel];
    }
    return _goInfoLabel;
}

-(UIButton *)goInfoBtn
{
    if (!_goInfoBtn) {
        _goInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goInfoBtn.frame = CGRectMake(kScreenWidth-30, 8, 20, 20);
        _goInfoBtn.backgroundColor = [UIColor lightGrayColor];
        _goInfoBtn.layer.cornerRadius = _goInfoBtn.width/2;
        [_goInfoBtn setImage:[UIImage imageNamed:@"player_input_color_more_icon"] forState:UIControlStateNormal];
        [_goInfoBtn addTarget:self action:@selector(gotoInfoBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:_goInfoBtn];
    }
    return _goInfoBtn;
}

-(void)gotoInfoBtnClick
{
   
}

-(NSMutableArray *)viewArray
{
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
