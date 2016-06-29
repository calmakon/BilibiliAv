//
//  RankListController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/15.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "RankListController.h"
#import "RankAvModel.h"
#import "YYModel.h"
#import "RankAvCell.h"
#import <UITableView+SDAutoTableViewCellHeight.h>
#import "AvDetailController.h"

@interface RankListController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy) NSMutableArray * dataArray;
@property (nonatomic,strong) UITableView * tableView;

@end

@implementation RankListController
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
-(void)reauestData
{
    NSLog(@"接口 == %@",self.url);
    if (!self.url) return;
    
   [HttpClient GET:self.url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
       NSDictionary * rootDic = (NSDictionary *)response;
       NSString * code = rootDic[@"code"];
       if ([code integerValue] == 0) {
           NSDictionary * dic = rootDic[@"list"];
           for (int i=0;i<dic.count-1;i++) {
               NSString * key = [NSString stringWithFormat:@"%d",i];
               NSDictionary * subDic = [dic objectForKey:key];
               RankAvModel * rankAv = [RankAvModel yy_modelWithDictionary:subDic];
               rankAv.rank = key;
               [self.dataArray addObject:rankAv];
           }
           [self.tableView reloadData];
       }
   } failure:^(NSError *err) {
       NSLog(@"error:%@",err);
   }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self reauestData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RankAvModel * rank = self.dataArray[indexPath.row];
    return [tableView cellHeightForIndexPath:indexPath model:rank keyPath:@"model" cellClass:[RankAvCell class] contentViewWidth:self.view.width];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RankAvModel * model = self.dataArray[indexPath.row];
    AvDetailController * avdetail = [AvDetailController new];
    avdetail.aid = model.aid;
    [self.navigationController pushViewController:avdetail animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RankAvCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RankAvCell"];
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [self.view addSubview:_tableView];
        
        [_tableView registerClass:[RankAvCell class] forCellReuseIdentifier:@"RankAvCell"];
    }
    return _tableView;
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
