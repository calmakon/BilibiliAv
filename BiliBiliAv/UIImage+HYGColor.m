//
//  UIImage+HYGColor.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/10.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "UIImage+HYGColor.h"

@implementation UIImage (HYGColor)

- (UIImage *)imageWithColor:(UIColor *)color

{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, self.size.height);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextClipToMask(context, rect, self.CGImage);
    
    [color setFill];
    
    CGContextFillRect(context, rect);
    
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end
