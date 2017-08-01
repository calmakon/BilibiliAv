//
//  LiveController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/10.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveController.h"
#import "LiveItem.h"
#import "LiveData.h"
#import "YYModel.h"
#import "headView.h"
#import <MJRefresh.h>
#import "ItemCell.h"
#import "LiveListItem.h"
#import "LiveListData.h"
#import "LiveCell.h"
#import "LiveHeadView.h"
#import "LiveBannerCell.h"
#import "LiveDetailController.h"
static NSInteger const itemSection = 0;
static NSInteger const hotSection = 1;

@interface LiveController ()<UITableViewDelegate,UITableViewDataSource>
{
    LiveListItem * _liveData;
    LiveListData * _liveListData;
}

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) headView * headView;

@end

@implementation LiveController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registTableViewIdentyfier];
    [self.tableView.mj_header beginRefreshing];
}

-(void)registTableViewIdentyfier
{
    [self.tableView registerClass:[ItemCell class] forCellReuseIdentifier:@"itemCell"];
    [self.tableView registerClass:[LiveCell class] forCellReuseIdentifier:@"liveCell"];
    [self.tableView registerClass:[LiveBannerCell class] forCellReuseIdentifier:@"liveBannerCell"];
}

-(void)requestLiveData
{
   [HttpClient GET:kLiveTopUrl params:nil isCache:NO cacheSuccess:^(id cacheResponse) {
       
   } success:^(id response) {
       NSDictionary * jsonDic = (NSDictionary *)response;
       if ([jsonDic[@"code"] integerValue] ==0) {
           NSDictionary * data = jsonDic[@"data"];
           NSDictionary * dataR = data[@"recommend_data"];
           LiveListItem * liveData = [LiveListItem yy_modelWithDictionary:dataR];
           _liveData = liveData;
           [self requestLiveListData];
       }
   } failure:^(NSError *err) {
       NSLog(@"error ：%@",err);
       if (self.tableView.mj_header.isRefreshing) {
           [self.tableView.mj_header endRefreshing];
       }
   }];
}

