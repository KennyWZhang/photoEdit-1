//
//  ImageDemonstrateController.m
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/25/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import "ImageDemonstrateController.h"
#import "ImageFiltersManager.h"

@interface ImageDemonstrateController ()

@property (nonatomic, weak) IBOutlet UIImageView *currentImageView;

@end

@implementation ImageDemonstrateController

+ (NSString *)storyBoardID
{
    return @"ImageDemonstrateController";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
}

#pragma mark - private methods

- (IBAction)processPhoto:(id)sender
{
    self.currentImageView.image = [[ImageFiltersManager sharedInstance] processBlurFilterUsingPixels:self.currentImage];
    self.currentImage = self.currentImageView.image;
}

- (void)prepareViewController
{
    self.currentImageView.image = self.currentImage;
}

@end
