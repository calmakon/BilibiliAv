//
//  LatestUpdateCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LatestUpdateCell.h"
#import "BangumiImageView.h"
#import "YYLabel.h"

@interface LatestUpdateCell ()
@property(nonatomic,strong) UIImageView * tipImageView;
@property(nonatomic,strong) UILabel * typeLabel;
@property(nonatomic,strong) YYLabel * gotoInfoLabel;
@property(nonatomic,strong) UIButton * gotoInfoBtn;
@property(nonatomic,copy) NSMutableArray * dataArray;
@end
@implementation LatestUpdateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CALayer * bgLayer = [CALayer layer];
        bgLayer.size = CGSizeMake(kScreenWidth, 8);
        bgLayer.backgroundColor = kBgColor.CGColor;
        [self.layer addSublayer:bgLayer];
        
        self.tipImageView.frame = CGRectMake(10, 8, 17, 17);
        [self gotoInfoBtn];
    }
    return self;
}

-(void)setList:(BangumiList *)list
{
    self.typeLabel.frame = CGRectMake(self.tipImageView.right+5, self.tipImageView.top, stringWidth(self.typeLabel.text, 14), 20);
    
    if (list.gotoInfoText) {
        self.gotoInfoLabel.size = CGSizeMake(kScreenWidth-150, 20);
        self.gotoInfoLabel.right = self.gotoInfoBtn.left-10;
        self.gotoInfoLabel.top = self.typeLabel.top;
        self.gotoInfoLabel.textLayout = list.gotoInfoText;
    }
}

-(UIView *)bgView
{
    if (!_bgView) {
        _bgView = [UIView new];
        _bgView.size = CGSizeMake(kScreenWidth, self.cellHeight-8);
        _bgView.top = 8;
        _bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bgView];
        
        CALayer * topLine = [CALayer layer];
        topLine.size = CGSizeMake(kScreenWidth, CGFloatFromPixel(2));
        topLine.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1].CGColor;
        
        CALayer * bottomLine = [CALayer layer];
        bottomLine.size = CGSizeMake(kScreenWidth, CGFloatFromPixel(2));
        bottomLine.bottom = _bgView.height;
        bottomLine.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1].CGColor;
        [_bgView.layer addSublayer:topLine];
        [_bgView.layer addSublayer:bottomLine];
    }
    return _bgView;
}

-(UIImageView *)tipImageView
{
    if (!_tipImageView) {
        _tipImageView = [UIImageView new];
        _tipImageView.image = [UIImage imageNamed:@"bangumi_unfinished"];
        [self.bgView addSubview:_tipImageView];
    }
    return _tipImageView;
}

-(UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [UILabel new];
        _typeLabel.textColor = [UIColor colorWithHexString:TextColor];
        _typeLabel.text = @"新番连载";
        _typeLabel.backgroundColor = [UIColor whiteColor];
        _typeLabel.textAlignment = NSTextAlignmentLeft;
        _typeLabel.font = [UIFont systemFontOfSize:14];
        [self.bgView addSubview:_typeLabel];
    }
    return _typeLabel;
}

-(YYLabel *)gotoInfoLabel
{
    if (!_gotoInfoLabel) {
        _gotoInfoLabel = [YYLabel new];
        _gotoInfoLabel.backgroundColor = [UIColor whiteColor];
        _gotoInfoLabel.font = [UIFont systemFontOfSize:14];
        _gotoInfoLabel.displaysAsynchronously = YES;
        _gotoInfoLabel.ignoreCommonProperties = YES;
        _gotoInfoLabel.fadeOnAsynchronouslyDisplay = NO;
        _gotoInfoLabel.numberOfLines = 1;
        [self.bgView addSubview:_gotoInfoLabel];
    }
    return _gotoInfoLabel;
}

-(UIButton *)gotoInfoBtn
{
    if (!_gotoInfoBtn) {
        _gotoInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _gotoInfoBtn.frame = CGRectMake(kScreenWidth-30, 8, 20, 20);
        _gotoInfoBtn.backgroundColor = [UIColor lightGrayColor];
        _gotoInfoBtn.layer.cornerRadius = _gotoInfoBtn.width/2;
        [_gotoInfoBtn setImage:[UIImage imageNamed:@"player_input_color_more_icon"] forState:UIControlStateNormal];
        [_gotoInfoBtn addTarget:self action:@selector(gotoInfoBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:_gotoInfoBtn];
    }
    return _gotoInfoBtn;
}

-(void)gotoInfoBtnClick
{
    
}

-(void)setBodys:(NSArray *)bodys
{
    _bodys = bodys;
    if (bodys && bodys.count>0) {
        for (int i=0; i<6; i++) {
            BangumiImageView * imageView = self.dataArray[i];
            imageView.bangumiBody = bodys[i];
        }
    }
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        for (int i=0; i<6; i++) {
            BangumiImageView * imageView = [[BangumiImageView alloc] init];
            imageView.frame = CGRectMake(10+i%2*(10+self.viewWidth), 40+i/2*(10+self.viewHeight), self.viewWidth, self.viewHeight);
            [self.bgView addSubview:imageView];
            imageView.tag = i;
            [_dataArray addObject:imageView];
            
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avClick:)];
            [imageView addGestureRecognizer:tap];
        }
    }
    return _dataArray;
}

-(void)avClick:(UITapGestureRecognizer *)tap
{
    BangumiImageView * imageView = (BangumiImageView *)tap.view;
    if (self.block) {
        self.block(self.bodys[imageView.tag]);
    }
}

-(void)cellClickWithBlock:(cellItemClickBlock)block
{
    self.block = block;
}

-(CGFloat)viewWidth
{
    return ([UIScreen mainScreen].bounds.size.width-(10*3))/2;
}

-(CGFloat)viewHeight
{
    return self.viewWidth*0.6+30+8+10;
}

-(CGFloat)cellHeight
{
    return 40+self.viewHeight*3+10*2;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
