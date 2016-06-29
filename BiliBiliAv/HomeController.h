//
//  HomeController.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/10.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLTabedSlideView.h"
@interface HomeController : UIViewController<DLTabedSlideViewDelegate>
@property (nonatomic,strong) DLTabedSlideView * tabSlideView;
@end
