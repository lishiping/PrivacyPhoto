//
//  LSPWebView.h
//  e-mail:83118274@qq.com
//
//  Created by lishiping on 17/4/25.
//  Copyright © 2017年 lishiping. All rights reserved.
//
//If you think this open source library is of great help to you, please open the URL to click the Star,your approbation can encourage me, the author will publish the better open source library for guys again
//如果您认为本开源库对您很有帮助，请打开URL给作者点个赞，您的认可给作者极大的鼓励，作者还会发布更好的开源库给大家

//github address//https://github.com/lishiping/SPWebView
//github address//https://github.com/lishiping/SPDebugBar
//github address//https://github.com/lishiping/SPFastPush
//github address//https://github.com/lishiping/SPMacro
//github address//https://github.com/lishiping/SafeData
//github address//https://github.com/lishiping/SPCategory

#import <UIKit/UIKit.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
#import <WebKit/WebKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol LSPWebViewDelegate <NSObject>

@optional
//将WKWebView原本代理方法转接一次，可用可不用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error;
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

- (void)webView:(WKWebView *)webView updateProgress:(float)progress;//增加了WKWebView的加载进度的代理方法

/**
 OC和JS通讯使用，向web注册原生方法，当js事件调用方法列表里面的函数，相应的函数执行
 如下所示：
 - (NSObject *)registerJavaScriptHandler{
     return self;
 }
 - (NSArray<NSString *> *)registerJavascriptName{
 return @[@"fetchMessage",@"showJSData"];
 }
 //fetchMessage 要与上面数组返回字符串名字对应
 - (void)fetchMessage:(NSDictionary *)dic{
 NSLog(@"%@", dic);
 }
 - (void)showJSData{
 }
 */
//以下两个方法成对使用
- (NSArray<NSString *>*)registerJavascriptName;//给WKWebView注册方法使用
- (NSObject *)registerJavaScriptHandler;//接收js调用方法的对象

@end

@interface LSPWebView : UIView

@property ( nonatomic, weak) id <LSPWebViewDelegate> delegate;
@property ( nonatomic, weak) UIViewController *panelViewController;//webview的父控制器，为了webview里面alert弹窗等使用的
@property (nonatomic, assign) BOOL useCookie;//是否使用浏览器cookie缓存
@property ( nonatomic, readonly, copy) NSURL *URL;//读取当前的url
@property ( nonatomic, readonly, strong) NSURLRequest *request;//读取当前的请求
@property ( nonatomic, readonly, copy) NSString *title;//读取webview的标题
@property ( nonatomic, readonly) WKWebView *webView;
@property ( nonatomic, readonly) BOOL canGoBack;//web.canGoBack
@property ( nonatomic, readonly) BOOL canGoForward;//web.canGoForward
@property ( nonatomic, assign) BOOL isAllowNativeHelperJS;//默认不开启，打开原生和js交互帮助，为了统一js端调用iOS和Android原生方法名，需要植入一个js文件
@property ( nonatomic, assign) BOOL isShowProgressView;//是否显示加载进度条
@property ( nonatomic, strong) UIColor *progressColor;//进度条颜色
@property ( nonatomic, strong,readonly) UIProgressView *progressView;//进度条视图

/****************************init**********************/
- (instancetype)initWithFrame:(CGRect)frame;

/****************************load**********************/
- (void)loadURLString:(NSString *)urlString;
- (void)loadURL:(NSURL *)URL;
- (void)loadRequest:(NSURLRequest *)request;
- (void)reload;
- (void)stopLoading;
- (void)goBack;
- (void)goForward;

/****************************evaluateJavaScript**********************/
- (void)evaluateJavaScript:(NSString *)function;
- (void)evaluateJavaScript:(NSString *)function completionHandler:(nullable void (^)(id obj, NSError *error))completionHandler;

/// 追加用户代理里面的参数
/// @param userAgetString 用户代理参数
-(void)configUserAgentByAppend:(NSString*)userAgetString;

/// 清理cookie缓存
-(void)clearCookie;

@end

NS_ASSUME_NONNULL_END
