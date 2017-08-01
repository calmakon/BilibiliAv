//
//  LiveListItem.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/21.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "LiveData.h"
#import "LiveItem.h"
#import "YYTextLayout.h"

@class Partition;
@interface LiveListItem : NSObject
@property (nonatomic,copy) NSArray * banner_data;
@property (nonatomic,copy) NSArray * lives;
@property (nonatomic,strong) Partition * partition;

@property(nonatomic,copy) YYTextLayout * moreText;
@end


@class Sub_icon;
@interface Partition : NSObject
@property (nonatomic,copy) NSString * area;
@property (nonatomic,copy) NSString * count;
@property (nonatomic,copy) NSString * id;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,strong) Sub_icon * sub_icon;
//扩展
@property (nonatomic,copy) NSString * reFreshUrl;
@end

@interface Sub_icon : NSObject
@property (nonatomic,copy) NSString * height;
@property (nonatomic,copy) NSString * width;
@property (nonatomic,copy) NSString * src;
@end
