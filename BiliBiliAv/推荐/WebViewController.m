//
//  WebViewController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/6/14.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "WebViewController.h"
#import "NSAttributedString+YYText.h"
#import "AvDetailController.h"
@interface WebViewController ()<UIWebViewDelegate>
@property (nonatomic,strong) UIWebView * webView;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.url;
    NSURLRequest * reauest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:reauest];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
     //NSLog(@"网址 == %@",requestString);
    
    if ([requestString rangeOfString:@"av"].location != NSNotFound) {
        NSInteger l1 = [requestString rangeOfString:@"av"].location;
        NSRange range = NSMakeRange(l1+2, requestString.length-1-2-l1);
        NSString * ss = [requestString substringWithRange:range];
        NSLog(@"id == %@",ss);
        AvDetailController * av = [AvDetailController new];
        av.aid = ss;
        [self.navigationController pushViewController:av animated:YES];
        return NO;
    }
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
   
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

-(UIWebView *)webView
{
    if (!_webView) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        _webView = [UIWebView new];
        _webView.delegate = self;
        [self.view addSubview:_webView];
        
        _webView.sd_layout.leftEqualToView(self.view).topSpaceToView(self.view,64).rightEqualToView(self.view).bottomEqualToView(self.view);
    }
    return _webView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   self.navigationController.navigationBar.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
