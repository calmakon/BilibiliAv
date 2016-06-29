//
//  BangumiImageView.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "BangumiImageView.h"
#import "UpdateTimeConfig.h"

@interface BangumiImageView ()

@end

@implementation BangumiImageView

-(void)setBangumiBody:(BangumiBody *)bangumiBody
{
    if (bangumiBody) {
        self.imageView.frame = CGRectMake(0, 0, self.width, self.width*0.6);
        __weak typeof(self) weakSelf = self;
        [self.imageView setImageWithURL:[NSURL URLWithString:bangumiBody.cover] placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } transform:^UIImage *(UIImage *image, NSURL *url) {
            return [image imageAddCornerWithRadius:10 andSize:CGSizeMake(weakSelf.imageView.width, weakSelf.imageView.height)];
        } completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
            
        }];
        //新番推荐
        self.avTitleLabel.text = bangumiBody.title;
        CGSize size = stringSize(bangumiBody.title, self.width, 12);
        self.avTitleLabel.frame = CGRectMake(5, self.imageView.bottom+3, self.imageView.width-10, size.height);
        BOOL isToDay = [UpdateTimeConfig isToDay:bangumiBody.last_time];
        if (isToDay) {
            self.avDateLabel.textColor = kStyleColor;
        }
        self.avDateLabel.text = [NSString stringWithFormat:@"%@  ·  第%@话",[UpdateTimeConfig returnConfigTimeWithCursor:bangumiBody.last_time],bangumiBody.newest_ep_index];
        self.avDateLabel.frame = CGRectMake(5, self.avTitleLabel.bottom+5, stringWidth(self.avDateLabel.text, 12), 15);
    }
}


@end
