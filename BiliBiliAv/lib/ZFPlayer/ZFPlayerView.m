//
//  ZFPlayerView.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry/Masonry.h>
#import <XXNibBridge/XXNibBridge.h>
#import "ZFPlayerControlView.h"
#import "ZFBrightnessView.h"
#import "ZFPlayer.h"
#import "CFDanmakuView.h"
#import "PlayerLaodStatusView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)(((rgbValue)&0xFF0000) >> 16)) / 255.0 green:((float)(((rgbValue)&0xFF00) >> 8)) / 255.0 blue:((float)((rgbValue)&0xFF)) / 255.0 alpha:1.0]

static const CGFloat ZFPlayerAnimationTimeInterval             = 7.0f;
static const CGFloat ZFPlayerControlBarAutoFadeOutTimeInterval = 0.5f;

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, //横向移动
    PanDirectionVerticalMoved    //纵向移动
};

//播放器的几种状态
typedef NS_ENUM(NSInteger, ZFPlayerState) {
    ZFPlayerStateBuffering,  //缓冲中
    ZFPlayerStatePlaying,    //播放中
    ZFPlayerStateStopped,    //停止播放
    ZFPlayerStatePause       //暂停播放
};

static ZFPlayerView* playerView = nil;

@interface ZFPlayerView () <XXNibBridge,UIGestureRecognizerDelegate,CFDanmakuDelegate>
@property(nonatomic,strong) PlayerLaodStatusView * loadingView;
/** 快进快退label */
@property(nonatomic,strong) UILabel                 *horizontalLabel;
/** 系统菊花 */
@property(nonatomic,strong) UIActivityIndicatorView *activity;
/** 返回按钮*/
@property(nonatomic,strong) UIButton * backBtn;
/** 播放属性 */
@property (nonatomic, strong) AVPlayer            *player;
/** 播放属性 */
@property (nonatomic, strong) AVPlayerItem        *playerItem;
/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer       *playerLayer;
/** 滑杆 */
@property (nonatomic, strong) UISlider            *volumeViewSlider;
/** 计时器 */
@property (nonatomic, strong) NSTimer             *timer;
/** 控制层View */
@property (nonatomic, strong) ZFPlayerControlView *controlView;
/**弹幕view*/
@property(nonatomic,strong) CFDanmakuView * danmukuView;
/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat             sumTime;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection        panDirection;
/** 播发器的几种状态 */
@property (nonatomic, assign) ZFPlayerState       state;
/** 是否为全屏 */
@property (nonatomic, assign) BOOL                isFullScreen;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                isVolume;
/** 是否显示controlView*/
@property (nonatomic, assign) BOOL                isMaskShowing;
/** 是否被用户暂停 */
@property (nonatomic, assign) BOOL                isPauseByUser;
/** 是否播放本地文件 */
@property (nonatomic, assign) BOOL                isLocalVideo;
/** slider上次的值 */
@property (nonatomic, assign) CGFloat             sliderLastValue;
/** 是否缩小视频在底部 */
@property (nonatomic, assign) BOOL                isBottomVideo;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, assign) double lastTime;
@property (nonatomic ,strong) DanMuKuModel * danmukModel;
@end

@implementation ZFPlayerView

/**
 *  类方法创建，该方法适用于代码创建View
 *
 *  @return ZFPlayer
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self awakeFromNib];
        [self addSubview:self.loadingView];
        [self addSubview:self.danmukuView];
        //[self reSetDanmakuViewWhenFullScreen:NO];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor                 = [UIColor blackColor];
    // 设置快进快退label
    self.horizontalLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:ZFPlayerSrcName(@"Management_Mask")]];
    // 亮度调节
    [ZFBrightnessView sharedBrightnesView];
    [self.activity stopAnimating];
    self.horizontalLabel.hidden = YES;
}

- (void)dealloc
{
     NSLog(@"%@释放了",self.class);
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 移除观察者
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
}

/**
 *  重置player
 */
