//
//  ReplyDetailController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/6.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "ReplyDetailController.h"
#import "ReplyDetailCell.h"
#import "ReplyLayout.h"
#import "HttpClient.h"
#import "ReplyList.h"
#import "YYModel.h"
#import <MJRefresh.h>
static NSInteger page = 1;
@interface ReplyDetailController ()<UITableViewDelegate,UITableViewDataSource>
{
    ReplyList * _replyList;
}
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,copy) NSMutableArray * replyData;
@end

@implementation ReplyDetailController

-(NSMutableArray *)replyData
{
    if (!_replyData) {
        _replyData = [NSMutableArray array];
    }
    return _replyData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"评论详情";
    
    [self.tableView.mj_header beginRefreshing];
}

-(void)requestReply
{
    NSString * url = [NSString stringWithFormat:kReplyUrl,self.reply.oid,page,self.reply.rpid,self.reply.type];
    NSLog(@"评论地址 == %@",url);
    [HttpClient GET:url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * rootDic = (NSDictionary *)response;
        NSString * code = rootDic[@"code"];
        
        [self stopTableHeadAndFooterRefreshing];
        
        if (page == 1) {
            [self.replyData removeAllObjects];
        }
        
        if ([code integerValue] == 0) {
            _replyList = [ReplyList yy_modelWithDictionary:rootDic[@"data"]];
            [self.replyData addObjectsFromArray:_replyList.replies];
            if (_replyList.replies.count == 0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
            [self.tableView reloadData];
        }
    } failure:^(NSError *err) {
        NSLog(@"错误：%@",err);
        [self stopTableHeadAndFooterRefreshing];
    }];
}

-(void)stopTableHeadAndFooterRefreshing
{
    if (self.tableView.mj_header.isRefreshing) {
        [self.tableView.mj_header endRefreshing];
    }else if (self.tableView.mj_footer.isRefreshing){
        [self.tableView.mj_footer endRefreshing];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else{
        return self.replyData.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReplyLayout * layout;
    ReplyListModel * data;
    if (indexPath.section == 0) {
        data = self.reply;
        layout = [[ReplyLayout alloc] initWithDetail:data];
    }else{
        data = self.replyData[indexPath.row];
        layout = [[ReplyLayout alloc] initWithDetail:data];
    }
    
    return layout.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0000001;
    }else{
        return self.replyData.count>0?35:0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0000001;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView * view = [UIView new];
        
        return view;
    }else if (self.replyData.count>0){
        UIView * view = [UIView new];
        view.backgroundColor = tableView.backgroundColor;
        
        UILabel * titleLabel = [UILabel new];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.textColor = [UIColor colorWithHexString:TextColor];
        titleLabel.text = @"相关回复";
        [view addSubview:titleLabel];
        
        UILabel * numLabel = [UILabel new];
        numLabel.font = titleLabel.font;
        numLabel.textColor = [UIColor lightGrayColor];
        [view addSubview:numLabel];
        
        titleLabel.sd_layout.leftSpaceToView(view,10).topSpaceToView(view,10).heightIs(15);
        [titleLabel setSingleLineAutoResizeWithMaxWidth:60];
        
        numLabel.sd_layout.leftSpaceToView(titleLabel,10).topSpaceToView(view,10).heightIs(15);
        [numLabel setSingleLineAutoResizeWithMaxWidth:80];
        
        numLabel.text = [NSString stringWithFormat:@"共%@条",_replyList.page.count];
        
        return view;
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ReplyDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:@"reply"  forIndexPath:indexPath];
    
    ReplyLayout * layout;
    ReplyListModel * data;
    if (indexPath.section == 0) {
        data = self.reply;
        layout = [[ReplyLayout alloc] initWithDetail:data];
    }else{
        data = self.replyData[indexPath.row];
        layout = [[ReplyLayout alloc] initWithDetail:data];
    }
    
    cell.replyLayout = layout;
    
    return cell;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = kBgColor;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        
        [_tableView registerClass:[ReplyDetailCell class] forCellReuseIdentifier:@"reply"];
        
        @weakify(self);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            page = 1;
            [weak_self.tableView.mj_footer resetNoMoreData];
            [weak_self requestReply];
        }];
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            page ++;
            [weak_self requestReply];
        }];
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
