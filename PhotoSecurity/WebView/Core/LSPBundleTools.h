//
//  LSPBundleTools.h
//
//  Created by lishiping on 2020/10/14.
//  Copyright © 2019 lishiping. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//读取图片的宏
#define LSP_IMAGE(__bundle,__imgName)    [LSPBundleTools getImageBundle:__bundle imageName:__imgName]

//读取路径的宏
#define LSP_BUNDLE_PATH(__bundle,__fileName)    [LSPBundleTools getPathBundle:__bundle fileName:__fileName]

//读取资源包的宏
#define LSP_MAIN_BUNDLE(__bundle)    [LSPBundleTools getMainBundle:__bundle]

NS_ASSUME_NONNULL_BEGIN

@interface LSPBundleTools : NSObject

+ (NSBundle *)getMainBundle:(NSString *)bundleName;

/// lsp增加通用的读取bundle文件路径的方法
/// @param bundleName bundle名字
/// @param name 文件名字带有文件类型后缀的
+ (NSString *)getPathBundle:(NSString *)bundleName fileName:(NSString *)name;

+ (UIImage *)getImageBundle:(NSString *)bundleName imageName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
