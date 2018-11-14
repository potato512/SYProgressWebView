//
//  SYProgressWebView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 16/12/15.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import "SYProgressWebView.h"

static void *ContextProgressValueChange = &ContextProgressValueChange;

@interface SYProgressWebView () <UIAlertViewDelegate>

@property (nonatomic, strong) WKWebView *wkWebViewLoad;
@property (nonatomic, strong) UIWebView *uiWebViewLoad;
@property (nonatomic, strong) UIProgressView *progressViewLoad;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIView *buttonView;

@property (nonatomic, strong) NSTimer *progressTimer;

@property (nonatomic, strong) NSString *barTitle;
@property (nonatomic, copy) void (^shouldStartBlock)(SYProgressWebView *webView, NSString *title, NSURL *url);
@property (nonatomic, copy) void (^didStartBlock)(SYProgressWebView *webView);
@property (nonatomic, copy) void (^didFinishBlock)(SYProgressWebView *webView, NSString *title, NSURL *url);
@property (nonatomic, copy) void (^didFailBlock)(SYProgressWebView *webView, NSString *title, NSURL *url, NSError *error);

@end

@implementation SYProgressWebView

#pragma mark - 实始化

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeInfo];
        
        [self setUI];
        [self reloadUI];
    }
    
    return self;
}

- (void)dealloc
{
    self.progressViewLoad = nil;
    self.activityView = nil;
    self.buttonView = nil;
    
    if (self.wkWebViewLoad)
    {
        [self.wkWebViewLoad removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
        
        self.wkWebViewLoad.navigationDelegate = nil;
        self.wkWebViewLoad.UIDelegate = nil;
        [self.wkWebViewLoad loadHTMLString:@"" baseURL:nil];
        [self.wkWebViewLoad stopLoading];
        [self.wkWebViewLoad removeFromSuperview];
        self.wkWebViewLoad = nil;
        
        NSLog(@"WKWebView（%@）被释放了", self.wkWebViewLoad);
    }
    else if (self.uiWebViewLoad)
    {
        self.uiWebViewLoad.delegate = nil;
        [self.uiWebViewLoad loadHTMLString:@"" baseURL:nil];
        [self.uiWebViewLoad stopLoading];
        [self.uiWebViewLoad removeFromSuperview];
        self.uiWebViewLoad = nil;
        
        NSLog(@"UIWebView（%@）被释放了", self.uiWebViewLoad);
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSLog(@"%@ 被释放了!!!", self);
}

- (void)initializeInfo
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.barTitle = @"加载中……";
}

#pragma mark - 视图

- (void)setUI
{
    if (isIOS8)
    {
        [self setWkWebViewUI];
    }
    else
    {
        [self setUIWebViewUI];
    }

    [self setProgressViewUI];
    [self setAcvitityViewUI];
    [self setButtonViewUI];
}

- (void)reloadUI
{
    if (self.uiWebViewLoad)
    {
        self.uiWebViewLoad.frame = self.bounds;
    }
    else if (self.wkWebViewLoad)
    {
        self.wkWebViewLoad.frame = self.bounds;
    }
    
    self.progressViewLoad.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.progressViewLoad.frame.size.height);
    self.activityView.center = self.center;
    
    [self resetButtonViewUI];
}

- (void)setUIWebViewUI
{
    self.uiWebViewLoad = [[UIWebView alloc] init];
    [self addSubview:self.uiWebViewLoad];
    self.uiWebViewLoad.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.uiWebViewLoad.multipleTouchEnabled = YES;
    self.uiWebViewLoad.autoresizesSubviews = YES;
    self.uiWebViewLoad.scrollView.alwaysBounceVertical = YES;
    self.uiWebViewLoad.scrollView.bounces = NO;
    
    self.uiWebViewLoad.delegate = self;
    self.uiWebViewLoad.scrollView.delegate = self;
}

