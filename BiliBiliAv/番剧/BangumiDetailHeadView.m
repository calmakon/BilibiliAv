//
//  BangumiDetailHeadView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/7.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiDetailHeadView.h"
#import "UIImage+HYGColor.h"
#import "UIImageView+YYWebImage.h"

@interface BangumiDetailHeadView ()
@property (nonatomic,strong) UIView * contentView;
@property (nonatomic,strong) UIView * infoView;
@property (nonatomic,strong) UIScrollView * seasonView;
@property (nonatomic,strong) UIView * itemView;
@property (nonatomic,strong) UIView * briefView;
@property (nonatomic,strong) UIImageView * iconImageView;
@property (nonatomic,strong) UIButton * backBtn;
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) UILabel * bangumiTitleLabel;
@property (nonatomic,strong) UILabel * statusLabel;
@property (nonatomic,strong) UILabel * playLabel;

@property (nonatomic,strong) UILabel * numLabel;
@property (nonatomic,strong) UILabel * updataNumLabel;
@property (nonatomic,strong) UILabel * briefLabel;
@property (nonatomic,strong) UIScrollView * tagView;
@end

@implementation BangumiDetailHeadView

-(instancetype)init
{
    if (self = [super init]) {
        self.size = CGSizeMake(kScreenWidth, 0);
        [self infoView];
        [self contentView];
        [self itemView];
        [self sendSubviewToBack:self.contentView];
    }
    return self;
}

-(void)setDetail:(BangumiDeatail *)detail
{
    if (!detail) return;
    _detail = detail;
    
    [self.iconImageView setImageWithURL:[NSURL URLWithString:detail.cover] placeholder:[UIImage imageNamed:@""]];
    self.bangumiTitleLabel.text = detail.title;
    if ([detail.is_finish integerValue] != 0) {
        self.statusLabel.text = @"已完结";
    }else{
        self.statusLabel.text = [NSString stringWithFormat:@"连载中，每周%@更新",detail.weekday];
    }
    self.playLabel.text = [NSString stringWithFormat:@"播放：%@  订阅：%@",[HYGUtility shortedNumberDesc:[detail.play_count integerValue]],[HYGUtility shortedNumberDesc:[detail.favorites integerValue]]];
    
    for (UIView * view in self.itemView.subviews) {
        [view removeFromSuperview];
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeObserver:self forKeyPath:@"selected"];
        }
    }
    
    [self layoutSeasonViewWithDetail:detail];
    
    [self layoutItemViewWithDetail:detail];
}

