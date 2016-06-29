//
//  DanMuKuModel.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/23.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class d;
@interface DanMuKuModel : NSObject
@property(nonatomic,copy) NSString * __name;
@property(nonatomic,copy) NSString * chatid;
@property(nonatomic,copy) NSString * chatserver;
@property(nonatomic,copy) NSString * mission;
@property(nonatomic,copy) NSString * maxlimit;
@property(nonatomic,copy) NSString * source;
@property(nonatomic,copy) NSArray * d;
@end

@interface d: NSObject
@property(nonatomic,copy) NSString * __text;
@property(nonatomic,copy) NSString * _p;
@end