- (void)resetPlayer
{
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 移除观察者
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
  
    // 关闭定时器
    [self.timer invalidate];
    // 暂停
    [self pause];
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    // 重置控制层View
    [self.controlView resetControlView];
    [self removeFromSuperview];
}

-(void)resetPlayerCopy
{
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 移除观察者
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    // 关闭定时器
    [self.timer invalidate];
    // 暂停
    [self pause];
    
    [self addSubview:self.loadingView];
    [self.danmukuView clear];
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 替换PlayerItem
    [self.player replaceCurrentItemWithPlayerItem:nil];
    
    // 重置控制层View
    [self.controlView resetControlView];
}

#pragma mark - 观察者、通知

/**
 *  添加观察者
 */
- (void)addObserverAndNotification {
    // AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // slider开始滑动事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.controlView.videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    // 播放按钮点击事件
    [self.controlView.startBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"play_back_full")] forState:UIControlStateNormal];
    // 返回按钮点击事件
    [self.backBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    // 全屏按钮点击事件
    [self.controlView.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 监听播放状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听loadedTimeRanges属性
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is empty
    [self.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    // Will warn you when your buffer is good to go again.
    [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];

    // 监测设备方向
    [self listeningRotating];
}

/**
 *  监听设备旋转通知
 */
- (void)listeningRotating{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
}

-(void)setLoadingStatus:(NSString *)loadingStatus
{
    if (!loadingStatus) return;
    _loadingStatus = loadingStatus;
    
    self.loadingView.loadingStatus = loadingStatus;
}

#pragma mark - layoutSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.controlView.frame = self.bounds;
    [self resetFrame:self.bounds];
    // 屏幕方向一发生变化就会调用这里
    self.isMaskShowing = YES;
    // 延迟隐藏controlView
    [self hideControlView];
}

-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.size = CGSizeMake(30, 30);
        _backBtn.left = 12;
        _backBtn.top = 20;
        [self.controlView addSubview:_backBtn];
    }
    return _backBtn;
}

-(UIActivityIndicatorView *)activity
{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.size = CGSizeMake(40, 40);
        [self addSubview:_activity];
    }
    return _activity;
}

-(UILabel *)horizontalLabel
{
    if (!_horizontalLabel) {
        _horizontalLabel = [[UILabel alloc] init];
        _horizontalLabel.size = CGSizeMake(120, 40);
        _horizontalLabel.textAlignment = NSTextAlignmentCenter;
        _horizontalLabel.textColor = [UIColor whiteColor];
        _horizontalLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_horizontalLabel];
    }
    return _horizontalLabel;
}

#pragma mark - 设置视频URL

/**
 *  videoURL的setter方法
 *
 *  @param videoURL videoURL
 */
- (void)setVideoURL:(NSURL *)videoURL
{
    // 每次播放视频都解锁屏幕锁定
    //[self unLockTheScreen];
    self.state = ZFPlayerStateStopped;
    
    // 初始化playerItem
    self.playerItem  = [AVPlayerItem playerItemWithURL:videoURL];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    // 初始化playerLayer
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    // AVLayerVideoGravityResize,       // 非均匀模式。两个维度完全填充至整个视图区域
    // AVLayerVideoGravityResizeAspect,  // 等比例填充，直到一个维度到达区域边界
    // AVLayerVideoGravityResizeAspectFill, // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
    
    // 此处根据视频填充模式设置
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    // 添加playerLayer到self.layer
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    // 添加观察者、通知
    [self addObserverAndNotification];
    
    // 初始化显示controlView为YES
    self.isMaskShowing = YES;
    // 延迟隐藏controlView
    [self autoFadeOutControlBar];
    
    // 计时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(playerTimerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    // 根据屏幕的方向设置相关UI
    if (!self.isBangumiAv) {
        [self onDeviceOrientationChange];
    }
    
    // 添加手势
    [self createGesture];
    
    //获取系统音量
    [self configureVolume];
    
    // 本地文件不设置ZFPlayerStateBuffering状态
    if ([videoURL.scheme isEqualToString:@"file"]) {
        self.state = ZFPlayerStatePlaying;
        self.isLocalVideo = YES;
    } else {
        self.state = ZFPlayerStateBuffering;
        self.isLocalVideo = NO;
    }
    
    // 开始播放
    [self play];
    self.controlView.startBtn.selected = YES;
    self.isPauseByUser = NO;
    [self.activity startAnimating];
    
    
    //强制让系统调用layoutSubviews 两个方法必须同时写
    [self setNeedsLayout]; //是标记 异步刷新 会调但是慢
    [self layoutIfNeeded]; //加上此代码立刻刷新
}

