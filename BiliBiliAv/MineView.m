//
//  MineView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "MineView.h"

@implementation MineView

-(void)setItemArray:(NSArray *)itemArray
{
    if (!itemArray) return;
    _itemArray = itemArray;
    
    for (int i=0; i<itemArray.count; i++) {
        MineItemView * itemView = [MineItemView new];
        itemView.left = i%4*itemView.width;
        itemView.top = i/4*itemView.height;
        [self addSubview:itemView];
        itemView.tag = i;
        
        MineItem * item = itemArray[i];
        itemView.item = item;
        
        if (i == itemArray.count-1) {
            self.size = CGSizeMake(kScreenWidth, itemView.bottom);
        }
        
        if (item.icon.length!=0||item.title.length!=0) {
            UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
            [tap addTarget:self action:@selector(itemClick:)];
            [itemView addGestureRecognizer:tap];
        }
    }
}

-(void)itemClick:(UITapGestureRecognizer *)tap
{
    MineItemView * tapView = (MineItemView *)tap.view;
    if ([self.delegate respondsToSelector:@selector(selectItemWithIndex:)]) {
        [self.delegate selectItemWithIndex:tapView.tag];
    }
}

@end
