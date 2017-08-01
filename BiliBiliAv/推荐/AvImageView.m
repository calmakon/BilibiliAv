//
//  AvImageView.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/3.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "AvImageView.h"
#import "YYAnimatedImageView.h"
#import "BliBiliTabBarController.h"
#import "AvDetailController.h"

//#import "UpdateTimeConfig.h"

@interface AvImageView ()<UIViewControllerPreviewingDelegate>
//正在直播
@property(nonatomic,strong) YYAnimatedImageView * liveIconImageView;
@property(nonatomic,strong) UILabel * liveAudienceNumLabel;
@property(nonatomic,strong) UILabel * liveUpContentLabel;
@property (nonatomic,strong) UIViewController * topViewController;
@property (nonatomic,strong) UIButton * refreshBtn;
@end


@implementation AvImageView

-(UIViewController *)topViewController
{
    if (!_topViewController) {
        BliBiliTabBarController * tabbsr = (id)[[UIApplication sharedApplication].delegate window].rootViewController;
        UINavigationController * nav = tabbsr.selectedViewController;
        _topViewController = nav.topViewController;
    }
    return _topViewController;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kBgColor;
    }
    return self;
}

-(void)setIsOpen3DTouch:(BOOL)isOpen3DTouch
{
    if (!isOpen3DTouch) return;
    //3DTouch相关
    [self.topViewController registerForPreviewingWithDelegate:self sourceView:self];
}

-(void)setIsLast:(BOOL)isLast
{
    _isLast = isLast;
    if (isLast) {
        [self refreshBtn];
        if ((self.dataBody.goTo && [self.dataBody.goTo isEqualToString:@"live"])||self.liveData) {
            self.liveTitleLabel.size = CGSizeMake(self.imageView.width-self.refreshBtn.width+5, 30);
        }
        else{
           self.avTitleLabel.size = CGSizeMake(self.imageView.width-self.refreshBtn.width+5, 30);
        }
    }
}