//创建手势
- (void)createGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    
    [self addGestureRecognizer:tap];
}

//获取系统音量
- (void)configureVolume
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
}

#pragma mark - ShowOrHideControlView

- (void)autoFadeOutControlBar
{
    if (!self.isMaskShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self performSelector:@selector(hideControlView) withObject:nil afterDelay:ZFPlayerAnimationTimeInterval];

}

/**
 *  取消延时隐藏controlView的方法
 */
- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/**
 *  隐藏控制层
 */
- (void)hideControlView
{
    if (!self.isMaskShowing) {
        return;
    }
    
    [UIView animateWithDuration:ZFPlayerControlBarAutoFadeOutTimeInterval animations:^{
        self.controlView.alpha = 0;
       
        self.backBtn.alpha  = 0;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }completion:^(BOOL finished) {
        self.isMaskShowing = NO;
    }];
}

/**
 *  显示控制层
 */
- (void)animateShow
{
    if (self.isMaskShowing) {
        return;
    }
    
    [UIView animateWithDuration:ZFPlayerControlBarAutoFadeOutTimeInterval animations:^{
        self.backBtn.alpha = 1;
        // 视频在bottom小屏,并且不是全屏状态
        if (self.isBottomVideo && !self.isFullScreen) {
            self.controlView.alpha = 0;
        }else {
            self.controlView.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
    } completion:^(BOOL finished) {
        self.isMaskShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            
            if (self.player.status == AVPlayerStatusReadyToPlay) {
                [self.loadingView resetLoadingView];
                _loadingView = nil;
                //播放弹幕
                if (self.danmukuView.isPrepared) {
                    [self.danmukuView start];
                }
                if (self.danmukuView.isPauseing) {
                    [self.danmukuView resume];
                }
                self.state = ZFPlayerStatePlaying;
                // 加载完成后，再添加平移手势
                // 添加平移手势，用来控制音量、亮度、快进快退
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
                pan.delegate                = self;
                [self addGestureRecognizer:pan];
                
            } else if (self.player.status == AVPlayerStatusFailed){
                //
                if (self.danmukuView.isPlaying) {
                    [self.danmukuView pause];
                }
                
                [self.activity startAnimating];
            }
            
        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.controlView.progressView setProgress:timeInterval / totalDuration animated:NO];
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                //NSLog(@"playbackBufferEmpty");
                if (self.danmukuView.isPlaying) {
                    [self.danmukuView pause];
                }
                
                self.state = ZFPlayerStateBuffering;
                [self bufferingSomeSecond];
            }
            
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp){
                //NSLog(@"playbackLikelyToKeepUp");
                self.state = ZFPlayerStatePlaying;
            }
            
        }
    }
}

/**
 *  全屏按钮事件
 *
 *  @param sender 全屏Button
 */
- (void)fullScreenAction:(UIButton *)sender
{
    if (self.isFullScreen) {
        [self backOrientationPortrait];
    }
    [self setDeviceOrientationLandscapeRight];
}

