//
//  MineItemModel.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MineItem.h"
@interface MineItemModel : NSObject
@property (nonatomic,copy) NSArray * mine;
@property (nonatomic,copy) NSArray * message;
@property (nonatomic,assign) CGFloat mineCellHeight;
@property (nonatomic,assign) CGFloat messageCellHeight;
@end