- (void)setWkWebViewUI
{
    self.wkWebViewLoad = [[WKWebView alloc] init];
    [self addSubview:self.wkWebViewLoad];
    self.wkWebViewLoad.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.wkWebViewLoad.multipleTouchEnabled = YES;
    self.wkWebViewLoad.autoresizesSubviews = YES;
    self.wkWebViewLoad.scrollView.alwaysBounceVertical = YES;
    self.wkWebViewLoad.scrollView.bounces = NO;
    [self.wkWebViewLoad addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:ContextProgressValueChange];
    
    self.wkWebViewLoad.navigationDelegate = self;
    self.wkWebViewLoad.UIDelegate = self;
}

- (void)setProgressViewUI
{
    self.progressViewLoad = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self addSubview:self.progressViewLoad];
    self.progressViewLoad.trackTintColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    
    // 设置进度条颜色
    self.progressColor = [UIColor redColor];
}

- (void)setAcvitityViewUI
{
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
    [self addSubview:self.activityView];
    self.activityView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityView.hidesWhenStopped = YES;
    self.activityView.color = [UIColor redColor];
    [self.activityView stopAnimating];
}

- (void)setButtonViewUI
{
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.backgroundColor = [UIColor clearColor];
    [buttonBack setTitle:@"后退" forState:UIControlStateNormal];
    [buttonBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonBack setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    buttonBack.tag = 1001;
    [buttonBack addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonForward = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonForward setTitle:@"前退" forState:UIControlStateNormal];
    buttonForward.backgroundColor = [UIColor clearColor];
    [buttonForward setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonForward setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    buttonForward.tag = 1002;
    [buttonForward addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonReload = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [buttonReload setTitle:@"刷新" forState:UIControlStateNormal];
    buttonReload.backgroundColor = [UIColor clearColor];
    [buttonReload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonReload setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    buttonReload.tag = 1003;
    [buttonReload addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.buttonView = [[UIView alloc] init];
    [self addSubview:self.buttonView];
    self.buttonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    self.buttonView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.8];
    [self.buttonView addSubview:buttonBack];
    [self.buttonView addSubview:buttonForward];
    [self.buttonView addSubview:buttonReload];
    
    self.buttonView.userInteractionEnabled = NO;
    self.buttonView.alpha = 0.0;
}

- (void)resetButtonViewUI
{
    if (self.showActionButton)
    {
        self.buttonView.alpha = 1.0;
        
        CGFloat widthButton = (self.frame.size.width / 3);
        CGFloat heightButton = 40.0;
        CGFloat originYButton = (self.frame.size.height - heightButton);
        self.buttonView.frame = CGRectMake(0.0, originYButton, self.frame.size.width, heightButton);
        
        UIButton *buttonBack = (UIButton *)[self.buttonView viewWithTag:1001];
        buttonBack.frame = CGRectMake(0.0, 0.0, widthButton, heightButton);
        
        UIButton *buttonForward = (UIButton *)[self.buttonView viewWithTag:1002];
        buttonForward.frame = CGRectMake((buttonBack.frame.origin.x + buttonBack.frame.size.width), 0.0, widthButton, heightButton);
        
        UIButton *buttonReload = (UIButton *)[self.buttonView viewWithTag:1003];
        buttonReload.frame = CGRectMake((buttonForward.frame.origin.x + buttonForward.frame.size.width), 0.0, widthButton, heightButton);
    }
}

#pragma mark - UIScrollViewDelegate

CGFloat previousOffsetY = 0.0;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat hiddenOffset = offsetY - previousOffsetY;
    [UIView animateWithDuration:0.6 animations:^{
        CGRect rect = self.buttonView.frame;
        rect.origin.y = ((hiddenOffset > 0.0) ? self.frame.size.height : (self.frame.size.height - self.buttonView.frame.size.height));
        self.buttonView.frame = rect;
    }];
    previousOffsetY = offsetY;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (webView == self.uiWebViewLoad)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self activityViewStart];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebViewDidStartLoad:)])
        {
            [self.delegate progressWebViewDidStartLoad:self];
        }
        
        if (self.didStartBlock)
        {
            self.didStartBlock(self);
        }
    }
}

