//
//  BangumiDetailController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/7.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiDetailController.h"
#import "BangumiDeatail.h"
#import "YYModel.h"
#import "BangumiDetailHeadView.h"
#import "UIImageView+YYWebImage.h"
#import "ReplyList.h"
#import "ReplyCell.h"
#import "ReplyListModel.h"
#import "ReplyLayout.h"
#import "BangumiPlayerController.h"
@interface BangumiDetailController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    BangumiDeatail * _detail;
    ReplyList * _replyList;
    CGFloat _alpha;
    UIStatusBarStyle _barStyle;
}
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) BangumiDetailHeadView * headView;
@property (nonatomic,strong) UIImageView * bgImageView;
@property (nonatomic,copy) NSMutableArray * replyArray;
@end

@implementation BangumiDetailController
-(NSMutableArray *)replyArray
{
    if (!_replyArray) {
        _replyArray = [NSMutableArray array];
    }
    return _replyArray;
}
-(void)downLoadDetailData
{
    NSString * url = [NSString stringWithFormat:kBangumiDetailUrl,self.season_id];
    NSLog(@"地址 == %@",url);
    [HttpClient GET:url params:nil isCache:YES cacheSuccess:^(id cacheResponse) {
        if (cacheResponse) {
            NSDictionary * jsonDic = (NSDictionary *)cacheResponse;
            if ([jsonDic[@"code"] integerValue] == 0) {
                NSDictionary * result = jsonDic[@"result"];
                _detail = [BangumiDeatail yy_modelWithDictionary:result];
                self.headView.detail = _detail;
                [self.bgImageView setImageWithURL:[NSURL URLWithString:_detail.cover] placeholder:nil];
                [self tableView];
                //[self.tableView reloadData];
            }
        }
    } success:^(id response) {
        NSLog(@"加载完成");
        NSDictionary * jsonDic = (NSDictionary *)response;
        if ([jsonDic[@"code"] integerValue] == 0) {
            NSDictionary * result = jsonDic[@"result"];
            _detail = [BangumiDeatail yy_modelWithDictionary:result];
            self.headView.detail = _detail;
            [self.bgImageView setImageWithURL:[NSURL URLWithString:_detail.cover] placeholder:nil];
            self.tableView.tableHeaderView = self.headView;
            [self.view sendSubviewToBack:self.bgImageView];
            [self requestReply];
        }
    } failure:^(NSError *err) {
        NSLog(@"error:%@",err);
        [LCProgressHUD showFailureText:err.description];
    }];
}

-(void)requestReply
{
    NSString * url = [NSString stringWithFormat:kBangumiReplyUrl,[_detail.episodes[0] av_id]];
    NSLog(@"评论地址 == %@",url);
    [HttpClient GET:url params:nil isCache:NO cacheSuccess:nil success:^(id response) {
        NSDictionary * rootDic = (NSDictionary *)response;
        NSString * code = rootDic[@"code"];
        
        if ([code integerValue] == 0) {
            _replyList = [ReplyList yy_modelWithDictionary:rootDic[@"data"]];
            [self.replyArray removeAllObjects];
            for (int i=0; i<3; i++) {
                ReplyListModel * data = _replyList.replies[i];
                [self.replyArray addObject:data];
            }
            [self.tableView reloadData];
            [LCProgressHUD hide];
        }
    } failure:^(NSError *err) {
        NSLog(@"错误：%@",err);
        [LCProgressHUD showFailureText:err.description];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"番剧详情";
    [self downLoadDetailData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReplyListModel * reply = self.replyArray[indexPath.row];
    ReplyLayout * layout = [[ReplyLayout alloc] initWithDetail:reply];
    
    return layout.height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.replyArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [UIView new];
    view.size = CGSizeMake(kScreenWidth, 40);
    view.backgroundColor = self.view.backgroundColor;
    UILabel * label = [UILabel new];
    label.left = 10;
    label.top = 10;
    label.font = [UIFont systemFontOfSize:13];
    label.text = [NSString stringWithFormat:@"评论（%@）",_replyList.page.acount];
    label.size = CGSizeMake([label.text widthForFont:label.font], 20);
    [view addSubview:label];
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReplyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"reply"  forIndexPath:indexPath];
    ReplyListModel * data = self.replyArray[indexPath.row];
    ReplyLayout * layout = [[ReplyLayout alloc] initWithDetail:data];
    cell.replyLayout = layout;
    return cell;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
        
        //_tableView.tableHeaderView = self.headView;
        _tableView.tableFooterView = [UIView new];
        
        [_tableView registerClass:[ReplyCell class] forCellReuseIdentifier:@"reply"];
    }
    return _tableView;
}

-(BangumiDetailHeadView *)headView
{
    if (!_headView) {
        _headView = [BangumiDetailHeadView new];
        
        [_headView backWithBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        //番剧选季点击
        [_headView seasonItemClickedWithBlock:^(Season *season) {
            self.season_id = season.season_id;
            if ([_detail.season_id integerValue] == [season.season_id integerValue]) return ;
            [LCProgressHUD showLoadingText:nil];
            [self downLoadDetailData];
        }];
        
        //番剧选集点击进行播放
        [_headView itemClickedWithBlock:^(BangumiAvBody *body) {
            NSLog(@"当前第%@集",body.index);
            BangumiPlayerController * player = [BangumiPlayerController new];
            player.aid = body.av_id;
            [self presentViewController:player animated:YES completion:nil];
        }];
        
        //简介详情
        [_headView detailClickedWithBlock:^(BangumiDeatail *detail) {
            //跳转简介详情页
            
        }];
    }
    return _headView;
}

-(UIImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [UIImageView new];
        [self.view addSubview:self.bgImageView];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
        _bgImageView.size = CGSizeMake(self.view.width, self.view.height/2);
        
        UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *view = [[UIVisualEffectView alloc]initWithEffect:beffect];
        view.frame = _bgImageView.bounds;
        [_bgImageView addSubview:view];
    }
    return _bgImageView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setAlpha];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.viewControllers.count==1) {
        self.navigationController.navigationBar.hidden = YES;
    }else{
        self.navigationController.navigationBar.hidden = NO;
        [self setAlpha];
    }
}

-(void)setAlpha
{
    CGFloat yOffset = self.tableView.contentOffset.y;
    CGFloat alpha = yOffset/64;
    self.navigationController.navigationBar.alpha = alpha;
    if (yOffset <= 10) {
        self.tableView.bounces = NO;
    }else{
        self.tableView.bounces = YES;
    }
    if (yOffset <= 64) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.alpha = 1;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