//返回小屏幕
- (void)backOrientationPortrait{
    if (!self.isFullScreen) {
        return;
    }
    [self setupDanmakuData:self.danmukModel full:NO];
    [self.danmukuView pause];
    [self.danmukuView clear];
    
    self.isFullScreen = NO;
    [UIView animateWithDuration:0.3f animations:^{
        [self setTransform:CGAffineTransformIdentity];
        [self reSetDanmakuViewWhenFullScreen:NO];
        self.rFrame = self.originFrame;
        //[self resetFrame:self.view.bounds];
    } completion:^(BOOL finished) {
        if (self.danmukuView.isPrepared) {
            if (self.isPauseByUser) {
                
            }else{
               [self.danmukuView resume];
            }
        }
    }];
}

-(void)setIsBangumiAv:(BOOL)isBangumiAv
{
    _isBangumiAv = isBangumiAv;
    if (isBangumiAv) {
        [self setDeviceOrientationLandscapeRight];
        self.controlView.fullScreenBtn.hidden = YES;
    }
}

//电池栏在左全屏
- (void)setDeviceOrientationLandscapeRight{
    
    //    if (self.integer==2) {
    //        self.originFrame = self.view.frame;
    //        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    //        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    //        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    //        [UIView animateWithDuration:0.3f animations:^{
    //            self.frame = frame;
    //            [self.view setTransform:CGAffineTransformMakeRotation(M_PI)];
    //        } completion:^(BOOL finished) {
    //            self.integer = 1;
    //            self.isFullscreenMode = YES;
    //            self.videoControl.fullScreenButton.hidden = YES;
    //            self.videoControl.shrinkScreenButton.hidden = NO;
    //        }];
    //    }
    if (self.isFullScreen) {
        return;
    }
    [self setupDanmakuData:self.danmukModel full:YES];
    self.originFrame = self.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame;
    if (self.isBangumiAv) {
        frame = CGRectMake(0, 0, width, height);
    }else{
        frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    }
    
    [self.danmukuView pause];
    [self.danmukuView clear];
    
    self.isFullScreen = YES;
    [UIView animateWithDuration:0.3f animations:^{
        [self reSetDanmakuViewWhenFullScreen:YES];
        self.rFrame = frame;
        // [self resetFrame:self.view.bounds];
        if (!self.isBangumiAv) {
            [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        }
    } completion:^(BOOL finished) {
        //self.isFullScreen = YES;
        if (self.danmukuView.isPrepared) {
            if (self.isPauseByUser) {
                
            }else{
                [self.danmukuView resume];
            }
        }
    }];
    
}
//电池栏在右全屏
- (void)setDeviceOrientationLandscapeLeft{
    
    //    if  (self.integer==1){
    //        self.originFrame = self.view.frame;
    //        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    //        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    //        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    //        [UIView animateWithDuration:0.3f animations:^{
    //            self.frame = frame;
    //            [self.view setTransform:CGAffineTransformMakeRotation(-M_PI)];
    //        } completion:^(BOOL finished) {
    //            self.integer = 2;
    //            self.isFullscreenMode = YES;
    //            self.videoControl.fullScreenButton.hidden = YES;
    //            self.videoControl.shrinkScreenButton.hidden = NO;
    //        }];
    //    }
    if (self.isFullScreen) {
        return;
    }
    [self setupDanmakuData:self.danmukModel full:YES];
    self.originFrame = self.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame;
    if (self.isBangumiAv) {
        frame = CGRectMake(0, 0, width, height);
    }else{
        frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
    }
    [self.danmukuView pause];
    [self.danmukuView clear];
    
    self.isFullScreen = YES;
    [UIView animateWithDuration:0.3f animations:^{
        [self reSetDanmakuViewWhenFullScreen:YES];
        self.rFrame = frame;
        //[self resetFrame:self.view.bounds];
        if (!self.isBangumiAv) {
            [self setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        }
    } completion:^(BOOL finished) {
        //self.isFullScreen = YES;
        if (self.danmukuView.isPrepared) {
            if (self.isPauseByUser) {
                
            }else{
                [self.danmukuView resume];
            }
        }
    }];
}

- (void)setRFrame:(CGRect)rFrame
{
    [self setFrame:rFrame];
    [self resetFrame:self.bounds];
}

-(void)resetFrame:(CGRect)frame
{
    self.loadingView.frame = frame;
    [self.loadingView setNeedsLayout];
    self.danmukuView.frame = frame;
    self.activity.centerX = self.isFullScreen?self.centerY:self.centerX;
    self.activity.centerY = self.isFullScreen?self.centerX:self.centerY;
    self.horizontalLabel.centerX = self.isFullScreen?self.center.y:self.center.x;
    self.horizontalLabel.centerY = self.isFullScreen?self.center.x:self.center.y;
}

-(void)setupDanmuku:(DanMuKuModel *)danmukuModel
{
    self.danmukModel = danmukuModel;
    
    [self setupDanmakuData:danmukuModel full:self.isBangumiAv];
}

- (void)setupDanmakuData:(DanMuKuModel *)danmuku full:(BOOL)full
{
    CGFloat fontSocle = 1.8;
    if (full) {
        fontSocle = 1.4;
    }
    NSMutableArray* danmakus = [NSMutableArray array];
    for (d * danmu in danmuku.d) {
        CFDanmaku* danmaku = [[CFDanmaku alloc] init];
        
        NSString* attributesStr = danmu._p;
        NSArray* attarsArray = [attributesStr componentsSeparatedByString:@","];
        UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:[attarsArray[2] floatValue]/fontSocle];
        NSMutableAttributedString *contentStr = [[NSMutableAttributedString alloc] initWithString:danmu.__text?:@""];
        contentStr.color = attarsArray[3]?UIColorFromRGB(((long)[attarsArray[3] doubleValue])):[UIColor colorWithWhite:1 alpha:1];
        contentStr.strokeColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        contentStr.strokeWidth = @-1;
        contentStr.font = attarsArray[2]?font : [UIFont fontWithName:@"Arial-BoldMT" size:14];
        danmaku.contentStr = contentStr;
        
        CGFloat sendTime = [attarsArray[0] doubleValue];
        //        if (sendTime<=0.5) {
        //            danmaku.timePoint = 0.6;
        //        }else{
        //            danmaku.timePoint = sendTime?sendTime:0.6;
        //        }
        danmaku.timePoint = sendTime?:0.6;
        danmaku.position = ([attarsArray[1] integerValue]-1)%3;
        
        [danmakus addObject:danmaku];
    }
    
    [self.danmukuView prepareDanmakus:danmakus];
}


/**
 *  屏幕方向发生变化会调用这里
 */
- (void)onDeviceOrientationChange{
    
    UIDeviceOrientation orientation             = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            [self.controlView.fullScreenBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-shrinkscreen")] forState:UIControlStateNormal];
           
            [self backOrientationPortrait];

        }
            break;
        case UIInterfaceOrientationPortrait:{
            [self.controlView.fullScreenBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-fullscreen")] forState:UIControlStateNormal];
            
            [self backOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            [self.controlView.fullScreenBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-shrinkscreen")] forState:UIControlStateNormal];
            
            [self setDeviceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            [self.controlView.fullScreenBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-shrinkscreen")] forState:UIControlStateNormal];
    
            [self setDeviceOrientationLandscapeRight];

        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond
{
    [self.activity startAnimating];
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self pause];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
    });
}

#pragma mark - 计时器事件
/**
 *  计时器事件
 */
- (void)playerTimerAction
{
    if (_playerItem.duration.timescale != 0) {
        self.controlView.videoSlider.maximumValue = 1;//音乐总共时长
        self.controlView.videoSlider.value        = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);//当前进度

        //当前时长进度progress
        NSInteger proMin                          = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec                          = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟

        //duration 总时长
        NSInteger durMin                          = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总秒
        NSInteger durSec                          = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总分钟

        self.controlView.currentTimeLabel.text    = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        self.controlView.totalTimeLabel.text      = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
    }
}

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - slider事件

/**
 *  slider开始滑动事件
 *
 *  @param slider UISlider
 */
- (void)progressSliderTouchBegan:(UISlider *)slider
{
    [self cancelAutoFadeOutControlBar];
    // 暂停timer
    [self.timer setFireDate:[NSDate distantFuture]];
}

/**
 *  slider滑动中事件
 *
 *  @param slider UISlider
 */
- (void)progressSliderValueChanged:(UISlider *)slider
{
    NSString *style = @"";
    CGFloat value = slider.value - self.sliderLastValue;
    if (value > 0) {
        style = @">>";
    } else if (value < 0) {
        style = @"<<";
    }
     self.sliderLastValue = slider.value;
    //拖动改变视频播放进度
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        
        [self pause];
        //计算出拖动的当前秒数
        CGFloat total                       = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;

        NSInteger dragedSeconds             = floorf(total * slider.value);

        //转换成CMTime才能给player来控制播放进度

        CMTime dragedCMTime                 = CMTimeMake(dragedSeconds, 1);
        // 拖拽的时长
        NSInteger proMin                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) / 60;//当前秒
        NSInteger proSec                    = (NSInteger)CMTimeGetSeconds(dragedCMTime) % 60;//当前分钟

        //duration 总时长
        NSInteger durMin                    = (NSInteger)total / 60;//总秒
        NSInteger durSec                    = (NSInteger)total % 60;//总分钟

        NSString *currentTime               = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
        NSString *totalTime                 = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];

        self.controlView.currentTimeLabel.text = currentTime;
        self.horizontalLabel.hidden         = NO;
        self.horizontalLabel.text           = [NSString stringWithFormat:@"%@ %@ / %@",style, currentTime, totalTime];
        
    }
}

/**
 *  slider结束滑动事件
 *
 *  @param slider UISlider
 */
- (void)progressSliderTouchEnded:(UISlider *)slider
{
    // 继续开启timer
    [self.timer setFireDate:[NSDate date]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.horizontalLabel.hidden = YES;
    });
    // 结束滑动时候把开始播放按钮改为播放状态
    self.controlView.startBtn.selected = YES;
    self.isPauseByUser                 = NO;
    
    // 滑动结束延时隐藏controlView
    [self autoFadeOutControlBar];
    
    //计算出拖动的当前秒数
    CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;

    NSInteger dragedSeconds = floorf(total * slider.value);

    //转换成CMTime才能给player来控制播放进度

    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    
    [self endSlideTheVideo:dragedCMTime];
}

