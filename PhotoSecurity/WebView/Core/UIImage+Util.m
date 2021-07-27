//
//  UIImage+Util.m
//  SanChiStudent
//
//  Created by xhwl on 16/8/18.
//  Copyright © 2016年 学会未来. All rights reserved.
//

#import "UIImage+Util.h"
#import <Accelerate/Accelerate.h>
#import <UIImage+GIF.h>

@implementation UIImage (Util)

+ (UIImage *)imageWithColor:(UIColor *)color {
    // 描述矩形
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 获取位图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);
    // 渲染上下文
    CGContextFillRect(context, rect);
    // 从上下文中获取图片
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Private
- (UIImage *)imageForUpload:(CGFloat)suggestPixels {
    const CGFloat kMaxPixels = 4000000;
    const CGFloat kMaxRatio  = 3;
    
    CGFloat width = self.size.width;
    CGFloat height= self.size.height;
    
    //对于超过建议像素，且长宽比超过max ratio的图做特殊处理
    if (width * height > suggestPixels &&
        (width / height > kMaxRatio || height / width > kMaxRatio)) {
        return [self scaleWithMaxPixels:kMaxPixels];
    } else {
        return [self scaleWithMaxPixels:suggestPixels];
    }
}

- (UIImage *)scaleWithMaxPixels: (CGFloat)maxPixels {
    CGFloat width = self.size.width;
    CGFloat height= self.size.height;
    if (width * height < maxPixels || maxPixels == 0)
    {
        return self;
    }
    CGFloat ratio = sqrt(width * height / maxPixels);
    if (fabs(ratio - 1) <= 0.01)
    {
        return self;
    }
    CGFloat newSizeWidth = width / ratio;
    CGFloat newSizeHeight= height/ ratio;
    return [self scaleToSize:CGSizeMake(newSizeWidth, newSizeHeight)];
}

//内缩放，一条变等于最长边，另外一条小于等于最长边
- (UIImage *)scaleToSize:(CGSize)newSize {
    CGFloat width = self.size.width;
    CGFloat height= self.size.height;
    CGFloat newSizeWidth = newSize.width;
    CGFloat newSizeHeight= newSize.height;
    if (width <= newSizeWidth &&
        height <= newSizeHeight) {
        return self;
    }
    
    if (width == 0 || height == 0 || newSizeHeight == 0 || newSizeWidth == 0) {
        return nil;
    }
    CGSize size;
    if (width / height > newSizeWidth / newSizeHeight) {
        size = CGSizeMake(newSizeWidth, newSizeWidth * height / width);
    } else {
        size = CGSizeMake(newSizeHeight * width / height, newSizeHeight);
    }
    return [self drawImageWithSize:size];
}

