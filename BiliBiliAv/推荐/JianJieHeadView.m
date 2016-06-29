//
//  JianJieHeadView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/3/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "JianJieHeadView.h"
#import "UIImageView+YYWebImage.h"
#import "NSAttributedString+YYText.h"
#import "HYGUtility.h"
#import "UIImage+HYGColor.h"

#define kBtnWidth (kScreenWidth-80-40*3)/4
@implementation menuView
{
    NSMutableArray * _labelArray;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = kScreenWidth;
        frame.size.height = 1;
    }
    self = [super initWithFrame:frame];
    _labelArray = [NSMutableArray array];
    [self configMenus];
    return self;
}

-(void)setStat:(Stat *)stat
{
    NSArray * nums = @[stat.share,stat.coin,stat.favorite];
    for (int i=0; i<_labelArray.count; i++) {
        UILabel * label = _labelArray[i];
        
        if (!nums[i]) {
            label.hidden = YES;
        }else{
            label.text = nums[i];
            label.size = CGSizeMake([label.text widthForFont:label.font]+8, 15);
            label.left += kBtnWidth/2-label.size.width/2;
            label.layer.cornerRadius = label.size.height/2;
            label.layer.masksToBounds = YES;
            
            [UIView animateWithDuration:0.25 animations:^{
                label.top = 0;
            }];
            [self shakeToShow:label];
        }
    }
}

//设置放大缩小动画
- (void) shakeToShow:(UIView*)aView{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.25;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    animation.values = values;
    [aView.layer addAnimation:animation forKey:nil];
}

-(void)configMenus
{
    NSArray * titleArray = @[@"分  享",@"投硬币",@"收  藏",@"缓  存"];
    for (int i=0; i<4; i++) {
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.size = CGSizeMake(kBtnWidth, kBtnWidth);
        button.left = 40+i*(kBtnWidth+40);
        button.top = 20;
        [button setBackgroundImage:[UIImage imageNamed:@"iphonevideoinfo_button@2x~iphone"] forState:UIControlStateNormal];
        button.layer.cornerRadius = kBtnWidth/2;
        [self addSubview:button];
        
        UILabel * numLabel;
        if (i<3) {
            numLabel = [UILabel new];
            numLabel.left = button.left;
            numLabel.top = button.top;
            numLabel.textAlignment = NSTextAlignmentCenter;
            numLabel.font = [UIFont systemFontOfSize:10];
            numLabel.backgroundColor = [UIColor whiteColor];
            [self addSubview:numLabel];
            [_labelArray addObject:numLabel];
        }
        
        UILabel * label = [UILabel new];
        label.size = CGSizeMake(kBtnWidth+10, 20);
        label.text = titleArray[i];
        label.top = button.bottom+2;
        label.left = button.left-5;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:TextColor];
        [self addSubview:label];
        
        switch (i) {
            case 0:
                numLabel.textColor = [UIColor colorWithRed:0.18 green:0.78 blue:0.49 alpha:1];
                [button setImage:[[UIImage imageNamed:@"iphonevideoinfo_share"] imageWithColor:numLabel.textColor] forState:UIControlStateNormal];
                self.shareBtn = button;
                break;
            case 1:
                numLabel.textColor = [UIColor colorWithRed:0.97 green:0.81 blue:0.38 alpha:1];
                [button setImage:[[UIImage imageNamed:@"iphonevideoinfo_bp"] imageWithColor:numLabel.textColor] forState:UIControlStateNormal];
                self.cionBtn = button;
                break;
            case 2:
                numLabel.textColor = [UIColor colorWithRed:0.90 green:0.57 blue:0.66 alpha:1];
                [button setImage:[[UIImage imageNamed:@"iphonevideoinfo_fav"] imageWithColor:numLabel.textColor] forState:UIControlStateNormal];
                self.saveBtn = button;
                break;
            case 3:
                [button setImage:[[UIImage imageNamed:@"iphonevideoinfo_dl"] imageWithColor:[UIColor colorWithRed:0.38 green:0.65 blue:0.96 alpha:1]] forState:UIControlStateNormal];
                self.cacheBtn = button;
                break;
            default:
                break;
        }
    }
}

@end

@implementation pageView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = kScreenWidth;
        frame.size.height = 1;
    }
    self = [super initWithFrame:frame];
    
    return self;
}

