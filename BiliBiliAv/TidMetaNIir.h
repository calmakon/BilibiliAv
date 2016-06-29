//
//  TidMetaNIir.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/15.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Root;
@interface TidMetaNIir : NSObject

@property (nonatomic,copy) NSArray * root;
+ (TidMetaNIir *)shareTidMeta;
@end

@interface Root : NSObject

@property (nonatomic,copy) NSString * searchname;
@property (nonatomic,copy) NSString * captionname;
@property (nonatomic,copy) NSString * tid;
@property (nonatomic,copy) NSString * typeName;
@property (nonatomic,copy) NSString * url;

@end

