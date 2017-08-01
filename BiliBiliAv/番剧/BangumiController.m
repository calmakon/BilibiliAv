//
//  BangumiController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/10.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiController.h"
#import "HttpClient.h"
#import "YYModel.h"
#import "BangumiList.h"
#import "BangumiBody.h"
#import "LatestUpdateCell.h"
#import "headView.h"
#import "ItemCell.h"
#import "ItemConfig.h"
#import <MJRefresh.h>
#import "BangumiRecom.h"
#import "BangumiRecomCell.h"
#import "RecomTopCell.h"
#import <UITableView+SDAutoTableViewCellHeight.h>
#import "RecomHeadView.h"
#import "HYGUtility.h"
#import "BangumiEndCell.h"
#import "BangumiDetailController.h"
#import "WebViewController.h"
static NSInteger const itemSection = 0;
static NSInteger const endSection = 2;
static NSInteger const recomSection = 3;
@interface BangumiController ()<UITableViewDataSource,UITableViewDelegate>
{
    BangumiList * _bangumiList;
    NSMutableArray * _refreshDataArray;
    NSMutableArray * _recomArray;
    headView * headview;
}
@property(nonatomic,strong) UITableView * tableView;

@end

@implementation BangumiController

- (void)viewDidLoad {
    [super viewDidLoad];
    _recomArray = [NSMutableArray array];
    
    [self registerTableViewCellClass];
    
    [self.tableView.mj_header beginRefreshing];
}

-(void)registerTableViewCellClass
{
    [self.tableView registerClass:[LatestUpdateCell class] forCellReuseIdentifier:@"LatestUpdateCell"];
    [self.tableView registerClass:[ItemCell class] forCellReuseIdentifier:@"ItemCell"];
    [self.tableView registerClass:[BangumiRecomCell class] forCellReuseIdentifier:@"BangumiRecomCell"];
    [self.tableView registerClass:[RecomTopCell class] forCellReuseIdentifier:@"RecomTopCell"];
    [self.tableView registerClass:[BangumiEndCell class] forCellReuseIdentifier:@"BangumiEndCell"];
}

-(void)downLoadTuiJianData
{
    [HttpClient GET:kBangumiUrl params:nil isCache:YES cacheSuccess:^(id cacheResponse) {
        if (cacheResponse) {
            NSDictionary * jsonDic = (NSDictionary *)cacheResponse;
            if ([jsonDic[@"code"] integerValue] == 0) {
                NSDictionary * result = jsonDic[@"result"];
                _bangumiList = [BangumiList yy_modelWithDictionary:result];
                headview.picArray = _bangumiList.banners;
                [self.tableView reloadData];
            }
        }
    } success:^(id response) {
        NSLog(@"加载完成");
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            NSDictionary * result = jsonDic[@"result"];
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
            _bangumiList = [BangumiList yy_modelWithDictionary:result];
            headview.picArray = _bangumiList.banners;
            [self.tableView reloadData];
            
            [self downLoadRecomData];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)downLoadRecomData
{
    [HttpClient GET:kTuiJianUrl params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSLog(@"加载完成");
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            [_recomArray removeAllObjects];
            NSArray * results = jsonDic[@"result"];
            for (NSDictionary * dic in results) {
                BangumiRecom * recom = [BangumiRecom yy_modelWithDictionary:dic];
                [_recomArray addObject:recom];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:recomSection] withRowAnimation:UITableViewRowAnimationFade];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}

-(NSArray *)picArray
{
    if (_bangumiList.banners.count>0) {
        NSMutableArray * array = [NSMutableArray array];
        for (int i=0; i<_bangumiList.banners.count; i++) {
            BangumiBanner * banner = _bangumiList.banners[i];
            [array addObject:banner.img];
        }
        return [NSArray arrayWithArray:array];
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == recomSection) {
        return _recomArray.count;
    }else{
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == itemSection) {
        ItemConfig * config = [ItemConfig new];
        config.type = Bangumi;
        return [config cellHeight];
    }else if (indexPath.section == endSection){
        return _bangumiList.endCellHeight;
    }else if (indexPath.section == recomSection){
        BangumiRecom * recom = _recomArray[indexPath.row];
        if (indexPath.row == 0) {
            return [tableView cellHeightForIndexPath:indexPath model:recom keyPath:@"recom" cellClass:[RecomTopCell class] contentViewWidth:kScreenWidth];
        }
        
        return [tableView cellHeightForIndexPath:indexPath model:recom keyPath:@"recom" cellClass:[BangumiRecomCell class] contentViewWidth:kScreenWidth];
    }else{
        return _bangumiList.cellHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == recomSection) {
        return 48;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == recomSection) {
        RecomHeadView * headView = [RecomHeadView new];
        return headView;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == recomSection) {
        BangumiRecom * recom = _recomArray[indexPath.row];
        BangumiDetailController * detail = [BangumiDetailController new];
        detail.season_id = recom.seasonId;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == itemSection) {
        ItemCell * cell = [[ItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        ItemConfig * itemConfig = [ItemConfig new];
        itemConfig.type = Bangumi;
        cell.item = itemConfig;
        return cell;
    }else if (indexPath.section == endSection){
        BangumiEndCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BangumiEndCell"];
        
        cell.endBodys = _bangumiList.ends;
        
        [cell itemClickWithBlock:^(BangumiBody *body) {
            BangumiDetailController * detail = [BangumiDetailController new];
            detail.season_id = body.season_id;
            [self.navigationController pushViewController:detail animated:YES];
        }];
        
        return cell;
    }else if (indexPath.section == recomSection){
        if (indexPath.row == 0) {
            RecomTopCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RecomTopCell"];
            
            cell.recom = _recomArray[indexPath.row];
            
            return cell;
        }
        BangumiRecomCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BangumiRecomCell"];
        
        cell.recom = _recomArray[indexPath.row];
        
        return cell;
    }else{
        LatestUpdateCell * cell = [[LatestUpdateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.list = _bangumiList;
        cell.bodys = _bangumiList.latestUpdate.list;
        [cell cellClickWithBlock:^(BangumiBody *body) {
            BangumiDetailController * detail = [BangumiDetailController new];
            detail.season_id = body.season_id;
            [self.navigationController pushViewController:detail animated:YES];
        }];
        
        return cell;
    }
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-49) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        headview = [[headView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
        _tableView.tableHeaderView = headview;
        
        [headview picClickWithBlock:^(TopPicModel *topPic) {
            BangumiDetailController * detail = [BangumiDetailController new];
            NSArray * array = [topPic.link componentsSeparatedByString:@"/"];
            detail.season_id = array.lastObject;
            [self.navigationController pushViewController:detail animated:YES];
        }];
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self downLoadTuiJianData];
        }];
    }
    return _tableView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.viewControllers.count==1) {
        self.navigationController.navigationBar.hidden = YES;
    }else{
        self.navigationController.navigationBar.hidden = NO;
    }
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
