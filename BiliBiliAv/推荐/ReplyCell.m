//
//  ReplyCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/5.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "ReplyCell.h"
#import "YYAnimatedImageView.h"
#import "UIImageView+YYWebImage.h"
#import "LevelLabel.h"
#import "YYLabel.h"
#import "JianJieLayout.h"
#import "NSAttributedString+YYText.h"
#import "HYGUtility.h"
#import "WebViewController.h"
@implementation moreHotView

-(instancetype)init
{
    if (self = [super init]) {
        //self.frame = CGRectMake(0, 0, kScreenWidth, 30);
        self.backgroundColor = kBgColor;
        
        UIView * leftLine = [UIView new];
        leftLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:leftLine];
        UIButton * moreHotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreHotBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [moreHotBtn setTitle:@"更多热门评论>>" forState:UIControlStateNormal];
        [moreHotBtn setTitleColor:kStyleColor forState:UIControlStateNormal];
        [self addSubview:moreHotBtn];
        
        UIView * rightLine = [UIView new];
        rightLine.backgroundColor = leftLine.backgroundColor;
        [self addSubview:rightLine];
        
        moreHotBtn.sd_layout.widthIs(100).heightRatioToView(self,1).centerYEqualToView(self).centerXEqualToView(self);
        leftLine.sd_layout.leftSpaceToView(self,0).rightSpaceToView(moreHotBtn,5).centerYEqualToView(moreHotBtn).heightIs(1);
        rightLine.sd_layout.leftSpaceToView(moreHotBtn,5).rightSpaceToView(self,0).centerYEqualToView(moreHotBtn).heightIs(1);
    }
    return self;
}

@end

@interface ReplyCell ()

@property (nonatomic,strong) YYAnimatedImageView * iconImageView;
@property (nonatomic,strong) UIView * lineView;
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * floorLabel;
@property (nonatomic,strong) YYLabel * contentLabel;
@property (nonatomic,strong) UIImageView * sexImageView;
@property (nonatomic,strong) UIImageView * levelImageView;
@property (nonatomic,strong) UIImageView * replyImageView;
@property (nonatomic,strong) UILabel * replyLabel;
@property (nonatomic,strong) UIButton * zanBtn;
@property (nonatomic,strong) UIButton * moreBtn;
@property (nonatomic,strong) moreHotView * moreHotReplyView;
@end

@implementation ReplyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = kBgColor;
        
        [self layout];
    }
    return self;
}

-(void)layout
{
    UIView * contentView = self.contentView;
    
    self.lineView = [UIView new];
    self.lineView.backgroundColor = [UIColor lightGrayColor];
    [contentView addSubview:self.lineView];
    
    self.lineView.sd_layout.leftSpaceToView(contentView,0).topSpaceToView(contentView,0).rightSpaceToView(contentView,0).heightIs(CGFloatFromPixel(1));
    
    self.iconImageView.sd_layout.leftSpaceToView(contentView,10).topSpaceToView(contentView,45).widthIs(25).heightEqualToWidth();
    self.nameLabel.sd_layout.leftSpaceToView(self.iconImageView,10).topEqualToView(self.iconImageView).heightIs(15);
    [self.nameLabel setSingleLineAutoResizeWithMaxWidth:120];
    self.sexImageView.sd_layout.leftSpaceToView(self.nameLabel,5).centerYEqualToView(self.nameLabel).widthIs(10).heightEqualToWidth();
    self.moreBtn.sd_layout.rightSpaceToView(contentView,10).topEqualToView(self.nameLabel).heightIs(15).widthIs(25);
    self.zanBtn.sd_layout.rightSpaceToView(self.moreBtn,10).topEqualToView(self.nameLabel).widthIs(45).heightIs(15);
    
    self.replyLabel.sd_layout.rightSpaceToView(self.zanBtn,10).topEqualToView(self.nameLabel).heightIs(15);
    [self.replyLabel setSingleLineAutoResizeWithMaxWidth:50];
    self.replyImageView.sd_layout.rightSpaceToView(self.replyLabel,5).topEqualToView(self.nameLabel).widthIs(15).heightIs(15);
    
    self.floorLabel.sd_layout.leftEqualToView(self.nameLabel).topSpaceToView(self.nameLabel,2).heightIs(12);
    [self.floorLabel setSingleLineAutoResizeWithMaxWidth:100];
    self.levelImageView.sd_layout.topSpaceToView(self.iconImageView,5).centerXEqualToView(self.iconImageView).widthRatioToView(self.iconImageView,1).heightIs(10);
    self.contentLabel.sd_layout.leftEqualToView(self.nameLabel).rightSpaceToView(contentView,10).topSpaceToView(self.floorLabel,10);
    
    self.moreHotReplyView.sd_layout.leftSpaceToView(contentView,0).topSpaceToView(contentView,0).rightSpaceToView(contentView,0).heightIs(31);
}

-(void)hiddeTopLine
{
    self.lineView.hidden = YES;
}

-(void)showTopLine
{
   self.lineView.hidden = NO;
}

