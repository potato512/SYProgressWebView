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

~~~

~~~ javascript

// 定义成属性（便于控制timer）
@property (nonatomic, strong)  SYProgressWebView *webView;

~~~

~~~ javascript

// 实例化及使用（使用block回调，注意循环引用）
self.webView = [[SYProgressWebView alloc] init];
[self.view addSubview:self.webView];
self.webView.frame = self.view.bounds;
self.webView.url = url;
self.webView.isBackRoot = NO;
self.webView.showActivityView = YES;
self.webView.showActionButton = YES;
[self.webView reloadUI];
// 注意循环引用
__weak typeof(self) weakWebView = self;
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


~~~

~~~ javascript

// 实例化及使用（使用代理方法，注意添加代理对象与代理协议）
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
// 代理对象 SYProgressWebViewDelegate
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

// 注意事项（在视图控制器被释放前，注意timer的处理）
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.webView)
    {
        [self.webView timerKill];
    }
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



