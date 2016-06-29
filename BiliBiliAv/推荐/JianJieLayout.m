//
//  JianJieLayout.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/3/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "JianJieLayout.h"
#import "ImageText.h"
#import "NSAttributedString+YYText.h"
/*
 将每行的 baseline 位置固定下来，不受不同字体的 ascent/descent 影响。
 
 注意，Heiti SC 中，    ascent + descent = font size，
 但是在 PingFang SC 中，ascent + descent > font size。
 所以这里统一用 Heiti SC (0.86 ascent, 0.14 descent) 作为顶部和底部标准，保证不同系统下的显示一致性。
 间距仍然用字体默认
 */

@implementation AvTextLinePositionModifier

- (instancetype)init {
    self = [super init];
    
    if (kiOS9Later) {
        _lineHeightMultiple = 1.34;   // for PingFang SC
    } else {
        _lineHeightMultiple = 1.3125; // for Heiti SC
    }
    
    return self;
}

- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(YYTextContainer *)container {
    //CGFloat ascent = _font.ascender;
    CGFloat ascent = _font.pointSize * 0.86;
    
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (YYTextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row  * lineHeight;
        line.position = position;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    AvTextLinePositionModifier *one = [self.class new];
    one->_font = _font;
    one->_paddingTop = _paddingTop;
    one->_paddingBottom = _paddingBottom;
    one->_lineHeightMultiple = _lineHeightMultiple;
    return one;
}

- (CGFloat)heightForLineCount:(NSUInteger)lineCount {
    if (lineCount == 0) return 0;
    //    CGFloat ascent = _font.ascender;
    //    CGFloat descent = -_font.descender;
    CGFloat ascent = _font.pointSize * 0.86;
    CGFloat descent = _font.pointSize * 0.14;
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    return _paddingTop + _paddingBottom + ascent + descent + (lineCount - 1) * lineHeight;
}

@end

@implementation JianJieLayout
-(instancetype)initWithDetail:(AvDetailModel *)detail
{
    if (!detail) return nil;
    self = [super init];
    _detail = detail;
    //_isFold = YES;
    [self layout];
    return self;
}

-(void)layout
{
    [self _layout];
}

-(void)_layout
{
    _topMargin = 10;
    _titleInfoHeight = 0;
    _tipPading = 10;
    _playAndDanmuHeight = 0;
    _contentHeight = 0;
    _contentFoldHeight = 0;
    _menuViewHeight = 0;
    _uperInfoHeight = 0;
    _aboutAvHeight = 0;
    _tipOneHeight = 25;
    _tipViewHeight = 0;
    
    [self _layoutTitle];
    [self _layoutPlayAndDanmu];
    [self _layoutContent];
    
    [self _layoutMenu];
    [self _layoutPageView];
    [self _layoutUperInfo];
    [self _layoutAboutAv];
    
    _height = 0;
    _height += _topMargin;
    _height += _titleInfoHeight;
    _height += _playAndDanmuHeight;
    
    _height += _contentHeight;
    _height += _menuViewHeight;
    _height += _pageViewHeight;
    _height += _uperInfoHeight;
    _height += _aboutAvHeight;
}

-(void)_layoutTitle{
    _titleInfoHeight = 0;
    _titleLayout = nil;
    
    NSString * title = _detail.title;
    if (title.length == 0) {
        return;
    }
    NSMutableAttributedString * titleText = [[NSMutableAttributedString alloc] initWithString:title];
    if (titleText.length == 0) return;
    titleText.font = [UIFont systemFontOfSize:14];
    titleText.color = [UIColor colorWithHexString:TextColor];
    
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(kScreenWidth-20, HUGE);
    container.maximumNumberOfRows = 1;
    _titleLayout = [YYTextLayout layoutWithContainer:container text:titleText];
    if (!_titleLayout) return;
    
    _titleInfoHeight = _titleLayout.textBoundingSize.height;
}

-(void)_layoutPlayAndDanmu{
    _playAndDanmuHeight = 0;
    _playAndDanmuLayout = nil;
    
    NSString * playNum = _detail.stat.view;
    NSString * danmukuNum = _detail.stat.danmaku;
    if (playNum.length == 0&&danmukuNum.length == 0) {
        return;
    }
    NSMutableAttributedString * playDanmukuText = [[NSMutableAttributedString alloc] initWithString:@""];
    UIImage *playImage = [UIImage imageNamed:@"misc_playCount"];
    NSAttributedString *playImageText = [ImageText _attachmentWithFontSize:12 image:playImage shrink:NO];
    [playDanmukuText appendAttributedString:playImageText];
    NSMutableAttributedString * playText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",playNum]];
    playText.font = [UIFont systemFontOfSize:12];
    playText.color = [UIColor lightGrayColor];
    [playDanmukuText appendAttributedString:playText];
    
    [playDanmukuText appendString:@"   "];
    UIImage *danmuImage = [UIImage imageNamed:@"misc_danmakuCount"];
    NSAttributedString *danmuImageText = [ImageText _attachmentWithFontSize:12 image:danmuImage shrink:NO];
    [playDanmukuText appendAttributedString:danmuImageText];
    NSMutableAttributedString * danmuText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",danmukuNum]];
    danmuText.font = [UIFont systemFontOfSize:12];
    danmuText.color = [UIColor lightGrayColor];
    [playDanmukuText appendAttributedString:danmuText];
    
    YYTextContainer * container = [YYTextContainer containerWithSize:CGSizeMake(kScreenWidth-20, HUGE)];
    container.maximumNumberOfRows = 1;
    _playAndDanmuLayout = [YYTextLayout layoutWithContainer:container text:playDanmukuText];
    _playAndDanmuHeight = _playAndDanmuLayout.textBoundingSize.height;
}

-(void)_layoutContent{
    _contentHeight = 0;
    _contentLayout = nil;
    
    NSString * content = _detail.desc;

    NSMutableAttributedString * contentText = [ImageText _textWithTextString:content fontSize:13 textColor:[UIColor lightGrayColor]];
    if (contentText.length == 0) return;
    
    AvTextLinePositionModifier *modifier = [AvTextLinePositionModifier new];
    modifier.font = [UIFont systemFontOfSize:13];
    modifier.paddingTop = _topMargin;
    modifier.paddingBottom = _topMargin;
    
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(kScreenWidth-20, HUGE);
    container.linePositionModifier = modifier;
    
    _contentLayout = [YYTextLayout layoutWithContainer:container text:contentText];
    if (!_contentLayout) return;
    
    _contentHeight = [modifier heightForLineCount:_contentLayout.rowCount];
}

-(void)_layoutMenu{
    CGFloat btnWidth = (kScreenWidth-80-50*3)/4;
    _menuViewHeight = 20+btnWidth+20+10;
    _stat = _detail.stat;
}

-(void)_layoutPageView
{
    _pages = _detail.pages;
    if (_detail.pages.count<=1) {
        _pageViewHeight = 0;
    }else{
        _pageViewHeight = 110;
    }
}

-(void)_layoutUperInfo{
    _owner = _detail.owner;
    _upDate = _detail.pubdate;
    _uperInfoHeight = 80;
}

-(void)_layoutAboutAv{
    _aboutAvHeight = _topMargin*2+20;
    
    [self _layoutTips];
    
    _aboutAvHeight += _tipViewHeight;
}

-(void)_layoutTips{
    _tipViewHeight = _topMargin*2+20;
    NSArray * tips = _detail.tags;
    if (tips.count == 0) {
        return;
    }
    NSMutableArray * layouts = [NSMutableArray array];
    for (int i=0; i<tips.count; i++) {
        NSString * tip = tips[i];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:tip];
        text.font = [UIFont systemFontOfSize:13];
        text.color = [UIColor colorWithHexString:TextColor];
        
        YYTextContainer * container = [YYTextContainer containerWithSize:CGSizeMake([tip widthForFont:text.font], 25)];
        container.maximumNumberOfRows = 1;
        YYTextLayout * layout = [YYTextLayout layoutWithContainer:container text:text];
        [layouts addObject:layout];
    }
    CGFloat x = 10;
    for (int i = 0; i<layouts.count; i++) {
        YYTextLayout * layout = layouts[i];
        x += layout.textBoundingSize.width + 20 + _tipPading;
        if (x > kScreenWidth-10) {
            _tipViewHeight += _tipOneHeight+_topMargin;
            x = 10+layout.textBoundingSize.width + 20 + _tipPading;
        }
    }
    _tagLayouts = [NSArray arrayWithArray:layouts];
    _tipViewHeight += _topMargin;
}

@end
