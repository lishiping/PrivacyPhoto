//
//  LSPBundleTools.m
//
//  Created by lishiping on 2020/10/14.
//  Copyright © 2019 lishiping. All rights reserved.
//

#import "LSPBundleTools.h"

@implementation LSPBundleTools

+ (NSBundle *)getMainBundle:(NSString *)bundleName
{
    return [self getMainBundle:bundleName cls:self.class];
}

+ (NSBundle *)getMainBundle:(NSString *)bundleName cls:(Class)c {
    NSBundle *b = [NSBundle bundleForClass:[c class]];
    NSURL *url = [b URLForResource:bundleName withExtension:@"bundle"];
    NSBundle *b1 = [NSBundle bundleWithURL:url];
    return b1;
    
}
+ (UIImage *)getImageBundle:(NSString *)bundleName imageName:(NSString *)name
{
    return [self getImageBundle:bundleName cls:self.class imageName:name type:@"png"];
}

+ (NSString *)getPathBundle:(NSString *)bundleName fileName:(NSString *)name
{
    NSBundle *b = [NSBundle bundleForClass:self];
    NSURL *url = [b URLForResource:bundleName withExtension:@"bundle"];
    NSBundle *b1 = [NSBundle bundleWithURL:url];
    NSString *p = [b1 pathForResource:name ofType:nil];
    return p;
}

+ (UIImage *)getImageBundle:(NSString *)bundleName cls:(Class)c imageName:(NSString *)name {
    return [self getImageBundle:bundleName cls:c imageName:name type:@"png"];
}

+ (UIImage *)getImageBundle:(NSString *)bundleName cls:(Class)c imageName:(NSString *)name type:(NSString *)type {
    NSBundle *b = [NSBundle bundleForClass:[c class]];
    NSURL *url = [b URLForResource:bundleName withExtension:@"bundle"];
    NSBundle *b1 = [NSBundle bundleWithURL:url];
    NSString *p = nil;
    if ([UIScreen mainScreen].scale == 3) {
        p = [b1 pathForResource:[name stringByAppendingString:@"@3x"] ofType:type];
    }else{
        p = [b1 pathForResource:[name stringByAppendingString:@"@2x"] ofType:type];
    }
    
    if (!p) {
        p = [b1 pathForResource:name ofType:type];
    }
    return [UIImage imageWithContentsOfFile:p];
}

@end
