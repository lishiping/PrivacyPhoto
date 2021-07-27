//
//  LSPWebView.m
//  e-mail:83118274@qq.com
//
//  Created by lishiping on 17/4/25.
//  Copyright © 2017年 lishiping. All rights reserved.
//

//  实现思路参照CHWebView,感谢作者Chausson开源,在作者原有基础上优化更新,使用NJKWebViewProgress

//If you think this open source library is of great help to you, please open the URL to click the Star,your approbation can encourage me, the author will publish the better open source library for guys again
//如果您认为本开源库对您很有帮助，请打开URL给作者点个赞，您的认可给作者极大的鼓励，作者还会发布更好的开源库给大家

//github address//https://github.com/lishiping/SPWebView
//github address//https://github.com/lishiping/SPDebugBar
//github address//https://github.com/lishiping/SPFastPush
//github address//https://github.com/lishiping/SPMacro
//github address//https://github.com/lishiping/SafeData
//github address//https://github.com/lishiping/SPCategory

//----------------------screen size-------------------------
//----------------------屏幕尺寸-------------------------

#define LSP_SCREEN_WIDTH      ([UIScreen mainScreen].bounds.size.width)

#define LSP_SCREEN_HEIGHT     ([UIScreen mainScreen].bounds.size.height)

#if DEBUG

#define SP_LOG(...)                 NSLog(__VA_ARGS__);

#else


#define SP_LOG(...)

#endif


#import "LSPWebView.h"
#import <WebKit/WebKit.h>

@interface LSPWebWeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

@implementation LSPWebWeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end


@interface LSPWebView ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property ( nonatomic, strong) WKWebView *instanceWebView;//临时的为了设置UA创建的对象

@property ( nonatomic, strong) WKWebView *webView;
@property ( nonatomic, strong) UIProgressView *progressView;

@end

@implementation LSPWebView

#pragma mark - init &dealloc

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self addSubview:self.webView];
    _isAllowNativeHelperJS = NO;
    _progressColor = UIColor.blueColor;
    [self registerForKVO];
    [self registerFunction];
    return self;
}

-(void)dealloc
{
    [self unregisterFromKVO];
    SP_LOG(@"LSPWebView正常释放");
}

#pragma mark - load method
- (void)loadURLString:(NSString *)urlString
{
    NSAssert(urlString.length, @"Error SPWebView loadURL: is not allow nil or empty");
    NSURLRequest *rquest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self loadRequest:rquest];
}

- (void)loadURL:(NSURL *)URL
{
    NSURLRequest *rquest = [NSURLRequest requestWithURL:URL];
    [self loadRequest:rquest];
}

- (void)loadRequest:(NSURLRequest *)req
{
    NSMutableURLRequest *request = req.mutableCopy;
    _request = request;
    if (_useCookie) {
        // 3. 向Http Header中设置Cookie
        NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
        request.allHTTPHeaderFields = dict.copy;
    }
    [self.webView loadRequest:request];
}

- (void)reload{
    [self invokeName:@"reload"];
}

- (void)stopLoading{
    [self invokeName:@"stopLoading"];
}

- (void)goBack{
    [self invokeName:@"goBack"];
}

- (void)goForward{
    [self invokeName:@"goForward"];
}

- (BOOL)canGoBack
{
    return self.webView.canGoBack;
}

- (BOOL)canGoForward
{
    return self.webView.canGoForward;
}

- (void)invokeName:(NSString *)name{
    SEL selector = NSSelectorFromString(name);
    if ([_webView respondsToSelector:selector]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            IMP imp = [self->_webView methodForSelector:selector];
            void (*func)(id, SEL) = (void *)imp;
            func(self->_webView, selector);
        });
    }
}

#pragma mark - evaluateJavaScript
- (void)evaluateJavaScript:(NSString *)function{
    [self evaluateJavaScript:function completionHandler:nil];
}

- (void)evaluateJavaScript:(NSString *)function completionHandler:(void (^)( id, NSError * error))completionHandler
{
    [self.webView evaluateJavaScript:function completionHandler:^(id a, NSError *e){
        if (completionHandler) {
            completionHandler(a,e);
        }
    }];
}

