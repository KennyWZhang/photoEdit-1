//
//  ImageFiltersManager.h
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/25/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageFiltersManager : NSObject

@property (nonatomic, strong) NSArray *filtersName;

+ (instancetype)sharedInstance;
- (UIImage *)createImageWithUIImage:(UIImage *)originalImage withFilter:(NSString *)filter depth:(NSInteger)depth;
- (UIImage *)processBlackFilterUsingPixels:(UIImage *)inputImage withDepth:(NSUInteger)depth;
- (UIImage *)processBlurFilterUsingPixels:(UIImage *)inputImage;
- (UIImage *)processMotionBlurFilterUsingPixels:(UIImage *)inputImage;
- (UIImage *)processSharpFilterUsingPixels:(UIImage *)inputImage;
- (UIImage *)processEdgeDetectionFilterUsingPixels:(UIImage *)inputImage;
- (UIImage *)processEmbossFilterUsingPixels:(UIImage *)inputImage;

@end
