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
    NSArray * array = @[@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=13&type=json&sign=a8c5a05c91bd5e8013af4acbf9cf084f",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=1&type=json&sign=080df36924656e43a6befc395b1061e0",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=3&type=json&sign=2ec375c581983397132ce5e3107b3bb0",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=129&type=json&sign=f1cd349de3a84354c443271ae309afb2",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=4&type=json&sign=0d0cb04633c028552a00d4a3936fee82",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=36&type=json&sign=fd92d37dc004bcc7ac25f48b5223d85e",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=160&type=json&sign=ff47dc05dae10d812fc8af8ecfbd7efb",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=119&type=json&sign=48a4c379c83822bf6344708f8970c361",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=155&type=json&sign=36a58c8ae2535590930e147199e5f23f",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=5&type=json&sign=573d78f7345073ec1ab11af9c4bc582c",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=23&type=json&sign=7a766e0e6caf85c44b61a518c3d4f40b",@"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3390&build=3390&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=11&type=json&sign=e0cbc4f1ef0cb8b5cac2d3d4cfe0e66b"];
    
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
