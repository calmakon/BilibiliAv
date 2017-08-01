//
//  LiveListData.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/21.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LiveListItem.h"
#import "Banner.h"
@interface LiveListData : NSObject
@property (nonatomic,copy) NSArray * banner;
@property (nonatomic,copy) NSArray * partitions;
@end
