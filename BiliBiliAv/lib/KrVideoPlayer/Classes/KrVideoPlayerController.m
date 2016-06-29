//
//  KrVideoPlayerController.m
//  KrVideoPlayerPlus
//
//  Created by JiaHaiyang on 15/6/19.
//  Copyright (c) 2015年 JiaHaiyang. All rights reserved.
//

#import "KrVideoPlayerController.h"
#import "KrVideoPlayerControlView.h"
#import "PlayerLaodStatusView.h"
#import "CFDanmakuView.h"
#import <AVFoundation/AVFoundation.h>

static const CGFloat kVideoPlayerControllerAnimationTimeinterval = 0.3f;

@interface KrVideoPlayerController()<CFDanmakuDelegate>
{
    NSDate *_danmuStartDate;
    NSTimer * _danmuTimer;
}
@property (nonatomic, strong) KrVideoPlayerControlView *videoControl;
@property(nonatomic,strong) PlayerLaodStatusView * loadingView;
@property(nonatomic,strong) CFDanmakuView * danmukuView;
@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, assign) double lastTime;
@end

@implementation KrVideoPlayerController

- (void)dealloc
{
    [self cancelObserver];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControl];
        [self.view addSubview:self.loadingView];
        [self.view addSubview:self.danmukuView];
        self.videoControl.frame = self.view.bounds;
        [self configObserver];
        [self configControlAction];
        [self ListeningRotating];
        
    }
    return self;
}

#pragma mark - Override Method

- (void)setContentURL:(NSURL *)contentURL
{
    [self stop];
    [super setContentURL:contentURL];
    [self play];
}

#pragma mark - Publick Method

- (void)showInWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dismiss
{
    [self stopDurationTimer];
    [self stop];
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.dimissCompleteBlock) {
            self.dimissCompleteBlock();
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Private Method

- (void)configObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
}

- (void)cancelObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configControlAction
{
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification
{
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        [self.loadingView removeFromSuperview];
        self.videoControl.pauseButton.hidden = NO;
        self.videoControl.playButton.hidden = YES;
        [self startDurationTimer];
        [self.videoControl.indicatorView stopAnimating];
        [self.videoControl autoFadeOutControlBar];
        //播放弹幕
        if (self.danmukuView.isPrepared) {
            [self.danmukuView start];
        }
        if (self.danmukuView.isPauseing) {
            [self.danmukuView resume];
        }
    } else {
        self.videoControl.pauseButton.hidden = YES;
        self.videoControl.playButton.hidden = NO;
        [self stopDurationTimer];
        if (self.danmukuView.isPlaying) {
            [self.danmukuView pause];
        }
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.danmukuView stop];
            [self.videoControl animateShow];
        }
    }
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification
{
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControl.indicatorView startAnimating];
    }
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification
{
    
}

- (void)onMPMovieDurationAvailableNotification
{
    [self setProgressSliderMaxMinValues];
}

- (void)playButtonClick
{
    [self play];
    if (self.danmukuView.isPauseing) {
        [self.danmukuView resume];
    }
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
}

- (void)pauseButtonClick
{
    [self pause];
    if (self.danmukuView.isPlaying) {
        [self.danmukuView pause];
    }
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
}

- (void)backButtonClick
{
    if (self.backClickBlock) {
        self.backClickBlock();
    }
    //[self dismiss];
}

- (void)fullScreenButtonClick
{
    if (self.isFullscreenMode) {
        return;
    }
    [self setDeviceOrientationLandscapeRight];
}
- (void)shrinkScreenButtonClick
{
    if (!self.isFullscreenMode) {
        return;
    }
    
    [self backOrientationPortrait];
    
}

#pragma mark - 弹幕代理
- (NSTimeInterval)danmakuViewGetPlayTime:(CFDanmakuView*)danmakuView
{
    if (self.videoControl.progressSlider.value == floor(self.duration))
        [self.danmukuView stop];
    return self.videoControl.progressSlider.value;
}

-(void)setupDanmuku:(NSArray *)danmukus
{
    [self.danmukuView prepareDanmakus:danmukus];
}

- (BOOL)danmakuViewIsBuffering:(CFDanmakuView*)danmakuView
{
    return NO;
}


