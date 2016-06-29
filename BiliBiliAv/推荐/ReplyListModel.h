//
//  ReplyListModel.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/5.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Content,Member;
@interface ReplyListModel : NSObject
@property (nonatomic,copy) NSString * action;
@property (nonatomic,copy) NSString * count;
@property (nonatomic,copy) NSString * ctime;
@property (nonatomic,copy) NSString * floor;
@property (nonatomic,copy) NSString * like;
@property (nonatomic,copy) NSString * mid;
@property (nonatomic,copy) NSString * oid;
@property (nonatomic,copy) NSString * parent;
@property (nonatomic,copy) NSString * parent_str;
@property (nonatomic,copy) NSString * rcount;
@property (nonatomic,copy) NSString * root;
@property (nonatomic,copy) NSString * root_str;
@property (nonatomic,copy) NSString * rpid;
@property (nonatomic,copy) NSString * rpid_str;
@property (nonatomic,copy) NSString * state;
@property (nonatomic,copy) NSString * type;
@property (nonatomic,strong) Content * content;
@property (nonatomic,strong) Member * member;
@property (nonatomic,copy) NSArray * replies;
@property (nonatomic,copy) NSArray * listReplys;
@end

@interface Content : NSObject
@property (nonatomic,copy) NSString * device;
@property (nonatomic,copy) NSString * message;
@property (nonatomic,copy) NSString * plat;
@end

@class LevelInfo;
@interface Member : NSObject
@property (nonatomic,copy) NSString * avatar;
@property (nonatomic,copy) NSString * DisplayRank;
@property (nonatomic,copy) NSString * mid;
@property (nonatomic,copy) NSString * rank;
@property (nonatomic,copy) NSString * sex;
@property (nonatomic,copy) NSString * sign;
@property (nonatomic,copy) NSString * uname;
@property (nonatomic,strong) LevelInfo * level_info;
@end

@interface LevelInfo : NSObject
@property (nonatomic,copy) NSString * current_exp;
@property (nonatomic,copy) NSString * current_level;
@property (nonatomic,copy) NSString * current_min;
@property (nonatomic,copy) NSString * next_exp;
@end
