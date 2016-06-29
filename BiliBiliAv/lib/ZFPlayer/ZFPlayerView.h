//
//  ZFPlayerView.h
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

#import <UIKit/UIKit.h>
#import "DanMuKuModel.h"
#import "NSAttributedString+YYText.h"
typedef void(^ZFPlayerGoBackBlock)(void);

@interface ZFPlayerView : UIView

/** 视频URL */
@property (nonatomic, strong) NSURL               *videoURL;
/** 返回按钮Block */
@property (nonatomic, copy  ) ZFPlayerGoBackBlock goBackBlock;

/** ViewController中页面是否消失 */
@property (nonatomic, assign) BOOL                viewDisappear;
@property (nonatomic, assign) CGRect rFrame;

/**
 *  取消延时隐藏controlView的方法,在ViewController的delloc方法中调用
 *  用于解决：刚打开视频播放器，就关闭该页面，maskView的延时隐藏还未执行。
 */
- (void)cancelAutoFadeOutControlBar;

/**
 *  重置player
 */
- (void)resetPlayer;
/*
 不移除播放器的情况下重置player
 */
- (void)resetPlayerCopy;
/** 
 *  播放
 */
- (void)play;
/** 
  * 暂停 
 */
- (void)pause;

-(void)setupDanmuku:(DanMuKuModel *)danmukuModel;
@property (nonatomic,copy) NSString * loadingStatus;
@property (nonatomic,assign) BOOL isBangumiAv;
@end