-(void)layoutSeasonViewWithDetail:(BangumiDeatail *)detail
{
    if (detail.seasons.count<=1) return;
    CGFloat seasonItemHeight = self.seasonView.height;
    for (UIView * view in self.seasonView.subviews) {
        [view removeFromSuperview];
    }
    CGFloat x = 0;
    for (int i = 0; i<detail.seasons.count; i++) {
        Season * season = detail.seasons[i];
        UIButton * seasonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        seasonItem.titleLabel.font = [UIFont systemFontOfSize:12];
        CGFloat width = [season.title widthForFont:seasonItem.titleLabel.font]+30;
        seasonItem.left = x;
        seasonItem.top = 0;
        seasonItem.size = CGSizeMake(width, seasonItemHeight);
        x += width+5;
        if (i == 0) {
            [seasonItem setBackgroundImage:[UIImage imageNamed:@"season_seasonLeft"] forState:UIControlStateNormal];
            [seasonItem setBackgroundImage:[UIImage imageNamed:@"season_seasonLeft_s"] forState:UIControlStateSelected];
        }else if (i == detail.seasons.count-1){
            [seasonItem setBackgroundImage:[UIImage imageNamed:@"season_seasonRight"] forState:UIControlStateNormal];
            [seasonItem setBackgroundImage:[UIImage imageNamed:@"season_seasonRight_s"] forState:UIControlStateSelected];
        }else{
            [seasonItem setBackgroundImage:[UIImage imageNamed:@"season_seasonMiddle"] forState:UIControlStateNormal];
            [seasonItem setBackgroundImage:[UIImage imageNamed:@"season_seasonMiddle_s"] forState:UIControlStateSelected];
        }
        [seasonItem setTitle:season.title forState:UIControlStateNormal];
        [seasonItem setTitleColor:[UIColor colorWithHexString:TextColor] forState:UIControlStateNormal];
        [seasonItem setTitleColor:kStyleColor forState:UIControlStateSelected];
        if ([detail.season_id integerValue] == [season.season_id integerValue]) {
            seasonItem.selected = YES;
        }
        seasonItem.tag = i;
        [seasonItem addTarget:self action:@selector(seasonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.seasonView addSubview:seasonItem];
        if (i == detail.seasons.count-1) {
            self.seasonView.contentSize = CGSizeMake(seasonItem.right, 0);
        }
    }
}

-(void)layoutItemViewWithDetail:(BangumiDeatail *)detail
{
    if (detail.seasons.count>1) {
        self.itemView.top = self.seasonView.bottom;
    }
    UILabel * numLabel = [UILabel new];
    numLabel.font = [UIFont systemFontOfSize:15];
    numLabel.textAlignment = NSTextAlignmentLeft;
    [self.itemView addSubview:numLabel];
    numLabel.left = 10;
    numLabel.top = 10;
    numLabel.size = CGSizeMake(100, 20);
    numLabel.text = [NSString stringWithFormat:@"选集（%ld）",detail.episodes.count];
    self.numLabel = numLabel;
    
    UILabel * updataNumLabel = [UILabel new];
    updataNumLabel.font = [UIFont systemFontOfSize:13];
    updataNumLabel.textAlignment = NSTextAlignmentRight;
    [self.itemView addSubview:updataNumLabel];
    updataNumLabel.left = kScreenWidth-110;
    updataNumLabel.top = 10;
    updataNumLabel.size = CGSizeMake(100, 20);
    
    if ([detail.is_finish integerValue] != 0) {
        updataNumLabel.text = [NSString stringWithFormat:@"全%ld话",detail.episodes.count];
        //如果是已完结番剧，并且第一集是最后一集，倒序数组
        if ([[detail.episodes[0] index] integerValue]>1) {
            detail.episodes = [[detail.episodes reverseObjectEnumerator] allObjects];
        }
    }else{
        updataNumLabel.text = [NSString stringWithFormat:@"更新 第%@话",detail.newest_ep_index];
    }
    self.updataNumLabel = updataNumLabel;
    
    CGFloat itemPadding = 10;
    CGFloat itemWidth = (kScreenWidth-5*itemPadding)/4;
    CGFloat itemHeight = itemWidth*0.5;
    
    for (int i=0; i<detail.episodes.count; i++) {
        BangumiAvBody * body = detail.episodes[i];
        UIButton * itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [itemBtn setTitle:body.index forState:UIControlStateNormal];
        itemBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [itemBtn setTitleColor:[UIColor colorWithHexString:TextColor] forState:UIControlStateNormal];
        [itemBtn setTitleColor:kStyleColor forState:UIControlStateSelected];
        itemBtn.left = itemPadding+i%4*(itemWidth+itemPadding);
        itemBtn.top = numLabel.bottom+10+i/4*(itemPadding+itemHeight);
        itemBtn.size = CGSizeMake(itemWidth, itemHeight);
        itemBtn.tag = i;
        [itemBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        itemBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        itemBtn.layer.borderWidth = kCGFloatFromPixel(1);
        itemBtn.layer.cornerRadius = 5;
        itemBtn.clipsToBounds = YES;
        [itemBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
        [self.itemView addSubview:itemBtn];
        
        if ([detail.is_finish integerValue] != 0&&i == 0) {
            itemBtn.selected = YES;
        }else if([detail.is_finish integerValue] == 0&&i == detail.episodes.count-1){
            itemBtn.selected = YES;
        }
        
        if (i == detail.episodes.count-1) {
            self.itemView.height = itemBtn.bottom+itemPadding;
        }
    }
    
    [self layoutBriefViewWithDetail:detail];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    UIButton * itemBtn = (UIButton *)object;
    if ([keyPath isEqualToString:@"selected"]) {
        if ([[change objectForKey:@"new"] integerValue] == YES) {
            itemBtn.layer.borderColor = kStyleColor.CGColor;
            itemBtn.layer.borderWidth = kCGFloatFromPixel(1);
        }else{
            itemBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            itemBtn.layer.borderWidth = kCGFloatFromPixel(1);
        }
    }
}

-(void)layoutBriefViewWithDetail:(BangumiDeatail *)detail
{
    self.briefView.top = self.itemView.bottom;
    self.briefLabel.text = detail.brief;
    self.briefLabel.left = 10;
    self.briefLabel.top = 40;
    self.briefLabel.size = [detail.brief sizeForFont:self.briefLabel.font size:CGSizeMake(self.briefView.width-20, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
    
    self.tagView.top = self.briefLabel.bottom+15;
    self.tagView.left = 10;
    self.tagView.size = CGSizeMake(self.briefView.width-20, 25);
    self.briefView.height = self.tagView.bottom+10;
    
    if (detail.tags.count == 0) return;
    for (UIView * view in self.tagView.subviews) {
        [view removeFromSuperview];
    }

    CGFloat x = 0;
    for (int i=0; i<detail.tags.count; i++) {
        Tag * tag = detail.tags[i];
        UIButton * tagBtn = [UIButton new];
        [self.tagView addSubview:tagBtn];
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [tagBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [tagBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        [tagBtn setTitleColor:[UIColor colorWithHexString:TextColor] forState:UIControlStateNormal];
        [tagBtn setTitle:tag.tag_name forState:UIControlStateNormal];
        CGFloat width = [tag.tag_name widthForFont:tagBtn.titleLabel.font]+20;
        tagBtn.left = x;
        tagBtn.top = 0;
        tagBtn.size = CGSizeMake(width, self.tagView.height);
        tagBtn.layer.cornerRadius = tagBtn.height/2;
        tagBtn.clipsToBounds = YES;
        tagBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        tagBtn.layer.borderWidth = CGFloatFromPixel(1);
        x += 10+width;
        if (i == detail.tags.count-1) {
            self.tagView.contentSize = CGSizeMake(tagBtn.right, 0);
        }
    }
    self.contentView.height = self.briefView.bottom;
    self.height = self.contentView.bottom;
}

-(void)itemClick:(UIButton *)itemBtn
{
    BangumiAvBody * body = self.detail.episodes[itemBtn.tag];
    for (UIView * view in self.itemView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton * btn = (UIButton *)view;
            if (btn.tag == itemBtn.tag) {
                btn.selected = YES;
                if (self.itemBlock) {
                    self.itemBlock(body);
                }
            }else{
                btn.selected = NO;
            }
        }
    }
}

-(void)itemClickedWithBlock:(ItemClickBlock)block
{
    self.itemBlock = block;
}

-(void)seasonClick:(UIButton *)seasonItem
{
    Season * season = self.detail.seasons[seasonItem.tag];
    for (UIView * view in self.seasonView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton * btn = (UIButton *)view;
            if (btn.tag == seasonItem.tag) {
                btn.selected = YES;
                if (self.seasonBlock) {
                    self.seasonBlock(season);
                }
            }else{
                btn.selected = NO;
            }
        }
    }
}

-(void)seasonItemClickedWithBlock:(seasonItemClickBlock)block
{
    self.seasonBlock = block;
}

-(UIView *)contentView
{
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = kBgColor;
        [self addSubview:_contentView];
        
        _contentView.left = 0;
        _contentView.top = self.infoView.height-30;
        _contentView.width = kScreenWidth;
        _contentView.height = 0;
    }
    return _contentView;
}

-(UIView *)infoView
{
    if (!_infoView) {
        _infoView = [UIView new];
        _infoView.backgroundColor = [UIColor clearColor];
        _infoView.size = CGSizeMake(kScreenWidth, 140);
        [self addSubview:_infoView];
        
        [_infoView addSubview:self.backBtn];
        [self.backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.backBtn.left = 10;
        self.backBtn.top = 30;
        self.backBtn.size = CGSizeMake(20, 18);
        
        [_infoView addSubview:self.titleLabel];
        self.titleLabel.top = self.backBtn.top;
        self.titleLabel.width = [self.titleLabel.text widthForFont:self.titleLabel.font];
        self.titleLabel.left = _infoView.width/2-self.titleLabel.width/2;
        self.titleLabel.height = 20;
        
        [_infoView addSubview:self.iconImageView];
        self.iconImageView.left = 10;
        self.iconImageView.top = self.backBtn.bottom+10;
        self.iconImageView.size = CGSizeMake(kScreenWidth*0.3, (kScreenWidth*0.3)*1.3);
        _infoView.height = self.iconImageView.bottom;
        
        
        [_infoView addSubview:self.bangumiTitleLabel];
        self.bangumiTitleLabel.left = self.iconImageView.right+10;
        self.bangumiTitleLabel.top = self.iconImageView.top;
        self.bangumiTitleLabel.size = CGSizeMake(kScreenWidth-self.bangumiTitleLabel.left-10, 20);
        
        [_infoView addSubview:self.statusLabel];
        self.statusLabel.left = self.bangumiTitleLabel.left;
        self.statusLabel.top = self.bangumiTitleLabel.bottom+5;
        self.statusLabel.size = CGSizeMake(self.bangumiTitleLabel.width, 15);
        
        [_infoView addSubview:self.playLabel];
        self.playLabel.left = self.bangumiTitleLabel.left;
        self.playLabel.top = self.statusLabel.bottom+5;
        self.playLabel.size = CGSizeMake(self.bangumiTitleLabel.width, 15);
        
        NSArray * titleArray = @[@"分 享",@"追 番",@"缓 存"];
        CGFloat btnWidth = 40;
        CGFloat btnPadding = ((kScreenWidth-self.iconImageView.right)-btnWidth*3)/4;
        for (int i=0; i<3; i++) {
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.size = CGSizeMake(btnWidth, btnWidth);
            btn.left = self.iconImageView.right+btnPadding+i*(btnWidth+btnPadding);
            btn.top = _infoView.height-55;
            [btn setBackgroundImage:[UIImage imageNamed:@"iphonevideoinfo_button@2x~iphone"] forState:UIControlStateNormal];
            [_infoView addSubview:btn];
            
            [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel * label = [UILabel new];
            label.size = CGSizeMake(btnWidth, 15);
            label.text = titleArray[i];
            label.top = btn.bottom+2;
            label.left = btn.left;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor colorWithHexString:TextColor];
            [_infoView addSubview:label];
            
            switch (i) {
                case 0:
                    [btn setImage:[[UIImage imageNamed:@"iphonevideoinfo_share"] imageWithColor:[UIColor colorWithRed:0.18 green:0.78 blue:0.49 alpha:1]] forState:UIControlStateNormal];
                    //self.shareBtn = button;
                    break;
                case 1:
                    [btn setImage:[[UIImage imageNamed:@"videoinfo_followbangumi"] imageWithColor:[UIColor colorWithRed:0.90 green:0.57 blue:0.66 alpha:1]] forState:UIControlStateNormal];
                    //self.cionBtn = button;
                    break;
                case 2:
                    [btn setImage:[[UIImage imageNamed:@"iphonevideoinfo_dl"] imageWithColor:[UIColor colorWithRed:0.38 green:0.65 blue:0.96 alpha:1]] forState:UIControlStateNormal];
                    //self.saveBtn = button;
                    break;
                
                default:
                    break;
            }
        }
    }
    return _infoView;
}

-(void)click
{
    NSLog(@"nnnnnnnnnnn");
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[[UIImage imageNamed:@"common_back"] imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    }
    return _backBtn;
}

-(void)backBtnClick
{
    if (self.backBlock) {
        self.backBlock();
    }
}

-(void)backWithBlock:(BackBlock)block
{
    self.backBlock = block;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = @"番剧详情";
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor whiteColor];
        
    }
    return _titleLabel;
}

-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.layer.cornerRadius = 5;
        _iconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconImageView.clipsToBounds = YES;
        _iconImageView.layer.borderWidth = 2;
    }
    return _iconImageView;
}

-(UILabel *)bangumiTitleLabel
{
    if (!_bangumiTitleLabel) {
        _bangumiTitleLabel = [UILabel new];
        _bangumiTitleLabel.font = [UIFont systemFontOfSize:15];
        _bangumiTitleLabel.textColor = [UIColor whiteColor];
        
    }
    return _bangumiTitleLabel;
}

-(UILabel *)statusLabel
{
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
        _statusLabel.font = [UIFont systemFontOfSize:12];
        _statusLabel.textColor = [UIColor whiteColor];
        
    }
    return _statusLabel;
}

