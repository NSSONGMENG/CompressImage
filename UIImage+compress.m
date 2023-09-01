//
//  UIImage+compress.m
//  ShadowDemo
//
//  Created by song.meng on 2023/8/31.
//  Copyright © 2023 MOMO. All rights reserved.
//

#import "UIImage+compress.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (compress)

/// 等比缩小图片，不支持等比放大
/// - Parameters:
///   - data: 图片数据流，通过PH框架获取的相册内容本身包含数据流，使用数据流可带来较好的内存表现
///   - size: 宽高的最大像素数，若大于图片实际最大值，则以实际尺寸为准，否则等比压缩
+ (UIImage *)scaleImageWithData:(NSData *)data
                   maxPixelSize:(NSUInteger)size
{
    if (!data) return nil;
    if (size <= 0) return nil;
    
    // 转成UIImage实例并不会占用很大的内存
    UIImage *img = [UIImage imageWithData:data];
    if (!img) return nil;
    
    if (MAX(CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage)) < size) {
        return img;
    }
    
    return [self _scaleImageWithData:data maxPixelSize:size];
}

/// 根据现实图片带来的内存开销等比缩小图片
/// - Parameters:
///   - data: 图片数据流，通过PH框架获取的相册内容本身包含数据流，使用数据流可带来较好的内存表现
///   - kbLimit: 图片显示带来的内存开销
+ (UIImage *)scaleImageWithData:(NSData *)data
                bitmapSizeLimit:(NSUInteger)kbLimit
{
    if (!data) return nil;
    if (kbLimit <= 0) return nil;
    
    // 转成UIImage实例并不会占用很大的内存
    UIImage *img = [UIImage imageWithData:data];
    if (!img) return nil;
    
    CGSize  oriSize = CGSizeMake(CGImageGetWidth(img.CGImage), CGImageGetHeight(img.CGImage));
    NSUInteger  oriCost = CGImageGetBytesPerRow(img.CGImage) * CGImageGetHeight(img.CGImage) >> 10; // kb
    
    if (kbLimit >= oriCost) {
        return img;
    }

    CGFloat scale = sqrt(1.0 * oriCost / kbLimit);
    
    NSUInteger  size = MAX(oriSize.width, oriSize.height);
    return [self _scaleImageWithData:data maxPixelSize:floor(size / scale)];
}


+ (UIImage *)_scaleImageWithData:(NSData *)data
                    maxPixelSize:(NSUInteger)size
{
    CFDataRef dataRef = (__bridge CFDataRef)data;
    
    CFDictionaryRef dicOptionsRef = (__bridge CFDictionaryRef) @{
                                                                 (id)kCGImageSourceCreateThumbnailFromImageIfAbsent : @(YES),
                                                                 (id)kCGImageSourceThumbnailMaxPixelSize : @(size),
                                                                 (id)kCGImageSourceShouldCache : @(NO),
                                                                 };
    CGImageSourceRef src = CGImageSourceCreateWithData(dataRef, nil);
    CGImageRef thumImg = CGImageSourceCreateThumbnailAtIndex(src, 0, dicOptionsRef);
    CFRelease(src);

    if (thumImg != nil) {
        UIImage *result = [UIImage imageWithCGImage:thumImg];
        CFRelease(thumImg);
        return result;
    }
    
    return nil;
}


- (NSData *)compressWithLimit:(NSUInteger)kbLimit
{
    NSData *aimData = nil;
    CGFloat compress = 1.0;
    int repeat = 0;
    
    while (repeat < 6 && compress > 0.25) {
        @autoreleasepool {
            aimData = UIImageJPEGRepresentation(self, compress);
                        
            if (kbLimit > 0 && (aimData.length >> 10) > kbLimit) {
                if (((aimData.length >> 10) / kbLimit) >= 2) {
                    compress -= (repeat == 0) ? 0.1 : 0.2;      // 0.9不足1.0的1/4
                } else {
                    compress -= 0.05;
                }
            } else {
                break;
            }
            
            repeat ++;
        }
    }

    return aimData;
}

@end
