//
//  ItemCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "ItemCell.h"
#import "ItemView.h"

@interface ItemCell ()
@property(nonatomic,strong) UIView * bgView;
@property (nonatomic,strong) ItemView * itemView;
@property (nonatomic,copy) NSArray * items;
@end

@implementation ItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = kBgColor;
    }
    return self;
}

-(void)setItem:(ItemConfig *)item
{
    self.itemView.items = item.items;
}


-(ItemView *)itemView
{
    if (!_itemView) {
        _itemView = [ItemView new];
        [self.contentView addSubview:_itemView];
    }
    return _itemView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
