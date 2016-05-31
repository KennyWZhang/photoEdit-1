//
//  ImageDemonstrateController.m
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/25/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import "ImageDemonstrateController.h"
#import "ImageFiltersManager.h"
#import "ImageFilterCollectionViewCell.h"

@interface ImageDemonstrateController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIImageView *currentImageView;
@property (nonatomic, weak) IBOutlet UICollectionView *filterCollectionView;
@property (nonatomic, strong) NSArray<NSString *> *filtersNameDataSource;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

static const CGFloat kCollectionViewInset = 10.0;

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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filtersNameDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageFilterCollectionViewCell *cell = [self.filterCollectionView dequeueReusableCellWithReuseIdentifier:[ImageFilterCollectionViewCell storyboardID] forIndexPath:indexPath];
    cell.filterName = self.filtersNameDataSource[indexPath.row];
    [cell.activityIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [[ImageFiltersManager sharedInstance] createImageWithUIImage:self.currentImage withFilter:self.filtersNameDataSource[indexPath.row]];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.image = image;
            [cell.activityIndicator stopAnimating];
        });
    });
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.filterCollectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [[ImageFiltersManager sharedInstance] createImageWithUIImage:self.currentImage withFilter:self.filtersNameDataSource[indexPath.row]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentImageView.image = image;
            [self.activityIndicator stopAnimating];
        });
    });
}

#pragma mark - UICollectionViewFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.filterCollectionView.bounds.size.height - kCollectionViewInset, self.filterCollectionView.bounds.size.height);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, kCollectionViewInset, 0, kCollectionViewInset);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kCollectionViewInset;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}



#pragma mark - private methods

- (IBAction)processPhoto:(id)sender
{
    self.currentImageView.image = [[ImageFiltersManager sharedInstance] processSharpFilterUsingPixels:self.currentImage];
    self.currentImage = self.currentImageView.image;
}

- (void)prepareViewController
{
    self.currentImageView.image = self.currentImage;
    self.filtersNameDataSource = [[ImageFiltersManager sharedInstance]filtersName];
    [self.filterCollectionView registerNib:[ImageFilterCollectionViewCell cellNib] forCellWithReuseIdentifier:[ImageFilterCollectionViewCell storyboardID]];
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.dataSource = self;
    self.filterCollectionView.scrollEnabled = YES;
}

@end
