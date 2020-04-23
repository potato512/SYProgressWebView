//
//  SYProgressWebView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 16/12/15.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import "SYProgressWebView.h"
#import <WebKit/WebKit.h>

static NSInteger const kTagButtonBack = 1001;
static NSInteger const kTagButtonForward = 1002;
static NSInteger const kTagButtonReload = 1003;
//
static CGFloat const kHeightButton = 40;
static CGFloat const kHeightBottom = 34;
//
static void *ContextProgressValueChange = &ContextProgressValueChange;

#pragma mark - SYProgressWebView

@interface SYProgressWebView () <UIAlertViewDelegate, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSString *urlTitle;
//
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
//
@property (nonatomic, strong) UIView *buttonView;

//
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
    if (self) {
        [self initializeInfo];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeInfo];
    }
    return self;
}

- (void)layoutSubviews
{
    [self reloadUI];
}

- (void)dealloc
{
    [self releaseWKWebView];
    
    NSLog(@"%@ 被释放了!!!", self);
}

#pragma mark - 视图

- (void)initializeInfo
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //
    self.urlTitle = @"加载中...";
}

- (void)reloadUI
{
    self.wkWebView.frame = self.bounds;
    self.progressView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.progressView.frame.size.height);
    self.activityView.center = self.center;
    
    [self reloadButtonViewUI];
}

- (void)reloadButtonViewUI
{
    self.wkWebView.scrollView.delegate = nil;
    [self sendSubviewToBack:self.buttonView];
    if (self.showActionButton) {
        //
        self.wkWebView.scrollView.delegate = self;
        //
        self.buttonView.hidden = NO;
        self.buttonView.userInteractionEnabled = YES;
        self.buttonView.alpha = 1.0;
        [self bringSubviewToFront:self.buttonView];
        //
        CGFloat widthButton = (self.frame.size.width / 3);
        CGFloat heightButton = kHeightButton;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            if (window.safeAreaInsets.bottom > 0.0) {
                heightButton = kHeightButton + kHeightBottom;
            }
        }
        CGFloat originYButton = (self.frame.size.height - heightButton);
        self.buttonView.frame = CGRectMake(0.0, originYButton, self.frame.size.width, heightButton);
        //
        self.backButton.frame = CGRectMake(0.0, 0.0, widthButton, heightButton);
        self.forwardButton.frame = CGRectMake((self.backButton.frame.origin.x + self.backButton.frame.size.width), 0.0, widthButton, heightButton);
        self.reloadButton.frame = CGRectMake((self.forwardButton.frame.origin.x + self.forwardButton.frame.size.width), 0.0, widthButton, heightButton);
        //
        CGFloat topTitle = 0;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].delegate.window;
            if (window.safeAreaInsets.bottom > 0.0) {
                topTitle = -20;
            }
        }
        self.backButton.titleEdgeInsets = UIEdgeInsetsMake(topTitle, 0, 0, 0);
        self.forwardButton.titleEdgeInsets = UIEdgeInsetsMake(topTitle, 0, 0, 0);
        self.reloadButton.titleEdgeInsets = UIEdgeInsetsMake(topTitle, 0, 0, 0);
    }
}

- (void)releaseWKWebView
{
    [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    self.wkWebView.navigationDelegate = nil;
    self.wkWebView.UIDelegate = nil;
    [self.wkWebView loadHTMLString:@"" baseURL:nil];
    [self.wkWebView stopLoading];
    [self.wkWebView removeFromSuperview];
    //
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
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

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (webView == self.wkWebView) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebViewDidStartLoad:)]) {
            [self.delegate progressWebViewDidStartLoad:self];
        }
        
        if (self.didStartBlock) {
            self.didStartBlock(self);
        }
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView == self.wkWebView) {
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.urlTitle = webView.title;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFinishLoadingURL:)]) {
            [self.delegate progressWebView:self title:self.urlTitle didFinishLoadingURL:webView.URL];
        }
        
        if (self.didFinishBlock) {
            self.didFinishBlock(self, self.urlTitle, webView.URL);
        }
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView == self.wkWebView) {
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.urlTitle = @"加载失败";
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFailToLoadURL:error:)]) {
            [self.delegate progressWebView:self title:self.urlTitle didFailToLoadURL:webView.URL error:error];
        }
        
        if (self.didFailBlock) {
            self.didFailBlock(self, self.urlTitle, webView.URL, error);
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView == self.wkWebView) {
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.urlTitle = @"加载失败";
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFailToLoadURL:error:)]) {
            [self.delegate progressWebView:self title:self.urlTitle didFailToLoadURL:webView.URL error:error];
        }
        
        if (self.didFailBlock) {
            self.didFailBlock(self, self.urlTitle, webView.URL, error);
        }
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (webView == self.wkWebView) {
        [self activityViewStart];
        
        NSURL *URL = navigationAction.request.URL;
        if ([self canOpenWithUrl:URL]) {
            if (!navigationAction.targetFrame) {
                [self loadRequestWithURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:shouldStartLoadWithURL:)]) {
                [self.delegate progressWebView:self title:self.urlTitle shouldStartLoadWithURL:navigationAction.request.URL];
            }
            
            if (self.shouldStartBlock) {
                self.shouldStartBlock(self, self.urlTitle, navigationAction.request.URL);
            }
        } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [self launchExternalAppWithURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (webView == self.wkWebView) {
        [self activityViewStop];
        [self buttonViewEnable:YES];
        
        self.urlTitle = webView.title;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressWebView:title:didFinishLoadingURL:)]) {
            [self.delegate progressWebView:self title:self.urlTitle didFinishLoadingURL:webView.URL];
        }
        
        if (self.didFinishBlock) {
            self.didFinishBlock(self, self.urlTitle, webView.URL);
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return self.wkWebView;
}

