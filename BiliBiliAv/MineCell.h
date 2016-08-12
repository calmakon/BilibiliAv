//
//  MineCell.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineItemModel.h"

typedef void(^selectBlock)(NSInteger index);

@interface MineCell : UITableViewCell
@property (nonatomic,copy) NSArray * itemArray;
@property (nonatomic,copy) selectBlock seleB;
-(void)selectItemWithBlock:(selectBlock)block;
@end
