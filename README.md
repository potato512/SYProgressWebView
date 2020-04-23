# SYProgressWebView
带有进度条的网页加载视图

# 效果图
![progressWebView.gif](./progressWebView.gif)

# 使用

* 使用介绍
  * 自动导入：使用命令pod 'SYProgressWebView' 导入到项目中
  * 手动导入：或下载源码后，将源码添加到项目中

~~~ javascript

// 导入头文件
#import "SYProgressWebView.h"

~~~


~~~ javascript

// 定义成属性
@property (nonatomic, strong)  SYProgressWebView *webView;

~~~

~~~ javascript

// 实例化及使用（使用block回调，注意循环引用）
self.webView = [[SYProgressWebView alloc] init];
[self.view addSubview:self.webView];
self.webView.frame = self.view.bounds;
self.webView.isBackRoot = NO;
self.webView.showActivityView = YES;
self.webView.showActionButton = YES;
~~~

~~~ javascript

// 网页加载
NSString *url = @"https://www.baidu.com";

// 方法1
self.webView.url = url;

// 方法2
[self.webView loadRequestWithURLStr:url];

~~~

~~~ javascript

// block回调 注意循环引用
__weak UIViewController *weakSelf = self;
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


~~~

~~~ javascript

// 代理回调

// 代理协议
SYProgressWebViewDelegate

// 代理对象 
self.webView.delegate = self;

~~~

~~~ javascript

// 实现代理方法
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

~~~

~~~ javascript

// 返回前一个视图控制器（区分present，或push）
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

~~~ 


# 修改完善
* 20200423
  * 版本号：1.1.0
  * 修改优化
    * iOS 8.0及以上系统适配
    * 保留WKWebView，去掉UIWebView
    * 动作按钮UI刘海适配（后退、前进、刷新）
    * 删除冗余代码







