//
//  ImageText.h
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/3/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AvDetailModel.h"

@interface ImageText : NSObject
+ (NSAttributedString *)_attachmentWithFontSize:(CGFloat)fontSize image:(UIImage *)image shrink:(BOOL)shrink;
+ (NSMutableAttributedString *)_textWithTextString:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor;
@end
