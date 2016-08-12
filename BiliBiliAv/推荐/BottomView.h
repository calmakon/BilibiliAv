//
//  BottomView.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/8/11.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopPicModel.h"
typedef void (^bannerClickBlock) (NSString * url);
@interface BottomView : UIView
@property (nonatomic,strong) TopPicModel * banner;
@property(nonatomic,copy) bannerClickBlock block;
-(void)bannerClickWithBlock:(bannerClickBlock)block;
@end
