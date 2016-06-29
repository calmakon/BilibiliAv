//
//  TuiJianController.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/2/18.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "TuiJianController.h"
#import "AvListCell.h"
#import "AvBaseCell.h"
#import "HostRecommendCell.h"
#import "AvRecomCell.h"
#import "WebLinkCell.h"
#import "TopicCell.h"
#import "TvCell.h"
#import "NSObject+YYModel.h"
#import "AVModel.h"
#import "TuiJianList.h"
#import "HttpClient.h"
#import "headView.h"
#import "AvDetailController.h"
#import <MJRefresh.h>
#import "BangumiDetailController.h"
#import "WebViewController.h"
#import "TopPicModel.h"
#import "RankViewController.h"
#import "HomeController.h"
#import "TidMetaNIir.h"
@interface TuiJianController ()<UITableViewDataSource,UITableViewDelegate,UIViewControllerPreviewingDelegate>
{
    //NSMutableArray * _dataArray;
    NSMutableArray * _refreshDataArray;
    //NSMutableArray * _imageArray;
    headView * headview;
}
@property(nonatomic,strong) UITableView * tableView;
@property (nonatomic,copy) NSArray * dataArray;
@property (nonatomic,copy) NSArray * imageArray;
@property (nonatomic,copy) NSArray * topPicArray;
@end

@implementation TuiJianController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _dataArray = [NSMutableArray array];
    _refreshDataArray = [NSMutableArray array];
    _imageArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    [TidMetaNIir shareTidMeta];
    [self registerTableViewCellClass];
    
    [self.tableView.mj_header beginRefreshing];
}

-(void)registerTableViewCellClass
{
   [self.tableView registerClass:[HostRecommendCell class] forCellReuseIdentifier:@"HostRecommendCell"];
    [self.tableView registerClass:[AvListCell class] forCellReuseIdentifier:@"AvListCell"];
    [self.tableView registerClass:[AvRecomCell class] forCellReuseIdentifier:@"AvRecomCell"];
    [self.tableView registerClass:[WebLinkCell class] forCellReuseIdentifier:@"WebLinkCell"];
    [self.tableView registerClass:[TopicCell class] forCellReuseIdentifier:@"TopicCell"];
    [self.tableView registerClass:[TvCell class] forCellReuseIdentifier:@"TvCell"];
}



-(void)downLoadData
{
    NSLog(@"正在加载数据......");
    
    [HttpClient GET:tuiJianTopUrl params:nil isCache:YES cacheSuccess:^(id cacheResponse) {
        if (cacheResponse) {
            NSDictionary * jsonDic = (NSDictionary *)cacheResponse;
            NSMutableArray * dataArray = [NSMutableArray array];
            if ([jsonDic[@"code"] integerValue] ==0) {
                NSArray * listArray = jsonDic[@"data"];
                for (NSDictionary * dic in listArray) {
                    TopPicModel * topPic = [TopPicModel yy_modelWithDictionary:dic];
                    [dataArray addObject:topPic];
                }
                self.imageArray = dataArray;
            }
        }
    } success:^(id response) {
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] ==0) {
            NSArray * listArray = jsonDic[@"data"];
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
            NSMutableArray * dataArray = [NSMutableArray array];
            for (NSDictionary * dic in listArray) {
                TopPicModel * topPic = [TopPicModel yy_modelWithDictionary:dic];
                [dataArray addObject:topPic];
            }
            self.imageArray = dataArray;
        }
    } failure:^(NSError *err) {
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}

