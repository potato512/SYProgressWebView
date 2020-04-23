//
//  SYProgressWebView.h
//  zhangshaoyu
//
//  Created by zhangshaoyu on 16/12/15.
//  Copyright © 2016年 zhangshaoyu. All rights reserved.
//  github：https://github.com/potato512/SYProgressWebView

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark - SYProgressWebViewDelegate

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

#pragma mark - SYProgressWebView

@interface SYProgressWebView : UIView 


#pragma mark - 属性

/**
 *  代理对象
 */
@property (nonatomic, weak) id <SYProgressWebViewDelegate> delegate;

/**
 *  是否显示加载进度条（默认YES，显示）
 */
@property (nonatomic, assign) BOOL showProgress;
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


/**
 使用示例
 1、导入头文件
 #import "SYProgressWebView.h"
 
 2、实例化
 // 实例方法1
 _webView = [[SYProgressWebView alloc] initWithFrame:self.view.bounds];
 // 实例方法2
 // _webView = [[SYProgressWebView alloc] init];
 // _webView.frame = self.view.bounds;
 //
 [self.view addSubview:_webView];
 
 3、属性设置
 _webView.isBackRoot = YES;
 _webView.showActivityView = YES;
 //
 _webView.showActionButton = YES;
 _webView.backButton.backgroundColor = [UIColor yellowColor];
 _webView.forwardButton.backgroundColor = [UIColor greenColor];
 _webView.reloadButton.backgroundColor = [UIColor brownColor];
         
 4、网页加载
 NSString *url = @"https://www.baidu.com";
 // 方法1
 _webView.url = url;
 // 方法2
 [_webView loadRequestWithURLStr:url];
 
 5、方法回调
 // 方法1 block回调
 [_webView loadRequest:^(SYProgressWebView *webView, NSString *title, NSURL *url) {
     NSLog(@"准备加载。title = %@, url = %@", title, url);
 } didStart:^(SYProgressWebView *webView) {
     NSLog(@"开始加载。");
 } didFinish:^(SYProgressWebView *webView, NSString *title, NSURL *url) {
     NSLog(@"成功加载。title = %@, url = %@", title, url);
 } didFail:^(SYProgressWebView *webView, NSString *title, NSURL *url, NSError *error) {
     NSLog(@"失败加载。title = %@, url = %@, error = %@", title, url, error);
 }];
 
 // 方法2 代理回调
 // 添加协议
 SYProgressWebViewDelegate
 // 设置代理
 self.webView.delegate = self;
 // 实现代理方法
 - (void)progressWebViewDidStartLoad:(SYProgressWebView *)webview
 {
     NSLog(@"开始加载。");
 }

 - (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title shouldStartLoadWithURL:(NSURL *)url
 {
     NSLog(@"准备加载。title = %@, url = %@", title, url);
 }

 - (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title didFinishLoadingURL:(NSURL *)url
 {
     NSLog(@"成功加载。title = %@, url = %@", title, url);
 }

 - (void)progressWebView:(SYProgressWebView *)webview title:(NSString *)title didFailToLoadURL:(NSURL *)url error:(NSError *)error
 {
     NSLog(@"失败加载。title = %@, url = %@, error = %@", title, url, error);
 }
 
 6、返回网页子级视图操作示例
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
 
 */
