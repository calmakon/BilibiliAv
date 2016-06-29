//
//  ReplyList.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/5.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReplyListModel.h"

@class Pagee;
@interface ReplyList : NSObject
@property (nonatomic,copy) NSArray * hots;
@property (nonatomic,strong) Pagee * page;
@property (nonatomic,copy) NSArray * replies;
@end

@interface Pagee : NSObject
@property (nonatomic,copy) NSString * acount;
@property (nonatomic,copy) NSString * count;
@property (nonatomic,copy) NSString * num;
@property (nonatomic,copy) NSString * size;
@end

