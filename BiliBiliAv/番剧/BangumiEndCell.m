//
//  BangumiEndCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiEndCell.h"
#import "BangumiEndView.h"

@interface BangumiEndCell ()
@property(nonatomic,strong) UIView * bgView;
@property(nonatomic,copy) NSMutableArray * viewArray;
@property(nonatomic,strong) UIImageView * tipImageView;
@property(nonatomic,strong) UILabel * typeLabel;
@property(nonatomic,strong) UILabel * goInfoLabel;
@property (nonatomic,strong) UIButton * goInfoBtn;
@property(nonatomic,strong) UIScrollView * scrollView;
@end

@implementation BangumiEndCell

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
        
        self.tipImageView.frame = CGRectMake(10, 10, 14, 14);
        self.typeLabel.frame = CGRectMake(self.tipImageView.right+5, self.tipImageView.top, stringWidth(self.typeLabel.text, 14), 15);
    }
    return self;
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
            BangumiEndView * tvView = [[BangumiEndView alloc] initWithFrame:CGRectMake(10+i*(10+width), 0, width, height+40)];
            tvView.tag = i;
            [_scrollView addSubview:tvView];
            
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avClick:)];
            [tvView addGestureRecognizer:tap];
            
            [self.viewArray addObject:tvView];
        }
        _scrollView.frame = CGRectMake(0, 40, self.bgView.width, height+40);
        _scrollView.contentSize = CGSizeMake(width*6+7*10, 0);
    }
    return _scrollView;
}

-(void)avClick:(UITapGestureRecognizer *)tap
{
    BangumiEndView * imageView = (BangumiEndView *)tap.view;
    if (self.itemBlock) {
        self.itemBlock(self.endBodys[imageView.tag]);
    }
}

-(void)itemClickWithBlock:(ItemClickBlock)block
{
    self.itemBlock = block;
}

-(UIImageView *)tipImageView
{
    if (!_tipImageView) {
        _tipImageView = [UIImageView new];
        _tipImageView.image = [UIImage imageNamed:@"hd_home_region_icon_32_s"];
        [self.bgView addSubview:_tipImageView];
    }
    return _tipImageView;
}

-(UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [UILabel new];
        _typeLabel.text = @"完结动画";
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


-(void)setEndBodys:(NSArray *)endBodys
{
    _endBodys = endBodys;
    if (endBodys && endBodys.count>0) {
        for (int i=0; i<endBodys.count; i++) {
            BangumiEndView * endView = (BangumiEndView *)self.viewArray[i];
            endView.endBody = endBodys[i];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
