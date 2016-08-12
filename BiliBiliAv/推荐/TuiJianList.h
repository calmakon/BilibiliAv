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
@class AVModelBody,Banner;
@interface TuiJianList : NSObject
@property(nonatomic,copy) NSMutableArray * body;
@property (nonatomic,strong) Banner * banner;
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


@interface Banner : NSObject
@property(nonatomic,copy) NSMutableArray * bottom;
@end


