//
//  LiveCell.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/11/24.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveItem.h"
#import "LiveListItem.h"
#import "AvImageView.h"

typedef void (^LiveClickBlock)(LiveItem *item);
typedef void(^refreshLiveDataBlock)();
@interface LiveCell : UITableViewCell
@property (nonatomic,strong) LiveItem * leftItem;
@property (nonatomic,strong) LiveItem * rightItem;
@property (nonatomic,strong) LiveListItem * listData;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) BOOL isHot;

@property (nonatomic,copy) LiveClickBlock clickBlock;
-(void)liveItemClickWithBlock:(LiveClickBlock)block;
@property (nonatomic,copy) refreshLiveDataBlock refreshBlock;
-(void)refreshLiveDataWithBlock:(refreshLiveDataBlock)block;
@end