- (UIImage *)drawImageWithSize:(CGSize)size {
    CGSize drawSize = CGSizeMake(floor(size.width), floor(size.height));
    UIGraphicsBeginImageContext(drawSize);
    
    [self drawInRect:CGRectMake(0, 0, drawSize.width, drawSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)fixOrientation {
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


#pragma mark - 压缩图片
+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}


- (UIImage *)scaleToWidth:(CGFloat)width {
    // 如果传入的宽度比当前宽度还要大,就直接返回
    if (width > self.size.width) {
        return  self;
    }
    
    // 计算缩放之后的高度
    CGFloat height = (width / self.size.width) * self.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 高斯模糊
- (UIImage *)gaussBlur:(CGFloat)blurLevel {
    blurLevel = MIN(2.0, MAX(0.0, blurLevel));
    
    int boxSize = (int)(blurLevel * 0.1 * MIN(self.size.width, self.size.height));
    boxSize = boxSize - (boxSize % 2) + 1;
    
    NSData *imageData = UIImageJPEGRepresentation(self, 1);
    UIImage *tmpImage = [UIImage imageWithData:imageData];
    
    CGImageRef img = tmpImage.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    NSInteger windowR = boxSize/2;
    CGFloat sig2 = windowR / 3.0;
    if(windowR>0){ sig2 = -1/(2*sig2*sig2); }
    
    int16_t *kernel = (int16_t*)malloc(boxSize*sizeof(int16_t));
    int32_t  sum = 0;
    for(NSInteger i=0; i<boxSize; ++i){
        kernel[i] = 255*exp(sig2*(i-windowR)*(i-windowR));
        sum += kernel[i];
    }
    
    // convolution
    error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, kernel, boxSize, 1, sum, NULL, kvImageEdgeExtend);
    error = vImageConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, kernel, 1, boxSize, sum, NULL, kvImageEdgeExtend);
    outBuffer = inBuffer;
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

/**
 *  圆形头像的绘制
 *
 *  @param icon 头像文件名
 *
 *  @return image
 */
+ (UIImage *)imageWithIconName:(NSString *)icon borderWidth:(CGFloat)border {
    UIImage *image = [UIImage imageNamed:icon];
    return [image imageWithBorderWidth:border];
}

/**
 *  圆形头像的绘制
 *  @return image
 */
- (UIImage *)imageWithBorderWidth:(CGFloat)border {
    return [self imageWithBorderWidth:border borderColor:[UIColor whiteColor]];
}

- (UIImage *)imageWithBorderWidth:(CGFloat)border borderColor:(UIColor *)borderColor {
    UIImage *borderImg = [self imageWithColor:borderColor];
    
    UIImage *image = self;
    CGSize size = CGSizeMake(image.size.width + border, image.size.height + border);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextClip(context);
    
    // 绘制边框图片
    [borderImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 设置头像
    CGFloat iconX = border*0.5;
    CGFloat iconY = border*0.5;
    CGFloat iconW = image.size.width;
    CGFloat iconH = image.size.height;
    
    //绘制圆形头像范围
    CGContextAddEllipseInRect(context, CGRectMake(iconX, iconY, iconW, iconH));
    //剪切可视范围
    CGContextClip(context);
    //绘制头像
    [image drawInRect:CGRectMake(iconX, iconY, iconW, iconH)];
    //取出整个头像上下文的图片
    UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return iconImage;
}

- (UIImage *)imageWithImageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor {
    CGSize size = CGSizeMake(imageWidth + 2 * borderWidth, imageHeight + 2 * borderWidth);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    [borderColor set];
    [path fill];
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(borderWidth, borderWidth, imageWidth, imageHeight)];
    [path addClip];
    [self drawInRect:CGRectMake(borderWidth, borderWidth, imageWidth, imageHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+ (UIImage *)getLocalGIFWithFileName:(NSString *)fileName {
//    if (fileName) {
//        return nil;
//    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@".gif"];
    NSData *gifImageData = [NSData dataWithContentsOfFile:filePath];
    return [UIImage sd_imageWithGIFData:gifImageData];
}

/**
 *  从图片中按指定的位置大小截取图片的一部分
 *
 *  @param image UIImage image 原始的图片
 *  @param rect  CGRect rect 要截取的区域
 *
 *  @return UIImage
 */
+ (UIImage *)ct_imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    //截取部分图片并生成新图片
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, dianRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    return newImage;
}

- (CGFloat)zoomForHeightWithMaxWidth:(CGFloat)maxWidth {
    if (maxWidth <= 0) {
        return 0;
    }
    if (self == nil) {
        return 0;
    }
    
    CGFloat scale = self.size.height/self.size.width;
    CGFloat imageHeight = maxWidth*scale;

    return imageHeight;
}

+ (UIImage *)base64StringToImage:(NSString *)base64Str {
    NSData *imageData =[[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *photo = [UIImage imageWithData:imageData ];
    return photo;
}

+ (UIImage *)j_placeHolderImage {
     return [UIImage imageNamed:@"app_placeholder"];
}
//+ (UIImage *)j_readingPlaceHolderImageSmall {
//    static UIImage *placeImage;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        placeImage = [UIImage imageNamed:@"app_reading_placeholder_small"];
//        placeImage = [UIImage getPlaceHolderImageWithImage:placeImage bgSize:CGSizeMake(68, 68)];
//        placeImage = [placeImage stretchableImageWithLeftCapWidth:placeImage.size.width*0.1 topCapHeight:placeImage.size.height*0.1];
//    });
//        
//    return placeImage;
//}
//+ (UIImage *)j_readingPlaceHolderImageLarge {
//    static UIImage *placeImage;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        placeImage = [UIImage imageNamed:@"app_reading_placeholder_large"];
//        placeImage = [UIImage getPlaceHolderImageWithImage:placeImage bgSize:CGSizeMake(344, 400)];
//        placeImage = [placeImage stretchableImageWithLeftCapWidth:placeImage.size.width*0.1 topCapHeight:placeImage.size.height*0.1];
//    });
//
//    return placeImage;
//}
//+ (UIImage *)getPlaceHolderImageWithImage:(UIImage *)image bgSize:(CGSize)bgSize {
//    CGFloat canvasW = bgSize.height;
//    CGFloat canvasH = bgSize.height;
//    UIGraphicsBeginImageContext(CGSizeMake(canvasW, canvasH));
//
//    UIImage *bgImage = [UIImage imageWithColor:[UIColor colorWithHex:0xF2F2F2]];
//    [bgImage drawInRect:CGRectMake(0, 0, canvasW, canvasH)];
//
//    CGFloat imageW = image.size.width;
//    CGFloat imageH = image.size.height;
//    CGFloat imageX = (canvasW-imageW)*0.5;
//    CGFloat imageY = (canvasH-imageW)*0.5;
//    [image drawInRect:CGRectMake(imageX, imageY, imageW, imageH)];
//
//    UIImage *placeImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return placeImage;
//}

@end
