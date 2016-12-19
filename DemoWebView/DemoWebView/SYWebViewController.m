//
//  SYWebViewController.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 14-6-14.
//  Copyright (c) 2014年 zhangshaoyu. All rights reserved.
//

#import "SYWebViewController.h"
//#import "ZLCWebView.h"
#import "SYProgressWebView.h"

@interface SYWebViewController () <SYProgressWebViewDelegate>

@property (nonatomic, strong)  SYProgressWebView *webView;

@end

@implementation SYWebViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"加载中……";
    [self setUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.webView)
    {
        [self.webView timerKill];
    }
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (void)dealloc
{
    self.webView = nil;
    
    NSLog(@"%@ 被释放了!!!", self);
}

#pragma mark - 创建视图

- (void)setUI
{
    [self navigationItemButtonUI];
    
    if ([self.navigationController.viewControllers indexOfObject:self] == 0)
    {
        [self webViewUIPresent];
    }
    else
    {
        [self webViewUIPush];
    }
}

#pragma mark 网页视图

- (void)webViewUIPush
{
    NSString *url = @"https://www.baidu.com";
//    NSString *url = @"http://www.hao123.com";
//    NSString *url = @"http://www.toutiao.com";
//    NSString *url = @"http://192.168.3.100:8089/ecsapp/appInventoryModel/intoTotalInvView?account=jie.zheng&token=1";
    
    
    
    WeakWebView;
    // 方法1 实例化
//    self.webView = [[ZLCWebView alloc] initWithFrame:self.view.bounds];
    // 方法2 实例化
    self.webView = [[SYProgressWebView alloc] init];
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.bounds;
    self.webView.url = url;
    self.webView.isBackRoot = NO;
    self.webView.showActivityView = YES;
    self.webView.showActionButton = YES;
    [self.webView reloadUI];
    [self.webView loadRequest:^(SYProgressWebView *webView, NSString *title, NSURL *url) {
        NSLog(@"准备加载。title = %@, url = %@", title, url);
        weakWebView.title = title;
    } didStart:^(SYProgressWebView *webView) {
        NSLog(@"开始加载。");
    } didFinish:^(SYProgressWebView *webView, NSString *title, NSURL *url) {
        NSLog(@"成功加载。title = %@, url = %@", title, url);
        weakWebView.title = title;
    } didFail:^(SYProgressWebView *webView, NSString *title, NSURL *url, NSError *error) {
        NSLog(@"失败加载。title = %@, url = %@, error = %@", title, url, error);
        weakWebView.title = title;
    }];
}

- (void)webViewUIPresent
{
    NSString *url = @"https://www.baidu.com";
//    NSString *url = @"http://www.hao123.com";
//    NSString *url = @"http://www.toutiao.com";
//    NSString *url = @"http://192.168.3.100:8089/ecsapp/appInventoryModel/intoTotalInvView?account=jie.zheng&token=1";
    

    // 方法1 实例化
//    self.webView = [[ZLCWebView alloc] initWithFrame:self.view.bounds];
    // 方法2 实例化
    self.webView = [[SYProgressWebView alloc] init];
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.bounds;
    self.webView.url = url;
    self.webView.isBackRoot = NO;
    self.webView.showActivityView = YES;
    self.webView.showActionButton = YES;
    self.webView.backButton.backgroundColor = [UIColor yellowColor];
    self.webView.forwardButton.backgroundColor = [UIColor greenColor];
    self.webView.reloadButton.backgroundColor = [UIColor brownColor];
    [self.webView reloadUI];
    self.webView.delegate = self;
}

#pragma mark 取消按钮

- (void)navigationItemButtonUI
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -20.0, 0.0, 0.0);
    [backButton setImage:[UIImage imageNamed:@"backPreviousImage"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backPreviousController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc ] initWithCustomView:backButton];
}

#pragma mark - 响应事件

- (void)backPreviousController
{
    if (self.webView)
    {
        if (self.webView.isBackRoot)
        {
            [self.webView stopLoading];
            
            if ([self.navigationController.viewControllers indexOfObject:self] == 0)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        else
        {
            if ([self.webView canGoBack])
            {
                [self.webView goBack];
            }
            else
            {
                if ([self.navigationController.viewControllers indexOfObject:self] == 0)
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }
    }
}

#pragma mark - SYProgressWebViewDelegate

- (void)progressWebViewDidStartLoad:(SYProgressWebView *)webview
{
    NSLog(@"开始加载。");
}

- (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title shouldStartLoadWithURL:(NSURL *)url
{
    NSLog(@"准备加载。title = %@, url = %@", title, url);
    self.title = title;
}

- (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title didFinishLoadingURL:(NSURL *)url
{
    NSLog(@"成功加载。title = %@, url = %@", title, url);
    self.title = title;
}

- (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title didFailToLoadURL:(NSURL *)url error:(NSError *)error
{
    NSLog(@"失败加载。title = %@, url = %@, error = %@", title, url, error);
    self.title = title;
}


@end
