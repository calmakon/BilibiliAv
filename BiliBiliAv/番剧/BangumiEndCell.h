//
//  BangumiEndCell.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/12.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BangumiBody.h"
typedef void (^ItemClickBlock)(BangumiBody *body);
@interface BangumiEndCell : UITableViewCell
@property(nonatomic,copy) NSArray * endBodys;
@property (nonatomic,copy) ItemClickBlock itemBlock;
-(void)itemClickWithBlock:(ItemClickBlock)block;
@end