#pragma mark - WKWebView Deleagte
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:( WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [self.delegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

// 4 开始获取到网页内容时返回
// 当内容开始返回时调用,当内容开始到达主框架时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}

// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (_useCookie) {
        //如果开启缓存，本地的cookie再次加入，给前端
        NSMutableDictionary *cookieDict = [NSMutableDictionary dictionary];
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [cookieJar cookies]) { // 先将cookie去重，再拼接
            [cookieDict setObject:cookie.value forKey:cookie.name];
        }
        NSMutableString *cookie = [[NSMutableString alloc] init];
        for (NSString *key in cookieDict) { // 此处需要主要注意【格式】
            [cookie appendFormat:@"document.cookie = '%@=%@';\n",key,cookieDict[key]];
        }
        [self evaluateJavaScript:cookie];
    }
    
    if (_isAllowNativeHelperJS){
        [self registerNativeHelperJS];
    }
    
    [self registerFunction];
    
    if ([self.delegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [self.delegate webView:webView didFinishNavigation:navigation];
    }
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:( WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [self.delegate webView:webView didFailNavigation:navigation withError:error];
    }
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([self.delegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//3在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (_useCookie) {
        //接收前端的cookie，缓存到本地
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:response.URL];
        //读取wkwebview中的cookie
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    if ([self.delegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [self.delegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }else{
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    //在网页内部点击按钮打开新网页的时候这样判断有效，如果不加入就不会自动跳转,响应js的window.open方法
    if(navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame){
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

//2.WebVeiw关闭（9.0中的新方法）
- (void)webViewDidClose:(WKWebView *)webView
{
    
}

//3.显示一个JS的Alert（与JS交互）
//此方法作为js的alert方法接口的实现，默认弹出窗口应该只有提示信息及一个确认按钮，当然可以添加更多按钮以及其他内容，但是并不会起到什么作用
//点击确认按钮的相应事件需要执行completionHandler，这样js才能继续执行
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    //js 里面的alert实现，如果不实现，网页的alert函数无效
    UIViewController *vc = (UIViewController*)self.panelViewController;
    
    if (vc && [vc isKindOfClass:UIViewController.class]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completionHandler) {
                completionHandler();
            }
        }]];
        [vc presentViewController:alert animated:YES completion:NULL];
    }
}

//4.弹出一个输入框（与JS交互的）
// prompt
//作为js中prompt接口的实现，默认需要有一个输入框一个按钮，点击确认按钮回传输入值
//当然可以添加多个按钮以及多个输入框，不过completionHandler只有一个参数，如果有多个输入框，需要将多个输入框中的值通过某种方式拼接成一个字符串回传，js接收到之后再做处理
//参数 prompt 为 prompt(<message>, <defaultValue>);中的<message>
//参数defaultText 为 prompt(<message>, <defaultValue>);中的 <defaultValue>
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    UIViewController *vc = (UIViewController*)self.panelViewController;
    if (vc && [vc isKindOfClass:UIViewController.class]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = defaultText;
        }];
        [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(alertController.textFields[0].text?:@"");
        }])];
        [vc presentViewController:alertController animated:YES completion:nil];
    }
}

//5.显示一个确认框（JS的）
// confirm
//作为js中confirm接口的实现，需要有提示信息以及两个相应事件， 确认及取消，并且在completionHandler中回传相应结果，确认返回YES， 取消返回NO
//参数 message为  js 方法 confirm(<message>) 中的<message>
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    //js 里面的alert实现，如果不实现，网页的alert函数无效
    UIViewController *vc = (UIViewController*)self.panelViewController;
    
    if (vc && [vc isKindOfClass:UIViewController.class]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                 message:message?:@""
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确认"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
            completionHandler(YES);
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action){
            completionHandler(NO);
        }]];
        
        [vc presentViewController:alertController animated:YES completion:NULL];
    }
}

//收到JS的回执脚本就会运行一次
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    [self invokeIMPFunction:message.body name:message.name];
}

#pragma mark - KVO 监听WKWebView
- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"estimatedProgress", @"title", nil];
}

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [_webView addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        @try {
            [_webView removeObserver:self forKeyPath:keyPath];
        } @catch (NSException *exception) {
            SP_LOG(@"%d %s %@",__LINE__,__PRETTY_FUNCTION__,[exception description]);
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateUIForWKWebView:) withObject:object waitUntilDone:NO];
    } else {
        [self updateUIForWKWebView:object];
    }
}

#pragma mark - Private

