//
//  TuiJianList.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/2/19.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "TuiJianList.h"
#import "NSAttributedString+YYText.h"
#import "YYTextRunDelegate.h"
static CGFloat const kPaddingHeight = 10;//通用控件之间间隔
static CGFloat const kCellPaddingHeight = 8;//cell之间间隔
static CGFloat const kTitleImagePaddingHeight = 3;//视频图片和标题之间间隔
static CGFloat const kBangumiBtnHeight = 40;//番剧推荐底部按钮高度
static CGFloat const kMoreBtnHeight = 34;//视频图片和标题之间间隔
static CGFloat const kTitleHeight = 30;//标题高度
static CGFloat const kImagePlayNumPaddingHeight = 5;//标题和播放量label间隔
static CGFloat const kTopPicViweHeight = 168;//话题View高度
static CGFloat const kRankCellHeight = 120;//排行cell高度
static CGFloat const kTitleViewHeight = 40;//各版块标题view的高度
static CGFloat const kAvListImageHeightScole = 0.6;//视频图片的宽高比
static CGFloat const kTvListImageHeightScole = 1.4;//电视剧图片宽高比

@implementation TuiJianList
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"body" : [AVModelBody class]};
}

-(NSString *)tipImageName
{
    NSString * name;
    if ([self.type isEqualToString:@"recommend"]) {
        name = @"home_recommend@2x";
    }else if ([self.type isEqualToString:@"live"]){
        name = @"home_region_icon_71";
    }else if ([self.type isEqualToString:@"bangumi_2"]){
        //饭局推荐
        name = @"home_region_icon_13@2x";
    }else if ([self.type isEqualToString:@"weblink"]){
        //话题
        name = @"home_region_icon_51@2x";
    }else if ([self.type isEqualToString:@"region"]){
        if ([self.head.title isEqualToString:@"动画区"]) {
            name = @"home_region_icon_1@2x";
        }else if ([self.head.title isEqualToString:@"音乐区"]){
            name = @"home_region_icon_3@2x";
        }else if ([self.head.title isEqualToString:@"舞蹈区"]){
            name = @"home_region_icon_129@2x";
        }else if ([self.head.title isEqualToString:@"游戏区"]){
            name = @"home_region_icon_4@2x";
        }else if ([self.head.title isEqualToString:@"鬼畜区"]){
            name = @"home_region_icon_119@2x";
        }else if ([self.head.title isEqualToString:@"科技区"]){
            name = @"home_region_icon_36@2x";
        }else if ([self.head.title isEqualToString:@"娱乐区"]){
            name = @"home_region_icon_5@2x";
        }else if ([self.head.title isEqualToString:@"电影区"]){
            name = @"home_region_icon_23@2x";
        }else if ([self.head.title isEqualToString:@"时尚区"]){
            name = @"home_region_icon_154@2x";
        }
    }else{
        name = @"home_region_icon_11@2x";
    }
    return name;
}

-(YYTextLayout *)gotoInfoText
{
    YYTextLayout * textLayout;
    NSMutableAttributedString * text;
    if ([self.type isEqualToString:@"recommend"]) {
        text = [NSMutableAttributedString new];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:nil]];
        UIImage *image = [UIImage imageNamed:@"home_rank@2x"];
        NSAttributedString *imageText = [self _attachmentWithFontSize:14 image:image shrink:NO];
        [text appendAttributedString:imageText];
        [text appendString:@"  "];
        NSMutableAttributedString * textRank = [[NSMutableAttributedString alloc] initWithString:@"排行榜"];
        textRank.color = [UIColor colorWithRed:0.81 green:0.32 blue:0.48 alpha:1];
        textRank.font = [UIFont systemFontOfSize:14];
        [text appendAttributedString:textRank];
        
    }else if ([self.type isEqualToString:@"live"]){
        text = [[NSMutableAttributedString alloc] initWithString:@"当前个直播，进去看看"];
        text.font = [UIFont systemFontOfSize:14];
        text.color = [UIColor lightGrayColor];
        [text insertString:self.head.count atIndex:2];
        [text setColor:[UIColor colorWithRed:0.95 green:0.59 blue:0.71 alpha:1] range:NSMakeRange(2, self.head.count.length)];
    }else if ([self.type isEqualToString:@"bangumi_2"]){
        //番剧推荐
        text = [[NSMutableAttributedString alloc] initWithString:@"查看所有番剧"];
        text.font = [UIFont systemFontOfSize:14];
        text.color = [UIColor lightGrayColor];
    }else{
        text = [[NSMutableAttributedString alloc] initWithString:@"进去看看"];
        text.font = [UIFont systemFontOfSize:14];
        text.color = [UIColor lightGrayColor];
    }
    text.alignment = NSTextAlignmentRight;
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kScreenWidth-150, 9999)];
    container.maximumNumberOfRows = 1;
    textLayout = [YYTextLayout layoutWithContainer:container text:text];
    return textLayout;
}

