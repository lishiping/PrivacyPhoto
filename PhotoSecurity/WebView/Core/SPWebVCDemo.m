//
//  SPWebVCDemo.m
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


#import "SPWebVCDemo.h"

@interface SPWebVCDemo ()

@end

@implementation SPWebVCDemo


- (void)viewDidLoad{
    [super viewDidLoad];
    
//    NSBundle *bundle = [SPWebView bundleForName:@"SPWebView"];
//    NSString *url =  [NSBundle pathForResource:@"sppointIcon@2x" ofType:@"png" inDirectory:bundle.bundlePath];
//
//    UIImage *image = [[UIImage imageWithContentsOfFile:url] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

//    UIButton *callJS = [UIButton buttonWithType:UIButtonTypeCustom];
//    callJS.frame = CGRectMake(0, 0, 22, 44);
////    [callJS setImage:image forState:UIControlStateNormal];
////    [callJS setTitle:@"调用JS方法" forState:UIControlStateNormal];
//    [callJS setImage:[UIImage imageNamed:@"icon-more"] forState:UIControlStateNormal];
//    [callJS addTarget:self action:@selector(callJS) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithCustomView:callJS];
//    self.navigationItem.rightBarButtonItem = right;
}

#pragma mark -
- (void)callJS{
    //OC 调用JS代码，OC以字符串的形式向JS注入JS方法
//    [self invokeJavaScript:@"callFromOC('I am iOS,OC invoke JS')"];
    
    // 必须要提供url 才会显示分享标签否则只显示图片
    // 设置分享内容
//        NSArray *activityItems = @[self.URL];
//    // 创建分享的视图控制器
//        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    // 操作回调，执行完成后调用
//        activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable CLActivityType, BOOL SDImageLoader, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
//        };
//    // 模态显示视图控制器
//        [self presentViewController:activityVC animated:YES completion:nil];
}

//JS invoke OC Code (JS调用OC代码)
//OC代码的实现,继承SPWebViewController则只需要实现注册名称和注册接收方法的实现。
/****************************JS invoke OC**********************/

- (NSArray<NSString *> *)registerJavascriptName{
    return @[@"fetchMessage",@"showJSData"];
}
//fetchMessage 要与上面数组返回字符串名字对应
- (void)fetchMessage:(NSDictionary *)dic{
    NSLog(@"%@", dic);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"I got message from js about =%@",dic] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)showJSData{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"Show Function"] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

/****************************JS invoke OC**********************/


@end
