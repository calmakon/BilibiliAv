//
//  HYGHttpClient.h
//  SDLayoutTest
//
//  Created by 胡亚刚 on 16/4/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "YYCache.h"
#import "YYMemoryCache.h"
typedef NS_ENUM(NSUInteger, HTTPClientRequestCachePolicy){
    HTTPClientReturnCacheDataThenLoad = 0,///< 有缓存就先返回缓存，同步请求数据
    HTTPClientReloadIgnoringLocalCacheData, ///< 忽略缓存，重新请求
    HTTPClientReturnCacheDataElseLoad,///< 有缓存就用缓存，没有缓存就重新请求(用于数据不变时)
    HTTPClientReturnCacheDataDontLoad,///< 有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
};

typedef NS_ENUM(NSInteger, RequestMethodType){
    RequestMethodTypePost = 0,
    RequestMethodTypeGet,
};

@interface HYGHttpClient : NSObject
+(AFHTTPSessionManager *)shareManager;
+(YYCache *)shareCache;
/**
 *  发送一个请求
 *
 *  @param url          请求路径
 *  @param params       请求参数
 *  @param success      请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure      请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */

+(void)GET:(NSString *)url params:(NSDictionary *)params isCache:(BOOL)isCache success:(void (^)(id response))success
   failure:(void (^)(NSError *err))failure;

+(void)POST:(NSString *)url params:(NSDictionary *)params success:(void (^)(id response))success
    failure:(void (^)(NSError *err))failure;

@end
