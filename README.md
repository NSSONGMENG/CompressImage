# 压缩图片的正确姿势

## 概念分析

明确压缩和缩放两个概念

    压缩：通过降低图片的质量，将图片的数据流长度缩减到一定范围内。
    缩放：等比缩小图片尺寸（宽和高等比缩小）。

图片的内存开销：即为了渲染或压缩图片需将其解码，内存开销主要是指解码后bitmap占用的内存空间。

bitmap大小的计算公式为：

 **bitmapSize = pixelCount \* pixelSize \* frameCount**

因此影响bitmap大小的因素有下：

    1.  图片的数量（UIImage有个images成员，一般为count为1）
    
    2.  像素数（宽x高）
    
    3.  像素的色彩空间（可以认为是固定的RGBA）
    
    4.  色彩空间每个元素占用的空间（可以认为是固定的8bit）
    

**由以上概念解释可得出两个重要结论：**

1.  **图片数据量的大小与图片位图的内存开销没有必然联系**
    
2.  **影响图片位图内存开销的核心因素是像素数，即图片尺寸**


## 处理大图的正确姿势

当图片尺寸非常大的时候，压缩和查看均会带来巨大的内存开销（pixelCount \* 4 >> 20 MB），在内存高位情况下发送或查看大尺寸图片可能造成OOM现象。因此应慎重考虑对图片的处理应该仅压缩数据量，还是一并考虑对尺寸进行限制。合理的方案一定是在考虑App稳定性的基础上优化数据流量，因为稳定性存在问题的情况下，其他一切都是空谈。

1.  缩放到指定尺寸，该尺寸下不会导致过大的内存开销
2.  在第一补的基础上尽量压缩到指定数据量范围
    

    Q：为何先缩放？

    A：压缩必然涉及解码，解码大尺寸图片带来的内存开销更大

    Q：缩放图片时用图片的NSData数据还是UIImage对象

    A：若使用CoreGraphics重绘参数为UIImage对象和data流都可以；若使用ImageIO缩放，参数应为NSData数据，因为ImageIO需要的参数为NSData，而UIImage对象转NSData涉及图片解码，会带来额外的内存开销。


## 如何处理网图

SDWebImage库有如下代码：
```Objective-C
/*
 * Defines the maximum size in MB of the decoded image when the flag `SDWebImageScaleDownLargeImages` is set
 * Suggested value for iPad1 and iPhone 3GS: 60.
 * Suggested value for iPad2 and iPhone 4: 120.
 * Suggested value for iPhone 3G and iPod 2 and earlier devices: 30.
 */
#if SD_MAC
static CGFloat kDestImageLimitBytes = 90.f * kBytesPerMB;
#elif SD_UIKIT
static CGFloat kDestImageLimitBytes = 60.f * kBytesPerMB;
#elif SD_WATCH
static CGFloat kDestImageLimitBytes = 30.f * kBytesPerMB;
#endif
```

即在在加载图片时options选项中包含`SDWebImageScaleDownLargeImages`时会对大图进行等比缩放，默认标准是图片的bitmap占用内存不超过60MB，当然可以通过`SDImageCoderHelper`的方法重置。

```Objective-C

+ (void)setDefaultScaleDownLimitBytes:(NSUInteger)defaultScaleDownLimitBytes {
    if (defaultScaleDownLimitBytes < kBytesPerPixel) {
        return;
    }
    kDestImageLimitBytes = defaultScaleDownLimitBytes;
}
```
