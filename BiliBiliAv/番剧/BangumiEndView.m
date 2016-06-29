//
//  BangumiEndView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiEndView.h"

@implementation BangumiEndView

-(void)setEndBody:(BangumiBody *)endBody
{
    if (endBody) {
        [self.imageView setImageWithURL:[NSURL URLWithString:endBody.cover] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } transform:^UIImage *(UIImage *image, NSURL *url) {
            return [image imageByRoundCornerRadius:5];
        } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
            
        }];
        self.titleLabel.text = endBody.title;
        self.upDateTvLabel.text = [NSString stringWithFormat:@"%@话全",endBody.total_count];
    }
}


@end