- (void)registerFunction
{
    LSPWebWeakScriptMessageDelegate *scriptMsgDelegate = [[LSPWebWeakScriptMessageDelegate alloc] initWithDelegate:self];
    
    WKUserContentController *userContentController = _webView.configuration.userContentController?:[WKUserContentController new];
    _webView.configuration.userContentController = userContentController;
    if (self.delegate && [self.delegate respondsToSelector:@selector(registerJavascriptName)]) {
        [[self.delegate registerJavascriptName] enumerateObjectsUsingBlock:^(NSString * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
            //window.webkit.messageHandlers.<name>.postMessage(<messageBody>)
            //其中<name>，就是上面方法里的第二个参数`name`。
            //例如我们调用API的时候第二个参数填@"Share"，那么在JS里就是:
            //window.webkit.messageHandlers.Share.postMessage(<messageBody>)
            //(<messageBody>)是一个键值对，键是body，值可以有多种类型的参数。
            // 在`WKScriptMessageHandler`协议中，我们可以看到mssage是`WKScriptMessage`类型，有一个属性叫body。
            // 而注释里写明了body 的类型：Allowed types are NSNumber, NSString, NSDate, NSArray, NSDictionary, and NSNull.
            //            function shareClick() {
            //    window.webkit.messageHandlers.Share.postMessage({title:'测试分享的标题',content:'测试分享的内容',url:'http://www.baidu.com'});
            //            }
            [userContentController removeScriptMessageHandlerForName:name];
            [userContentController addScriptMessageHandler:scriptMsgDelegate name:name];
        }];
    }
}

- (void)registerNativeHelperJS
{
    NSString *file = [[NSBundle mainBundle]pathForResource:@"spnativehelper" ofType:@"js"];
    if (file) {
        NSString *js = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
        [self evaluateJavaScript:js];
    }
    else{
        NSURL *url = [[LSPWebView bundleForName:@"SPWebView"] URLForResource:@"spnativehelper" withExtension:@"js"];
        NSString *js = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        [self evaluateJavaScript:js];
    }
}

- (void)updateUIForWKWebView:(WKWebView *)web
{
    float progress =web.estimatedProgress;
    if (_progressView) {
        if (progress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self->_progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self->_progressView setProgress:0.0f animated:NO];
            }];
        }else{
            [_progressView setAlpha:1.0f];
            BOOL animated = progress > _progressView.progress;
            [_progressView setProgress:progress animated:animated];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(webView:updateProgress:)]) {
        [self.delegate webView:web updateProgress:progress];
    }
}

- (void)invokeIMPFunction:(id)body name:(NSString *)name{
    NSObject *observe  = [self.delegate registerJavaScriptHandler];
    if (observe) {
        SEL selector;
        id param = nil;
        if ([body isKindOfClass:[NSString class]] && ![body isEqualToString:@""]) {
            param = [self objectWithJsonString:body];
        }else if ([body isKindOfClass:[NSDictionary class]] && ((NSDictionary*)body).allKeys.count>0){
            param = body;
        }
        if (param) {
            //有参数，创建带有参数的方法
            selector = NSSelectorFromString([name stringByAppendingString:@":"]);
        }else{
            //创建无参数方法
            selector = NSSelectorFromString(name);
        }
        if ([observe respondsToSelector:selector]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                IMP imp = [observe methodForSelector:selector];
                if (param) {
                    void (*func)(id, SEL, id) = (void *)imp;
                    func(observe, selector,param);
                }else{
                    void (*func)(id, SEL) = (void *)imp;
                    func(observe, selector);
                }
            });
        }
    }
}

- (id)objectWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        SP_LOG(@"json解析失败：%@",err);
        return nil;
    }
    return object;
}

-(void)configUserAgentByAppend:(NSString *)userAgetString
{
    if (!userAgetString || userAgetString.length == 0) {
        return;
    }
    double version = [UIDevice currentDevice].systemVersion.doubleValue;
    if (version > 12.0 && version < 13.0) {
        [self creatWebview_userAgent:userAgetString];
    } else {
        [self config_WKWebView:self.webView userAgent:userAgetString completionHandler:nil];
    }
}

-(void)creatWebview_userAgent:(NSString*)userAgent
{
    //在设置UA之前先创建一个假的webview一步设置ua，然后再设置本地的UA
    WKWebView *wkwebview = nil;
    if (self.instanceWebView) {
        wkwebview = self.instanceWebView;
    }else{
        wkwebview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, LSP_SCREEN_WIDTH, LSP_SCREEN_HEIGHT) configuration:[self wkWebViewconfiguration]];
        self.instanceWebView = wkwebview;
    }
    __weak typeof(self) weak_self = self;
    [self config_WKWebView:wkwebview userAgent:userAgent completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self config_WKWebView:strong_self.webView userAgent:userAgent completionHandler:nil];
    }];
}

