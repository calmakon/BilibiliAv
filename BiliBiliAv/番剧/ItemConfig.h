//
//  ItemConfig.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum type{
    Live = 0,
    Bangumi = 1
}Type;

@class ItemModel;
@interface ItemConfig : NSObject
@property (nonatomic,copy) NSArray * items;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) Type type;
@end

@interface ItemModel : NSObject
@property (nonatomic,copy) NSString * icon;
@property (nonatomic,copy) NSString * title;
@end