// 监视请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (webView == self.uiWebViewLoad)
    {
        if (UIWebViewNavigationTypeLinkClicked == navigationType)
        {
            NSURL *url = [request URL];
            NSString *urlString = url.relativeString;
            urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSRange range = [urlString rangeOfString:@"/" options:NSBackwardsSearch];
            if (range.location != NSNotFound)
            {
                urlString = [urlString substringFromIndex:range.location + range.length];
                range = [urlString rangeOfString:@"."];
                if (range.location != NSNotFound)
                {
                    urlString = [urlString substringToIndex:range.location];
                }
                
                self.barTitle = urlString;
            }
        }
        
        if (![self canOpenWithUrl:request.URL])
        {
            [self progressStartLoading];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:shouldStartLoadWithURL:)])
            {
                [self.delegate progressWebView:self title:self.barTitle shouldStartLoadWithURL:request.URL];
            }
            
            if (self.shouldStartBlock)
            {
                self.shouldStartBlock(self, self.barTitle, request.URL);
            }
        }
        else
        {
            [self launchExternalAppWithURL:request.URL];
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView == self.uiWebViewLoad)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.barTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        if (!self.uiWebViewLoad.isLoading)
        {
            [self progressStopLoading];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFinishLoadingURL:)])
        {
            [self.delegate progressWebView:self title:self.barTitle didFinishLoadingURL:webView.request.URL];
        }
        
        if (self.didFinishBlock)
        {
            self.didFinishBlock(self, self.barTitle, webView.request.URL);
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (webView == self.uiWebViewLoad)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.barTitle = @"加载失败";
        
        if (!self.uiWebViewLoad.isLoading)
        {
            [self progressStopLoading];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFailToLoadURL:error:)])
        {
            [self.delegate progressWebView:self title:self.barTitle didFailToLoadURL:webView.request.URL error:error];
        }
        
        if (self.didFailBlock)
        {
            self.didFailBlock(self, self.barTitle, webView.request.URL, error);
        }
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (webView == self.wkWebViewLoad)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebViewDidStartLoad:)])
        {
            [self.delegate progressWebViewDidStartLoad:self];
        }
        
        if (self.didStartBlock)
        {
            self.didStartBlock(self);
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView == self.wkWebViewLoad)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.barTitle = webView.title;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFinishLoadingURL:)])
        {
            [self.delegate progressWebView:self title:self.barTitle didFinishLoadingURL:webView.URL];
        }
        
        if (self.didFinishBlock)
        {
            self.didFinishBlock(self, self.barTitle, webView.URL);
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView == self.wkWebViewLoad)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.barTitle = @"加载失败";
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFailToLoadURL:error:)])
        {
            [self.delegate progressWebView:self title:self.barTitle didFailToLoadURL:webView.URL error:error];
        }
        
        if (self.didFailBlock)
        {
            self.didFailBlock(self, self.barTitle, webView.URL, error);
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView == self.wkWebViewLoad)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.barTitle = @"加载失败";
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFailToLoadURL:error:)])
        {
            [self.delegate progressWebView:self title:self.barTitle didFailToLoadURL:webView.URL error:error];
        }
        
        if (self.didFailBlock)
        {
            self.didFailBlock(self, self.barTitle, webView.URL, error);
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (webView == self.wkWebViewLoad)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [self activityViewStart];
        
        NSURL *URL = navigationAction.request.URL;
        if ([self canOpenWithUrl:URL])
        {
            if (!navigationAction.targetFrame)
            {
                [self loadRequestWithURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:shouldStartLoadWithURL:)])
            {
                [self.delegate progressWebView:self title:self.barTitle shouldStartLoadWithURL:navigationAction.request.URL];
            }
            
            if (self.shouldStartBlock)
            {
                self.shouldStartBlock(self, self.barTitle, navigationAction.request.URL);
            }
        }
        else if ([[UIApplication sharedApplication] canOpenURL:URL])
        {
            [self launchExternalAppWithURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (webView == self.wkWebViewLoad)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.barTitle = webView.title;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFinishLoadingURL:)])
        {
            [self.delegate progressWebView:self title:self.barTitle didFinishLoadingURL:webView.URL];
        }
        
        if (self.didFinishBlock)
        {
            self.didFinishBlock(self, self.barTitle, webView.URL);
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame)
    {
        [webView loadRequest:navigationAction.request];
    }
    return self.wkWebViewLoad;
}

