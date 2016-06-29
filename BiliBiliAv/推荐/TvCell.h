//
//  TvCell.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuiJianList.h"
@interface TvCell : UITableViewCell
@property(nonatomic,copy) NSArray * bodys;
@property(nonatomic,strong) TuiJianList * list;
@end