-(void)requestLiveListData
{
    [HttpClient GET:kLiveListUrl params:nil isCache:NO cacheSuccess:^(id cacheResponse) {
        if (cacheResponse) {
            NSDictionary * jsonDic = (NSDictionary *)cacheResponse;
            if ([jsonDic[@"code"] integerValue] == 0) {
                NSDictionary * data = jsonDic[@"data"];
                LiveListData * liveListData = [LiveListData yy_modelWithDictionary:data];
                self.headView.picArray = liveListData.banner;
                _liveListData = liveListData;
                [self.tableView reloadData];
            }
        }
    } success:^(id response) {
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] ==0) {
            NSDictionary * data = jsonDic[@"data"];
            LiveListData * liveListData = [LiveListData yy_modelWithDictionary:data];
            self.headView.picArray = liveListData.banner;
            _liveListData = liveListData;
            [self.tableView reloadData];
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
        }
    } failure:^(NSError *err) {
        NSLog(@"error ：%@",err);
        if (self.tableView.mj_header.isRefreshing) {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-49) style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        headView * head = [[headView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
        _tableView.tableHeaderView = head;
        self.headView = head;
        
        [head picClickWithBlock:^(TopPicModel *topPic) {
            //跳转轮播图详情页
            
        }];
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            _liveData = nil;
            _liveListData = nil;
            [self requestLiveData];
        }];
    }
    return _tableView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == itemSection) {
        ItemConfig * config = [ItemConfig new];
        config.type = Live;
        return [config cellHeight];
    }else{
        return [LiveItem cellHeight];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1+1+_liveListData.partitions.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == itemSection) {
        return 1;
    }else if (section == hotSection){
        return _liveData.lives.count/2+_liveData.banner_data.count;
    }else{
        return 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section!=itemSection) {
        return 40;
    }
    return 0.0001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section!=itemSection) {
        LiveHeadView * headView = [LiveHeadView new];
        LiveListItem * item;
        if (section == hotSection) {
            item = _liveData;
        }else{
            item = _liveListData.partitions[section-2];
        }
        headView.item = item;
        return headView;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == itemSection) {
        ItemCell * cell = [[ItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"itemCell"];
        ItemConfig * itemConfig = [ItemConfig new];
        itemConfig.type = Live;
        cell.item = itemConfig;
        return cell;
    }else if(indexPath.section == hotSection){
        if (indexPath.row == 3) {
            LiveBannerCell * cell = [[LiveBannerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"liveBannerCell"];
            cell.liveData = _liveData.banner_data[0];
            
            [cell bannerClickWithBlock:^(LiveItem *item) {
                //跳转直播详情页 观看直播
                LiveDetailController * detail = [[LiveDetailController alloc] init];
                detail.liveData = item;
                [self.navigationController pushViewController:detail animated:YES];
            }];
            
            return cell;
        }else{
            LiveCell * cell = [[LiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"liveCell"];
            
            NSInteger leftIndex;
            NSInteger rightIndex;
            if (indexPath.row<=2) {
                leftIndex = indexPath.row*2;
                rightIndex = indexPath.row*2+1;
            }else if(indexPath.row>=4){
                leftIndex = indexPath.row*2-_liveData.banner_data.count*2;
                rightIndex = indexPath.row*2-_liveData.banner_data.count*2+1;
            }
            LiveItem * leftItem = _liveData.lives[leftIndex];
            LiveItem * rightItem = _liveData.lives[rightIndex];
            cell.isHot = YES;
            cell.index = rightIndex;
            cell.listData = _liveData;
            cell.leftItem = leftItem;
            cell.rightItem = rightItem;
            [cell liveItemClickWithBlock:^(LiveItem *item) {
                //跳转直播详情页 观看直播
                LiveDetailController * detail = [[LiveDetailController alloc] init];
                detail.liveData = item;
                [self.navigationController pushViewController:detail animated:YES];
            }];
            [cell refreshLiveDataWithBlock:^{
                [self refreshLiveHotData];
            }];
            return cell;
        }
    }else{
        LiveCell * cell = [[LiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"liveCell"];
        
        NSInteger leftIndex = indexPath.row*2;
        NSInteger rightIndex = indexPath.row*2+1;
        LiveItem * leftItem = [_liveListData.partitions[indexPath.section-2] lives][leftIndex];
        LiveItem * rightItem = [_liveListData.partitions[indexPath.section-2] lives][rightIndex];
        cell.isHot = NO;
        cell.index = rightIndex;
        cell.listData = _liveListData.partitions[indexPath.section-2];
        cell.leftItem = leftItem;
        cell.rightItem = rightItem;
        [cell liveItemClickWithBlock:^(LiveItem *item) {
            //跳转直播详情页 观看直播
            LiveDetailController * detail = [[LiveDetailController alloc] init];
            detail.liveData = item;
            [self.navigationController pushViewController:detail animated:YES];
        }];
        
        [cell refreshLiveDataWithBlock:^{
            [self reFreshLiveListDataWithIndex:indexPath.section listData:_liveListData.partitions[indexPath.section-2]];
        }];
        return cell;
    }
}

-(void)refreshLiveHotData
{
    [HttpClient GET:kLiveHotRefresh params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            NSDictionary * data = jsonDic[@"data"];
            LiveListItem * liveData = [LiveListItem yy_modelWithDictionary:data];
            _liveData = liveData;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:hotSection] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
    }];
}

-(void)reFreshLiveListDataWithIndex:(NSInteger)index listData:(LiveListItem *)listData
{
    [HttpClient GET:listData.partition.reFreshUrl params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] ==0) {
            NSArray * datas = jsonDic[@"data"];
            NSMutableArray * refreshDatas = [NSMutableArray array];
            for (NSDictionary * data in datas) {
                LiveItem * item = [LiveItem yy_modelWithDictionary:data];
                [refreshDatas addObject:item];
            }
            listData.lives = [refreshDatas copy];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(NSError *err) {
        NSLog(@"error ：%@",err);
    }];
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
