//
//  BangumiList.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BangumiBody.h"
#import "YYTextLayout.h"

@class BangumiLatestUpdate,BangumiBanner;
@interface BangumiList : NSObject
@property(nonatomic,copy) NSMutableArray * banners;
@property(nonatomic,copy) NSMutableArray * ends;
@property (nonatomic,strong) BangumiLatestUpdate * latestUpdate;
@property(nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGFloat endCellHeight;
@property(nonatomic,copy) YYTextLayout * gotoInfoText;
@end

@interface BangumiLatestUpdate : NSObject
@property(nonatomic,copy) NSMutableArray * list;
@property (nonatomic,copy) NSString * updateCount;
@end

@interface BangumiBanner : NSObject
@property(nonatomic,copy) NSString * img;
@property (nonatomic,copy) NSString * link;
@property (nonatomic,copy) NSString * title;
@end


