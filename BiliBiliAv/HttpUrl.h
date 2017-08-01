//
//  HttpUrl.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/15.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#ifndef HttpUrl_h
#define HttpUrl_h

//推荐
#define kRankItemUrl @"http://app.bilibili.com/x/region/list/old?build=3390&platform=ios&device=phone"//排行榜分区
#define TuiJianUrl @"http://app.bilibili.com/x/v2/show?access_key=6b60e915a1374240922b8d3a10ad1a21&actionKey=appkey&appkey=27eb53fc9058f8c3&build=3480&channel=appstore&device=phone&mobi_app=iphone&plat=1&platform=ios&sign=2144dd6db2b13275933dd47bebc2b5af&ts=1470825898&warm=0"//推荐页内容接口
#define hostRefreshUrl @"http://app.bilibili.com/x/v2/show/change?access_key=6b60e915a1374240922b8d3a10ad1a21&actionKey=appkey&appkey=27eb53fc9058f8c3&build=3480&channel=appstore&device=phone&mobi_app=iphone&plat=1&platform=ios&rand=1&sign=f515661ecae55696f1ee68bcae0fc021&ts=1470886984"//热门焦点刷新接口
#define liveRefreshUrl @"http://app.bilibili.com/x/show/live?access_key=6b60e915a1374240922b8d3a10ad1a21&actionKey=appkey&appkey=27eb53fc9058f8c3&build=3170&channel=appstore&device=phone&plat=1&platform=ios&rand=3&sign=1217d38b80e1c210d5d0047938f821ae&ts=1462804495"//直播刷新接口
#define listRefeshUrl @"http://www.bilibili.com/index/ding/%@.json?access_key=6b60e915a1374240922b8d3a10ad1a21&actionKey=appkey&appkey=27eb53fc9058f8c3&build=3170&device=phone&pagesize=4&platform=ios&sign=687d43011556aa534f63c339654a5f18&tid=%@&ts=1462784682"//各分区刷新接口
#define tuiJianTopUrl @"http://app.bilibili.com/x/banner?build=3380&channel=appstore&plat=2"//顶部轮播图接口
//视频详情，播放
    //评论
#define replyUrl @"http://api.bilibili.com/x/reply?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=5b65015c833a54fcb6543f5ab579cff9&appkey=27eb53fc9058f8c3&appver=3060&build=3060&oid=%@&platform=ios&pn=%ld&ps=20&sign=4c56ee759fe3ddbd9a458e22ba6e4b69&sort=0&type=1"
    //详情
#define avDetailUrl @"http://app.bilibili.com/x/view?access_key=5b65015c833a54fcb6543f5ab579cff9&actionKey=appkey&aid=%@&appkey=27eb53fc9058f8c3&build=3060&device=phone&plat=0&platform=ios&sign=80950c02804851e278aa56e94d06dc01&ts=1458631180"
    //视频地址
#define getVideoUrl @"http://interface.bilibili.com/playurl?platform=phone&_device=phone&_hwid=831fc7511fa9aff5&_tid=0&_p=1&_down=0&quality=3&otype=json&appkey=86385cdc024c0f6c&type=mp4&sign=7fed8a9b7b446de4369936b6c1c40c3f&_aid=%@&cid=%@"
    //弹幕地址
#define danmukuUrl @"http://comment.bilibili.com/%@.xml"
#define kBUrl @"http://bangumi.bilibili.com/player/playurl?module=bangumi&buvid=f802a5d1a89ba885f9681ef303ae9ad1&otype=json&appkey=YvirImLGlLANCLvM&cid=%@&type=any&mid=%@&build=4000&quality=2&access_key=5792e15eb435255d48c351f39f39d93e&device=phone&mobi_app=iphone&platform=iphone&sign=bd5905bbffc5352a9f5940fbc078bfa3"
//评论详情
#define kReplyUrl @"http://api.bilibili.com/x/reply/reply?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3170&build=3170&oid=%@&platform=ios&pn=%ld&ps=20&root=%@&sign=cb2c90e3fa537f6203aa7c3bba08f880&type=%@"


//番剧
    //番剧页列表
#define kBangumiUrl @"http://bangumi.bilibili.com/api/app_index_page_v2?access_key=6b60e915a1374240922b8d3a10ad1a21&actionKey=appkey&appkey=27eb53fc9058f8c3&build=3220&device=phone&platform=ios&sign=a1d7f24669ac7f82dec69bf0d871d260&ts=1462933241"
    //番剧推荐
#define kTuiJianUrl @"http://bangumi.bilibili.com/api/bangumi_recommend?access_key=6b60e915a1374240922b8d3a10ad1a21&actionKey=appkey&appkey=27eb53fc9058f8c3&build=3220&cursor=0&device=phone&pagesize=10&platform=ios&sign=802f05401736fbe97ce8f9733fa9d08a&ts=1463032023"
//番剧详情
    //详情
#define kBangumiDetailUrl @"http://bangumi.bilibili.com/api/season_v3?access_key=6b60e915a1374240922b8d3a10ad1a21&actionKey=appkey&appkey=27eb53fc9058f8c3&build=3480&device=phone&mobi_app=iphone&platform=ios&season_id=%@&sign=5fcac73281014d66c19b9b90493087be&ts=1470888803&type=bangumi"
    //番剧评论
#define kBangumiReplyUrl @"http://api.bilibili.com/x/reply?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3360&build=3360&nohot=1&oid=%@&platform=ios&pn=1&ps=10&sign=7cdd2702bd5fb3395ac71fecad977a21&sort=2&type=1"

//排行榜
#define kRankUrl @"http://api.bilibili.com/list?_device=iphone&_hwid=f802a5d1a89ba885&_ulv=10000&access_key=6b60e915a1374240922b8d3a10ad1a21&appkey=27eb53fc9058f8c3&appver=3380&build=3380&ios=0&order=hot&page=0&pagesize=20&platform=ios&tid=%@&type=json&sign=%@"


//直播
    //推荐主播
#define kLiveTopUrl @"http://live.bilibili.com/AppNewIndex/recommend?access_key=5792e15eb435255d48c351f39f39d93e&actionKey=appkey&appkey=27eb53fc9058f8c3&build=4000&buvid=f802a5d1a89ba885f9681ef303ae9ad1&device=phone&mobi_app=iphone&platform=ios&scale=2&sign=252853e3cdf5a553020d08439d61e739&ts=1479625500"
    //直播分区列表
#define kLiveListUrl @"http://live.bilibili.com/AppNewIndex/common?scale=2&device=phone&platform=ios"
#define kLiveRefresh @"http://live.bilibili.com/AppIndex/dynamic?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&area=%@&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=2fb1712ad7b9896defe1b62a012c1716&ts=1480829184"
#define kLiveHotRefresh @"http://live.bilibili.com/AppIndex/recommendRefresh?access_key=a1c57ef9f7e54c152ac660a0952484c9&actionKey=appkey&appkey=27eb53fc9058f8c3&build=4000&device=phone&mobi_app=iphone&platform=ios&sign=b8ddac211e977ead18bab5ff6f34df97&ts=1480829423"
#endif /* HttpUrl_h */
