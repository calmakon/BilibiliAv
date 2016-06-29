//
//  HYG3DTouch.h
//  SDLayoutTest
//
//  Created by 胡亚刚 on 16/5/3.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HYG3DTouchItem.h"

@interface HYG3DTouch : NSObject
/*
 初始化 items:多个HYG3DTouchItem的数组,最多四个,多余的设置无效
             HYG3DTouchItem * itemmm = [HYG3DTouchItem new];
             itemmm.type = @"one";
             itemmm.localizedTitle = @"标签1";
             itemmm.localizedSubtitle = @"呵呵。。";
             itemmm.iconImageName = @"xxx.png";
             itemmm.userInfo = @{@"demo":@"demoValue"};
             [items addObject:itemmm];
 */
+ (void) initWithItems:(NSArray *)items;
/*
 初始化单个icon标签
 */
+ (UIApplicationShortcutItem *)initWithItem:(HYG3DTouchItem *)item;

@end
