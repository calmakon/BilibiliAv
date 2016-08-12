//
//  TidMetaNIir.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/15.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "TidMetaNIir.h"
#import "YYModel.h"
#import "HttpClient.h"
@implementation TidMetaNIir

+ (TidMetaNIir *)shareTidMeta
{
    static TidMetaNIir * tid = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [HttpClient GET:kRankItemUrl params:nil isCache:NO cacheSuccess:nil success:^(id response) {
            NSDictionary * rootDic = (NSDictionary *)response;
            NSString * code = rootDic[@"code"];
            if ([code integerValue] == 0) {
                NSDictionary * result = rootDic[@"result"];
                tid = [TidMetaNIir yy_modelWithDictionary:result];
                [tid configSign];
            }
        } failure:^(NSError *err) {
            
        }];
    });
    return tid;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"root" : [Root class]};
}

-(void)configSign
{
    //
    NSArray * array = @[@"http://www.bilibili.com/index/rank/all-03-13.json",
                        @"http://www.bilibili.com/index/rank/all-03-1.json",
                        @"http://www.bilibili.com/index/rank/all-03-3.json",
                        @"http://www.bilibili.com/index/rank/all-03-129.json",
                        @"http://www.bilibili.com/index/rank/all-03-4.json",
                        @"http://www.bilibili.com/index/rank/all-03-36.json",
                        @"http://www.bilibili.com/index/rank/all-03-160.json",
                        @"http://www.bilibili.com/index/rank/all-03-119.json",
                        @"http://www.bilibili.com/index/rank/all-03-155.json",
                        @"http://www.bilibili.com/index/rank/all-03-5.json",
                        @"http://www.bilibili.com/index/rank/all-03-23.json",
                        @"http://www.bilibili.com/index/rank/all-03-11.json"];
    
    for (int i=0; i<array.count; i++) {
        Root * root = self.root[i];
        NSString * tid = [NSString stringWithFormat:@"tid=%@",root.tid];
        NSString * url = array[i];
        if ([url rangeOfString:tid].location != NSNotFound) {
            root.url = url;
        }else{
            root.url = url;
        }
    }
}

@end

@implementation Root
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"typeName" : @"typename"};
}
@end
