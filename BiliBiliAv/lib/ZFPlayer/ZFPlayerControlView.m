//
//  ZFPlayerControlView.m
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

#import "ZFPlayerControlView.h"
#import "ZFPlayer.h"

@interface ZFPlayerControlView ()
/** bottom渐变层*/
@property (strong, nonatomic) CAGradientLayer *bottomGradientLayer;
/** top渐变层 */
@property (strong, nonatomic) CAGradientLayer *topGradientLayer;
/** bottomView*/
@property (weak, nonatomic  ) IBOutlet UIImageView     *bottomImageView;
/** topView */
@property (weak, nonatomic  ) IBOutlet UIImageView     *topImageView;

@end

@implementation ZFPlayerControlView

- (void)dealloc
{
    //NSLog(@"%@释放了",self.class);
}

- (void)awakeFromNib
{
    // 设置slider
    [self.videoSlider setThumbImage:[UIImage imageNamed:ZFPlayerSrcName(@"slider")] forState:UIControlStateNormal];
    
    [self insertSubview:self.progressView belowSubview:self.videoSlider];
    self.videoSlider.minimumTrackTintColor = [UIColor clearColor];
    self.videoSlider.maximumTrackTintColor = [UIColor clearColor];

    self.progressView.progressTintColor    = [UIColor colorWithRed:0.86 green:0.40 blue:0.54 alpha:1];
    self.progressView.trackTintColor       = [UIColor grayColor];
    
    // 初始化渐变层
    [self initCAGradientLayer];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bottomGradientLayer.frame = self.bottomImageView.bounds;
    self.topGradientLayer.frame = self.topImageView.bounds;
}

- (void)initCAGradientLayer
{
    //初始化Bottom渐变层
    self.bottomGradientLayer = [CAGradientLayer layer];
    [self.bottomImageView.layer addSublayer:self.bottomGradientLayer];
    //设置渐变颜色方向
    self.bottomGradientLayer.startPoint = CGPointMake(0, 0);
    self.bottomGradientLayer.endPoint   = CGPointMake(0, 1);
    //设定颜色组
    self.bottomGradientLayer.colors     = @[(__bridge id)[UIColor clearColor].CGColor,
                                            (__bridge id)[UIColor blackColor].CGColor];
    //设定颜色分割点
    self.bottomGradientLayer.locations  = @[@(0.0f) ,@(1.0f)];


    //初始Top化渐变层
    self.topGradientLayer               = [CAGradientLayer layer];
    [self.topImageView.layer addSublayer:self.topGradientLayer];
    //设置渐变颜色方向
    self.topGradientLayer.startPoint    = CGPointMake(1, 0);
    self.topGradientLayer.endPoint      = CGPointMake(1, 1);
    //设定颜色组
    self.topGradientLayer.colors        = @[(__bridge id)[UIColor blackColor].CGColor,
                                            (__bridge id)[UIColor clearColor].CGColor];
    //设定颜色分割点
    self.topGradientLayer.locations     = @[@(0.0f) ,@(1.0f)];

}

#pragma mark - Public Method

/** 重置ControlView */
- (void)resetControlView
{
    self.videoSlider.value = 0;
    self.progressView.progress = 0;
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"00:00";
}

/** 类方法创建 */
+ (instancetype)setupPlayerControlView
{
    return [[NSBundle mainBundle] loadNibNamed:@"ZFPlayerControlView" owner:nil options:nil].lastObject;
}

@end