/**
 *  滑动结束视频跳转
 *
 *  @param dragedCMTime 视频跳转的CMTime
 */
- (void)endSlideTheVideo:(CMTime)dragedCMTime
{
    //[_player pause];
   
    [self.player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        // 如果点击了暂停按钮
        if (self.isPauseByUser) {
            //NSLog(@"已暂停");
            return ;
        }
        [self play];
        if (!self.playerItem.isPlaybackLikelyToKeepUp && !self.isLocalVideo) {
            self.state = ZFPlayerStateBuffering;
            //NSLog(@"显示菊花");
            [self.activity startAnimating];
        }
    }];
}

#pragma mark - Action

/**
 *   轻拍方法
 *
 *  @param gesture UITapGestureRecognizer
 */
- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBottomVideo && !self.isFullScreen) {
            [self fullScreenAction:self.controlView.fullScreenBtn];
            return;
        }
        if (self.isMaskShowing) {
            [self hideControlView];
        } else {
            [self animateShow];
        }
    }
}

/**
 *  播放、暂停
 *
 *  @param button UIButton
 */
- (void)startAction:(UIButton *)button
{
    button.selected = !button.selected;
    self.isPauseByUser = !button.isSelected;
    if (button.selected) {
        [self play];
        self.state = ZFPlayerStatePlaying;
    } else {
        [self pause];
        self.state = ZFPlayerStatePause;
    }
}
/**
 *  播放
 */
