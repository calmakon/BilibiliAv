//
//  AvListCell.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/3.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "AvBaseCell.h"
@class AvListCell;
typedef void (^refreshListBlock) (AvListCell * listCell);
@interface AvListCell : AvBaseCell
@property(nonatomic,copy) NSString * typeName;

@property (nonatomic,copy) refreshListBlock refresh;
@property (nonatomic,copy) NSString * refreshNum;
- (void) refreshCurrentCellWithBlock:(refreshListBlock)blcok;
-(void)animaiton;
-(void)stopAnimation;

@end