-(void)config_WKWebView:(WKWebView*)wkwebview userAgent:(NSString*)userAgent completionHandler:(void (^)( NSString *_Nullable result, NSError * _Nullable error))completionHandler
{
    //配置UA的方法参考https://www.jianshu.com/p/50246a8aaddb
    if (!userAgent) {
        wkwebview.customUserAgent = nil;
        return;
    }
    __weak __typeof(wkwebview) weak_wkwebview = wkwebview;
    [wkwebview evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *result, NSError *error) {
        if (result.length>0){
            NSMutableString *mStr = [NSMutableString stringWithString:result];
            //如果result里面不包含Device说明还没设置过UA，所以第一次设置
            if (![result containsString:userAgent] && userAgent.length>0) {
                [mStr appendString:[NSString stringWithFormat:@" %@",userAgent]];
                //                NSDictionary *dictionary = @{@"UserAgent":mStr};
                //                //写入到本地序列化，可能会影响其他当前APP其他WKWebView浏览器的UA参数
                //                [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
                //                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            weak_wkwebview.customUserAgent = mStr;
        }
        else if(userAgent.length>0){
            NSMutableString *mStr = [NSMutableString stringWithString:userAgent];
            weak_wkwebview.customUserAgent = mStr;
        }
    }];
    
    wkwebview.configuration.applicationNameForUserAgent = userAgent;
}

-(void)clearCookie
{
    //allWebsiteDataTypes清除所有缓存
    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] removeCookiesSinceDate:dateFrom];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
    }];
    
    [self removeCookieWith:self.webView.configuration];
}

- (void)configCookieWith:(WKWebViewConfiguration *)configuration
{
    if (!configuration) {
        return;
    }
    
    WKUserContentController *userContentController = configuration.userContentController?:[[WKUserContentController alloc] init];
    configuration.userContentController = userContentController;
    
    NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    for (NSHTTPCookie *cookie in cookies) {
        NSString *cookieStr = [NSString stringWithFormat:@"document.cookie='%@=%@'",cookie.name,cookie.value];
        WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:cookieScript];
    }
    
    if (@available(iOS 11.0, *)) {
        WKHTTPCookieStore *cookieStroe = configuration.websiteDataStore.httpCookieStore;
        for (NSHTTPCookie *cookie in cookies) {
            [cookieStroe setCookie:cookie completionHandler:^{
            }];
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)removeCookieWith:(WKWebViewConfiguration *)configuration
{
    if (!configuration) {
        return;
    }
    
    WKUserContentController *userContentController = configuration.userContentController;
    if (!userContentController) {
        return;
    }
    
    [userContentController removeAllUserScripts];
}

#pragma mark - Getter & Setter
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.webView.frame = self.bounds;
    if (_progressView) {
        _progressView.frame = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, self.bounds.size.width, _progressView.frame.size.height);
    }
}

-(void)setIsShowProgressView:(BOOL)isShowProgressView
{
    _isShowProgressView = isShowProgressView;
    if (_isShowProgressView) {
        [self addSubview:self.progressView];
    }
    else{
        if (_progressView) {
            [_progressView removeFromSuperview];
        }
    }
}

-(void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    if (_progressView) {
        _progressView.progressTintColor = _progressColor;
    }
}

-(void)setUseCookie:(BOOL)useCookie
{
    _useCookie = useCookie;
    if (_useCookie) {
        [self configCookieWith:self.webView.configuration];
    }
}

- (WKWebViewConfiguration *)wkWebViewconfiguration
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = [[WKPreferences alloc]init];
    configuration.preferences.minimumFontSize = 10;
    configuration.preferences.javaScriptEnabled = true;
    // 默认是不能通过JS自动打开窗口的，必须通过用户交互才能打开
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.allowsInlineMediaPlayback = YES;
    configuration.processPool = [self.class wkProcessPool];
    return configuration;
}

-(UIProgressView*)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 2)];
        [_progressView setTrackTintColor:[UIColor clearColor]];
        _progressView.progressTintColor = self.progressColor;
        _progressView.backgroundColor = [UIColor clearColor];
    }
    return _progressView;
}

- (NSString *)title{
    return _webView.title;
}

- (NSURL *)URL{
    return _webView.URL;
}

-(WKWebView*)webView
{
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:[self wkWebViewconfiguration]];
        //        _webView.allowsBackForwardNavigationGestures =YES;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
    }
    return _webView;
}

+(WKProcessPool*)wkProcessPool{
    static dispatch_once_t once;
    static WKProcessPool * __singleton__;
    dispatch_once( &once, ^{
        __singleton__ = [[WKProcessPool alloc] init];
    });
    return __singleton__;
}

+ (NSBundle *)bundleForName:(NSString *)bundleName{
    NSString *pathComponent = [NSString stringWithFormat:@"%@.bundle", bundleName];
    NSString *bundlePath =[[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:pathComponent];
    NSBundle *customizedBundle = [NSBundle bundleWithPath:bundlePath];
    return customizedBundle;
}

@end