-(void)dealloc
{
    for (UIView * view in self.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeObserver:self forKeyPath:@"selected"];
        }
    }
}

-(void)setLayout:(JianJieLayout *)layout
{
    _layout = layout;
    self.height = layout.pageViewHeight;
    
    CALayer * topLine = [CALayer layer];
    topLine.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1].CGColor;
    topLine.size = CGSizeMake(kScreenWidth-20, CGFloatFromPixel(1));
    topLine.left = 10;
    topLine.top = 0;
    [self.layer addSublayer:topLine];
    
    self.pageLabel.text = [NSString stringWithFormat:@"分集（%ld）",layout.pages.count];
    
    CGFloat padding = 10;
    CGFloat width = (self.contentView.width-3*padding)/2.5;
    for (int i=0; i<layout.pages.count; i++) {
        Page * page = layout.pages[i];
        UIButton * pageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        pageBtn.left = padding+i*(width+padding);
        pageBtn.top = 5;
        pageBtn.size = CGSizeMake(width, self.contentView.height-10);
        [self.contentView addSubview:pageBtn];
        
        pageBtn.layer.cornerRadius = 3;
        pageBtn.layer.masksToBounds = YES;
        pageBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        pageBtn.layer.borderWidth = CGFloatFromPixel(1);
        
        [pageBtn setTitle:page.part forState:UIControlStateNormal];
        [pageBtn setTitleColor:[UIColor colorWithHexString:TextColor] forState:UIControlStateNormal];
        [pageBtn setTitleColor:kStyleColor forState:UIControlStateSelected];
        pageBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        pageBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        pageBtn.titleLabel.numberOfLines = 0;
        pageBtn.tag = i;
        [pageBtn addTarget:self action:@selector(pageSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        [pageBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
        if (i == layout.pages.count-1) {
            self.contentView.contentSize = CGSizeMake(pageBtn.right, self.contentView.height);
        }
        if (i == 0) {
            pageBtn.selected = YES;
        }
    }
}

-(void)pageSelectClick:(UIButton *)btn
{
    for (UIView * view in self.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton * seleBtn = (UIButton *)view;
            if (seleBtn.tag == btn.tag) {
                seleBtn.selected = YES;
                [self.contentView scrollRectToVisible:CGRectMake(seleBtn.origin.x, 0, seleBtn.width, self.contentView.height) animated:YES];
                if (self.pageBlock) {
                    Page * page = self.layout.pages[seleBtn.tag];
                    self.pageBlock(page.cid);
                }
            }else{
                seleBtn.selected = NO;
            }
        }
    }
}

-(void)pageSelectWithBlock:(pageClickBlock)block
{
    self.pageBlock = block;
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

-(UILabel *)pageLabel
{
    if (!_pageLabel) {
        _pageLabel = [UILabel new];
        _pageLabel.left = 10;
        _pageLabel.top = 10;
        _pageLabel.size = CGSizeMake(100, 20);
        _pageLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_pageLabel];
    }
    return _pageLabel;
}

-(UIButton *)inputBtn
{
    if (!_inputBtn) {
        _inputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _inputBtn.left = self.width-35;
        _inputBtn.top = 10;
        _inputBtn.size = CGSizeMake(20, 18);
        [_inputBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_inputBtn addTarget:self action:@selector(inputClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_inputBtn];
    }
    return _inputBtn;
}

-(UIScrollView *)contentView
{
    if (!_contentView) {
        _contentView = [UIScrollView new];
        //_contentView.backgroundColor = [UIColor redColor];
        _contentView.left = 10;
        _contentView.top = 40;
        _contentView.size = CGSizeMake(self.width-20, 60);
        _contentView.showsVerticalScrollIndicator = NO;
        [self addSubview:_contentView];
    }
    return _contentView;
}

@end

@implementation upInfoView

-(void)setLayout:(JianJieLayout *)layout
{
    _layout = layout;
    self.height = layout.uperInfoHeight;
    
    CALayer * topLine = [CALayer layer];
    topLine.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1].CGColor;
    topLine.size = CGSizeMake(kScreenWidth-20, CGFloatFromPixel(1));
    topLine.left = 10;
    topLine.top = 0;
    [self.layer addSublayer:topLine];
    
    CALayer * bottomLine = [CALayer layer];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1].CGColor;
    bottomLine.size = CGSizeMake(kScreenWidth-20, CGFloatFromPixel(1));
    bottomLine.left = 10;
    bottomLine.bottom = self.height;
    [self.layer addSublayer:bottomLine];
    
    self.iconImageView.top = self.height/2-self.iconImageView.height/2;
    self.nameLable.top = self.iconImageView.top;
    self.upDateLabel.top = self.nameLable.bottom;
    self.attractBtn.top = self.height/2-self.attractBtn.height/2;
    
    [self.iconImageView setImageWithURL:[NSURL URLWithString:layout.owner.face] placeholder:nil];
    self.nameLable.text = layout.owner.name;
    self.upDateLabel.text = [HYGUtility returnUploadTime:layout.upDate];
}

