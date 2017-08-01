//
//  TuiJianList.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/2/19.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVModel.h"
#import "TopPicModel.h"
#import "YYTextLayout.h"
@class AVModelBody,banner;
@interface TuiJianList : NSObject
@property(nonatomic,copy) NSMutableArray * body;
@property (nonatomic,strong) banner * banner;
@property(nonatomic,copy) NSString * param;
@property(nonatomic,copy) NSString * style;
@property(nonatomic,copy) NSString * title;
@property(nonatomic,copy) NSString * type;
@property(nonatomic,copy) NSString * live_count;

@property(nonatomic,assign) CGFloat cellHeight;
@property(nonatomic,copy) NSString * tipImageName;
@property(nonatomic,copy) NSString * typeName;
@property(nonatomic,copy) YYTextLayout * gotoInfoText;
@end


@interface banner : NSObject
@property(nonatomic,copy) NSMutableArray * bottom;
@end


