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
#import "BottomView.h"
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
    //[self.tableView registerClass:[WebLinkCell class] forCellReuseIdentifier:@"WebLinkCell"];
    //[self.tableView registerClass:[TopicCell class] forCellReuseIdentifier:@"TopicCell"];
    //[self.tableView registerClass:[TvCell class] forCellReuseIdentifier:@"TvCell"];
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
                NSArray * listArray = jsonDic[@"data"];
                NSMutableArray * dataArray = [NSMutableArray array];
                for (NSDictionary * dic in listArray) {
                    TuiJianList * listModel = [TuiJianList yy_modelWithDictionary:dic];
                    [dataArray addObject:listModel];
                }
                self.dataArray = [self configDataWithArray:dataArray];
                headview.picArray = self.imageArray;
                [self.tableView reloadData];
            }
        }
    } success:^(id response) {
        NSLog(@"加载完成");
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            NSArray * listArray = jsonDic[@"data"];
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
            NSMutableArray * dataArray = [NSMutableArray array];
            for (NSDictionary * dic in listArray) {
                TuiJianList * listModel = [TuiJianList yy_modelWithDictionary:dic];
                [dataArray addObject:listModel];
                NSLog(@"广告的个数 == %@",[listModel.banner.bottom[0] image]);
            }
            self.dataArray = [self configDataWithArray:dataArray];
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

-(NSArray *)configDataWithArray:(NSMutableArray *)dataArray
{
    NSMutableArray * array = [NSMutableArray array];
    if (dataArray) {
        for (TuiJianList * list in dataArray) {
            if (![list.type isEqualToString:@"activity"]) {
                [array addObject:list];
            }
        }
    }
    return array.copy;
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.00001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    TuiJianList * list = self.dataArray[section];
    if (list.banner && list.banner.bottom.count>0) {
        return 120;
    }
    return 0.0001;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
   TuiJianList * list = self.dataArray[section];
    if (list.banner && list.banner.bottom.count>0) {
        BottomView * bottomView = [BottomView new];
        bottomView.banner = list.banner.bottom[0];
        
        [bottomView bannerClickWithBlock:^(NSString *url) {
            WebViewController * web = [WebViewController new];
            web.url = url;
            [self.navigationController pushViewController:web animated:YES];
        }];
        
        return bottomView;
    }else{
       return nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TuiJianList * list = self.dataArray[indexPath.section];
    if ([list.type isEqualToString:@"recommend"]) {
        //热门推荐
        HostRecommendCell * cell = [[HostRecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HostRecommendCell"];
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
        
        [cell refreshDataWithBlock:^{
            [self refreshNextDataWithOldList:list index:indexPath.section];
        }];
    
        return cell;
    }else if ([list.type isEqualToString:@"live"]){
        //热门直播
        AvListCell * cell = [[AvListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AvListCell"];
        cell.list = list;
        cell.bodys = list.body;
        [cell cellClickWithBlock:^(AVModelBody *body) {
            
        }];
        
        [cell goInfoClickWithBlock:^{
            HomeController * home = (HomeController *)self.parentViewController;
            home.tabSlideView.selectedIndex = 0;
        }];
        
        [cell refreshDataWithBlock:^{
            [self refreshLiveNextDataWithOldList:list index:indexPath.section];
        }];
        
        return cell;
    }else if ([list.type isEqualToString:@"bangumi"]){
        //番剧推荐
        AvRecomCell * cell = [[AvRecomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AvRecomCell"];
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
    }else if ([list.type isEqualToString:@"region"]){
        //各分区
        AvListCell * cell = [[AvListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AvListCell"];
        cell.list = list;
        cell.bodys = list.body;
        @weakify(self);
        [cell cellClickWithBlock:^(AVModelBody *body) {
            AvDetailController * avdetail = [[AvDetailController alloc] init];
            avdetail.aid = body.param?:body.aid;
            [weak_self.navigationController pushViewController:avdetail animated:YES];
        }];
        
        [cell refreshDataWithBlock:^{
            [self refreshListNextDataWithOldList:list index:indexPath.section];
        }];
        
        return cell;
    }else{
        return nil;
    }
}

-(void)refreshNextDataWithOldList:(TuiJianList *)list index:(NSInteger)index
{
    [HttpClient GET:hostRefreshUrl params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            [_refreshDataArray removeAllObjects];
            NSArray * listArray = jsonDic[@"data"];
            NSMutableArray * dataArray = [NSMutableArray arrayWithArray:self.dataArray];
            for (NSDictionary * dic in listArray) {
                AVModelBody * listModel = [AVModelBody yy_modelWithDictionary:dic];
                AVModelBody * body = list.body[0];
                listModel.goTo = body.goTo;
                [_refreshDataArray addObject:listModel];
            }
            list.body = _refreshDataArray;
            [dataArray replaceObjectAtIndex:index withObject:list];
            self.dataArray = dataArray;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
    }];
}

-(void)refreshLiveNextDataWithOldList:(TuiJianList *)list index:(NSInteger)index
{
    [HttpClient GET:liveRefreshUrl params:nil isCache:NO cacheSuccess:nil success:^(id response){
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            [_refreshDataArray removeAllObjects];
            NSArray * listArray = jsonDic[@"data"];
            NSMutableArray * dataArray = [NSMutableArray arrayWithArray:self.dataArray];
            for (NSDictionary * dic in listArray) {
                AVModelBody * listModel = [AVModelBody yy_modelWithDictionary:dic];
                AVModelBody * body = list.body[0];
                listModel.goTo = body.goTo;
                [_refreshDataArray addObject:listModel];
            }
            list.body = _refreshDataArray;
            [dataArray replaceObjectAtIndex:index withObject:list];
            self.dataArray = dataArray;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
    }];
}

-(void)refreshListNextDataWithOldList:(TuiJianList *)list index:(NSInteger)index
{
    NSString * url = [NSString stringWithFormat:listRefeshUrl,list.param,list.param];
    [HttpClient GET:url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            [_refreshDataArray removeAllObjects];
            NSArray * listArray = jsonDic[@"list"];
            NSMutableArray * dataArray = [NSMutableArray arrayWithArray:self.dataArray];
            for (NSDictionary * dic in listArray) {
                AVModelBody * listModel = [AVModelBody yy_modelWithDictionary:dic];
                AVModelBody * body = list.body[0];
                listModel.goTo = body.goTo;
                [_refreshDataArray addObject:listModel];
            }
            list.body = _refreshDataArray;
            [dataArray replaceObjectAtIndex:index withObject:list];
            self.dataArray = dataArray;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
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