-(void)setReplyLayout:(ReplyLayout *)replyLayout
{
     if (!replyLayout) return;
    _replyLayout = replyLayout;
    
    @weakify(self);
    [self.iconImageView setImageWithURL:[NSURL URLWithString:replyLayout.data.member.avatar] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } transform:^UIImage *(UIImage *image, NSURL *url) {
        return [image imageAddCornerWithRadius:weak_self.iconImageView.height/2 andSize:CGSizeMake(weak_self.iconImageView.width, weak_self.iconImageView.height)];
    } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        
    }];
    self.nameLabel.text = replyLayout.data.member.uname;
    
    if ([replyLayout.data.member.sex isEqualToString:@"男"]) {
        [self.sexImageView setImage:[UIImage imageNamed:@"misc_sex_male"]];
    }else if([replyLayout.data.member.sex isEqualToString:@"女"]){
        [self.sexImageView setImage:[UIImage imageNamed:@"misc_sex_female"]];
    }
    
    self.floorLabel.text = [NSString stringWithFormat:@"#%@  %@",replyLayout.data.floor,[HYGUtility returnUploadTime:replyLayout.data.ctime]];
    
    self.contentLabel.textLayout = replyLayout.contentLayout;
    
    self.contentLabel.sd_layout.heightIs(replyLayout.contentHeight);
    [self.contentLabel updateLayout];
    
    if ([replyLayout.data.rcount integerValue]>0) {
        self.replyImageView.hidden = NO;
        self.replyLabel.hidden = NO;
        self.replyLabel.text = replyLayout.data.rcount;
    }else{
        self.replyImageView.hidden = YES;
        self.replyLabel.hidden = YES;
    }
    
    [self.zanBtn setTitle:[NSString stringWithFormat:@"%@",replyLayout.data.like] forState:UIControlStateNormal];
    
    self.levelImageView.image = [UIImage imageNamed:replyLayout.levelImageName];
    
    if (replyLayout.showMoreHot) {
        self.moreHotReplyView.hidden = NO;
        self.iconImageView.sd_layout.leftSpaceToView(self.contentView,10).topSpaceToView(self.contentView,45).widthIs(25).heightEqualToWidth();
        [self.iconImageView updateLayout];
    }else{
        self.moreHotReplyView.hidden = YES;
        self.iconImageView.sd_layout.leftSpaceToView(self.contentView,10).topSpaceToView(self.contentView,15).widthIs(25).heightEqualToWidth();
        [self.iconImageView updateLayout];
    }
}

-(YYAnimatedImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [YYAnimatedImageView new];
        [self.contentView addSubview:_iconImageView];
    }
    return _iconImageView;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

-(UILabel *)floorLabel
{
    if (!_floorLabel) {
        _floorLabel = [UILabel new];
        _floorLabel.font = [UIFont systemFontOfSize:10];
        _floorLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_floorLabel];
    }
    return _floorLabel;
}

-(YYLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [YYLabel new];
        
        _contentLabel.displaysAsynchronously = YES;
        _contentLabel.ignoreCommonProperties = YES;
        _contentLabel.fadeOnAsynchronouslyDisplay = NO;
        _contentLabel.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            YYTextHighlight *highlight = [text attribute:YYTextHighlightAttributeName atIndex:range.location];
            NSDictionary *info = highlight.userInfo;
            if (info.count == 0) return;
            UITabBarController * tab = (UITabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
            UINavigationController * nav = tab.selectedViewController;
            UIViewController * vc = nav.topViewController;
            WebViewController * web = [WebViewController new];
            web.url = info[@"url"];
            [vc.navigationController pushViewController:web animated:YES];
            NSLog(@"链接地址 == %@",info[@"url"]);
        };
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}

-(UIImageView *)sexImageView
{
    if (!_sexImageView) {
        _sexImageView = [UIImageView new];
        [self.contentView addSubview:_sexImageView];
    }
    return _sexImageView;
}

-(UIImageView *)levelImageView
{
    if (!_levelImageView) {
        _levelImageView = [UIImageView new];
        [self.contentView addSubview:_levelImageView];
    }
    return _levelImageView;
}

-(UIImageView *)replyImageView
{
    if (!_replyImageView) {
        _replyImageView = [UIImageView new];
        _replyImageView.image = [UIImage imageNamed:@"common_comment"];
        [self.contentView addSubview:_replyImageView];
    }
    return _replyImageView;
}

-(UILabel *)replyLabel
{
    if (!_replyLabel) {
        _replyLabel = [UILabel new];
        _replyLabel.font = [UIFont systemFontOfSize:12];
        _replyLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_replyLabel];
    }
    return _replyLabel;
}

-(UIButton *)zanBtn
{
    if (!_zanBtn) {
        _zanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zanBtn setImage:[UIImage imageNamed:@"misc_like_ico"] forState:UIControlStateNormal];
        [_zanBtn setImage:[UIImage imageNamed:@"misc_like_s_ico"] forState:UIControlStateSelected];
        [_zanBtn setTitle:@"0" forState:UIControlStateNormal];
        _zanBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_zanBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_zanBtn addTarget:self action:@selector(zanClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_zanBtn];
    }
    return _zanBtn;
}

-(UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setTitle:@"···" forState:UIControlStateNormal];
        [_moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_moreBtn addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_moreBtn];
    }
    return _moreBtn;
}

-(moreHotView *)moreHotReplyView
{
    if (!_moreHotReplyView) {
        _moreHotReplyView = [moreHotView new];
        [self.contentView addSubview:_moreHotReplyView];
        _moreHotReplyView.hidden = YES;
    }
    return _moreHotReplyView;
}

-(void)moreClick
{
   
}

-(void)zanClick
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end

