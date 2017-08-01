//
//  LivePalyerView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/12/2.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LivePalyerView.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "LiveToolView.h"
#import "AppDelegate.h"
static BOOL _isFill;
static CGRect _minFrame;
@interface LivePalyerView ()

@property (nonatomic,retain) id <IJKMediaPlayback>player;
@property (nonatomic,strong) LiveToolView * toolView;
@end

@implementation LivePalyerView

-(instancetype)init
{
    if (self = [super init]) {
        
        CGFloat height = kScreenWidth*9/16;
        self.frame = CGRectMake(0, 0, kScreenWidth, height);
        _minFrame = self.frame;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

-(void)setItem:(LiveItem *)item
{
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:item.playurl] withOptions:nil];
    UIView * playerView = [self.player view];
    playerView.frame = self.bounds;
    
    [self addSubview:playerView];
    
    [self.player setScalingMode:IJKMPMovieScalingModeAspectFill];
    [self installMovieNotificationObservers];
    
    if (![self.player isPlaying]) {
        [self.toolView showBarView];
        [self.player prepareToPlay];
    }
}

-(void)layoutSubviews
{
    [self.player view].frame = self.bounds;
    self.toolView.frame = self.bounds;
}

-(LiveToolView *)toolView
{
    if (!_toolView) {
        _toolView = [[LiveToolView alloc] initWithFrame:self.bounds];
        [self addSubview:_toolView];
        
        @weakify(self);
        [_toolView toolBarBtnClickWithBlock:^(BtnType type) {
            if (type == PopBack) {
                if (_isFill) {
                    [weak_self fillBack];
                }else{
                    UITabBarController * tab = (id)[[UIApplication sharedApplication].delegate window].rootViewController;
                    UINavigationController * nav = tab.selectedViewController;
                    [nav popViewControllerAnimated:YES];
                }
            }else if (type == More){
                NSLog(@"更多");
            }else if (type == Pause){
                NSLog(@"暂停");
                if ([weak_self.player isPlaying]) {
                    [weak_self.player pause];
                }else{
                    [weak_self.player play];
                }
            }else if (type == AllScreen){
                NSLog(@"全屏");
                if (_isFill) {
                    [weak_self fillBack];
                }else{
                    
                    [weak_self fillScreen];
                }
            }
        }];
    }
    return _toolView;
}

-(void)fillScreen
{
    AppDelegate * dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    dele.isFill = YES;
    dele.isRoll = YES;
    if (_isFill) {
        return;
    }
    [[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait]  forKey:@"orientation"];//这句话是防止手动先把设备置为横屏,导致下面的语句失效.
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    [UIView animateWithDuration:0.5 animations:^{
        UITabBarController * tab = (id)[[UIApplication sharedApplication].delegate window].rootViewController;
        UINavigationController * nav = tab.selectedViewController;
        UIViewController * vc = nav.topViewController;
        self.frame=vc.view.bounds;
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        _isFill = YES;
    }];
}

-(void)fillBack
{
    AppDelegate * dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    dele.isRoll = NO;
    if (!_isFill) {
        return;
    }
    [[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft]  forKey:@"orientation"];//这句话是防止手动先把设备置为横屏,导致下面的语句失效.
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = _minFrame;
        [self layoutSubviews];
    } completion:^(BOOL finished) {
        _isFill = NO;
        dele.isFill = NO;
    }];
}

-(void)dealloc
{
    [self.player stop];
    [self.player shutdown];
}

#pragma Selector func

- (void)loadStateDidChange:(NSNotification*)notification {
    IJKMPMovieLoadState loadState = self.player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"LoadStateDidChange: IJKMovieLoadStatePlayThroughOK: %d\n",(int)loadState);
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackFinish:(NSNotification*)notification {
    int reason =[[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPrepareToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    switch (self.player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)self.player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)self.player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)self.player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)self.player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)self.player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)self.player.playbackState);
            break;
        }
    }
}

#pragma Install Notifiacation

- (void)installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.player];
    
}

- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:self.player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:self.player];
    
}


@end