- (void)play
{
    [_player play];
    if (self.danmukuView.isPauseing) {
        [self.danmukuView resume];
    }
}

/**
 * 暂停
 */
- (void)pause
{
    [_player pause];
    [self.danmukuView pause];
}

/**
 *  返回按钮事件
 */
- (void)backButtonAction
{
    if (!self.isFullScreen) {
        // player加到控制器上，只有一个player时候
        [self.timer invalidate];
        [self pause];
        if (self.goBackBlock) {
            self.goBackBlock();
        }
    }else {
        if (self.isBangumiAv) {
            [self.timer invalidate];
            [self pause];
            UITabBarController * tab = (UITabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
            UINavigationController * nav = tab.selectedViewController;
            [nav.topViewController dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self backOrientationPortrait];
        }
    }
}

#pragma mark - NSNotification Action

/**
 *  播放完了
 *
 *  @param notification 通知
 */
- (void)moviePlayDidEnd:(NSNotification *)notification
{
    self.state                  = ZFPlayerStateStopped;
    ZFPlayerShared.isLockScreen = NO;
    //[self interfaceOrientation:UIInterfaceOrientationPortrait];
    // 关闭定时器
    [self.timer invalidate];
    // 重置Player
    [self resetPlayer];
    if (self.goBackBlock) {
        self.goBackBlock();
    }
}

/**
 *  应用退到后台
 */
- (void)appDidEnterBackground
{
    [self pause];
    self.state = ZFPlayerStatePause;
    [self cancelAutoFadeOutControlBar];
}

/**
 *  应用进入前台
 */
- (void)appDidEnterPlayGround
{
    self.isMaskShowing = NO;
    // 延迟隐藏controlView
    [self animateShow];
    if (!self.isPauseByUser) {
        self.state                         = ZFPlayerStatePlaying;
        self.controlView.startBtn.selected = YES;
        self.isPauseByUser                 = NO;
        [self play];
    }
}

#pragma mark - UIPanGestureRecognizer手势方法

/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                self.panDirection           = PanDirectionHorizontalMoved;
                // 取消隐藏
                self.horizontalLabel.hidden = NO;
                // 给sumTime初值
                CMTime time                 = self.player.currentTime;
                self.sumTime                = time.value/time.timescale;
                
                // 暂停视频播放
                [self pause];
                // 暂停timer
                [self.timer setFireDate:[NSDate distantFuture]];
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
                
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    
                    // 继续播放
                    [self play];
                    [self.timer setFireDate:[NSDate date]];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        // 隐藏视图
                        self.horizontalLabel.hidden = YES;
                    });
                    //快进、快退时候把开始播放按钮改为播放状态
                    self.controlView.startBtn.selected = YES;
                    self.isPauseByUser                 = NO;

                    // 转换成CMTime才能给player来控制播放进度
                    CMTime dragedCMTime                = CMTimeMake(self.sumTime, 1);
                    //[_player pause];
                    
                    [self endSlideTheVideo:dragedCMTime];

                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.horizontalLabel.hidden = YES;
                    });
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value
{
    if (self.isVolume) {
        // 更改系统的音量
        self.volumeViewSlider.value      -= value / 10000;// 越小幅度越小
    }else {
        //亮度
        [UIScreen mainScreen].brightness -= value / 10000;
        //NSString *brightness             = [NSString stringWithFormat:@"亮度%.0f%%",[UIScreen mainScreen].brightness/1.0*100];
        //self.horizontalLabel.hidden      = NO;
        //self.horizontalLabel.text        = brightness;
    }
}


