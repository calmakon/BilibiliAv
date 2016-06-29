//
//  headView.h
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/18.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopPicModel.h"
typedef void (^lunBoClickBlock)(TopPicModel * topPic);
@interface headView : UIView
@property(nonatomic,copy) NSArray * picArray;
@property (nonatomic,copy) lunBoClickBlock webBlock;
-(void)picClickWithBlock:(lunBoClickBlock)block;
@end
