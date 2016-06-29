//
//  WJSegmentMenu.h
//  WJSegmentMenu
//
//  Created by 吴计强 on 16/3/22.
//  Copyright © 2016年 com.firsttruck. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WJSegmentMenuDelegate <NSObject>

@optional

- (void)segmentWithIndex:(NSInteger)index title:(NSString *)title;

@end

@interface WJSegmentMenu : UIView

@property (nonatomic,weak) id<WJSegmentMenuDelegate>delegate;
@property(nonatomic,assign) CGFloat scole;
- (void)segmentWithTitles:(NSArray *)titles;

- (void)scrollWithOffSet:(CGFloat)offSet;


@end