#pragma mark - progress control (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebViewLoad)
    {
        [self.progressViewLoad setAlpha:1.0f];
        BOOL animated = self.wkWebViewLoad.estimatedProgress > self.progressViewLoad.progress;
        [self.progressViewLoad setProgress:self.wkWebViewLoad.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.wkWebViewLoad.estimatedProgress >= 1.0f)
        {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressViewLoad setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressViewLoad setProgress:0.0f animated:NO];
            }];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - progress Control (UIWebView)

- (void)progressStartLoading
{
    [self.progressViewLoad setProgress:0.0f animated:NO];
    [self.progressViewLoad setAlpha:1.0f];
    
    if (!self.progressTimer)
    {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:progressTime target:self selector:@selector(progressValueChange:) userInfo:nil repeats:YES];
    }
}

- (void)progressStopLoading
{
    if (self.progressTimer)
    {
        [self.progressTimer invalidate];
    }
    
    if (self.progressViewLoad)
    {
        [self.progressViewLoad setProgress:1.0f animated:YES];
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.progressViewLoad setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.progressViewLoad setProgress:0.0f animated:NO];
        }];
    }
}

- (void)progressValueChange:(NSTimer *)timer
{
    CGFloat increment = 0.005 / (self.progressViewLoad.progress + 0.2);
    if ([self.uiWebViewLoad isLoading])
    {
        CGFloat progress = (self.progressViewLoad.progress < 0.75f) ? (self.progressViewLoad.progress + increment) : (self.progressViewLoad.progress + 0.0005);
        if (self.progressViewLoad.progress < 0.95)
        {
            [self.progressViewLoad setProgress:progress animated:YES];
        }
    }
}

#pragma mark - External App Support

- (BOOL)canOpenWithUrl:(NSURL *)URL
{
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https", @"file"]];
    NSLog(@"URL.scheme = %@", URL.scheme);
    BOOL isValid = [validSchemes containsObject:URL.scheme];
    return isValid;
}

- (void)launchExternalAppWithURL:(NSURL *)URL
{
    NSLog(@"launchExternalAppWithURL = %@", URL);
}

#pragma mark - 方法

#pragma mark 响应方法

- (void)buttonAction:(UIButton *)button
{
    if (button.tag == 1001)
    {
        [self goBack];
    }
    else if (button.tag == 1002)
    {
        [self goForward];
    }
    else if (button.tag == 1003)
    {
        [self reload];
    }
}

- (void)buttonViewEnable:(BOOL)enable
{
    if (self.showActionButton)
    {
        if (self.buttonView)
        {
            self.buttonView.userInteractionEnabled = enable;
        }
    }
}

#pragma mark 加载状态符

- (void)activityViewStart
{
    self.progressView.alpha = 1.0;
    if (self.showActivityView)
    {
        [self.activityView startAnimating];
        [self bringSubviewToFront:self.activityView];
    }
}

- (void)activityViewStop
{
    if (self.showActivityView)
    {
        if ([self.activityView isAnimating])
        {
            [self.activityView stopAnimating];
            [self sendSubviewToBack:self.activityView];
        }
        self.activityView.alpha = 0.0;
    }
}

#pragma mark 计时器

/**
 *  计时器停止
 */