/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value
{
    // 快进快退的方法
    NSString *style = @"";
    if (value < 0) {
        style = @"<<";
    }
    else if (value > 0){
        style = @">>";
    }
    
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    
    // 需要限定sumTime的范围
    CMTime totalTime           = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) {
        self.sumTime = totalMovieDuration;
    }else if (self.sumTime < 0){
        self.sumTime = 0;
    }
    
    // 当前快进的时间
    NSString *nowTime         = [self durationStringWithTime:(int)self.sumTime];
    // 总时间
    NSString *durationTime    = [self durationStringWithTime:(int)totalMovieDuration];
    // 给label赋值
    self.horizontalLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",style, nowTime, durationTime];
}

/**
 *  根据时长求出字符串
 *
 *  @param time 时长
 *
 *  @return 时长字符串
 */
- (NSString *)durationStringWithTime:(int)time
{
    // 获取分钟
    NSString *min = [NSString stringWithFormat:@"%02d",time / 60];
    // 获取秒数
    NSString *sec = [NSString stringWithFormat:@"%02d",time % 60];
    return [NSString stringWithFormat:@"%@:%@", min, sec];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.controlView];
    // （屏幕下方slider区域不响应pan手势） || （在cell上播放视频 && 不是全屏状态）
    if ((point.y > self.bounds.size.height-40) && !self.isFullScreen) {
        return NO;
    }
    return YES;
}