-(void)downLoadTuiJianData
{
    [HttpClient GET:TuiJianUrl params:nil isCache:YES cacheSuccess:^(id cacheResponse) {
        if (cacheResponse) {
            NSDictionary * jsonDic = (NSDictionary *)cacheResponse;
            if ([jsonDic[@"code"] integerValue] == 0) {
                NSArray * listArray = jsonDic[@"result"];
                NSMutableArray * dataArray = [NSMutableArray array];
                for (NSDictionary * dic in listArray) {
                    TuiJianList * listModel = [TuiJianList yy_modelWithDictionary:dic];
                    [dataArray addObject:listModel];
                }
                self.dataArray = dataArray;
                headview.picArray = self.imageArray;
                [self.tableView reloadData];
            }
        }
    } success:^(id response) {
        NSLog(@"加载完成");
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            NSArray * listArray = jsonDic[@"result"];
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
            NSMutableArray * dataArray = [NSMutableArray array];
            for (NSDictionary * dic in listArray) {
                TuiJianList * listModel = [TuiJianList yy_modelWithDictionary:dic];
                [dataArray addObject:listModel];
            }
            self.dataArray = dataArray;
            headview.picArray = self.imageArray;
            [self.tableView reloadData];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TuiJianList * list = self.dataArray[indexPath.section];
    return list.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TuiJianList * list = self.dataArray[indexPath.section];
    if ([list.type isEqualToString:@"recommend"]) {
        //热门推荐
        HostRecommendCell * cell = [[HostRecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.list = list;
        cell.bodys = list.body;
        [cell cellClickWithBlock:^(AVModelBody *body) {
            AvDetailController * avdetail = [[AvDetailController alloc] init];
            avdetail.aid = body.param?:body.aid;
            [self.navigationController pushViewController:avdetail animated:YES];
        }];
        
        [cell goInfoClickWithBlock:^{
            //排行榜
            RankViewController * rank = [RankViewController new];
            [self.navigationController pushViewController:rank animated:YES];
        }];
        
        [cell refreshCurrentCellWithBlock:^(HostRecommendCell *hostCell) {
            [cell animaiton];
            [self refreshNextDataWithOldList:list index:indexPath.section cell:(UITableViewCell *)hostCell];
        }];
        return cell;
    }else if ([list.type isEqualToString:@"live"]){
        //热门直播
        AvListCell * cell = [[AvListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.typeName = list.typeName;
        cell.list = list;
        cell.bodys = list.body;
        [cell cellClickWithBlock:^(AVModelBody *body) {
            
        }];
        
        [cell goInfoClickWithBlock:^{
            HomeController * home = (HomeController *)self.parentViewController;
            home.tabSlideView.selectedIndex = 0;
        }];
        
        [cell refreshCurrentCellWithBlock:^(AvListCell *listCell) {
            [cell animaiton];
            [self refreshLiveNextDataWithOldList:list index:indexPath.section cell:listCell];
        }];
        
        return cell;
    }else if ([list.type isEqualToString:@"bangumi_2"]){
        //番剧推荐
        AvRecomCell * cell = [[AvRecomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.list = list;
        cell.bodys = list.body;
        [cell cellClickWithBlock:^(AVModelBody *body) {
            BangumiDetailController * detail = [BangumiDetailController new];
            detail.season_id = body.param;
            [self.navigationController pushViewController:detail animated:YES];
        }];
        
        [cell goInfoClickWithBlock:^{
            HomeController * home = (HomeController *)self.parentViewController;
            home.tabSlideView.selectedIndex = 2;
        }];
        
        return cell;
    }else if ([list.type isEqualToString:@"weblink"]){
        //话题
        TopicCell * cell = [[TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.list = list;
        cell.bodys = list.body;
        [cell cellClickWithBlock:^(NSString *url) {
            WebViewController * web = [WebViewController new];
            web.url = url;
            [self.navigationController pushViewController:web animated:YES];
        }];
        return cell;
    }else if([list.type isEqualToString:@"bangumi_3"]){
        //电视剧更新
        TvCell * cell = [[TvCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.list = list;
        cell.bodys = list.body;
        return cell;
    }else if (!list.type){
        WebLinkCell * cell = [[WebLinkCell alloc] init];
        cell.bodys = list.body;
        [cell cellClickWithBlock:^(AVModelBody *body) {
            AvDetailController * avdetail = [[AvDetailController alloc] init];
            avdetail.aid = body.param?:body.aid;
            [self.navigationController pushViewController:avdetail animated:YES];
        }];
        return cell;
    }else{
        //各分区
        AvListCell * cell = [[AvListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.typeName = list.typeName;
        cell.list = list;
        cell.bodys = list.body;
        @weakify(self);
        [cell cellClickWithBlock:^(AVModelBody *body) {
            AvDetailController * avdetail = [[AvDetailController alloc] init];
            avdetail.aid = body.param?:body.aid;
            [weak_self.navigationController pushViewController:avdetail animated:YES];
        }];
        
        [cell refreshCurrentCellWithBlock:^(AvListCell *listCell) {
            [cell animaiton];
            [self refreshListNextDataWithOldList:list index:indexPath.section cell:listCell];
        }];
        
        return cell;
    }
}

-(void)refreshNextDataWithOldList:(TuiJianList *)list index:(NSInteger)index cell:(UITableViewCell *)cell
{
    HostRecommendCell * currentCell = (HostRecommendCell *)cell;
    [currentCell animaiton];
    [HttpClient GET:hostRefreshUrl params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            [_refreshDataArray removeAllObjects];
            NSArray * listArray = jsonDic[@"data"];
            NSMutableArray * dataArray = [NSMutableArray arrayWithArray:self.dataArray];
            for (NSDictionary * dic in listArray) {
                AVModelBody * listModel = [AVModelBody yy_modelWithDictionary:dic];
                AVModelBody * body = list.body[0];
                listModel.style = body.style;
                [_refreshDataArray addObject:listModel];
            }
            list.body = _refreshDataArray;
            [dataArray replaceObjectAtIndex:index withObject:list];
            self.dataArray = dataArray;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
            [currentCell stopAnimation];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
        [currentCell stopAnimation];
    }];
}

-(void)refreshLiveNextDataWithOldList:(TuiJianList *)list index:(NSInteger)index cell:(AvListCell *)cell
{
    [cell animaiton];
    [HttpClient GET:liveRefreshUrl params:nil isCache:NO cacheSuccess:nil success:^(id response){
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            [_refreshDataArray removeAllObjects];
            NSArray * listArray = jsonDic[@"data"];
            NSMutableArray * dataArray = [NSMutableArray arrayWithArray:self.dataArray];
            for (NSDictionary * dic in listArray) {
                AVModelBody * listModel = [AVModelBody yy_modelWithDictionary:dic];
                AVModelBody * body = list.body[0];
                listModel.style = body.style;
                [_refreshDataArray addObject:listModel];
            }
            list.body = _refreshDataArray;
            [dataArray replaceObjectAtIndex:index withObject:list];
            self.dataArray = dataArray;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
            [cell stopAnimation];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
        [cell stopAnimation];
    }];
}

-(void)refreshListNextDataWithOldList:(TuiJianList *)list index:(NSInteger)index cell:(AvListCell *)cell
{
    //AvListCell * currentCell = (AvListCell *)cell;
    [cell animaiton];
    NSString * url = [NSString stringWithFormat:listRefeshUrl,list.head.param,list.head.param];
    [HttpClient GET:url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            [_refreshDataArray removeAllObjects];
            NSArray * listArray = jsonDic[@"list"];
            NSMutableArray * dataArray = [NSMutableArray arrayWithArray:self.dataArray];
            for (NSDictionary * dic in listArray) {
                AVModelBody * listModel = [AVModelBody yy_modelWithDictionary:dic];
                AVModelBody * body = list.body[0];
                listModel.style = body.style;
                [_refreshDataArray addObject:listModel];
            }
            list.body = _refreshDataArray;
            [dataArray replaceObjectAtIndex:index withObject:list];
            self.dataArray = dataArray;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
            [cell stopAnimation];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
        [cell stopAnimation];
    }];
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64-49) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        
        headview = [[headView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 120)];
        _tableView.tableHeaderView = headview;
        
        [headview picClickWithBlock:^(TopPicModel *topPic) {
            if ([topPic.type integerValue]==2) {
                WebViewController * web = [WebViewController new];
                web.url = topPic.value;
                [self.navigationController pushViewController:web animated:YES];
            }else if ([topPic.type integerValue] == 3){
                BangumiDetailController * detail = [BangumiDetailController new];
                detail.season_id = topPic.value;
                [self.navigationController pushViewController:detail animated:YES];
            }
        }];
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self downLoadData];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
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
