//
//  WebLinkCell.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/4.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuiJianList.h"
#import "AVModel.h"
typedef void (^cellClickBlock) (AVModelBody * body);
@interface WebLinkCell : UITableViewCell
@property(nonatomic,copy) NSArray * bodys;
@property(nonatomic,copy) cellClickBlock block;
-(void)cellClickWithBlock:(cellClickBlock)block;
@end
