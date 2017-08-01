//
//  LiveHeadView.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/24.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveListItem.h"
typedef void (^moreClickBlock) ();
@interface LiveHeadView : UIView

@property (nonatomic,strong) LiveListItem * item;

@property(nonatomic,copy) moreClickBlock moreBlock;
-(void)moreClickWithBlock:(moreClickBlock)block;

@end
