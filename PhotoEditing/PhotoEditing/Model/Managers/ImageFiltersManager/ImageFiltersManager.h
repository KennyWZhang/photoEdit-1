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

+ (instancetype)sharedInstance;
- (UIImage *)processUsingPixels:(UIImage *)inputImage;

@end
