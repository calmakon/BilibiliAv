//
//  BangumiPlayerController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/14.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiPlayerController.h"
#import "AvDetailModel.h"
#import "ZFPlayerView.h"
#import "YYModel.h"

@interface BangumiPlayerController ()
{
    AvDetailModel * _avDetail;
}
@property(nonatomic,strong) ZFPlayerView * avPalyerView;
@property(nonatomic,strong) DanMuKuModel * danmuku;
@end

@implementation BangumiPlayerController

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
    NSString * url = [NSString stringWithFormat:danmukuUrl,[[info.pages firstObject] cid]];
    
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

-(void)getCurrentVideoUrl:(AvDetailModel *)info
{
    NSString * url = [NSString stringWithFormat:getVideoUrl,info.aid,[[info.pages firstObject] cid]];
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
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self avPalyerView];
    [self downLoadDetailData];
}

-(ZFPlayerView *)avPalyerView
{
    if (!_avPalyerView) {
        _avPalyerView = [[ZFPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width*(9.0/16.0))];
        _avPalyerView.isBangumiAv = YES;
        [self.view addSubview:_avPalyerView];
        
        // 返回按钮事件
        __weak typeof(self) weakSelf = self;
        _avPalyerView.goBackBlock = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }
    return _avPalyerView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
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
