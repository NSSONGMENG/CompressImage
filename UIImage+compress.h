//
//  UIImage+compress.h
//  ShadowDemo
//
//  Created by song.meng on 2023/8/31.
//  Copyright © 2023 MOMO. All rights reserved.
//
//  1byte   = 1 << 3  bit
//  1kb     = 1 << 10 byte
//  1mb     = 1 << 20 byte
//
//  使用 <<、>> 位移操作能带来相对乘除法更好性能表现
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (compress)

/// 根据宽高的最大值等比缩小图片
/// - Parameters:
///   - data: 图片数据流，通过PH框架获取的相册内容本身包含图片数据流，使用数据流可带来较好的内存表现
///   - size: 宽高的最大像素数，若大于图片实际最大值，则以实际尺寸为准，否则等比压缩
+ (UIImage *)scaleImageWithData:(NSData *)data
                   maxPixelSize:(NSUInteger)size;

/// 根据显示图片带来的内存开销等比缩小图片
/// - Parameters:
///   - data: 图片数据流，通过PH框架获取的相册内容本身包含图片数据流，使用数据流可带来较好的内存表现
///   - kbLimit: 图片显示带来的内存开销
+ (UIImage *)scaleImageWithData:(NSData *)data
                bitmapSizeLimit:(NSUInteger)kbLimit;

/// 压缩数据量【正常从相册选择图片上传，应优先压缩尺寸获得目标产物后再压缩数据量，以达到更优的内存表现】
/// - Parameter kbLimit: 数据量限制，单位kb
- (NSData *)compressWithLimit:(NSUInteger)kbLimit;

@end

NS_ASSUME_NONNULL_END
