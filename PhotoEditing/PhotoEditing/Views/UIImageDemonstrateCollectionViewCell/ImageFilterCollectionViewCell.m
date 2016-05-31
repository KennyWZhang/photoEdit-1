//
//  ImageFilterCollectionViewCell.m
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/30/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import "ImageFilterCollectionViewCell.h"
#import <UIKit/UIKit.h>

@interface ImageFilterCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic,readwrite) IBOutlet UILabel *filterNameLabel;

@end

@implementation ImageFilterCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

+ (NSString *)storyboardID
{
    return @"ImageFilterCollectionViewCell";
}

+ (UINib *)cellNib
{
    return [UINib nibWithNibName:@"ImageFilterCollectionViewCell" bundle:nil];
}

- (void)setFilterName:(NSString *)name
{
    _filterName = name;
    self.filterNameLabel.text = name;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = _image;
}

@end
