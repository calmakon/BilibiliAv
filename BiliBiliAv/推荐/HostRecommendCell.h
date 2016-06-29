//
//  HostRecommendCell.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "AvBaseCell.h"
@class HostRecommendCell;
typedef void (^refreshBlock) (HostRecommendCell * hostCell);
@interface HostRecommendCell : AvBaseCell

@property (nonatomic,copy) refreshBlock refresh;
- (void) refreshCurrentCellWithBlock:(refreshBlock)blcok;
-(void)animaiton;
-(void)stopAnimation;
@end
