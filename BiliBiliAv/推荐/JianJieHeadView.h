//
//  JianJieHeadView.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/3/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JianJieLayout.h"
#import "AvDetailModel.h"
#import "YYLabel.h"
#import "YYAnimatedImageView.h"
#import "WebViewController.h"
@class Stat;
@interface menuView : UIView
@property (nonatomic,strong) UIButton * shareBtn;
@property (nonatomic,strong) UIButton * cionBtn;
@property (nonatomic,strong) UIButton * saveBtn;
@property (nonatomic,strong) UIButton * cacheBtn;
@property (nonatomic,strong) Stat * stat;
@end

typedef void(^pageClickBlock)(NSString * cid);
@class Page;
@interface pageView : UIView
@property (nonatomic,strong) UIButton * inputBtn;
@property (nonatomic,strong) UILabel * pageLabel;
@property (nonatomic,strong) UIScrollView * contentView;
@property (nonatomic,strong) JianJieLayout * layout;
@property (nonatomic,copy) pageClickBlock pageBlock;
-(void)pageSelectWithBlock:(pageClickBlock)block;
@end

@class Owner,AvDetailModel;
@interface upInfoView : UIView
@property (nonatomic,strong) YYAnimatedImageView * iconImageView;
@property (nonatomic,strong) UILabel * nameLable;
@property (nonatomic,strong) UILabel * upDateLabel;
@property (nonatomic,strong) UIButton * attractBtn;
@property (nonatomic,strong) JianJieLayout * layout;
@end

@interface aboutAvView : UIView
@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic,strong) JianJieLayout * layout;
@end


@class menuView,pageView,upInfoView,aboutAvView;
@interface JianJieHeadView : UIView
@property (nonatomic,strong) YYLabel * titleLabel;
@property (nonatomic,strong) YYLabel * playAndDanmuLabel;
@property (nonatomic,strong) YYLabel * contentLabel;
@property (nonatomic,strong) menuView * menuV;
@property (nonatomic,strong) pageView * pageV;
@property (nonatomic,strong) upInfoView * upView;
@property (nonatomic,strong) aboutAvView * aboutView;
@property (nonatomic,strong) JianJieLayout * layout;

@end
