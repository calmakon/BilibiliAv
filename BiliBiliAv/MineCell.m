//
//  MineCell.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "MineCell.h"
#import "MineView.h"

@interface MineCell ()<MineViewDelegate>
@property (nonatomic,strong) MineView * mineView;
@end

@implementation MineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

-(void)setItemArray:(NSArray *)itemArray
{
    _itemArray = itemArray;
    self.mineView.itemArray = itemArray;
}

-(MineView *)mineView
{
    if (!_mineView) {
        _mineView = [MineView new];
        _mineView.delegate = self;
        [self.contentView addSubview:_mineView];
    }
    return _mineView;
}

-(void)selectItemWithIndex:(NSInteger)index
{
    if (self.seleB) {
        self.seleB(index);
    }
}

-(void)selectItemWithBlock:(selectBlock)block
{
    self.seleB = block;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
