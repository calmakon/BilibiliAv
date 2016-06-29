//
//  JianJieLayout.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/3/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvDetailModel.h"
#import "YYTextLayout.h"

@class YYTextLayout,AvDetailModel,Owner,Stat;
@interface JianJieLayout : NSObject
-(instancetype)initWithDetail:(AvDetailModel *)detail;
-(void)layout;
@property (nonatomic,strong) AvDetailModel * detail;
@property (nonatomic,assign) CGFloat topMargin;
@property (nonatomic,assign) CGFloat titleInfoHeight;
@property (nonatomic,strong) YYTextLayout * titleLayout;
@property (nonatomic,strong) YYTextLayout * playAndDanmuLayout;
@property (nonatomic,assign) CGFloat playAndDanmuHeight;
@property (nonatomic,assign) CGFloat contentHeight;
@property (nonatomic,assign) BOOL isFold;
@property (nonatomic,assign) CGFloat contentFoldHeight;
@property (nonatomic,strong) YYTextLayout * contentLayout;

@property (nonatomic,assign) CGFloat menuViewHeight;
@property (nonatomic,strong) Stat * stat;

@property (nonatomic,assign) CGFloat pageViewHeight;
@property (nonatomic,copy) NSArray * pages;

@property (nonatomic,assign) CGFloat uperInfoHeight;
@property (nonatomic,strong) Owner * owner;
@property (nonatomic,strong) NSString * upDate;

@property (nonatomic,assign) CGFloat aboutAvHeight;
@property (nonatomic,assign) CGFloat tipPading;
@property (nonatomic,assign) CGFloat tipOneHeight;
@property (nonatomic,assign) CGFloat tipViewHeight;
@property (nonatomic,copy) NSArray * tagLayouts;
@property (nonatomic,assign) CGFloat height;
@end
/**
 文本 Line 位置修改
 将每行文本的高度和位置固定下来，不受中英文/Emoji字体的 ascent/descent 影响
 */
@interface AvTextLinePositionModifier : NSObject <YYTextLinePositionModifier>
@property (nonatomic, strong) UIFont *font; // 基准字体 (例如 Heiti SC/PingFang SC)
@property (nonatomic, assign) CGFloat paddingTop; //文本顶部留白
@property (nonatomic, assign) CGFloat paddingBottom; //文本底部留白
@property (nonatomic, assign) CGFloat lineHeightMultiple; //行距倍数
- (CGFloat)heightForLineCount:(NSUInteger)lineCount;
@end
