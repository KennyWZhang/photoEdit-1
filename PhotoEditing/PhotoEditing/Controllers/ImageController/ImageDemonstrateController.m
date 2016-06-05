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
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIAlertView+Blocks.h"

@interface ImageDemonstrateController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIImageView *currentImageView;
@property (nonatomic, weak) IBOutlet UICollectionView *filterCollectionView;
@property (nonatomic, strong) NSArray<NSString *> *filtersNameDataSource;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIImage *backupImage;

@end

static const CGFloat kCollectionViewInset = 10.0;
static const CGFloat kCollectionViewCellWidth = 110.f;

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
}

#pragma mark - Actions

- (IBAction)applyAction:(id)sender
{
    self.currentImage = self.currentImageView.image;
    [self.filterCollectionView reloadData];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreDetailAction:(id)sender
{
    __weak typeof(self) weakself = self;
    UIAlertController *moreDetailsAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [moreDetailsAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself savePhotoToLibrary];
    }]];
    
    [moreDetailsAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Back to original image", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakself.currentImageView.image = weakself.backupImage;
    }]];
    [moreDetailsAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:moreDetailsAlertController animated:YES completion:nil];
    
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
    UIImage *tmpImage = self.currentImage;
    CGSize newSize = CGSizeMake(self.filterCollectionView.bounds.size.height - kCollectionViewInset, self.filterCollectionView.bounds.size.height);
    UIGraphicsBeginImageContext(newSize);
    [tmpImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [[ImageFiltersManager sharedInstance] createImageWithUIImage:newImage withFilter:self.filtersNameDataSource[indexPath.row]];
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
    return CGSizeMake(kCollectionViewCellWidth - kCollectionViewInset, self.filterCollectionView.bounds.size.height);
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
    self.backupImage = self.currentImage;
    self.filtersNameDataSource = [[ImageFiltersManager sharedInstance]filtersName];
    [self.filterCollectionView registerNib:[ImageFilterCollectionViewCell cellNib] forCellWithReuseIdentifier:[ImageFilterCollectionViewCell storyboardID]];
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.dataSource = self;
    self.filterCollectionView.scrollEnabled = YES;
}

- (void)savePhotoToLibrary
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:self.currentImageView.image.CGImage orientation:(ALAssetOrientation)[self.currentImageView.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
        NSString *result = error ? @"Not saved." : @"Succesfully saved";
        [UIAlertView showWithTitle:@"Result" message:NSLocalizedString(result, nil) handler:nil];
    }];
}

@end
