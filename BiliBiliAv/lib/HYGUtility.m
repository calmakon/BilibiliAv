//
//  HYGUtility.m
//  SDLayoutTest
//
//  Created by 胡亚刚 on 16/4/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "HYGUtility.h"

@implementation HYGUtility
+ (NSString *) returnConfigDateStr:(NSDate *)lastDate
{
    NSTimeInterval late = [lastDate timeIntervalSince1970]*1;
    NSDate* currentDate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: currentDate];
    NSDate *localeDate = [currentDate  dateByAddingTimeInterval: interval];
    
    NSTimeInterval now=[localeDate timeIntervalSince1970]*1;
    
    NSTimeInterval cha = late-now;
    
    NSString *dayStr;
    NSString *hourStr;
    NSString *minStr;
    
    NSMutableString *timeString = [[NSMutableString alloc] initWithString:@""];
    double day = cha/86400;
    if (day>1) {
        dayStr = [NSString stringWithFormat:@"%f", day];
        dayStr = [dayStr substringToIndex:dayStr.length-7];
        dayStr=[NSString stringWithFormat:@"%@天", dayStr];
        [timeString appendString:dayStr];
    }
    
    double hour = (cha-(NSInteger)day*86400);
    if (hour>1) {
        hourStr = [NSString stringWithFormat:@"%f", hour/3600];
        hourStr = [hourStr substringToIndex:hourStr.length-7];
        hourStr=[NSString stringWithFormat:@"%@小时", hourStr];
        [timeString appendString:hourStr];
    }
    
    double min = (hour-(NSInteger)(hour/3600)*3600);
    if (min>1) {
        minStr = [NSString stringWithFormat:@"%f", min/60];
        minStr = [minStr substringToIndex:minStr.length-7];
        minStr=[NSString stringWithFormat:@"%@分钟", minStr];
        [timeString appendString:minStr];
    }
    
    return timeString;
}

+ (NSString *) returnUploadTime:(NSString *)customDate
{
//    NSDateFormatter *date=[[NSDateFormatter alloc] init];
//    [date setDateFormat:@"EEE MMM dd HH:mm:ss yyyy"];
//    NSDate *d=[date dateFromString:customDate];
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:customDate.doubleValue];
    NSTimeInterval late = [d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        if ([timeString intValue]<1) {
            timeString=@"刚刚";
        }else{
            timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        }
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
        
    }
    return timeString;
}

+(NSString *)filterHTML:(NSString *)html trimWhiteSpace:(BOOL)trim
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    
    NSScanner * scanner2 = [NSScanner scannerWithString:html];
    NSString * text2 = nil;
    while([scanner2 isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner2 scanUpToString:@"&" intoString:nil];
        //找到标签的结束位置
        [scanner2 scanUpToString:@";" intoString:&text2];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@;",text2] withString:@""];
    }
    
    return trim ? [html stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : html;
}

//生成缩略图
+ (UIImage *) image: (UIImage *) image fillSize: (CGSize) viewSize
{
    CGSize size = image.size;
    
    CGFloat scaleX = viewSize.width / size.width;
    CGFloat scaleY = viewSize.height / size.height;
    CGFloat scale = MAX(scaleX, scaleY);
    
    UIGraphicsBeginImageContext(viewSize);
    
    CGFloat width = size.width * scale;
    CGFloat height = size.height * scale;
    
    float dWidth = ((viewSize.width - width) / 2.0f);
    float dHeight = ((viewSize.height - height) / 2.0f);
    
    CGRect rect = CGRectMake(dWidth, dHeight, size.width * scale, size.height * scale);
    [image drawInRect:rect];
    
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImg;
}

+ (NSString *) getConstellationWithMonth:(NSInteger)month day:(NSInteger)day
{
    NSString * con = nil;
    if (!month||!day)return nil;
    
    if (month==1) {
        if (day>=20) {
            con = @"水瓶座";
        }else{
            con = @"摩羯座";
        }
    }
    
    if (month==2) {
        if (day>=19) {
            con = @"双鱼座";
        }else{
            con = @"水瓶座";
        }
    }
    
    if (month==3) {
        if (day>=21) {
            con = @"白羊座";
        }else{
            con = @"双鱼座";
        }
    }
    
    if (month==4) {
        if (day>=20) {
            con = @"金牛座";
        }else{
            con = @"白羊座";
        }
    }
    
    if (month==5) {
        if (day>=21) {
            con = @"双子座";
        }else{
            con = @"金牛座";
        }
    }
    
    if (month==6) {
        if (day>=22) {
            con = @"巨蟹座";
        }else{
            con = @"双子座";
        }
    }
    
    if (month==7) {
        if (day>=23) {
            con = @"狮子座";
        }else{
            con = @"巨蟹座";
        }
    }
    
    if (month==8) {
        if (day>=23) {
            con = @"处女座";
        }else{
            con = @"狮子座";
        }
    }
    
    if (month==9) {
        if (day>=23) {
            con = @"天秤座";
        }else{
            con = @"处女座";
        }
    }
    
    if (month==10) {
        if (day>=24) {
            con = @"天蝎座";
        }else{
            con = @"天秤座";
        }
    }
    
    if (month==11) {
        if (day>=23) {
            con = @"射手座";
        }else{
            con = @"天蝎座";
        }
    }
    
    if (month==12) {
        if (day>=20) {
            con = @"摩羯座";
        }else{
            con = @"射手座";
        }
    }
    
    return con;
}

+ (NSString *)shortedNumberDesc:(NSInteger)number {
    // should be localized
    if (number <= 9999) return [NSString stringWithFormat:@"%d", (int)number];
    if (number <= 9999999) return [NSString stringWithFormat:@"%d万", (int)(number / 10000)];
    return [NSString stringWithFormat:@"%d千万", (int)(number / 10000000)];
}

+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(14[0,0-9])|(15[0,0-9])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

+ (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

+ (NSString *)getCurrentCursor
{
    NSTimeInterval currentDate = [[NSDate date] timeIntervalSince1970];
    NSString * cursor = [NSString stringWithFormat:@"%.0f",currentDate];
    return cursor;
}

@end