-(void)setDataBody:(AVModelBody *)dataBody
{
    _dataBody = dataBody;
    if (dataBody) {
//        self.imageView.frame = CGRectMake(0, 0, self.width, self.width*0.6);
//        self.shadowBgView.frame = CGRectMake(0, self.imageView.bottom-40, self.imageView.width, 40);
        //NSLog(@"类型 == %@",dataBody.style);
        __weak typeof(self) weakSelf = self;
        [self.imageView setImageWithURL:[NSURL URLWithString:dataBody.cover?:dataBody.pic] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } transform:^UIImage *(UIImage *image, NSURL *url) {
            return [image imageAddCornerWithRadius:6 andSize:CGSizeMake(weakSelf.imageView.width, weakSelf.imageView.height)];
        } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
            
        }];
        if (dataBody.goTo && [dataBody.goTo isEqualToString:@"live"]) {
            //正在直播
            self.LiveOwnerNameLabel.text = dataBody.up?:dataBody.name;
            self.LiveOwnerNameLabel.frame = CGRectMake(5, self.imageView.bottom-20, stringWidth(dataBody.up?:dataBody.name, 12), 15);
            
            CGFloat onLineWidth = stringWidth(dataBody.online, 10);
            self.liveTipImageView.frame = CGRectMake(self.imageView.width-onLineWidth-5-15, 0, 15, 13);
            self.liveTipImageView.centerY = self.LiveOwnerNameLabel.centerY;
            
            self.seeingCountLabel.text = dataBody.online;
            self.seeingCountLabel.frame = CGRectMake(self.liveTipImageView.right+2, self.liveTipImageView.top, onLineWidth, 18);
            self.seeingCountLabel.centerY = self.LiveOwnerNameLabel.centerY;
            
            NSString * text = [NSString stringWithFormat:@"#%@# %@",dataBody.area,dataBody.title];
            self.liveTitleLabel.attributedText = [ImageText _textWithTextString:text fontSize:12 textColor:[UIColor colorWithHexString:TextColor]];
            
            CGSize size = stringSize(text, self.width, 12);
            CGFloat labelHeight = size.height;
            if (size.height>30) {
                labelHeight = 30;
            }
            self.liveTitleLabel.frame = CGRectMake(5, self.imageView.bottom+3, self.imageView.width-10, labelHeight);

        }else if (dataBody.goTo && [dataBody.goTo isEqualToString:@"bangumi"]){
            //新番推荐
            self.avTitleLabel.text = dataBody.title;
            CGSize size = stringSize(dataBody.title, self.width, 12);
            self.avTitleLabel.frame = CGRectMake(5, self.imageView.bottom+3, self.imageView.width-10, size.height);
            self.avDateLabel.text = dataBody.desc1;
            self.avDateLabel.frame = CGRectMake(5, self.avTitleLabel.bottom+5, stringWidth(dataBody.desc1, 12), 15);
        }else{
            if ([dataBody.goTo isEqualToString:@"av"]) {
                //各个分区
                self.avTitleLabel.text = dataBody.title;
                
                CGSize size = stringSize(dataBody.title, self.width, 12);
                CGFloat labelHeight = size.height;
                if (size.height>30) {
                    labelHeight = 30;
                }
                self.avTitleLabel.frame = CGRectMake(5, self.imageView.bottom+3, self.imageView.width-10, labelHeight);
                self.playImageView.frame = CGRectMake(5, self.imageView.bottom-15, 12, 10);

                self.playNumLabel.frame = CGRectMake(self.playImageView.right+3, self.playImageView.top, [dataBody.play widthForFont:self.playNumLabel.font], self.playImageView.height);
                self.playNumLabel.text = dataBody.play;
                
                self.danmukuImageView.frame = CGRectMake(self.imageView.width/2, self.playImageView.top, 12, 10);
                self.danmukuNumLabel.frame = CGRectMake(self.danmukuImageView.right+3, self.danmukuImageView.top, [dataBody.danmaku?:dataBody.video_review widthForFont:self.danmukuNumLabel.font], self.danmukuImageView.height);
                self.danmukuNumLabel.text = dataBody.danmaku?:dataBody.video_review;
            }
        }
    }
}

-(void)setIsHot:(BOOL)isHot
{
    _isHot = isHot;
}

-(void)setLiveData:(LiveItem *)liveData
{
    if (!liveData) return;
    _liveData = liveData;
    __weak typeof(self) weakSelf = self;
    [self.imageView setImageWithURL:[NSURL URLWithString:liveData.cover.src] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } transform:^UIImage *(UIImage *image, NSURL *url) {
        return [image imageAddCornerWithRadius:10 andSize:CGSizeMake(weakSelf.imageView.width, weakSelf.imageView.height)];
    } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        
    }];
    
    self.LiveOwnerNameLabel.text = liveData.owner.name;
    self.LiveOwnerNameLabel.frame = CGRectMake(5, self.imageView.bottom-20, stringWidth(liveData.owner.name, 12), 15);
    
    CGFloat onLineWidth = stringWidth(liveData.online, 10);
    self.liveTipImageView.frame = CGRectMake(self.imageView.width-onLineWidth-5-15, 0, 15, 13);
    self.liveTipImageView.centerY = self.LiveOwnerNameLabel.centerY;
    
    self.seeingCountLabel.text = liveData.online;
    self.seeingCountLabel.frame = CGRectMake(self.liveTipImageView.right+2, self.liveTipImageView.top, onLineWidth, 18);
    self.seeingCountLabel.centerY = self.LiveOwnerNameLabel.centerY;
    
    NSString * text;
    if (self.isHot) {
        text = [NSString stringWithFormat:@"#%@# %@",liveData.area,liveData.title];
    }else{
        text = liveData.title;
    }
    //NSLog(@"标题 == %@",text);
    self.liveTitleLabel.attributedText = [ImageText _textWithTextString:text fontSize:12 textColor:[UIColor colorWithHexString:TextColor]];
    
    CGFloat labelHeight = 30;
    self.liveTitleLabel.frame = CGRectMake(5, self.imageView.bottom+3, self.imageView.width-10, labelHeight);
    self.height = self.liveTitleLabel.bottom+10;
}

