//
//  TvView.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVModel.h"
#import "UIImageView+YYWebImage.h"

@interface TvView : UIView
@property(nonatomic,strong) UIImageView * imageView;
@property(nonatomic,strong) UILabel * titleLabel;
@property(nonatomic,strong) UILabel * upDateTvLabel;
@property(nonatomic,strong) AVModelBody * dataBody;
@end
