//
//  HYGHttpClient.m
//  SDLayoutTest
//
//  Created by 胡亚刚 on 16/4/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "HYGHttpClient.h"
#import "YYCache.h"
#import "YYMemoryCache.h"
//#import "XMLDictionary.h"
static NSString * const HTTPClientRequestCache = @"HTTPClientRequestCache";

@implementation HYGHttpClient
+(YYCache *)shareCache
{
    static YYCache * cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[YYCache alloc] initWithName:HTTPClientRequestCache];
        cache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
        cache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
    });
    return cache;
}
+(AFHTTPSessionManager *)shareManager
{
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setHTTPAdditionalHeaders:[NSDictionary dictionaryWithObjectsAndKeys:@"application/json",@"Content-Type",@"application/json",@"Accept", nil]];
        manager = [[AFHTTPSessionManager manager] initWithSessionConfiguration:config];
    });
    return manager;
}

+(void)GET:(NSString *)url params:(NSDictionary *)params isCache:(BOOL)isCache success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self requestWihtMethod:RequestMethodTypeGet isCache:isCache requestCachePolicy:HTTPClientReturnCacheDataThenLoad url:url params:params success:success failure:failure];
}

+(void)POST:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [self requestWihtMethod:RequestMethodTypePost isCache:nil requestCachePolicy:HTTPClientReloadIgnoringLocalCacheData url:url params:params success:success failure:failure];
}

+(void)requestWihtMethod:(RequestMethodType)methodType isCache:(BOOL)isCache requestCachePolicy:(HTTPClientRequestCachePolicy)cachePolicy url:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    if (isCache) {
        NSString * cacheKey = url;
        YYCache * cache = [HYGHttpClient shareCache];
        id object = [cache objectForKey:cacheKey];
        
        switch (cachePolicy) {
            case HTTPClientReturnCacheDataThenLoad: {//先返回缓存，同时请求
                if (object) {
                    success(object);
                }
                [self requestWihtMethod:methodType url:url params:params cache:cache cacheKey:cacheKey success:success failure:failure];
                break;
            }
            case HTTPClientReloadIgnoringLocalCacheData: {//忽略本地缓存直接请求
                //不做处理，直接请求
                [self requestWihtMethod:methodType url:url params:params cache:cache cacheKey:cacheKey success:success failure:failure];
                break;
            }
            case HTTPClientReturnCacheDataElseLoad: {//有缓存就返回缓存，没有就请求
                if (object) {//有缓存
                    success(object);
                }else{
                    [self requestWihtMethod:methodType url:url params:params cache:cache cacheKey:cacheKey success:success failure:failure];
                }
                break;
            }
            case HTTPClientReturnCacheDataDontLoad: {//有缓存就返回缓存,从不请求（用于没有网络）
                if (object) {//有缓存
                    success(object);
                }
            }
            default:
                break;
        }
    }else{
        [self requestWihtMethod:methodType url:url params:params cache:nil cacheKey:nil success:success failure:failure];
    }
    
}

+(void)requestWihtMethod:(RequestMethodType)methodType  url:(NSString *)url params:(NSDictionary *)params cache:(YYCache *)cache cacheKey:(NSString *)cacheKey success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    //获得请求管理者
    AFHTTPSessionManager * mgr =[HYGHttpClient shareManager];
    
    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
//    if ([url containsString:@"xml"]) {
//        mgr.responseSerializer = [AFXMLParserResponseSerializer serializer];
//    }
    [mgr.operationQueue cancelAllOperations];
    switch (methodType) {
        case RequestMethodTypeGet:
        {
            //GET请求
            [mgr GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    //                    if ([url containsString:@"xml"]) {
                    //                        if ([responseObject isKindOfClass:[NSXMLParser class]]) {
                    //                            NSDictionary * dic = [NSDictionary dictionaryWithXMLParser:responseObject];
                    //                            responseObject = dic;
                    //                        }
                    //                    }
                    if (cache) {
                        [cache setObject:responseObject forKey:cacheKey];
                    }
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
        case RequestMethodTypePost:
        {
            //POST请求
            [mgr POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    if (cache) {
                        [cache setObject:responseObject forKey:cacheKey];
                    }
                    success(responseObject);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
        default:
            break;
    }
}


@end