#pragma mark -3DTouchDelegate
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    //3DTouch相关
    AvDetailController * detail = [[AvDetailController alloc] init];
    previewingContext.sourceRect = self.bounds;
    detail.aid = self.dataBody.param?:self.dataBody.aid;
    return detail;
}

- (void)previewingContext:(id)previewingContext commitViewController:(UIViewController *)viewControllerToCommit

{
    //3DTouch相关
    viewControllerToCommit.view.backgroundColor = [UIColor whiteColor];
    
    [self.topViewController showViewController:viewControllerToCommit sender:self.topViewController];
}


-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.frame = CGRectMake(0, 0, self.width, self.width*0.6);
        self.shadowBgView.frame = CGRectMake(0, _imageView.bottom-40, _imageView.width, 40);
        [self addSubview:_imageView];
    }
    return _imageView;
}

-(UILabel *)avTitleLabel
{
    if (!_avTitleLabel) {
        _avTitleLabel = [UILabel new];
        _avTitleLabel.backgroundColor = kBgColor;
        _avTitleLabel.textColor = [UIColor colorWithHexString:TextColor];
        _avTitleLabel.numberOfLines = 2;
        _avTitleLabel.textAlignment = NSTextAlignmentLeft;
        _avTitleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_avTitleLabel];
    }
    return _avTitleLabel;
}

-(UIImageView *)shadowBgView
{
    if (!_shadowBgView) {
        _shadowBgView = [UIImageView new];
        _shadowBgView.image = [[UIImage imageNamed:@"shadow_1_40_gradual_line"]imageAddCornerWithRadius:6 andSize:CGSizeMake(self.imageView.width, 40)];
        [self.imageView addSubview:_shadowBgView];
    }
    return _shadowBgView;
}

-(UIImageView *)playImageView
{
    if (!_playImageView) {
        _playImageView = [UIImageView new];
        _playImageView.image = [UIImage imageNamed:@"misc_playCount_new"];
        [self.imageView addSubview:_playImageView];
    }
    return _playImageView;
}

-(UILabel *)playNumLabel
{
    if (!_playNumLabel) {
        _playNumLabel = [UILabel new];
        //_playNumLabel.backgroundColor = [UIColor whiteColor];
        _playNumLabel.textAlignment = NSTextAlignmentLeft;
        _playNumLabel.font = [UIFont systemFontOfSize:10];
        _playNumLabel.textColor = [UIColor whiteColor];
        [self.imageView addSubview:_playNumLabel];
    }
    return _playNumLabel;
}

-(UIImageView *)danmukuImageView
{
    if (!_danmukuImageView) {
        _danmukuImageView = [UIImageView new];
        _danmukuImageView.image = [UIImage imageNamed:@"misc_danmakuCount_new"];
        [self.imageView addSubview:_danmukuImageView];
    }
    return _danmukuImageView;
}

-(UILabel *)danmukuNumLabel
{
    if (!_danmukuNumLabel) {
        _danmukuNumLabel = [UILabel new];
        _danmukuNumLabel.textAlignment = NSTextAlignmentLeft;
        //_danmukuNumLabel.backgroundColor = [UIColor whiteColor];
        _danmukuNumLabel.font = [UIFont systemFontOfSize:10];
        _danmukuNumLabel.textColor = [UIColor whiteColor];
        [self.imageView addSubview:_danmukuNumLabel];
    }
    return _danmukuNumLabel;
}

-(UILabel *)LiveOwnerNameLabel
{
    if (!_LiveOwnerNameLabel) {
        _LiveOwnerNameLabel = [UILabel new];
        _LiveOwnerNameLabel.textAlignment = NSTextAlignmentLeft;
        _LiveOwnerNameLabel.font = [UIFont systemFontOfSize:10];
        _LiveOwnerNameLabel.textColor = [UIColor whiteColor];
        [self.imageView addSubview:_LiveOwnerNameLabel];
    }
    return _LiveOwnerNameLabel;
}

