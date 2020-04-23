//
//  SYWebViewController.m
//  zhangshaoyu
//
//  Created by zhangshaoyu on 14-6-14.
//  Copyright (c) 2014年 zhangshaoyu. All rights reserved.
//

#import "SYWebViewController.h"
// 导入头文件
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
    
    if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
        // present出的视图
        [self loadUIPresent];
    } else {
        // push出的视图
        [self loadUIPush];
    }
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
    if (self.webView.isBackRoot) {
        [self.webView stopLoading];
        
        if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        } else {
            if ([self.navigationController.viewControllers indexOfObject:self] == 0) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
}

#pragma mark - 网页视图

#pragma mark 加载显示

- (void)loadUIPush
{
    NSString *url = @"https://www.baidu.com";
//    NSString *url = @"http://www.hao123.com";
//    NSString *url = @"http://www.toutiao.com";
//    NSString *url = @"http://192.168.3.100:8089/ecsapp/appInventoryModel/intoTotalInvView?account=jie.zheng&token=1";
    
    
    
    __weak SYWebViewController *weakSelf = self;
    //
    self.webView.url = url; // 方法1
//    [self.webView loadRequestWithURLStr:url]; // 方法2
    [self.webView loadRequest:^(SYProgressWebView *webView, NSString *title, NSURL *url) {
        NSLog(@"准备加载。title = %@, url = %@", title, url);
        weakSelf.title = title;
    } didStart:^(SYProgressWebView *webView) {
        NSLog(@"开始加载。");
    } didFinish:^(SYProgressWebView *webView, NSString *title, NSURL *url) {
        NSLog(@"成功加载。title = %@, url = %@", title, url);
        weakSelf.title = title;
    } didFail:^(SYProgressWebView *webView, NSString *title, NSURL *url, NSError *error) {
        NSLog(@"失败加载。title = %@, url = %@, error = %@", title, url, error);
        weakSelf.title = title;
    }];
}

- (void)loadUIPresent
{
    NSString *url = @"https://www.baidu.com";
//    NSString *url = @"http://www.hao123.com";
//    NSString *url = @"http://www.toutiao.com";
//    NSString *url = @"http://192.168.3.100:8089/ecsapp/appInventoryModel/intoTotalInvView?account=jie.zheng&token=1";
    

    //
//    self.webView.url = url; // 方法1
    [self.webView loadRequestWithURLStr:url]; // 方法2
    self.webView.delegate = self;
}

#pragma mark getter

- (SYProgressWebView *)webView
{
    if (_webView == nil) {
        // 实例方法1
        _webView = [[SYProgressWebView alloc] initWithFrame:self.view.bounds];
        // 实例方法2
//        _webView = [[SYProgressWebView alloc] init];
//        _webView.frame = self.view.bounds;
        // 属性设置
        _webView.isBackRoot = YES;
        _webView.showActivityView = YES;
//        _webView.showActionButton = YES;
        _webView.backButton.backgroundColor = [UIColor yellowColor];
        _webView.forwardButton.backgroundColor = [UIColor greenColor];
        _webView.reloadButton.backgroundColor = [UIColor brownColor];
        //
        [self.view addSubview:_webView];
    }
    return _webView;
}

#pragma mark SYProgressWebViewDelegate

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
