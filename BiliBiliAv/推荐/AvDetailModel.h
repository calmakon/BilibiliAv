//
//  AvDetailModel.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/22.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Owner,Stat,RelateModel,Page;
@interface AvDetailModel : NSObject
@property(nonatomic,copy) NSString * aid;
@property(nonatomic,copy) NSString * copyright;
@property(nonatomic,copy) NSString * desc;
@property(nonatomic,copy) NSString * pic;
@property(nonatomic,copy) NSString * pubdate;
@property(nonatomic,copy) NSString * tid;
@property(nonatomic,copy) NSString * title;
@property(nonatomic,copy) NSString * tname;
@property(nonatomic,copy) NSArray * tags;
@property(nonatomic,copy) NSArray * relates;
@property(nonatomic,copy) NSArray * pages;
@property(nonatomic,strong) Stat * stat;
@property(nonatomic,strong) Owner * owner;
@end

@interface Owner: NSObject
@property(nonatomic,copy) NSString * face;
@property(nonatomic,copy) NSString * mid;
@property(nonatomic,copy) NSString * name;
@end

@interface Stat: NSObject
@property(nonatomic,copy) NSString * coin;
@property(nonatomic,copy) NSString * danmaku;
@property(nonatomic,copy) NSString * favorite;
@property(nonatomic,copy) NSString * reply;
@property(nonatomic,copy) NSString * share;
@property(nonatomic,copy) NSString * view;
@end

@class Stat,Owner;
@interface RelateModel: NSObject
@property(nonatomic,copy) NSString * aid;
@property(nonatomic,copy) NSString * pic;
@property(nonatomic,copy) NSString * title;
@property(nonatomic,strong) Stat * stat;
@property(nonatomic,strong) Owner * owner;
@end

@interface Page: NSObject
@property(nonatomic,copy) NSString * cid;
@property(nonatomic,copy) NSString * from;
@property(nonatomic,copy) NSString * has_alias;
@property(nonatomic,copy) NSString * link;
@property(nonatomic,copy) NSString * page;
@property(nonatomic,copy) NSString * part;
@property(nonatomic,copy) NSString * rich_vid;
@property(nonatomic,copy) NSString * vid;
@property(nonatomic,copy) NSString * weblink;
@end
