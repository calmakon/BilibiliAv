//
//  ImageText.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/3/26.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "ImageText.h"
#import "NSAttributedString+YYText.h"
#import "YYTextRunDelegate.h"
@implementation ImageText
+ (NSAttributedString *)_attachmentWithFontSize:(CGFloat)fontSize image:(UIImage *)image shrink:(BOOL)shrink {
    // Heiti SC 字体。。
    CGFloat ascent = fontSize * 0.86;
    CGFloat descent = fontSize * 0.14;
    CGRect bounding = CGRectMake(0, -0.14 * fontSize, fontSize, fontSize);
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(ascent - (bounding.size.height + bounding.origin.y), 0, descent + bounding.origin.y, 0);
    
    YYTextRunDelegate *delegate = [YYTextRunDelegate new];
    delegate.ascent = ascent;
    delegate.descent = descent;
    delegate.width = bounding.size.width;
    
    YYTextAttachment *attachment = [YYTextAttachment new];
    attachment.contentMode = UIViewContentModeScaleAspectFit;
    attachment.contentInsets = contentInsets;
    attachment.content = image;
    
    if (shrink) {
        // 缩小~
        CGFloat scale = 1 / 10.0;
        contentInsets.top += fontSize * scale;
        contentInsets.bottom += fontSize * scale;
        contentInsets.left += fontSize * scale;
        contentInsets.right += fontSize * scale;
        contentInsets = UIEdgeInsetPixelFloor(contentInsets);
        attachment.contentInsets = contentInsets;
    }
    
    NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:YYTextAttachmentToken];
    [atr setTextAttachment:attachment range:NSMakeRange(0, atr.length)];
    CTRunDelegateRef ctDelegate = delegate.CTRunDelegate;
    [atr setRunDelegate:ctDelegate range:NSMakeRange(0, atr.length)];
    if (ctDelegate) CFRelease(ctDelegate);
    
    return atr;
}

+(NSMutableAttributedString *)_textWithTextString:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor
{
    if (text.length == 0) {
        return nil;
    }
    // 高亮状态的背景
    YYTextBorder *highlightBorder = [YYTextBorder new];
    highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
    highlightBorder.cornerRadius = 3;
    highlightBorder.fillColor = [UIColor lightGrayColor];
    
    NSMutableAttributedString *resultText = [[NSMutableAttributedString alloc] initWithString:text];
    resultText.font = [UIFont systemFontOfSize:fontSize];
    resultText.color = textColor;

    // 匹配 http://
    NSArray *urlResults = [[self regexUrl] matchesInString:resultText.string options:kNilOptions range:text.rangeOfAll];
    for (NSTextCheckingResult *url in urlResults) {
        if (url.range.location == NSNotFound && url.range.length <= 1) continue;
        if ([resultText attribute:YYTextHighlightAttributeName atIndex:url.range.location] == nil) {
            [resultText setColor:kStyleColor range:url.range];
            
            // 高亮状态
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBackgroundBorder:highlightBorder];
            // 数据信息，用于稍后用户点击
            highlight.userInfo = @{@"url" : [resultText.string substringWithRange:NSMakeRange(url.range.location, url.range.length)]};
            [resultText setTextHighlight:highlight range:url.range];
        }
    }

    // 匹配 av号
    NSArray *avResults = [[self regexAvNo] matchesInString:resultText.string options:kNilOptions range:text.rangeOfAll];
    for (NSTextCheckingResult *url in avResults) {
        if (url.range.location == NSNotFound && url.range.length <= 1) continue;
        if ([resultText attribute:YYTextHighlightAttributeName atIndex:url.range.location] == nil) {
            [resultText setColor:kStyleColor range:url.range];
            
            // 高亮状态
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBackgroundBorder:highlightBorder];
            // 数据信息，用于稍后用户点击
            highlight.userInfo = @{@"url" : [resultText.string substringWithRange:NSMakeRange(url.range.location, url.range.length)]};
            [resultText setTextHighlight:highlight range:url.range];
        }
    }
    
    // 匹配 @用户名
    NSArray *atResults = [[self regexAt] matchesInString:resultText.string options:kNilOptions range:text.rangeOfAll];
    for (NSTextCheckingResult *at in atResults) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        if ([resultText attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
            [resultText setColor:kStyleColor range:at.range];
            
            // 高亮状态
            YYTextHighlight *highlight = [YYTextHighlight new];
            [highlight setBackgroundBorder:highlightBorder];
            // 数据信息，用于稍后用户点击
            highlight.userInfo = @{@"atUrl" : [resultText.string substringWithRange:NSMakeRange(at.range.location + 1, at.range.length - 1)]};
            [resultText setTextHighlight:highlight range:at.range];
        }
    }
    
    return resultText;
}

+ (NSRegularExpression *)regexUrl {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"http[s]?://[a-zA-Z0-9./?=_]+" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSRegularExpression *)regexAvNo {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"av[0-9]+" options:kNilOptions error:NULL];
    });
    return regex;
}

+ (NSRegularExpression *)regexAt {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5]+" options:kNilOptions error:NULL];
    });
    return regex;
}

@end
