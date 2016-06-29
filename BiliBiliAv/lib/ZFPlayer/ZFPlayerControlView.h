//
//  ZFPlayerControlView.h
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

@interface ZFPlayerControlView : UIView

/** 开始播放按钮 */
@property (weak, nonatomic) IBOutlet UIButton       *startBtn;
/** 当前播放时长label */
@property (weak, nonatomic) IBOutlet UILabel        *currentTimeLabel;
/** 视频总时长label */
@property (weak, nonatomic) IBOutlet UILabel        *totalTimeLabel;
/** 缓冲进度条 */
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
/** 滑杆 */
@property (weak, nonatomic) IBOutlet UISlider       *videoSlider;
/** 全屏按钮 */
@property (weak, nonatomic) IBOutlet UIButton       *fullScreenBtn;

/** 类方法创建 */
+ (instancetype)setupPlayerControlView;
/** 重置ControlView */
- (void)resetControlView;
@end
