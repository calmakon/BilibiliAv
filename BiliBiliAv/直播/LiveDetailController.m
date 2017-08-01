//
//  LiveDetailController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/12/2.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LiveDetailController.h"
#import "LivePalyerView.h"
#import "AppDelegate.h"
@interface LiveDetailController ()
@property (nonatomic,strong) LivePalyerView * playerView;
@end

@implementation LiveDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerView.item = self.liveData;
}

-(LivePalyerView *)playerView
{
    if (!_playerView) {
        _playerView = [[LivePalyerView alloc] init];
        [self.view addSubview:_playerView];
    }
    return _playerView;
}

-(BOOL)shouldAutorotate
{
    AppDelegate *dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (dele.isFill) {
        return YES;
    }
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    AppDelegate *dele = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (dele.isRoll&&dele.isFill) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

-(void)dealloc
{
    self.playerView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
