//
//  ReplyLayout.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/6.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "ReplyLayout.h"
#import "ImageText.h"

@implementation ReplyLayout

-(instancetype)initWithDetail:(ReplyListModel *)data
{
    if (!data) return nil;
    self = [super init];
    _data = data;
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
    _leftPadding = 10;
    _nameHeight = 15;
    _floorHeight = 12;
    
    [self _layoutContent];
    
    _height = 0;
    _height += 15+_nameHeight+2+_floorHeight+_topMargin;
    
    _height += _contentHeight+20;
}

-(void)_layoutContent{
    _contentHeight = 0;
    _contentLayout = nil;
    
    NSString * content = _data.content.message;
    
    NSMutableAttributedString * contentText = [ImageText _textWithTextString:content fontSize:13 textColor:[UIColor colorWithHexString:TextColor]];
    if (contentText.length == 0) return;
    
    AvTextLinePositionModifier *modifier = [AvTextLinePositionModifier new];
    modifier.font = [UIFont systemFontOfSize:13];
    modifier.paddingTop = 0;
    modifier.paddingBottom = 0;
    
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(kScreenWidth-45-10, HUGE);
    container.linePositionModifier = modifier;
    
    _contentLayout = [YYTextLayout layoutWithContainer:container text:contentText];
    if (!_contentLayout) return;
    
    _contentHeight = _contentLayout.textBoundingSize.height;
    
}

-(NSString *)levelImageName
{
    return [NSString stringWithFormat:@"misc_level_whiteLv%ld",[_data.member.level_info.current_level integerValue]];
}


@end
