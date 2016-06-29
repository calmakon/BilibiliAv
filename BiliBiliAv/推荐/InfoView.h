//
//  InfoView.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/24.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvDetailModel.h"
#import "ReplyList.h"
#import "ReplyListModel.h"
typedef void (^replyCellClickBlock)(ReplyListModel * data);
typedef void (^reSetAvPlayerBlock)(RelateModel *relate);
typedef void (^pageSeleBlock)(NSString *cid);
@interface InfoView : UIView
@property (nonatomic,strong) AvDetailModel * detail;
@property (nonatomic,strong) ReplyList * replyList;
@property(nonatomic,strong,readonly) UITableView * conmmentTableView;
@property (nonatomic,copy) replyCellClickBlock replyBlock;
-(void) seleWithBlock:(replyCellClickBlock)block;
@property (nonatomic,copy) reSetAvPlayerBlock reSetBlock;
-(void) reSetAvPlayerWithBlock:(reSetAvPlayerBlock)block;
@property (nonatomic,copy) pageSeleBlock pageBlock;
-(void) pageSelectWithBlock:(pageSeleBlock)block;
@end
