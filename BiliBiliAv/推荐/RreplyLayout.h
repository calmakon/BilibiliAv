//
//  RreplyLayout.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/6.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYTextLayout.h"
#import "ReplyListModel.h"
#import "JianJieLayout.h"
@interface RreplyLayout : NSObject
-(instancetype)initWithDetail:(ReplyListModel *)data;
-(void)layout;
@property (nonatomic,strong) ReplyListModel * data;
@property (nonatomic,assign) CGFloat topMargin;
@property (nonatomic,assign) CGFloat leftPadding;

@property (nonatomic,strong) YYTextLayout * contentLayout;
@property (nonatomic,assign) CGFloat contentHeight;
@property (nonatomic,assign) CGFloat nameHeight;
@property (nonatomic,assign) CGFloat height;
@end
