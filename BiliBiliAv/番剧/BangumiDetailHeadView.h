//
//  BangumiDetailHeadView.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/7.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BangumiDeatail.h"
typedef void (^BackBlock)();
typedef void (^ItemClickBlock)(BangumiAvBody *body);
typedef void (^seasonItemClickBlock)(Season *season);
typedef void (^detailClickBlock)(BangumiDeatail *detail);
@interface BangumiDetailHeadView : UIView
@property (nonatomic,strong) BangumiDeatail * detail;
@property (nonatomic,copy) BackBlock backBlock;
@property (nonatomic,copy) ItemClickBlock itemBlock;
@property (nonatomic,copy) detailClickBlock detailBlock;
@property (nonatomic,copy) seasonItemClickBlock seasonBlock;
-(void)backWithBlock:(BackBlock)block;
-(void)itemClickedWithBlock:(ItemClickBlock)block;
-(void)seasonItemClickedWithBlock:(seasonItemClickBlock)block;
-(void)detailClickedWithBlock:(detailClickBlock)block;
@end
