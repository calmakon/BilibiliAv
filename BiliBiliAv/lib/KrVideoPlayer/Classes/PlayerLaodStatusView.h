//
//  PlayerLaodStatusView.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/23.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerLaodStatusView : UIView
@property (nonatomic,strong,readonly) UIButton * popBtn;
@property (nonatomic,copy) NSString * loadingStatus;
-(void)resetLoadingView;
@end
