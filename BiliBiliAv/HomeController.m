//
//  HomeController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/10.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "HomeController.h"
//#import "DLFixedTabbarView.h"
#import "LiveController.h"
#import "TuiJianController.h"
#import "BangumiController.h"
#import "SectionController.h"

@interface HomeController ()

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layOutTabSlideView];
}

-(void)layOutTabSlideView
{
    //UIView * containerView = self.navigationController.navigationBar;
    
    self.tabSlideView.baseViewController = self;
    self.tabSlideView.delegate = self;
    self.tabSlideView.sd_layout.leftSpaceToView(self.view,0).topSpaceToView(self.view,0).rightSpaceToView(self.view,0).bottomSpaceToView(self.view,0);
    
    self.tabSlideView.tabItemNormalColor = [UIColor grayColor];
    self.tabSlideView.tabItemSelectedColor = kStyleColor;
    self.tabSlideView.tabbarTrackColor = kStyleColor;
    self.tabSlideView.tabbarBackgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
    self.tabSlideView.tabbarHeight = 44;
    self.tabSlideView.tabbarBottomSpacing = 0;
    
    DLTabedbarItem * liveItem = [DLTabedbarItem itemWithTitle:@"直播" image:nil selectedImage:nil];
    DLTabedbarItem * tuiJianitem = [DLTabedbarItem itemWithTitle:@"推荐" image:nil selectedImage:nil];
    DLTabedbarItem * bangumiItem = [DLTabedbarItem itemWithTitle:@"番剧" image:nil selectedImage:nil];
    DLTabedbarItem * sectionItem = [DLTabedbarItem itemWithTitle:@"分区" image:nil selectedImage:nil];
    self.tabSlideView.tabbarItems = @[liveItem, tuiJianitem, bangumiItem,sectionItem];
    [self.tabSlideView buildTabbar];
    
    self.tabSlideView.selectedIndex = 1;
}

-(NSInteger)numberOfTabsInDLTabedSlideView:(DLTabedSlideView *)sender
{
    return 4;
}

- (UIViewController *)DLTabedSlideView:(DLTabedSlideView *)sender controllerAt:(NSInteger)index{
    switch (index) {
        case 0:
        {
            LiveController *live = [[LiveController alloc] init];
            return live;
        }
        case 1:
        {
            TuiJianController *tuiJian = [[TuiJianController alloc] init];
            return tuiJian;
        }
        case 2:
        {
            BangumiController *bangumi = [[BangumiController alloc] init];
            return bangumi;
        }
        case 3:
        {
            SectionController *section = [[SectionController alloc] init];
            return section;
        }
        default:
            return nil;
    }
}


-(DLTabedSlideView *)tabSlideView
{
    if (!_tabSlideView) {
        _tabSlideView = [DLTabedSlideView new];
        [self.view addSubview:_tabSlideView];
    }
    return _tabSlideView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
