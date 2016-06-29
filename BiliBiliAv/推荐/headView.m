//
//  headView.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/18.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "headView.h"
#import "UIImageView+YYWebImage.h"
#import "SDCycleScrollView.h"
#import "UIImage+ImageRoundedCorner.h"

static CGFloat const topViewHeight = 120;
@interface headView ()<SDCycleScrollViewDelegate>
@property(nonatomic,strong) SDCycleScrollView *cycleScrollView;
@end

@implementation headView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        if (frame.size.width == 0||frame.size.height == 0) {
            frame.size = CGSizeMake(kScreenWidth, topViewHeight);
        }
    }
    return self;
}

-(void)setPicArray:(NSArray *)picArray
{
    _picArray = picArray;
    if (picArray&&picArray.count>0) {
        NSMutableArray * imageArr = [NSMutableArray array];
        for (int i=0; i<picArray.count; i++) {
            TopPicModel * model = picArray[i];
            [imageArr addObject:model.image?:model.img];
        }
        self.cycleScrollView.imageURLStringsGroup = imageArr;
    }
}

-(SDCycleScrollView *)cycleScrollView
{
    if (!_cycleScrollView) {
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:self.bounds imageURLStringsGroup:nil];
        _cycleScrollView.infiniteLoop = YES;
        _cycleScrollView.delegate = self;
        _cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
        _cycleScrollView.pageControlDotSize = CGSizeMake(5, 5);
        _cycleScrollView.pageControlDotPointY = 5;
        _cycleScrollView.autoScrollTimeInterval = 4;
        UIImage * image1 = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(5, 5)];
        UIImage * image2 = [UIImage imageWithColor:[UIColor colorWithRed:0.81 green:0.32 blue:0.48 alpha:1] size:CGSizeMake(5, 5)];
        _cycleScrollView.dotImage = [image1 imageAddCornerWithRadius:image1.size.width/2 andSize:image1.size];
        _cycleScrollView.currentDotIamge = [image2 imageAddCornerWithRadius:image2.size.width/2 andSize:image2.size];
        _cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
        [self addSubview:_cycleScrollView];
    }
    return _cycleScrollView;
}

-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    
    if (self.webBlock) {
        TopPicModel * model = self.picArray[index];
        self.webBlock(model);
    }
}

-(void)picClickWithBlock:(lunBoClickBlock)block
{
    self.webBlock = block;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