- (NSAttributedString *)_attachmentWithFontSize:(CGFloat)fontSize image:(UIImage *)image shrink:(BOOL)shrink {
    // Heiti SC 字体。。
    CGFloat ascent = fontSize * 0.86;
    CGFloat descent = fontSize * 0.14;
    CGRect bounding = CGRectMake(0, -0.14 * fontSize, fontSize, fontSize);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), 0, descent + bounding.origin.y, 0);
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width;
    
    YYTextAttachment *attachment = [YYTextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = contentInsets;
    attachment.content = image;
    
    if (shrink) {
        // 缩小~
        CGFloat scale = 1 / 10.0;
        contentInsets.top += fontSize * scale;
        contentInsets.bottom += fontSize * scale;
        contentInsets.left += fontSize * scale;
        contentInsets.right += fontSize * scale;
        contentInsets = UIEdgeInsetPixelFloor(contentInsets);
        attachment.contentInsets = contentInsets;
    }
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:YYTextAttachmentToken];
    [atr setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
    [atr setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);
    
    return atr;
}


-(NSString *)typeName
{
    NSString * name;
    if ([self.type isEqualToString:@"live"]){
        name = @"直播";
    }else if ([self.type isEqualToString:@"region"]){
        if ([self.head.title isEqualToString:@"动画区"]) {
            name = @"动画";
        }else if ([self.head.title isEqualToString:@"音乐区"]){
            name = @"音乐";
        }else if ([self.head.title isEqualToString:@"舞蹈区"]){
            name = @"舞蹈";
        }else if ([self.head.title isEqualToString:@"游戏区"]){
            name = @"游戏";
        }else if ([self.head.title isEqualToString:@"鬼畜区"]){
            name = @"鬼畜";
        }else if ([self.head.title isEqualToString:@"科技区"]){
            name = @"科技";
        }else if ([self.head.title isEqualToString:@"娱乐区"]){
            name = @"娱乐";
        }else if ([self.head.title isEqualToString:@"电影区"]){
            name = @"电影";
        }else if ([self.head.title isEqualToString:@"时尚区"]){
            name = @"时尚";
        }
    }
    return name;
}

-(CGFloat)cellHeight
{
    CGFloat width = (kScreenWidth-(kPaddingHeight*3))/2;
    CGFloat height = width*kAvListImageHeightScole+kTitleHeight+kTitleImagePaddingHeight+kImagePlayNumPaddingHeight+kPaddingHeight;
    if ([self.type isEqualToString:@"bangumi_2"]||[self.type isEqualToString:@"weblink"]||[self.type isEqualToString:@"bangumi_3"]||!self.type) {
        if ([self.type isEqualToString:@"bangumi_2"]) {
            return kTitleViewHeight+height*2+kPaddingHeight*2+kBangumiBtnHeight+20+kCellPaddingHeight;
        }else if ([self.type isEqualToString:@"weblink"]){
            return kTopPicViweHeight+kCellPaddingHeight;
        }else if ([self.type isEqualToString:@"bangumi_3"]){
            CGFloat width = (kScreenWidth-30)/2.5;
            CGFloat height = width*kTvListImageHeightScole;
            return height+kTitleViewHeight+40+kPaddingHeight+kCellPaddingHeight;
        }else{
            return kRankCellHeight;
        }
    }else{
        return kTitleViewHeight+height*2+kPaddingHeight*2+kMoreBtnHeight+kPaddingHeight+kCellPaddingHeight;
    }
}
@end
