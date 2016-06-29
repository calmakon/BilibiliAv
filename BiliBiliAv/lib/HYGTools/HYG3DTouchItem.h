//
//  HYG3DTouchItem.h
//  SDLayoutTest
//
//  Created by 胡亚刚 on 16/5/3.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYG3DTouchItem : NSObject

/*
 类型标记
 */
@property (nonatomic,copy) NSString * type;
/*
 标题
 */
@property (nonatomic,copy) NSString * localizedTitle;
/*
 二级标题
 */
@property (nonatomic,copy) NSString * localizedSubtitle;
/*
 自定义的icon图片名字
 */
@property (nonatomic,copy) NSString * iconImageName;
/*
 不使用自定义的icon，使用系统的icon类型
 */
@property (nonatomic,assign) UIApplicationShortcutIconType icon;
/*
 附加信息
 */
@property (nonatomic,copy) NSDictionary * userInfo;

@end
