//
//  LiveData.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/20.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveData.h"
#import "LiveItem.h"
@implementation LiveData
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"listItem" : [LiveListItem class]};
}
@end

