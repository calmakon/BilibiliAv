//
//  ReplyListModel.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/5.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "ReplyListModel.h"

@implementation ReplyListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"content" : [Content class],
             @"member":[Member class],
             @"replies":[ReplyListModel class]
             };
}

-(void)setReplies:(NSArray *)replies
{
    _replies = replies;
    if (replies.count == 0) {
        self.listReplys = @[];
    }else if (replies.count>3) {
        NSMutableArray * array = [NSMutableArray array];
        for (int i=0; i<3; i++) {
            ReplyListModel * data = replies[i];
            [array addObject:data];
        }
        self.listReplys = [NSArray arrayWithArray:array];
    }else{
        self.listReplys = replies;
    }
}

@end

@implementation Content

@end

@implementation Member

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"level_info" : [LevelInfo class]
             };
}

@end

@implementation LevelInfo


@end
