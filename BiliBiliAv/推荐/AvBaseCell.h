//
//  AvBaseCell.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuiJianList.h"
#import "AvImageView.h"
#import "AVModel.h"
typedef void (^cellItemClickBlock) (AVModelBody * body);
typedef void (^goInfoClickBlock) ();
@interface AvBaseCell : UITableViewCell
@property(nonatomic,strong) UIView * bgView;
@property(nonatomic,copy) NSArray * bodys;
@property(nonatomic,assign) CGFloat viewWidth;
@property(nonatomic,assign) CGFloat viewHeight;
@property(nonatomic,assign) CGFloat cellHeight;
@property(nonatomic,strong) TuiJianList * list;
@property(nonatomic,copy) cellItemClickBlock block;
-(void)cellClickWithBlock:(cellItemClickBlock)block;
@property(nonatomic,copy) goInfoClickBlock goInfoBlock;
-(void)goInfoClickWithBlock:(goInfoClickBlock)block;
@end
