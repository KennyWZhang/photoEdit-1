//
//  ImageFiltersManager.m
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/25/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import "ImageFiltersManager.h"
#import <UIKit/UIKit.h>

@implementation ImageFiltersManager

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _filtersName = @[@"Grey",@"Blur",@"Motion Blur",@"Sharp"];
    }
    
    return self;
}

- (UIImage *)createImageWithUIImage:(UIImage *)originalImage withFilter:(NSString *)filter;
{
    if ([filter isEqualToString:@"Grey"])
        return [self processBlackFilterUsingPixels:originalImage];
    else if ([filter isEqualToString:@"Blur"])
        return [self processBlurFilterUsingPixels:originalImage];
    else if ([filter isEqualToString:@"Motion Blur"])
        return [self processMotionBlurFilterUsingPixels:originalImage];
    else if ([filter isEqualToString:@"Sharp"])
        return [self processSharpFilterUsingPixels:originalImage];
    else
        return nil;
}

static const int filterMatrixSize = 9;
static const int filterSmallMatrixSize = 3;
static const UInt32 blurMatrix[filterMatrixSize][filterMatrixSize] = {{1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1},{1,1,1,1,1,1,1,1,1}};
static const UInt32 motionBlurMatrix[filterMatrixSize][filterMatrixSize] = {{1,0,0,0,0,0,0,0,0},{0,1,0,0,0,0,0,0,0},{0,0,1,0,0,0,0,0,0},{0,0,0,1,0,0,0,0,0},{0,0,0,0,1,0,0,0,0},{0,0,0,0,0,1,0,0,0},{0,0,0,0,0,0,1,0,0},{0,0,0,0,0,0,0,1,0},{0,0,0,0,0,0,0,0,1}};
static const int sharpMatrix[filterSmallMatrixSize][filterSmallMatrixSize] = {{-1, -1, -1},{-1, 9, -1},{-1, -1, -1}};

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )
#define RGBMake(r, g, b) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 )




- (UIImage *)processBlackFilterUsingPixels:(UIImage *)inputImage
{
    UInt32 *inputPixels;
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//opaque type encapsulates color space information that is used to specify how Quartz interprets color information
    NSUInteger bytesPerPixel = 4;//how much byte we need for 1 pixel
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;//bytes for 1 row
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));//memory for all pixels count
    //calloc - Allocates a block of memory for an array of num elements, each of them size bytes long, and initializes all its bits to zero.
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    for (NSUInteger j = 0; j < inputHeight; j++)
    {
        for (NSUInteger i = 0; i < inputWidth; i++)
        {
            UInt32 * currentPixel = inputPixels + (j * inputWidth) + i;
            UInt32 color = *currentPixel;
            // Average of RGB = greyscale
            UInt32 averageColor = (R(color) + G(color) + B(color)) / 3.0;
            
            *currentPixel = RGBAMake(averageColor, averageColor, averageColor, A(color));
        }
    }
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];//Create a new UIImage
    //release
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    
    
    return processedImage;
}

- (UIImage *)processBlurFilterUsingPixels:(UIImage *)inputImage
{
    UInt32 *inputPixels;
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//opaque type encapsulates color space information that is used to specify how Quartz interprets color information
    NSUInteger bytesPerPixel = 4;//how much byte we need for 1 pixel
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    for (NSUInteger j = 4; j < inputHeight - 4; j++)
    {
        for (NSUInteger i = 4; i < inputWidth - 4; i++)
        {
            Float32 newRedColor = 0;
            Float32 newGreenColor = 0;
            Float32 newBlueColor = 0;
            Float32 newA = 0;

            for (int filterMatrixI = 0 ; filterMatrixI < filterMatrixSize ; filterMatrixI ++)
            {
                for (int filterMatrixJ = 0; filterMatrixJ < filterMatrixSize; filterMatrixJ ++)
                {
                    UInt32 * currentPixel = inputPixels + ((j + filterMatrixJ - 4) * inputWidth) + i + filterMatrixI - 4;
                    UInt32 color = *currentPixel;
                    newRedColor += (R(color) * blurMatrix[filterMatrixI][filterMatrixJ]);
                    newGreenColor += (G(color) * blurMatrix[filterMatrixI][filterMatrixJ]);
                    newBlueColor += (B(color)* blurMatrix[filterMatrixI][filterMatrixJ]);
                    newA += A(color);
                    
                }
            }
            newRedColor /= filterMatrixSize * filterMatrixSize;
            newGreenColor /= filterMatrixSize * filterMatrixSize;
            newBlueColor /= filterMatrixSize * filterMatrixSize;
            newA /= filterMatrixSize * filterMatrixSize;

            UInt32 *currentMainImagePixel = inputPixels + (j * inputWidth) + i;

            *currentMainImagePixel = RGBAMake((UInt32)newRedColor, (UInt32)newGreenColor, (UInt32)newBlueColor, (UInt32)newA);
        }
    }
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    
    return processedImage;
}