-(YYAnimatedImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [YYAnimatedImageView new];
        _iconImageView.size = CGSizeMake(40, 40);
        _iconImageView.layer.cornerRadius = _iconImageView.width/2;
        _iconImageView.layer.masksToBounds = YES;
        _iconImageView.left = 10;
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

-(UIButton *)attractBtn
{
    if (!_attractBtn) {
        _attractBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _attractBtn.size = CGSizeMake(60, 30);
        _attractBtn.left = kScreenWidth-70;
        [_attractBtn setTitle:@"关注" forState:UIControlStateNormal];
        _attractBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_attractBtn setTitleColor:[UIColor colorWithRed:0.86 green:0.40 blue:0.54 alpha:1] forState:UIControlStateNormal];
        _attractBtn.layer.borderColor = [UIColor colorWithRed:0.86 green:0.40 blue:0.54 alpha:1].CGColor;
        _attractBtn.layer.borderWidth = 1;
        _attractBtn.layer.cornerRadius = 5;
        [self addSubview:_attractBtn];
    }
    return _attractBtn;
}

-(UILabel *)nameLable
{
    if (!_nameLable) {
        _nameLable = [UILabel new];
        _nameLable.size = CGSizeMake(kScreenWidth-70, 20);
        _nameLable.left = self.iconImageView.right+10;
        _nameLable.textColor = [UIColor colorWithHexString:TextColor];
        _nameLable.font = [UIFont systemFontOfSize:14];
        [self addSubview:_nameLable];
    }
    return _nameLable;
}

-(UILabel *)upDateLabel
{
    if (!_upDateLabel) {
        _upDateLabel = [UILabel new];
        _upDateLabel.size = self.nameLable.size;
        _upDateLabel.left = self.nameLable.left;
        _upDateLabel.textColor = [UIColor lightGrayColor];
        _upDateLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_upDateLabel];
    }
    return _upDateLabel;
}

@end
@implementation aboutAvView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = kScreenWidth;
        frame.size.height = 1;
    }
    self = [super initWithFrame:frame];
    
    return self;
}

-(void)setLayout:(JianJieLayout *)layout
{
    self.titleLabel.sd_layout.leftSpaceToView(self,10).topSpaceToView(self,10).heightIs(20);
    [self.titleLabel setSingleLineAutoResizeWithMaxWidth:100];
    if (layout.tagLayouts.count>0) {
        UIView * lastView = self;
        CGFloat x=10;
        CGFloat y=10;
        for (int index = 0; index<layout.tagLayouts.count; index++) {
            UIButton * tagBtn = [UIButton new];
            [self addSubview:tagBtn];
            YYTextLayout * tagLayout = layout.tagLayouts[index];
            tagBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [tagBtn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [tagBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
            [tagBtn setTitleColor:[UIColor colorWithHexString:TextColor] forState:UIControlStateNormal];
            [tagBtn setTitle:tagLayout.text.string forState:UIControlStateNormal];
            tagBtn.sd_layout.leftSpaceToView(lastView,10).topSpaceToView(self.titleLabel,y).widthIs(tagLayout.textBoundingSize.width+20).heightIs(25);
            tagBtn.layer.cornerRadius = tagBtn.height/2;
            tagBtn.clipsToBounds = YES;
            tagBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            tagBtn.layer.borderWidth = CGFloatFromPixel(1);
            
            lastView = tagBtn;
            x += tagBtn.width+10;
            if (x>self.width-10) {
                y += 25 + 10;
                tagBtn.sd_layout.topSpaceToView(self.titleLabel,y).leftSpaceToView(self,10).widthIs(tagLayout.textBoundingSize.width+20).heightIs(25);
                [tagBtn updateLayout];
                x=10+tagBtn.width+10;
            }
        }
    }
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor colorWithHexString:TextColor];
        _titleLabel.text = @"视频相关";
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end

@interface JianJieHeadView ()

@end

@implementation JianJieHeadView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = kScreenWidth;
        frame.size.height = 1;
    }
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    return self;
}

