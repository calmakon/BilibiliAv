//
//  TuiJianList.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/2/19.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVModel.h"
#import "YYTextLayout.h"
@class AVModelBody,AVModelHead;
@interface TuiJianList : NSObject
@property(nonatomic,copy) NSMutableArray * body;
@property(nonatomic,strong) AVModelHead * head;
@property(nonatomic,copy) NSString * type;
@property(nonatomic,assign) CGFloat cellHeight;
@property(nonatomic,copy) NSString * tipImageName;
@property(nonatomic,copy) NSString * typeName;
@property(nonatomic,copy) YYTextLayout * gotoInfoText;
@end
