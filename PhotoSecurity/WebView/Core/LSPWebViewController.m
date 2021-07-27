//
//  LSPWebViewController.m
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

#import "LSPWebViewController.h"
#import <SPMacro.h>
#import <SPFastPush.h>
#import <SPSafeData.h>
#import "NSDictionary+SPSafe.h"
#import "LSPBundleTools.h"
#import "LSPWebSheetView.h"
#import "UIImage+Util.h"
#import "UIBarButtonItem+JItem.h"

@interface LSPWebViewController ()<LSPWebViewDelegate>

@property (nonatomic,strong)UIBarButtonItem* customBackBarItem;
@property (nonatomic,strong)UIBarButtonItem* closeButtonItem;
@property (nonatomic,strong)UIBarButtonItem* rightButtonItem;
@property (nonatomic, strong) LSPWebView *webView;

@property (nonatomic, strong) NSURL *URL;

@end

@implementation LSPWebViewController

#pragma mark - init

-(instancetype)initWithURL:(NSURL *)URL
{
    self = [self init];
    _URL = URL;
    return self;
}

-(instancetype)init
{
    self = [super init];
    _useGoback = NO;
    _isHiddenProgressView = NO;
    _progressViewColor = SP_COLOR_HEX_STR(@"#43c6ac");
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self initialize];
    
    [self loadCurrentURL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    SP_SUPER_LOG(@"正常释放");
}

#pragma mark - initialize
- (void)initialize
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //是否使用返回goback风格
    if (_useGoback) {
        [self updateNavigationItems];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = self.customBackBarItem;
    }
    if (_isShowRightItem) {
        self.navigationItem.rightBarButtonItem = self.rightButtonItem;
    }
}
-(void)loadURL:(NSURL *)url
{
    if (url && ![url.absoluteString isEqualToString:self.URL.absoluteString]) {
        self.URL = url;
        [self loadCurrentURL];
    }
}

-(void)loadCurrentURL
{
    if (self.URL) {
        [self.webView loadURL:self.URL];
    }
}

-(void)refreshURL
{
    if (self.webView.URL) {
        [self.webView loadURL:self.webView.URL];
    }else{
        [self loadCurrentURL];
    }
}

#pragma mark - setter & getter method

-(void)setProgressViewColor:(UIColor *)progressViewColor{
    _progressViewColor = progressViewColor;
}

-(LSPWebView*)webView
{
    if (!_webView) {
        CGFloat y =[self isNavigationHidden] ? SP_STATUSBAR_HEIGHT : SP_NAVIBAR_STATUSBAR_HEIGHT;
        CGRect rect = CGRectMake(0,y, SP_SCREEN_WIDTH,SP_SCREEN_HEIGHT-y);
        _webView = [[LSPWebView alloc] initWithFrame:rect];
        _webView.progressColor = _progressViewColor;
        _webView.isShowProgressView = YES;
        _webView.delegate = self;
        _webView.panelViewController = self;
    }
    return _webView;
}

-(UIBarButtonItem*)customBackBarItem
{
    if (!_customBackBarItem) {
        SP_WEAK_SELF
        UIImage *image = [LSPBundleTools getImageBundle:@"SPWebView" imageName:@"spbackIcon@2x"];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithImage:image color:UIColor.blackColor click:^(id object) {
            [weak_self customBackItemClicked];
        }];
    }
    return _customBackBarItem;
}

-(UIBarButtonItem*)closeButtonItem
{
    if (!_closeButtonItem) {
        UIImage *image = [LSPBundleTools getImageBundle:@"SPWebView" imageName:@"delete"];
        image = [image imageWithColor:UIColor.whiteColor];
        _closeButtonItem = [[UIBarButtonItem alloc] initWithImage:image color:UIColor.blackColor click:^(id object) {
            SP_POP_TO_LAST_VC
        }];
    }
    return _closeButtonItem;
}

-(UIBarButtonItem*)rightButtonItem
{
    if (!_rightButtonItem) {
        SP_WEAK_SELF
        UIImage *image = [LSPBundleTools getImageBundle:@"SPWebView" imageName:@"sppointIcon@2x"];
        _rightButtonItem = [[UIBarButtonItem alloc] initWithImage:image color:UIColor.blackColor click:^(id object) {
            [weak_self showSheetView];
        }];
    }
    return _rightButtonItem;
}

-(void)updateNavigationItems
{
    if (self.webView.canGoBack) {
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem,self.closeButtonItem] animated:NO];
    }else{
        self.navigationItem.leftBarButtonItem = self.customBackBarItem;
    }
}

#pragma mark - click event
-(void)customBackItemClicked
{
    if (self.webView.canGoBack && _useGoback)
    {
        [self.webView goBack];
        [self updateNavigationItems];
    }
    else
    {
        [self closeItemClicked];
    }
}

-(void)closeItemClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showSheetView
{
    SP_WEAK_SELF
    LSPWebSheetView *sheet = [[LSPWebSheetView alloc] initWithBoxViewMargin:SP_SCREEN_HEIGHT-200 popDirection:LSPAutoPopFromDown parentViewSize:self.view.frame.size];
    sheet.refreshBlock = ^{
        [weak_self refreshURL];
    };
    sheet.copyBlock = ^{
        if (weak_self.webView.URL.absoluteString) {
            [UIPasteboard generalPasteboard].string = weak_self.webView.URL.absoluteString;
            [XPProgressHUD showToast:@"已复制到剪切板"];
        }
    };
    [sheet showOnParentView:self.view];
}

#pragma mark - WebViewDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView.title.length >0) {
        self.title = webView.title;
    }else{
        self.title = @"";
    }
}
/**
 * @brief Register Invoke JavaScript observe（指定接收对象，当前设置为self，也可以指给其他对象，在其他对象中实现注册名称和注册名称的实现方法）
 */
- (NSObject *)registerJavaScriptHandler{
    return self;
}

- (NSArray <NSString *>*)registerJavascriptName{
    return nil;
}

#pragma mark - Public
- (void)callFromNative:(NSString *)method params:(NSDictionary*)params
{
    return [self callFromNative:method params:params completionHandler:nil];
}

- (void)callFromNative:(NSString *)method params:(NSDictionary*)params completionHandler:(void (^)( id, NSError * error))completionHandler
{
    if (method.length>0)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setObject:method forKey:@"method"];
        NSString *paramstr = params.safe_toJSONString_UTF8;
        if (paramstr.length>0) {
            [dict setObject:paramstr forKey:@"params"];
        }
        NSString *jsString = [NSString stringWithFormat:@"callFromNative('%@')",dict.safe_toJSONString_UTF8];
        [self evaluateJavaScript:jsString completionHandler:completionHandler];
    }
}

- (void)evaluateJavaScript:(NSString *)function{
    [self.webView evaluateJavaScript:function];
}

- (void)evaluateJavaScript:(NSString *)function completionHandler:(void (^)( id, NSError * error))completionHandler{
    [self.webView evaluateJavaScript:function completionHandler:completionHandler];
}

#pragma mark Private
- (BOOL)isNavigationHidden
{
    return self.navigationController.navigationBar.hidden;
}

@end
