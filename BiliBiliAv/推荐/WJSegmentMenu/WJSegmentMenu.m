//
//  WJSegmentMenu.m
//  WJSegmentMenu
//
//  Created by 吴计强 on 16/3/22.
//  Copyright © 2016年 com.firsttruck. All rights reserved.
//

#import "WJSegmentMenu.h"
#import "UIColor+YYAdd.h"
@interface WJSegmentMenu (){
    
    CGFloat _btnW;
    UIView *_line;
    NSInteger _lastTag;
}

@end

@implementation WJSegmentMenu

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
        
        CALayer * line = [CALayer layer];
        line.frame = CGRectMake(0, self.bottom-1, self.width, CGFloatFromPixel(1));
        line.backgroundColor = [UIColor lightGrayColor].CGColor;
        [self.layer addSublayer:line];
    }
    return self;
}

- (void)segmentWithTitles:(NSArray *)titles{
    
    // 创建按钮
    _btnW = self.frame.size.width/4;
    for (int i = 0; i < titles.count; i ++) {
        
        UIButton *button = [[UIButton alloc]init];
        button.tag = 730+i;
        button.frame = CGRectMake(_btnW+(i * _btnW), 0, _btnW, self.frame.size.height-2);
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:0.86 green:0.40 blue:0.54 alpha:1] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        if (button.tag == 730) {
            button.selected = YES;
            _lastTag = button.tag;
        }
        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
    }
    
    // 创建滑块
    UIView *line = [[UIView alloc]init];
    line.frame = CGRectMake(_btnW, self.frame.size.height-2, _btnW, 2);
    line.backgroundColor = [UIColor colorWithRed:0.86 green:0.40 blue:0.54 alpha:1];
    [self addSubview:line];
    _line = line;
}

-(void)scrollWithOffSet:(CGFloat)offSet
{
    CGFloat x =_btnW+offSet/4;
    CGRect frame = _line.frame;
    frame.origin.x = x;
    _line.frame = frame;
    
    if (x == _btnW) {
        UIButton *leftBtn = (id)[self viewWithTag:730];
        leftBtn.selected = YES;
        UIButton *rightBtn = (id)[self viewWithTag:731];
        rightBtn.selected = NO;
    }
    if (x == 2*_btnW) {
        UIButton *leftBtn = (id)[self viewWithTag:730];
        leftBtn.selected = NO;
        UIButton *rightBtn = (id)[self viewWithTag:731];
        rightBtn.selected = YES;
    }
}

// 点击事件
- (void)click:(UIButton *)btn{
    if (_lastTag >= 700) {
        UIButton *lastBtn = (id)[self viewWithTag:_lastTag];
        lastBtn.selected = NO;
    }
    btn.selected = YES;    
    _lastTag = btn.tag;
    
    if ([_delegate respondsToSelector:@selector(segmentWithIndex:title:)]) {
        [_delegate segmentWithIndex:(btn.tag-730) title:btn.titleLabel.text];
    }
    
    
}



- (void)layoutSubviews{
    
    
}


@end
