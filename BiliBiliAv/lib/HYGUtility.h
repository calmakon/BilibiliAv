//
//  HYGUtility.h
//  SDLayoutTest
//
//  Created by 胡亚刚 on 16/4/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HYGUtility : NSObject
/*
 返回距离当前时间还有多久（天，小时，分钟）
 */
+ (NSString *) returnConfigDateStr:(NSDate *)lastDate;
/*
 返回多久时间前
 */
+ (NSString *) returnUploadTime:(NSString *)customDate;
/*
 去掉HTML标签
 */
//去掉html标签
+(NSString *)filterHTML:(NSString *)html trimWhiteSpace:(BOOL)trim;
/*
 缩放图片 （生成缩略图）
 */
+ (UIImage *) image: (UIImage *) image fillSize: (CGSize) viewsize;
/*
 根据几月几号返回所属星座
 */
+ (NSString *) getConstellationWithMonth:(NSInteger)month day:(NSInteger)day;
/*
 对长数字处理成短格式（1~9999->不变，10000~9999999->%ld万，10000000~MAX->%ld千万）
 */
+ (NSString *)shortedNumberDesc:(NSInteger)number;
/*
 验证邮箱
 */
+ (BOOL) validateEmail:(NSString *)email;
/*
 验证手机号
 */
+ (BOOL) validateMobile:(NSString *)mobile;
//密码
+ (BOOL) validatePassword:(NSString *)passWord;
/*
 验证身份证号
 */
+ (BOOL) validateIdentityCard: (NSString *)identityCard;
/*
 获取当前时间戳
 */
+ (NSString *)getCurrentCursor;

@end
