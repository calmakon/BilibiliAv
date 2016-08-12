//
//  MineView.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineItemView.h"
#import "MineItem.h"

@protocol MineViewDelegate <NSObject>

-(void)selectItemWithIndex:(NSInteger)index;

@end

@interface MineView : UIView
@property (nonatomic,copy) NSArray * itemArray;
@property (nonatomic,weak) id <MineViewDelegate>delegate;
@end
