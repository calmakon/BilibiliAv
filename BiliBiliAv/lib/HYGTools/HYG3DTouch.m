//
//  HYG3DTouch.m
//  SDLayoutTest
//
//  Created by 胡亚刚 on 16/5/3.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "HYG3DTouch.h"

@implementation HYG3DTouch
+(void)initWithItems:(NSArray *)items
{
    if (!items||items.count == 0) return;
    
    NSMutableArray * itemArray = [NSMutableArray array];
    for (int i=0; i<items.count; i++) {
        
        HYG3DTouchItem * hygItem = items[i];
        
        UIApplicationShortcutItem * item = [[UIApplicationShortcutItem alloc]initWithType:hygItem.type localizedTitle:hygItem.localizedTitle?:nil   localizedSubtitle:hygItem.localizedSubtitle?:nil icon:hygItem.iconImageName?[UIApplicationShortcutIcon iconWithTemplateImageName:hygItem.iconImageName]:(hygItem.icon?[UIApplicationShortcutIcon iconWithType:hygItem.icon]:nil) userInfo:hygItem.userInfo?:nil];
        [itemArray addObject:item];
    }
    [UIApplication sharedApplication].shortcutItems = itemArray;
}

+(UIApplicationShortcutItem *)initWithItem:(HYG3DTouchItem *)item
{
    if (!item) return nil;
    return [[UIApplicationShortcutItem alloc]initWithType:item.type localizedTitle:item.localizedTitle?:nil   localizedSubtitle:item.localizedSubtitle?:nil icon:item.iconImageName?[UIApplicationShortcutIcon iconWithTemplateImageName:item.iconImageName]:(item.icon?[UIApplicationShortcutIcon iconWithType:item.icon]:nil) userInfo:item.userInfo?:nil];
}

@end