#pragma mark - Setter 

/**
 *  设置播放的状态
 *
 *  @param state ZFPlayerState
 */
- (void)setState:(ZFPlayerState)state
{
    _state = state;
    if (state != ZFPlayerStateBuffering) {
        [self.activity stopAnimating];
    }
}

#pragma mark - 弹幕代理

-(NSTimeInterval)danmakuViewGetPlayTime:(CFDanmakuView *)danmakuView
{
    if (_playerItem.duration.timescale == 0) {
        return 0;
    }else {
        return (double)(_controlView.videoSlider.value * (_playerItem.duration.value / _playerItem.duration.timescale));
    }
}
- (BOOL)danmakuViewIsBuffering:(CFDanmakuView*)danmakuView
{
    return NO;
}

#pragma mark - Getter

/**
 *  懒加载Player
 *
 *  @return AVPlayer
 */
- (AVPlayer *)player
{
    if (!_player) {
        _player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
    }
    return _player;
}

/**
 * 懒加载 控制层View
 *
 *  @return ZFPlayerControlView
 */
- (ZFPlayerControlView *)controlView
{
    if (!_controlView) {
        _controlView = [ZFPlayerControlView setupPlayerControlView];
        [self addSubview:_controlView];
    }
    return _controlView;
}

-(PlayerLaodStatusView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[PlayerLaodStatusView alloc] initWithFrame:self.bounds];
        
        [_loadingView.popBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _loadingView;
}

-(CFDanmakuView *)danmukuView
{
    if (!_danmukuView) {
        _danmukuView = [[CFDanmakuView alloc] initWithFrame:self.bounds];
        self.danmukuView.duration = 6.5;
        self.danmukuView.centerDuration = 2.5;
        self.danmukuView.lineMargin = 0;
        self.danmukuView.lineHeight = 25*0.7;
        self.danmukuView.maxShowLineCount = self.bounds.size.height/self.danmukuView.lineHeight;;
        self.danmukuView.maxCenterLineCount = 5;
        _danmukuView.delegate = self;
    }
    return _danmukuView;
}

-(void)reSetDanmakuViewWhenFullScreen:(BOOL)full
{
    if (full) {
        self.danmukuView.duration = 6.5;
        self.danmukuView.centerDuration = 2.5;
        self.danmukuView.lineHeight = 25;
        self.danmukuView.lineMargin = 0;
        self.danmukuView.maxShowLineCount = kScreenWidth-(self.danmukuView.lineHeight-1)*self.danmukuView.lineMargin/self.danmukuView.lineHeight;
        self.danmukuView.maxCenterLineCount = self.danmukuView.maxShowLineCount;
    }else{
        self.danmukuView.duration = 6.5;
        self.danmukuView.centerDuration = 2.5;
        self.danmukuView.lineMargin = 0;
        self.danmukuView.lineHeight = 25*0.7;
        self.danmukuView.maxShowLineCount = self.bounds.size.height/self.danmukuView.lineHeight;;
        self.danmukuView.maxCenterLineCount = self.danmukuView.maxShowLineCount;
    }
}

@end
