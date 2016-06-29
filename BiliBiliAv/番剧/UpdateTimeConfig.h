//
//  UpdateTimeConfig.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateTimeConfig : NSObject
+ (NSString *) returnConfigTimeWithCursor:(NSString *)cursor;
+ (BOOL) isToDay:(NSString *)cursor;
@end
