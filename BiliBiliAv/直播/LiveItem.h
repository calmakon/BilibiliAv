//
//  LiveItem.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/20.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvDetailModel.h"
@class Cover;
@interface LiveItem : NSObject
@property (nonatomic,copy) NSString * accept_quality;
@property (nonatomic,copy) NSString * area;
@property (nonatomic,copy) NSString * area_id;
@property (nonatomic,copy) NSString * broadcast_type;
@property (nonatomic,copy) NSString * check_version;
@property (nonatomic,copy) NSString * is_tv;
@property (nonatomic,copy) NSString * online;
@property (nonatomic,copy) NSString * playurl;
@property (nonatomic,copy) NSString * room_id;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,strong) Owner * owner;
@property (nonatomic,strong) Cover * cover;
+(CGFloat) cellHeight;
@end

@interface Cover : NSObject
@property (nonatomic,copy) NSString * height;
@property (nonatomic,copy) NSString * width;
@property (nonatomic,copy) NSString * src;
@end
