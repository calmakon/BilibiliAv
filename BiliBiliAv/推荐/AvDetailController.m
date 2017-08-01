//
//  AvDetailController.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/22.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "AvDetailController.h"
#import "HttpClient.h"
#import "AvDetailModel.h"
#import "NSObject+YYModel.h"
#import "ZFPlayer.h"
#import "DanMuKuModel.h"
#import "CFDanmaku.h"
#import "InfoView.h"
#import "KrVideoPlayerController.h"
#import "ReplyList.h"
#import <MJRefresh.h>
#import "ReplyDetailController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)(((rgbValue)&0xFF0000) >> 16)) / 255.0 green:((float)(((rgbValue)&0xFF00) >> 8)) / 255.0 blue:((float)((rgbValue)&0xFF)) / 255.0 alpha:1.0]

static NSInteger replyPage = 1;
static NSString * _cid;
static AvDetailModel * _avDetail;
@interface AvDetailController ()

@property(nonatomic,strong) ZFPlayerView * avPalyerView;
@property(nonatomic,strong) InfoView * infoView;
@property(nonatomic,strong) DanMuKuModel * danmuku;
@end

@implementation AvDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self avPalyerView];
   
    [self downLoadDetailData];
}
/*
-(void)createDispatchQueueDowmLoadData
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    //下载详情数据
    dispatch_group_async(group, queue, ^{
        [self downLoadDetailData];
        
        dispatch_semaphore_signal(sem);
    });
    //下载弹幕
    dispatch_group_async(group, queue, ^{
        [self downLoadDanmuKuData:_avDetail];
        [self.avPalyerView setupDanmuku:self.danmuku];
        dispatch_semaphore_signal(sem);
    });
    //下载视频地址
    dispatch_group_async(group, queue, ^{
        self.avPalyerView.loadingStatus = @"正在获取视频地址...";
        [self getCurrentVideoUrl:_avDetail];
        
        dispatch_semaphore_signal(sem);
    });
    //下载评论数据
    dispatch_group_async(group, queue, ^{
        [self.infoView.conmmentTableView.mj_header beginRefreshing];
        
        dispatch_semaphore_signal(sem);
    });
    
    dispatch_group_notify(group, queue, ^{
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        
    });
}
*/
-(void)downLoadDetailData
{
    NSLog(@"正在加载....");
    if (self.aid&&self.aid.length!=0) {
        NSString * url = [NSString stringWithFormat:avDetailUrl,self.aid];
        NSLog(@"地址 == %@",url);
        [[HttpClient shareCache] removeObjectForKey:url];
        [HttpClient GET:url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
            NSDictionary * rootDic = (NSDictionary *)response;
            NSString * code = rootDic[@"code"];
            if ([code integerValue] == 0) {
                _avDetail = [AvDetailModel yy_modelWithDictionary:rootDic[@"data"]];
                self.infoView.detail = _avDetail;
                [self downLoadDanmuKuData:_avDetail];
            }
        } failure:^(NSError *err) {
            NSLog(@"错误：%@",err);
        }];
    }else{
        return;
    }
}

-(void)downLoadDanmuKuData:(AvDetailModel *)info
{
    NSString * url = [NSString stringWithFormat:danmukuUrl,_cid?:[[info.pages firstObject] cid]];
 
    self.avPalyerView.loadingStatus = @"正在载入弹幕...";
    [HttpClient GET:url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * dic = (NSDictionary *)response;
        self.danmuku = [DanMuKuModel yy_modelWithDictionary:dic];
        
        [self.avPalyerView setupDanmuku:self.danmuku];
     
        //刷新数据
        self.avPalyerView.loadingStatus = @"正在获取视频地址...";
        [self getCurrentVideoUrl:_avDetail];
    } failure:^(NSError *err) {
        
    }];
}

