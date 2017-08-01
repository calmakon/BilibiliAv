//
//  LiveToolView.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 2016/12/2.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,BtnType){
    PopBack,
    More,
    Pause,
    AllScreen
};
typedef void (^ToolBarClickBlock)(BtnType type);
@interface LiveToolView : UIView
-(void)showBarView;
@property (nonatomic,copy) ToolBarClickBlock clickBlock;
-(void)toolBarBtnClickWithBlock:(ToolBarClickBlock)block;
@end
