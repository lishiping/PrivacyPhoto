//
//  UIImage+Util.h
//  SanChiStudent
//
//  Created by xhwl on 16/8/18.
//  Copyright © 2016年 学会未来. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)

/**
 *  根据颜色生成一张尺寸为1*1的相同颜色图片
 */
- (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color;


#pragma mark - 压缩图片
/** 压缩图片(单位B) */
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;

/**
 *  缩放图片
 */
- (UIImage *)scaleToSize:(CGSize)newSize;
// 根据宽度缩放图片
- (UIImage *)scaleToWidth:(CGFloat)width;

- (UIImage *)fixOrientation;

/**
 *  高斯模糊
 * {blurLevel | 0 ≤ t ≤ 1}
 */
- (UIImage *)gaussBlur:(CGFloat)blurLevel;

/**
 *  圆形头像的绘制
 *
 *  @param icon 头像文件名
 *  @param border  边框直径
 *  @return image
 */
+ (UIImage *)imageWithIconName:(NSString *)icon borderWidth:(CGFloat)border;
- (UIImage *)imageWithBorderWidth:(CGFloat)border;
- (UIImage *)imageWithBorderWidth:(CGFloat)border borderColor:(UIColor *)borderColor;
// 为图片添加一个边框
- (UIImage *)imageWithImageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

/** 加载本地GIF图片 */
+ (UIImage *)getLocalGIFWithFileName:(NSString *)fileName;
/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param image UIImage image 原始的图片
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
+ (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect;

// 缩放图片
- (CGFloat)zoomForHeightWithMaxWidth:(CGFloat)maxWidth;


// base64转图片
+ (UIImage *)base64StringToImage:(NSString *)base64Str;

- (UIImage *)drawImageWithSize:(CGSize)size;
+ (UIImage *)j_placeHolderImage;
+ (UIImage *)j_readingPlaceHolderImageSmall;
+ (UIImage *)j_readingPlaceHolderImageLarge;

@end
