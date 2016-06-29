//
//  LatestUpdateCell.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BangumiList.h"
#import "BangumiBody.h"
typedef void (^cellItemClickBlock) (BangumiBody * body);
@interface LatestUpdateCell : UITableViewCell
@property(nonatomic,strong) UIView * bgView;
@property(nonatomic,copy) NSArray * bodys;
@property(nonatomic,assign) CGFloat viewWidth;
@property(nonatomic,assign) CGFloat viewHeight;
@property(nonatomic,assign) CGFloat cellHeight;
@property(nonatomic,strong) BangumiList * list;
@property(nonatomic,copy) cellItemClickBlock block;
-(void)cellClickWithBlock:(cellItemClickBlock)block;
@end
