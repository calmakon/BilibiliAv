//
//  LiveBannerCell.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/30.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveItem.h"
typedef void (^bannerClickBlock)(LiveItem *item);
@interface LiveBannerCell : UITableViewCell
@property (nonatomic,strong) LiveItem * liveData;
@property (nonatomic,copy) bannerClickBlock clickBlock;
-(void)bannerClickWithBlock:(bannerClickBlock)block;
@end