-(UIImageView *)liveTipImageView
{
    if (!_liveTipImageView) {
        _liveTipImageView = [UIImageView new];
        _liveTipImageView.image = [UIImage imageNamed:@"live_online_ico@2x"];
        [self.imageView addSubview:_liveTipImageView];
    }
    return _liveTipImageView;
}

-(YYLabel *)liveTitleLabel
{
    if (!_liveTitleLabel) {
        _liveTitleLabel = [YYLabel new];
        _liveTitleLabel.textColor = [UIColor colorWithHexString:TextColor];
        _liveTitleLabel.numberOfLines = 2;
        _liveTitleLabel.textAlignment = NSTextAlignmentLeft;
        _liveTitleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_liveTitleLabel];
    }
    return _liveTitleLabel;
}


//-(UIImageView *)liveIconImageView
//{
//    if (!_liveIconImageView) {
//        _liveIconImageView = [YYAnimatedImageView new];
//        _liveIconImageView.size = CGSizeMake(35, 35);
//        _liveIconImageView.layer.cornerRadius = _liveIconImageView.width/2;
//        _liveIconImageView.layer.masksToBounds = YES;
//        _liveIconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
//        _liveIconImageView.layer.borderWidth = 1;
//        [self addSubview:_liveIconImageView];
//    }
//    return _liveIconImageView;
//}

-(UILabel *)seeingCountLabel
{
    if (!_seeingCountLabel) {
        _seeingCountLabel = [UILabel new];
        _seeingCountLabel.textAlignment = NSTextAlignmentLeft;
        _seeingCountLabel.font = [UIFont systemFontOfSize:10];
        _seeingCountLabel.textColor = [UIColor whiteColor];
        [self.imageView addSubview:_seeingCountLabel];
    }
    return _seeingCountLabel;
}

//-(UILabel *)liveUpContentLabel
//{
//    if (!_liveUpContentLabel) {
//        _liveUpContentLabel = [UILabel new];
//        _liveUpContentLabel.textColor = [UIColor lightGrayColor];
//        _liveUpContentLabel.backgroundColor = [UIColor whiteColor];
//        _liveUpContentLabel.font = [UIFont systemFontOfSize:12];
//        _liveUpContentLabel.textAlignment = NSTextAlignmentLeft;
//        [self addSubview:_liveUpContentLabel];
//    }
//    return _liveUpContentLabel;
//}

-(UILabel *)avDateLabel
{
    if (!_avDateLabel) {
        _avDateLabel = [UILabel new];
        _avDateLabel.backgroundColor = kBgColor;
        _avDateLabel.textColor = [UIColor lightGrayColor];
        _avDateLabel.font = [UIFont systemFontOfSize:12];
        _avDateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_avDateLabel];
    }
    return _avDateLabel;
}

-(UIButton *)refreshBtn
{
    if (!_refreshBtn) {
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshBtn.top = self.imageView.bottom-15;
        _refreshBtn.size = CGSizeMake(60, 60);
        _refreshBtn.left = self.width-_refreshBtn.width+5;
        [_refreshBtn setTitleColor:[UIColor colorWithHexString:TextColor] forState:UIControlStateNormal];
        [_refreshBtn setImage:[UIImage imageNamed:@"home_refresh_new"] forState:UIControlStateNormal];
        [self addSubview:_refreshBtn];
        
        [_refreshBtn addTarget:self action:@selector(refreshBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

-(void)refreshBtnClick
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.refresh) {
            self.refresh();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self animaiton];
        });
    });
}

-(void)animaiton
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 0.5;
    rotationAnimation.repeatCount = INT_MAX;
    self.refreshBtn.imageView.layer.drawsAsynchronously = YES;
    [self.refreshBtn.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


-(void)refreshCurrentCellWithBlock:(refreshBlock)blcok
{
    self.refresh = blcok;
}


@end