-(UILabel *)playLabel
{
    if (!_playLabel) {
        _playLabel = [UILabel new];
        _playLabel.font = [UIFont systemFontOfSize:12];
        _playLabel.textColor = [UIColor whiteColor];
        
    }
    return _playLabel;
}

-(UIScrollView *)seasonView
{
    if (!_seasonView) {
        _seasonView = [UIScrollView new];
        _seasonView.left = 10;
        _seasonView.top = 30+10;
        _seasonView.size = CGSizeMake(kScreenWidth-20, 35);
        _seasonView.showsVerticalScrollIndicator = NO;
        _seasonView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:_seasonView];
    }
    return _seasonView;
}

-(UIView *)itemView
{
    if (!_itemView) {
        _itemView = [UIView new];
        _itemView.backgroundColor = kBgColor;
        [self.contentView addSubview:_itemView];
        
        _itemView.left = 0;
        _itemView.top = 30;
        _itemView.size = CGSizeMake(kScreenWidth, 0);
    }
    return _itemView;
}

-(UIView *)briefView
{
    if (!_briefView) {
        _briefView = [UIView new];
        _briefView.backgroundColor = kBgColor;
        _briefView.size = CGSizeMake(kScreenWidth, 0);
        [self.contentView addSubview:_briefView];
        
        UIView * topLine = [UIView new];
        topLine.backgroundColor = [UIColor lightGrayColor];
        topLine.size = CGSizeMake(kScreenWidth, kCGFloatFromPixel(1));
        [_briefView addSubview:topLine];
        
        UILabel * tipLabel = [UILabel new];
        tipLabel.left = 10;
        tipLabel.top = 15;
        tipLabel.text = @"简介";
        tipLabel.font = [UIFont systemFontOfSize:15];
        tipLabel.size = CGSizeMake([tipLabel.text widthForFont:tipLabel.font], 20);
        [_briefView addSubview:tipLabel];
        
        UIButton * detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        detailBtn.left = kScreenWidth-30;
        detailBtn.top = tipLabel.top;
        detailBtn.size = CGSizeMake(20, 18);
        [detailBtn setImage:[UIImage imageNamed:@"更多"] forState:UIControlStateNormal];
        [detailBtn addTarget:self action:@selector(detailClick) forControlEvents:UIControlEventTouchUpInside];
        [_briefView addSubview:detailBtn];
        
        UILabel * briefLabel = [UILabel new];
        briefLabel.numberOfLines = 0;
        briefLabel.font = [UIFont systemFontOfSize:12];
        briefLabel.textColor = [UIColor grayColor];
        [_briefView addSubview:briefLabel];
        self.briefLabel = briefLabel;
        
        UIScrollView * tagView = [UIScrollView new];
        tagView.showsVerticalScrollIndicator = NO;
        tagView.showsHorizontalScrollIndicator = NO;
        [_briefView addSubview:tagView];
        self.tagView = tagView;
    }
    return _briefView;
}

-(void)detailClick
{
    if (self.detailBlock) {
        self.detailBlock(self.detail);
    }
}

-(void)detailClickedWithBlock:(detailClickBlock)block
{
    self.detailBlock = block;
}

@end
