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
- (UIImage *)createImageWithUIImage:(UIImage *)originalImage withFilter:(NSString *)filter;
- (UIImage *)processBlackFilterUsingPixels:(UIImage *)inputImage;
- (UIImage *)processBlurFilterUsingPixels:(UIImage *)inputImage;
- (UIImage *)processMotionBlurFilterUsingPixels:(UIImage *)inputImage;
- (UIImage *)processSharpFilterUsingPixels:(UIImage *)inputImage;

@end