#pragma mark - progress control (WKWebView)

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView)
    {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if (self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
    if (button.tag == kTagButtonBack) {
        [self goBack];
    } else if (button.tag == kTagButtonForward) {
        [self goForward];
    } else if (button.tag == kTagButtonReload) {
        [self reload];
    }
}

- (void)buttonViewEnable:(BOOL)enable
{
    if (self.showActionButton) {
        if (self.buttonView) {
            self.buttonView.userInteractionEnabled = enable;
        }
    }
}

#pragma mark 加载状态符

- (void)activityViewStart
{
    self.progressView.alpha = 1.0;
    if (self.showActivityView) {
        [self.activityView startAnimating];
        [self bringSubviewToFront:self.activityView];
    }
}

- (void)activityViewStop
{
    if (self.showActivityView) {
        if ([self.activityView isAnimating]) {
            [self.activityView stopAnimating];
            [self sendSubviewToBack:self.activityView];
        }
        self.activityView.alpha = 0.0;
    }
}

#pragma mark 子网页操作

- (BOOL)canGoBack
{
    if (self.wkWebView.canGoBack) {
        return YES;
    }
    
    return NO;
}

- (void)goBack
{
    if (self.canGoBack) {
        if (self.wkWebView) {
            [self.wkWebView goBack];
        }
    }
}

- (void)goForward
{
    if (self.wkWebView.canGoForward) {
        [self.wkWebView goForward];
    }
}

- (void)reload
{
    if (self.wkWebView) {
        if ([self.wkWebView isLoading]) {
            [self.wkWebView stopLoading];
        }
        [self.wkWebView reload];
    }
}

- (void)stopLoading
{
    if (self.wkWebView) {
        if ([self.wkWebView isLoading]) {
            [self.wkWebView stopLoading];
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
    if (self.wkWebView) {
        [self.wkWebView loadRequest:request];
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
    
    if (self.wkWebView) {
        [self.wkWebView loadHTMLString:htmlTmp baseURL:nil];
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

- (WKWebView *)wkWebView
{
    if (_wkWebView == nil) {
        _wkWebView = [[WKWebView alloc] init];
        _wkWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _wkWebView.multipleTouchEnabled = YES;
        _wkWebView.autoresizesSubviews = YES;
        _wkWebView.scrollView.alwaysBounceVertical = YES;
        _wkWebView.scrollView.bounces = NO;
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:ContextProgressValueChange];
        //
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        //
        [self addSubview:_wkWebView];
    }
    return _wkWebView;
}

- (UIProgressView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.trackTintColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
        // 设置进度条颜色
        _progressView.tintColor = [UIColor redColor];
        //
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 80.0)];
        _activityView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activityView.hidesWhenStopped = YES;
        _activityView.color = [UIColor redColor];
        [_activityView stopAnimating];
        //
        [self addSubview:_activityView];
    }
    return _activityView;
}

- (UIView *)buttonView
{
    if (_buttonView == nil) {
        //
        _buttonView = [[UIView alloc] init];
        _buttonView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _buttonView.backgroundColor = UIColor.greenColor;// [UIColor colorWithWhite:0.5 alpha:0.8];
        _buttonView.hidden = YES;
        _buttonView.userInteractionEnabled = NO;
        _buttonView.alpha = 0.0;
        [self addSubview:_buttonView];
        //
        UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonBack.backgroundColor = [UIColor clearColor];
        [buttonBack setTitle:@"后退" forState:UIControlStateNormal];
        [buttonBack setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonBack setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        buttonBack.tag = kTagButtonBack;
        [buttonBack addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:buttonBack];
        //
        UIButton *buttonForward = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonForward setTitle:@"前进" forState:UIControlStateNormal];
        buttonForward.backgroundColor = [UIColor clearColor];
        [buttonForward setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonForward setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        buttonForward.tag = kTagButtonForward;
        [buttonForward addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:buttonForward];
        //
        UIButton *buttonReload = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonReload setTitle:@"刷新" forState:UIControlStateNormal];
        buttonReload.backgroundColor = [UIColor clearColor];
        [buttonReload setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonReload setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        buttonReload.tag = kTagButtonReload;
        [buttonReload addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:buttonReload];
    }
    return _buttonView;
}

- (UIButton *)backButton
{
    UIButton *button = (UIButton *)[self.buttonView viewWithTag:kTagButtonBack];
    return button;
}

- (UIButton *)forwardButton
{
    UIButton *button = (UIButton *)[self.buttonView viewWithTag:kTagButtonForward];
    return button;
}

- (UIButton *)reloadButton
{
    UIButton *button = (UIButton *)[self.buttonView viewWithTag:kTagButtonReload];
    return button;
}

#pragma mark setter

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    if (_progressColor) {
        self.progressView.tintColor = _progressColor;
    }
}

- (void)setUrl:(NSString *)url
{
    _url = url;
    if (_url && ([_url isKindOfClass:NSString.class] && 0 < _url.length)) {
        [self loadRequestWithURLStr:_url];
    }
}

- (void)setHtml:(NSString *)html
{
    _html = html;
    if (_html && ([_html isKindOfClass:NSString.class] && 0 < _html.length)) {
        [self loadRequestWithHTML:_html];
    }
}

@end