-(void)setLayout:(JianJieLayout *)layout
{
    if (!layout) {
        return;
    }
    CGFloat top = 10;
    self.height = layout.height;
    _layout = layout;
    self.titleLabel.textLayout = layout.titleLayout;
    self.titleLabel.height = layout.titleInfoHeight;
    self.titleLabel.top = top;
    if ([layout.titleLayout.text.string containsString:@"【"]) {
        self.titleLabel.left = 0;
    }
    top += layout.titleInfoHeight+10;
    
    self.playAndDanmuLabel.textLayout = layout.playAndDanmuLayout;
    self.playAndDanmuLabel.top = top;
    self.playAndDanmuLabel.height = layout.playAndDanmuHeight;
    top += layout.playAndDanmuHeight;
    
    self.contentLabel.textLayout = layout.contentLayout;
    self.contentLabel.top = top;
    self.contentLabel.height = layout.contentHeight;
    
    
    top += layout.contentHeight;
    
    self.menuV.height = layout.menuViewHeight;
    self.menuV.top = top;
    self.menuV.stat = layout.stat;
    top += layout.menuViewHeight;
    
    if (layout.pages.count<=1) {
        self.pageV.hidden = YES;
    }else{
        self.pageV.hidden = NO;
        self.pageV.height = layout.pageViewHeight;
        self.pageV.top = top;
        self.pageV.layout = layout;
        top += layout.pageViewHeight;
    }
    
    self.upView.height = layout.uperInfoHeight;
    self.upView.top = top;
    self.upView.layout = layout;
    top += layout.uperInfoHeight;
    
    self.aboutView.height = layout.aboutAvHeight;
    self.aboutView.top = top;
    self.aboutView.layout = layout;
}

-(YYLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [YYLabel new];
        _titleLabel.left = 10;
        _titleLabel.width = kScreenWidth-20;
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _titleLabel.displaysAsynchronously = YES;
        _titleLabel.ignoreCommonProperties = YES;
        _titleLabel.fadeOnAsynchronouslyDisplay = NO;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(YYLabel *)playAndDanmuLabel
{
    if (!_playAndDanmuLabel) {
        _playAndDanmuLabel = [YYLabel new];
        _playAndDanmuLabel.left = 10;
        _playAndDanmuLabel.width = kScreenWidth-20;
        _playAndDanmuLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _playAndDanmuLabel.displaysAsynchronously = YES;
        _playAndDanmuLabel.ignoreCommonProperties = YES;
        _playAndDanmuLabel.fadeOnAsynchronouslyDisplay = NO;
        
        [self addSubview:_playAndDanmuLabel];
    }
    return _playAndDanmuLabel;
}

-(YYLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [YYLabel new];
        _contentLabel.left = 10;
        _contentLabel.width = kScreenWidth-20;
        _contentLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
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
        
        [self addSubview:_contentLabel];
    }
    return _contentLabel;
}

-(menuView *)menuV
{
    if (!_menuV) {
        _menuV = [menuView new];
        _menuV.width = kScreenWidth;
        _menuV.backgroundColor = [UIColor clearColor];
        [self addSubview:_menuV];
    }
    return _menuV;
}

-(pageView *)pageV
{
    if (!_pageV) {
        _pageV = [pageView new];
        _pageV.width = kScreenWidth;
        _pageV.backgroundColor = [UIColor clearColor];
        [self addSubview:_pageV];
    }
    return _pageV;
}

-(upInfoView *)upView
{
    if (!_upView) {
        _upView = [upInfoView new];
        _upView.width = kScreenWidth;
        _upView.backgroundColor = [UIColor clearColor];
        [self addSubview:_upView];
    }
    return _upView;
}

-(aboutAvView *)aboutView
{
    if (!_aboutView) {
        _aboutView = [aboutAvView new];
        _aboutView.width = kScreenWidth;
        _aboutView.backgroundColor = [UIColor clearColor];
        [self addSubview:_aboutView];
    }
    return _aboutView;
}

@end