#pragma mark -- 设备旋转监听 改变视频全屏状态显示方向 --
//监听设备旋转方向
- (void)ListeningRotating{
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
}
- (void)onDeviceOrientationChange{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
            /**        case UIInterfaceOrientationUnknown:
             NSLog(@"未知方向");
             break;
             */
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
            [self backOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [self backOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在右");
            
            [self setDeviceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            
            NSLog(@"第1个旋转方向---电池栏在左");
            
            [self setDeviceOrientationLandscapeRight];
            
        }
            break;
            
        default:
            break;
    }
    
}
//返回小屏幕
- (void)backOrientationPortrait{
    if (!self.isFullscreenMode) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        if ([self.danmukuView isPlaying]) {
            [self.danmukuView pause];
            [self.danmukuView clear];
            [self reSetDanmakuViewWhenFullScreen:NO];
        }
        self.frame = self.originFrame;
        //[self resetFrame:self.view.bounds];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.videoControl.fullScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton.hidden = YES;
        
        if (self.willBackOrientationPortrait) {
            self.willBackOrientationPortrait();
            if (self.danmukuView.isPrepared) {
                [self.danmukuView start];
            }
        }
    }];
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
    if (self.isFullscreenMode) {
        return;
    }
    
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        if ([self.danmukuView isPlaying]) {
            [self.danmukuView pause];
            [self.danmukuView clear];
            [self reSetDanmakuViewWhenFullScreen:YES];
        }
        self.frame = frame;
       // [self resetFrame:self.view.bounds];
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton.hidden = NO;
        
        if (self.willChangeToFullscreenMode) {
            self.willChangeToFullscreenMode();
            if (self.danmukuView.isPrepared) {
                [self.danmukuView start];
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
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        if ([self.danmukuView isPlaying]) {
            [self.danmukuView pause];
            [self.danmukuView clear];
            [self reSetDanmakuViewWhenFullScreen:YES];
        }
        self.frame = frame;
        //[self resetFrame:self.view.bounds];
        [self.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton.hidden = NO;
        if (self.willChangeToFullscreenMode) {
            self.willChangeToFullscreenMode();
            if (self.danmukuView.isPrepared) {
                [self.danmukuView start];
            }
        }
    }];
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.f;
    self.videoControl.progressSlider.maximumValue = duration;
}

-(void)resetFrame:(CGRect)frame
{
    self.loadingView.frame = frame;
    [self.loadingView setNeedsLayout];
    self.danmukuView.frame = frame;
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControl autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)monitorVideoPlayback
{
    double currentTime = floor(self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = ceil(currentTime);
    self.videoControl.progressView.progress = self.playableDuration / self.duration;
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

- (void)startDurationTimer
{
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
}

- (void)fadeDismissControl
{
    [self.videoControl animateHide];
}

#pragma mark - Property

- (KrVideoPlayerControlView *)videoControl
{
    if (!_videoControl) {
        _videoControl = [[KrVideoPlayerControlView alloc] init];
    }
    return _videoControl;
}

-(PlayerLaodStatusView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[PlayerLaodStatusView alloc] initWithFrame:self.view.bounds];
    }
    return _loadingView;
}

-(CFDanmakuView *)danmukuView
{
    if (!_danmukuView) {
        _danmukuView = [[CFDanmakuView alloc] initWithFrame:self.view.bounds];
        _danmukuView.duration = 6.5;
        _danmukuView.centerDuration = 2.5;
        _danmukuView.lineHeight = 25*0.7;
        _danmukuView.maxShowLineCount = self.view.bounds.size.height/_danmukuView.lineHeight;
        _danmukuView.maxCenterLineCount = 5;
        
        _danmukuView.delegate = self;
    }
    return _danmukuView;
}

-(void)reSetDanmakuViewWhenFullScreen:(BOOL)full
{
    if (full) {
        self.danmukuView.lineHeight = 25;
        self.danmukuView.maxShowLineCount = self.view.bounds.size.height/self.danmukuView.lineHeight;;
        self.danmukuView.maxCenterLineCount = 10;
    }else{
        self.danmukuView.lineHeight = 25*0.7;
        self.danmukuView.maxShowLineCount = self.view.bounds.size.height/self.danmukuView.lineHeight;;
        self.danmukuView.maxCenterLineCount = 5;
    }
}

- (UIView *)movieBackgroundView
{
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [self resetFrame:self.view.bounds];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}

#pragma mark - 取出视频图片
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}


@end
