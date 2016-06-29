//
//  ReplyCell.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/5.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplyListModel.h"
#import "ReplyLayout.h"
@interface ReplyCell : UITableViewCell

@property (nonatomic,strong) ReplyLayout * replyLayout;
-(void)hiddeTopLine;
-(void)showTopLine;
@end

@interface moreHotView : UIView


@end

