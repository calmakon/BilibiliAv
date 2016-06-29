//
//  LevelLabel.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/5.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "LevelLabel.h"

@implementation LevelLabel

-(void)setLevel:(NSInteger)level
{
    if (level >= 4) {
        self.backgroundColor = [UIColor orangeColor];
    }else{
        if (level == 1) {
            self.backgroundColor = [UIColor grayColor];
        }
        if (level == 2) {
            self.backgroundColor = [UIColor colorWithRed:0.51 green:0.72 blue:0.25 alpha:1];
        }
        if (level == 3) {
            self.backgroundColor = [UIColor colorWithRed:0.49 green:0.81 blue:0.93 alpha:1];
        }
    }
}

@end
