//
//  MineController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/10.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "MineController.h"
#import "MineHeadView.h"
#import "UserModel.h"
#import "MineItemModel.h"
#import "YYModel.h"
#import "MineCell.h"
#import <UITableView+SDAutoTableViewCellHeight.h>
#define kItemDataFileName @"MineItem.plist"
@interface MineController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) MineHeadView * headView;
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) MineItemModel * itemMoel;
@property (nonatomic,copy) NSArray * headerArray;
@end

@implementation MineController

-(NSArray *)headerArray
{
    return @[@"个人中心",@"我的消息"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headView.sd_layout.leftEqualToView(self.view).topEqualToView(self.view).rightEqualToView(self.view);
    self.tableView.sd_layout.leftEqualToView(self.view).topSpaceToView(self.headView,0).rightEqualToView(self.view).bottomSpaceToView(self.view,49);
    
    UserModel * user = [UserModel new];
    user.userName = @"风@飞扬";
    user.coins = @"599.0";
    user.type = @"1";
    user.sex = @"0";
    user.lv = @"4";

    self.headView.user = user;
    [self.tableView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOffset = scrollView.contentOffset.y;
    if (yOffset <0) {
        self.tableView.backgroundColor = kStyleColor;
    }else{
        self.tableView.backgroundColor = kBgColor;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return self.itemMoel.mineCellHeight;
    }else{
        return self.itemMoel.messageCellHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 20;
    }else{
        return 10;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headView = [UIView new];
    headView.backgroundColor = [UIColor whiteColor];
    headView.size = CGSizeMake(kScreenWidth, 40);
    UILabel * titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [headView addSubview:titleLabel];
    
    titleLabel.left = 10;
    titleLabel.top = 10;
    titleLabel.size = CGSizeMake(200, 20);
    
    titleLabel.text = self.headerArray[section];
    
    return headView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footView = [UIView new];
    footView.backgroundColor = kBgColor;
    return footView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MineCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MineCell"];
    NSArray * itemArray = nil;
    if (indexPath.section == 0) {
        itemArray = self.itemMoel.mine;
    }else{
        itemArray = self.itemMoel.message;
    }
    cell.itemArray = itemArray;
    
    [cell selectItemWithBlock:^(NSInteger index) {
        if (indexPath.section == 0) {
            MineItem * item = self.itemMoel.mine[index];
            [LCProgressHUD showText:item.title];
        }else{
            MineItem * item = self.itemMoel.message[index];
            [LCProgressHUD showText:item.title];
        }
    }];
    
    return cell;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = kBgColor;
        _tableView.tableFooterView = [UIView new];
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[MineCell class] forCellReuseIdentifier:@"MineCell"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(MineItemModel *)itemMoel
{
    if (!_itemMoel) {
        NSString * path = [[NSBundle mainBundle] pathForResource:kItemDataFileName ofType:nil];
        NSDictionary * rootDic = [NSDictionary dictionaryWithContentsOfFile:path];
        _itemMoel = [MineItemModel yy_modelWithDictionary:rootDic];
    }
    return _itemMoel;
}

-(MineHeadView *)headView
{
    if (!_headView) {
        _headView = [MineHeadView new];
        [self.view addSubview:_headView];
    }
    return _headView;
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
