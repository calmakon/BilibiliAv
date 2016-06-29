//
//  KrVideoPlayerControlView.h
//  KrVideoPlayerPlus
//
//  Created by JiaHaiyang on 15/6/19.
//  Copyright (c) 2015年 JiaHaiyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerLaodStatusView.h"
@interface KrVideoPlayerControlView : UIView

@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong, readonly) UIView *bottomBar;
//@property(nonatomic,strong ,readonly) PlayerLaodStatusView * loadStatusView;
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *pauseButton;
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property(nonatomic,strong,readonly) UIProgressView * progressView;
@property (nonatomic, strong, readonly) UIButton *backButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;

- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;
//-(void)removeLoadView;
@end