- (void)timerKill
{
    if (self.progressTimer)
    {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    
    [self stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark 子网页操作

- (BOOL)canGoBack
{
    if (self.uiWebViewLoad && [self.uiWebViewLoad canGoBack])
    {
        return YES;
    }
    else if (self.wkWebViewLoad && [self.wkWebViewLoad canGoBack])
    {
        return YES;
    }
    
    return NO;
}

- (void)goBack
{
    if ([self canGoBack])
    {
        if (self.uiWebViewLoad)
        {
            [self.uiWebViewLoad goBack];
        }
        else if (self.wkWebViewLoad)
        {
            [self.wkWebViewLoad goBack];
        }
    }
}

- (void)goForward
{
    if (self.uiWebViewLoad && [self.uiWebViewLoad canGoForward])
    {
        [self.uiWebViewLoad goForward];
    }
    else if (self.wkWebViewLoad && [self.wkWebViewLoad canGoForward])
    {
        [self.wkWebViewLoad goForward];
    }
}

- (void)reload
{
    if (self.uiWebViewLoad)
    {
        if ([self.uiWebViewLoad isLoading])
        {
            [self.uiWebViewLoad stopLoading];
        }
        [self.uiWebViewLoad reload];
    }
    else if (self.wkWebViewLoad)
    {
        if ([self.wkWebViewLoad isLoading])
        {
            [self.wkWebViewLoad stopLoading];
        }
        [self.wkWebViewLoad reload];
    }
}

- (void)stopLoading
{
    if (self.uiWebViewLoad)
    {
        if ([self.uiWebViewLoad isLoading])
        {
            [self.uiWebViewLoad stopLoading];
        }
    }
    else if (self.wkWebViewLoad)
    {
        if ([self.wkWebViewLoad isLoading])
        {
            [self.wkWebViewLoad stopLoading];
        }
    }
}

#pragma mark 加载网页方法

/**
 *  加载网页（NSURLRequest请求地址）
 *
 *  @param request 请求地址
 */
- (void)loadRequest:(NSURLRequest *)request
{
    if (self.wkWebViewLoad)
    {
        [self.wkWebViewLoad loadRequest:request];
    }
    else
    {
        [self.uiWebViewLoad loadRequest:request];
    }
}

/**
 *  加载网页（URL网址）
 *
 *  @param URL 网址
 */
- (void)loadRequestWithURL:(NSURL *)URL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [self loadRequest:request];
}

/**
 *  加载网页（NSString网址）
 *
 *  @param urlStr 网址
 */
- (void)loadRequestWithURLStr:(NSString *)urlStr
{
    NSURL *URL = [NSURL URLWithString:urlStr];
    [self loadRequestWithURL:URL];
}

/**
 *  加载本地网页（NSString）
 *
 *  @param html 网页字符串
 */
- (void)loadRequestWithHTML:(NSString *)html
{
    NSString *htmlTmp = ((html && 0 < html.length) ? html : @"<html></html>");
    
    if (self.wkWebViewLoad)
    {
        [self.wkWebViewLoad loadHTMLString:htmlTmp baseURL:nil];
    }
    else if (self.uiWebViewLoad)
    {
        [self.uiWebViewLoad loadHTMLString:htmlTmp baseURL:nil];
    }
}

/**
 *  block回调
 *
 *  @param shouldStart 应该开始回调
 *  @param didStart    已经开始回调
 *  @param didFinish   已经结束
 *  @param didFail     失败
 */
- (void)loadRequest:(void (^)(SYProgressWebView *webView, NSString *title, NSURL *url))shouldStart didStart:(void (^)(SYProgressWebView *webView))didStart didFinish:(void (^)(SYProgressWebView *webView, NSString *title, NSURL *url))didFinish didFail:(void (^)(SYProgressWebView *webView, NSString *title, NSURL *url, NSError *error))didFail
{
    self.shouldStartBlock = [shouldStart copy];
    self.didStartBlock = [didStart copy];
    self.didFinishBlock = [didFinish copy];
    self.didFailBlock = [didFail copy];
}

#pragma mark - getter/setter

#pragma mark getter

- (UIProgressView *)progressView
{
    return self.progressViewLoad;
}

- (UIButton *)backButton
{
    UIButton *button = (UIButton *)[self.buttonView viewWithTag:1001];
    return button;
}

- (UIButton *)forwardButton
{
    UIButton *button = (UIButton *)[self.buttonView viewWithTag:1002];
    return button;
}

- (UIButton *)reloadButton
{
    UIButton *button = (UIButton *)[self.buttonView viewWithTag:1003];
    return button;
}

#pragma mark setter

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    if (_progressColor)
    {
        self.progressViewLoad.tintColor = _progressColor;
    }
}

- (void)setUrl:(NSString *)url
{
    _url = url;
    if (_url && 0 < _url.length)
    {
        [self loadRequestWithURLStr:_url];
    }
}

- (void)setHtml:(NSString *)html
{
    _html = html;
    if (_html && 0 < _html.length)
    {
        [self loadRequestWithHTML:_html];
    }
}

@end