-(void)requestReply
{
    NSString * url = [NSString stringWithFormat:replyUrl,self.aid,replyPage];
    NSLog(@"评论地址 == %@",url);
    [HttpClient GET:url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * rootDic = (NSDictionary *)response;
        NSString * code = rootDic[@"code"];
        
        [self stopTableHeadAndFooterRefreshing];
        
        if ([code integerValue] == 0) {
            ReplyList * list = [ReplyList yy_modelWithDictionary:rootDic[@"data"]];
            if (list.replies.count == 0) {
                [self.infoView.conmmentTableView.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
            self.infoView.replyList = list;
        }
    } failure:^(NSError *err) {
        NSLog(@"错误：%@",err);
        [self stopTableHeadAndFooterRefreshing];
    }];
}

-(void)stopTableHeadAndFooterRefreshing
{
    if (self.infoView.conmmentTableView.mj_header.isRefreshing) {
        [self.infoView.conmmentTableView.mj_header endRefreshing];
    }else if (self.infoView.conmmentTableView.mj_footer.isRefreshing){
        [self.infoView.conmmentTableView.mj_footer endRefreshing];
    }
}

-(void)getCurrentVideoUrl:(AvDetailModel *)info
{
    NSString * url = [NSString stringWithFormat:kBUrl,[[info.pages firstObject] cid],info.owner.mid];
    NSLog(@"获取视频地址接口 = %@",url);
    [HttpClient GET:url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * rootDic = (NSDictionary *)response;
        NSString * code = rootDic[@"code"];
        if ([code integerValue] == 0) {
            NSArray * urls = rootDic[@"durl"];
            NSArray * backup_Url = [[urls firstObject] objectForKey:@"backup_url"];
            NSString * backupUrl;
            if (backup_Url.count!=0) {
                backupUrl = [backup_Url objectAtIndex:0];
            }
            NSString * url;
            if (urls.count!=0) {
                url = [[urls firstObject] objectForKey:@"url"];
            }
            //刷新数据
            NSString * videoUrl;
            if (!url||url.length == 0) {
                if (backupUrl.length!=0) {
                    videoUrl = backupUrl;
                }
            }else{
                videoUrl = url;
            }
            //播放视频
            self.avPalyerView.loadingStatus = @"正在加载视频...";
            [self addVideoPlayerWithURL:[NSURL URLWithString:videoUrl]];
        }
    } failure:^(NSError *err) {
        NSLog(@"错误：%@",err);
    }];
}


- (void)addVideoPlayerWithURL:(NSURL *)url{
    NSLog(@"地址 == %@",url);
    self.avPalyerView.videoURL = url;
    
    [self.infoView.conmmentTableView.mj_header beginRefreshing];
}

-(ZFPlayerView *)avPalyerView
{
    if (!_avPalyerView) {
        _avPalyerView = [[ZFPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width*(9.0/16.0))];
        
        [self.view addSubview:_avPalyerView];
        
        // 返回按钮事件
        __weak typeof(self) weakSelf = self;
        _avPalyerView.goBackBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        [self infoView];
    }
    return _avPalyerView;
}

-(InfoView *)infoView
{
    if (!_infoView) {
        _infoView = [[InfoView alloc] initWithFrame:CGRectMake(0, self.avPalyerView.bottom, self.view.width, self.view.height-self.avPalyerView.bottom)];
        [self.view addSubview:_infoView];
        [self.view bringSubviewToFront:self.avPalyerView];
        
        @weakify(self);
        _infoView.conmmentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            replyPage = 1;
            [weak_self.infoView.conmmentTableView.mj_footer resetNoMoreData];
            [weak_self requestReply];
        }];
        
        _infoView.conmmentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            replyPage ++;
            [weak_self requestReply];
        }];
        
        [_infoView seleWithBlock:^(ReplyListModel *data) {
            ReplyDetailController * detail = [ReplyDetailController new];
            detail.reply = data;
            [weak_self.navigationController pushViewController:detail animated:YES];
        }];
        
        [_infoView reSetAvPlayerWithBlock:^(RelateModel *relate) {
            weak_self.aid = relate.aid;
            [weak_self.avPalyerView resetPlayerCopy];
            [weak_self downLoadDetailData];
        }];
        
        [_infoView pageSelectWithBlock:^(NSString *cid) {
            [weak_self.avPalyerView resetPlayerCopy];
            _cid = cid;
            [weak_self downLoadDanmuKuData:_avDetail];
        }];
    }
    return _infoView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    if (self.avPalyerView) {
        [self.avPalyerView play];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    if (self.avPalyerView) {
        [self.avPalyerView pause];
    }
}

-(void)dealloc
{
    [self.avPalyerView cancelAutoFadeOutControlBar];
    [self.avPalyerView resetPlayer];
    self.avPalyerView = nil;
    _avDetail = nil;
    _cid = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
