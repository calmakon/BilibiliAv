//
//  LiveCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/24.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveCell.h"

@interface LiveCell ()
@property (nonatomic,strong) AvImageView * leftImageView;
@property (nonatomic,strong) AvImageView * rightImageView;

@end

@implementation LiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat imageWidth = ([UIScreen mainScreen].bounds.size.width-(10*3))/2;
        self.contentView.backgroundColor = kBgColor;
        self.leftImageView.left = 10;
        self.leftImageView.top = 5;
        self.leftImageView.size = CGSizeMake(imageWidth, 0);
        
        self.rightImageView.left = self.leftImageView.right+10;
        self.rightImageView.top = 5;
        self.rightImageView.size = CGSizeMake(imageWidth, 0);
    }
    return self;
}

-(void)setIsHot:(BOOL)isHot
{
    _isHot = isHot;
}

-(void)setLeftItem:(LiveItem *)leftItem
{
    if (!leftItem) return;
    _leftItem = leftItem;
    self.leftImageView.isHot = self.isHot;
    self.leftImageView.liveData = leftItem;
    self.height = self.leftImageView.height+10;
}

-(void)setRightItem:(LiveItem *)rightItem
{
    if (!rightItem) return;
    _rightItem = rightItem;
    self.rightImageView.isHot = self.isHot;
    self.rightImageView.liveData = rightItem;
    
    if (self.isHot) {
        if (self.index == self.listData.lives.count-1) {
            self.rightImageView.isLast = YES;
        }
    }else{
        if (self.index == 3) {
            self.rightImageView.isLast = YES;
        }
    }
    self.height = self.rightImageView.height+10;
}

-(AvImageView *)leftImageView
{
    if (!_leftImageView) {
        _leftImageView = [AvImageView new];
        [self addSubview:_leftImageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveClick:)];
        [_leftImageView addGestureRecognizer:tap];
    }
    return _leftImageView;
}

-(AvImageView *)rightImageView
{
    if (!_rightImageView) {
        _rightImageView = [AvImageView new];
        [self addSubview:_rightImageView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveClick:)];
        [_rightImageView addGestureRecognizer:tap];
        
        [_rightImageView refreshCurrentCellWithBlock:^{
                        if (self.refreshBlock) {
                            self.refreshBlock();
                        }
        }];
    }
    return _rightImageView;
}

-(void)liveClick:(UITapGestureRecognizer *)tap
{
    AvImageView * imageView = (AvImageView *)tap.view;
    if (self.clickBlock) {
        self.clickBlock(imageView.liveData);
    }
}

-(void)liveItemClickWithBlock:(LiveClickBlock)block
{
    self.clickBlock = block;
}

-(void)refreshLiveDataWithBlock:(refreshLiveDataBlock)block
{
    self.refreshBlock = block;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
