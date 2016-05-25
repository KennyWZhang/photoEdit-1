//
//  ImageDemonstrateController.h
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/25/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDemonstrateController : UIViewController

@property (nonatomic, strong) UIImage *currentImage; // need hold this property in header bc we will set data from other controller

+ (NSString *)storyBoardID;

@end
