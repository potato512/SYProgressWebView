//
//  SYProgressWebView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 16/12/15.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

/******************************************************************************/

#pragma mark - 宏定义

#define WeakWebView __weak typeof(self) weakWebView = self

#define WidthMainScreen ([UIScreen mainScreen].bounds.size.width)
static NSTimeInterval const progressTime = (1.0 / 60.0);

#define isIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

/******************************************************************************/

@class SYProgressWebView;
@protocol SYProgressWebViewDelegate <NSObject>
@optional
/**
 *  加载成功
 *
 *  @param webview 返回SYProgressWebView
 *  @param title   返回网页标题
 *  @param URL     返回网页地址
 */
- (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title didFinishLoadingURL:(NSURL *)url;

/**
 *  加载失败
 *
 *  @param webview 返回SYProgressWebView
 *  @param title   返回网页标题
 *  @param URL     返回网页地址
 *  @param error   返回错误信息
 */
- (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title didFailToLoadURL:(NSURL *)url error:(NSError *)error;

/**
 *  准备加载
 *
 *  @param webview 返回SYProgressWebView
 *  @param title   返回网页标题
 *  @param URL     返回网页地址
 */
- (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title shouldStartLoadWithURL:(NSURL *)url;

/**
 *  开始加载
 *
 *  @param webview 返回SYProgressWebView
 */
- (void)progressWebViewDidStartLoad:(SYProgressWebView *)webview;

@end

@interface SYProgressWebView : UIView <WKNavigationDelegate, WKUIDelegate, UIWebViewDelegate, UIScrollViewDelegate>


#pragma mark - 属性

/**
 *  代理对象
 */
@property (nonatomic, weak) id <SYProgressWebViewDelegate> delegate;

/**
 *  网页加载进度条（UIProgressView）
 */
@property (nonatomic, strong, readonly) UIProgressView *progressView;
/**
 *  进度条颜色（默认红色）
 */
@property (nonatomic, strong) UIColor *progressColor;

/**
 *  打开子网页后是否直接返回根视图控制器（默认NO，直接返回根视图控制器）
 */
@property (nonatomic, assign) BOOL isBackRoot;

/**
 *  是否显示加载状态图形（默认NO，不显示）
 */
@property (nonatomic, assign) BOOL showActivityView;

/**
 *  网页操作按钮（默认不显示。后退/刷新/前进）
 */
@property (nonatomic, assign) BOOL showActionButton;

/**
 *  子网页返回按钮（用于设置属性，默认标题为"后退"）
 */
@property (nonatomic, strong, readonly) UIButton *backButton;
/**
 *  子网页前进按钮（用于设置属性，默认标题为"前进"）
 */
@property (nonatomic, strong, readonly) UIButton *forwardButton;
/**
 *  子网页刷新按钮（用于设置属性，默认标题为"刷新"）
 */
@property (nonatomic, strong, readonly) UIButton *reloadButton;

/**
 *  网址
 */
@property (nonatomic, strong) NSString *url;

/**
 *  本地html
 */
@property (nonatomic, strong) NSString *html;

#pragma mark - 方法

#pragma mark 实例化

/**
 *  实例化方法
 *
 *  @param frame 位置大小
 *
 *  @return SYProgressWebView
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  刷新视图（特别是需要显示子视图操作按钮时）
 */
- (void)reloadUI;

#pragma mark 计时器

/**
 *  计时器停止（在使用的视图控制器的视图即将消失时调用）
 */
- (void)timerKill;

#pragma mark 子网页操作

/**
 *  是否能返回上级网页
 */
- (BOOL)canGoBack;

/**
 *  返回上级网页
 */
- (void)goBack;

/**
 *  进入历史记录，即下个子网页
 */
- (void)goForward;

/**
 *  刷新网页
 */
- (void)reload;

/**
 *  停止加载网页
 */
- (void)stopLoading;

#pragma mark 加载网页方法

/**
 *  加载网页（NSURLRequest请求地址）
 *
 *  @param request 请求地址
 */
- (void)loadRequest:(NSURLRequest *)request;

/**
 *  加载网页（URL网址）
 *
 *  @param URL 网址
 */
- (void)loadRequestWithURL:(NSURL *)URL;

/**
 *  加载网页（NSString网址）
 *
 *  @param urlStr 网址
 */
- (void)loadRequestWithURLStr:(NSString *)urlStr;

/**
 *  加载本地网页（NSString）
 *
 *  @param html 网页字符串
 */
- (void)loadRequestWithHTML:(NSString *)html;

/**
 *  block回调
 *
 *  @param shouldStart 应该开始回调
 *  @param didStart    已经开始回调
 *  @param didFinish   已经结束
 *  @param didFail     失败
 */
- (void)loadRequest:(void (^)(SYProgressWebView *webView, NSString *title, NSURL *url))shouldStart didStart:(void (^)(SYProgressWebView *webView))didStart didFinish:(void (^)(SYProgressWebView *webView, NSString *title, NSURL *url))didFinish didFail:(void (^)(SYProgressWebView *webView, NSString *title, NSURL *url, NSError *error))didFail;

@end
