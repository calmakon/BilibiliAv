//
//  RankViewController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/15.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "RankViewController.h"
#import "RankListController.h"
#import "DLCustomSlideView.h"
#import "DLScrollTabbarView.h"
#import "DLLRUCache.h"
#import "TidMetaNIir.h"

@interface RankViewController ()<DLCustomSlideViewDelegate>
@property (nonatomic,strong) DLCustomSlideView * slideView;
@property (nonatomic,copy) NSMutableArray * itemArray;
@property (nonatomic,copy) NSArray * rootArray;
@end

@implementation RankViewController
-(NSMutableArray *)itemArray
{
    if (!_itemArray) {
        _itemArray = [NSMutableArray array];
    }
    return _itemArray;
}

-(NSArray *)rootArray
{
    if (!_rootArray) {
        _rootArray = [TidMetaNIir shareTidMeta].root;
    }
    return _rootArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self slideView];
}

-(DLCustomSlideView *)slideView
{
    if (!_slideView) {
        
        _slideView = [DLCustomSlideView new];
        [self.view addSubview:_slideView];
        
        _slideView.sd_layout.leftSpaceToView(self.view,0).topSpaceToView(self.view,0).rightSpaceToView(self.view,0).bottomSpaceToView(self.view,0);
        
        DLLRUCache *cache = [[DLLRUCache alloc] initWithCount:7];
        DLScrollTabbarView *tabbar = [[DLScrollTabbarView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        tabbar.backgroundColor = [UIColor whiteColor];
        tabbar.tabItemNormalColor = [UIColor grayColor];
        tabbar.tabItemSelectedColor = kStyleColor;
        tabbar.tabItemNormalFontSize = 15.0f;
        tabbar.trackColor = kStyleColor;
        for (int i=0; i<self.rootArray.count; i++) {
            Root * root = self.rootArray[i];
            NSString * title = root.typeName;
            DLScrollTabbarItem *item = [DLScrollTabbarItem itemWithTitle:title width:[title widthForFont:[UIFont systemFontOfSize:15]]+30];
            [self.itemArray addObject:item];
        }
        tabbar.tabbarItems = self.itemArray;
        
        [tabbar popWithBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        _slideView.tabbar = tabbar;
        _slideView.cache = cache;
        _slideView.tabbarBottomSpacing = 5;
        _slideView.baseViewController = self;
        _slideView.delegate = self;
        [_slideView setup];
        _slideView.selectedIndex = 0;
        
    }
    return _slideView;
}

- (NSInteger)numberOfTabsInDLCustomSlideView:(DLCustomSlideView *)sender{
    return self.itemArray.count;
}

- (UIViewController *)DLCustomSlideView:(DLCustomSlideView *)sender controllerAt:(NSInteger)index{
    RankListController *rank = [[RankListController alloc] init];
    Root * root = self.rootArray[index];
    rank.url = root.url;
    return rank;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
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