- (UIImage *)processMotionBlurFilterUsingPixels:(UIImage *)inputImage
{
    UInt32 *inputPixels;
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//opaque type encapsulates color space information that is used to specify how Quartz interprets color information
    NSUInteger bytesPerPixel = 4;//how much byte we need for 1 pixel
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    for (NSUInteger j = 4; j < inputHeight - 4; j++)
    {
        for (NSUInteger i = 4; i < inputWidth - 4; i++)
        {
            Float32 newRedColor = 0;
            Float32 newGreenColor = 0;
            Float32 newBlueColor = 0;
            Float32 newA = 0;
            
            for (int filterMatrixI = 0 ; filterMatrixI < filterMatrixSize ; filterMatrixI ++)
            {
                for (int filterMatrixJ = 0; filterMatrixJ < filterMatrixSize; filterMatrixJ ++)
                {
                    UInt32 * currentPixel = inputPixels + ((j + filterMatrixJ - 4) * inputWidth) + i + filterMatrixI - 4;
                    UInt32 color = *currentPixel;
                    newRedColor += (R(color) * motionBlurMatrix[filterMatrixI][filterMatrixJ]);
                    newGreenColor += (G(color) * motionBlurMatrix[filterMatrixI][filterMatrixJ]);
                    newBlueColor += (B(color)* motionBlurMatrix[filterMatrixI][filterMatrixJ]);
                    newA += (A(color) * motionBlurMatrix[filterMatrixI][filterMatrixJ]);
                }
            }
            newRedColor /= filterMatrixSize ;
            newGreenColor /= filterMatrixSize;
            newBlueColor /= filterMatrixSize ;
            newA /= filterMatrixSize;
            
            UInt32 *currentMainImagePixel = inputPixels + (j * inputWidth) + i;
            
            *currentMainImagePixel = RGBAMake(MIN((UInt32)newRedColor,255), MIN((UInt32)newGreenColor,255), MIN((UInt32)newBlueColor,255), (UInt32)newA);
        }
    }
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    
    return processedImage;
}

- (UIImage *)processSharpFilterUsingPixels:(UIImage *)inputImage
{
    UInt32 *inputPixels;
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImage);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImage);
    
    for (NSUInteger j = 1; j < inputHeight - 1; j++)
    {
        for (NSUInteger i = 1; i < inputWidth - 1; i++)
        {
            Float32 newRedColor = 0;
            Float32 newGreenColor = 0;
            Float32 newBlueColor = 0;
            Float32 newA = 0;
            
            for (int filterMatrixI = 0 ; filterMatrixI < filterSmallMatrixSize ; filterMatrixI ++)
            {
                for (int filterMatrixJ = 0; filterMatrixJ < filterSmallMatrixSize; filterMatrixJ ++)
                {
                    UInt32 * currentPixel = inputPixels + ((j + filterMatrixJ - 1) * inputWidth) + i + filterMatrixI - 1;
                    int color = *currentPixel;
                    newRedColor += (R(color) * sharpMatrix[filterMatrixI][filterMatrixJ]);
                    newGreenColor += (G(color) * sharpMatrix[filterMatrixI][filterMatrixJ]);
                    newBlueColor += (B(color)* sharpMatrix[filterMatrixI][filterMatrixJ]);
                     newA += (A(color) * sharpMatrix[filterMatrixI][filterMatrixJ]);
                }
            }
            
            int r = 0;
            int b = 0;
            int g = 0;
            int a = 0;
            
            
            if (newRedColor < 0 || newRedColor > 255)
                r = (int)(((newRedColor + 2040.0) * 255.0)/4335.0);
            else
                r = MAX( MIN((int)newRedColor,255), 0);
            
            if (newBlueColor < 0 || newBlueColor > 255)
                b = (int)(((newBlueColor + 2040.0) * 255.0)/4335.0);
            else
                b = MAX( MIN((int)newBlueColor,255), 0);
            
            if (newGreenColor < 0 || newGreenColor > 255)
                g = (int)(((newGreenColor + 2040.0) * 255.0)/4335.0);
            else
                g = MAX( MIN((int)newGreenColor,255), 0);
            
            if (newA < 0 || newA > 255)
                a = (int)(((newA + 2040.0) * 255.0)/4335.0);
            else
                a = MAX( MIN((int)newA,255), 0);

            a = 255;
            UInt32 *currentMainImagePixel = inputPixels + (j * inputWidth) + i;
            *currentMainImagePixel = RGBAMake(r,g,b,a);
        }
    }
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    
    return processedImage;
}

#undef RGBAMake
#undef R
#undef G
#undef B
#undef A
#undef Mask8

@end
