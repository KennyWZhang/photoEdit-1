//
//  ImageFilterCollectionViewCell.h
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/30/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageFilterCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *filterName;

+ (NSString *)storyboardID;
+ (UINib *)cellNib;

@end
