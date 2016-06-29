//
//  RreplyCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/6.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "RreplyCell.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "HYGUtility.h"
#import "WebViewController.h"
@interface RreplyCell ()
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * dateLabel;
@property (nonatomic,strong) YYLabel * contentLabel;
@property (nonatomic,strong) UIButton * moreBtn;
@end


@implementation RreplyCell

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

    UIView * topLine = [UIView new];
    topLine.backgroundColor = [UIColor lightGrayColor];
    [contentView addSubview:topLine];
    
    topLine.sd_layout.leftSpaceToView(contentView,45).topSpaceToView(contentView,0).rightSpaceToView(contentView,10).heightIs(CGFloatFromPixel(1));
    
    self.nameLabel.sd_layout.leftEqualToView(topLine).topSpaceToView(contentView,10).heightIs(15);
    [self.nameLabel setSingleLineAutoResizeWithMaxWidth:120];

    self.moreBtn.sd_layout.rightSpaceToView(contentView,10).topEqualToView(self.nameLabel).heightIs(15).widthIs(25);
    
    self.dateLabel.sd_layout.leftSpaceToView(self.nameLabel,5).topEqualToView(self.nameLabel).heightIs(12).centerYEqualToView(self.nameLabel);
    [self.dateLabel setSingleLineAutoResizeWithMaxWidth:100];
    
    self.contentLabel.sd_layout.leftEqualToView(self.nameLabel).topSpaceToView(self.nameLabel,10).rightSpaceToView(contentView,20);
}

-(void)setRreplyLayout:(RreplyLayout *)rreplyLayout
{
    if (!rreplyLayout) return;
    _rreplyLayout = rreplyLayout;
    
    self.nameLabel.text = rreplyLayout.data.member.uname;
    
    self.dateLabel.text = [HYGUtility returnUploadTime:rreplyLayout.data.ctime];
    self.contentLabel.textLayout = rreplyLayout.contentLayout;
    
    self.contentLabel.sd_layout.heightIs(rreplyLayout.contentHeight);
    [self.contentLabel updateLayout];
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

-(UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.font = [UIFont systemFontOfSize:10];
        _dateLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
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

-(void)moreClick
{
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
