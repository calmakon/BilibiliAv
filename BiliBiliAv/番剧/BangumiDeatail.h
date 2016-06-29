//
//  BangumiDeatail.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/7.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Actor,BangumiAvBody,Rank,Season,Tag;
@interface BangumiDeatail : NSObject
@property (nonatomic,copy) NSArray * actor;
@property (nonatomic,copy) NSString * allow_bp;
@property (nonatomic,copy) NSString * allow_download;
@property (nonatomic,copy) NSString * area;
@property (nonatomic,copy) NSString * arealimit;
@property (nonatomic,copy) NSString * bangumi_id;
@property (nonatomic,copy) NSString * bangumi_title;
@property (nonatomic,copy) NSString * brief;
@property (nonatomic,copy) NSString * coins;
@property (nonatomic,copy) NSString * copyright;
@property (nonatomic,copy) NSString * cover;
@property (nonatomic,copy) NSString * danmaku_count;
@property (nonatomic,copy) NSArray * episodes;
@property (nonatomic,copy) NSString * evaluate;
@property (nonatomic,copy) NSString * favorites;
@property (nonatomic,copy) NSString * is_finish;
@property (nonatomic,copy) NSString * newest_ep_id;
@property (nonatomic,copy) NSString * newest_ep_index;
@property (nonatomic,copy) NSString * play_count;
@property (nonatomic,copy) NSString * pub_time;
@property (nonatomic,strong) Rank * rank;
@property (nonatomic,copy) NSString * season_id;
@property (nonatomic,copy) NSString * season_title;
@property (nonatomic,copy) NSArray * seasons;
@property (nonatomic,copy) NSString * share_url;
@property (nonatomic,copy) NSString * squareCover;
@property (nonatomic,copy) NSString * staff;
@property (nonatomic,copy) NSArray * tags;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * total_count;
@property (nonatomic,copy) NSString * viewRank;
@property (nonatomic,copy) NSString * watchingCount;
@property (nonatomic,copy) NSString * weekday;
@end

@interface Actor: NSObject
@property (nonatomic,copy) NSString * actor;
@property (nonatomic,copy) NSString * actor_id;
@property (nonatomic,copy) NSString * role;
@end


@interface BangumiAvBody : NSObject
@property (nonatomic,copy) NSString * av_id;
@property (nonatomic,copy) NSString * coins;
@property (nonatomic,copy) NSString * cover;
@property (nonatomic,copy) NSString * danmaku;
@property (nonatomic,copy) NSString * episode_id;
@property (nonatomic,copy) NSString * index;
@property (nonatomic,copy) NSString * index_title;
@property (nonatomic,copy) NSString * is_new;
@property (nonatomic,copy) NSString * is_webplay;
@property (nonatomic,copy) NSString * mid;
@property (nonatomic,copy) NSString * page;
@property (nonatomic,copy) NSString * update_time;
@end

@class RankBody;
@interface Rank: NSObject
@property (nonatomic,copy) NSArray * list;
@property (nonatomic,copy) NSString * total_bp_count;
@property (nonatomic,copy) NSString * week_bp_count;
@end

@interface RankBody: NSObject
@property (nonatomic,copy) NSString * face;
@property (nonatomic,copy) NSString * uid;
@property (nonatomic,copy) NSString * uname;
@end

@interface Season: NSObject
@property (nonatomic,copy) NSString * bangumi_id;
@property (nonatomic,copy) NSString * cover;
@property (nonatomic,copy) NSString * is_finish;
@property (nonatomic,copy) NSString * newest_ep_id;
@property (nonatomic,copy) NSString * newest_ep_index;
@property (nonatomic,copy) NSString * season_id;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSString * total_count;
@end

@interface Tag: NSObject
@property (nonatomic,copy) NSString * index;
@property (nonatomic,copy) NSString * cover;
@property (nonatomic,copy) NSString * orderType;
@property (nonatomic,copy) NSString * style_id;
@property (nonatomic,copy) NSString * tag_id;
@property (nonatomic,copy) NSString * tag_name;
@property (nonatomic,copy) NSString * type;
@end
