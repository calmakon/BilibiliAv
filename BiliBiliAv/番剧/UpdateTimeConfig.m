//
//  UpdateTimeConfig.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "UpdateTimeConfig.h"
#import "NSDate+YYAdd.h"
@implementation UpdateTimeConfig

+(NSString *)returnConfigTimeWithCursor:(NSString *)cursor
{
   NSDate *date = [NSDate dateWithTimeIntervalSince1970:cursor.doubleValue];
    NSString * string = [date stringWithFormat:@"HH:mm"];
    NSInteger w = date.weekday;
    NSInteger h = date.hour;
    
    NSString * context;
    
    if (date.isYesterday) {
        context = @"昨天";
    }else{
        if (date.isToday) {
            if (h<6) {
                context = @"凌晨";
            }
            
            if (h<12&&h>6) {
                context = @"上午";
            }
            
            if (h<13&&h>11) {
                context = @"中午";
            }
            
            if (h>13) {
                context = @"下午";
            }
        }else{
            switch (w-1) {
                case 1:
                    context = @"周一";
                    break;
                case 2:
                    context = @"周二";
                    break;
                case 3:
                    context = @"周三";
                    break;
                case 4:
                    context = @"周四";
                    break;
                case 5:
                    context = @"周五";
                    break;
                case 6:
                    context = @"周六";
                    break;
                case 0:
                    context = @"周日";
                    break;
                default:
                    break;
            }
        }
    }
    
    return [NSString stringWithFormat:@"%@%@",context,string];
}

+(BOOL)isToDay:(NSString *)cursor
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:cursor.doubleValue];
    return date.isToday;
}

@end
