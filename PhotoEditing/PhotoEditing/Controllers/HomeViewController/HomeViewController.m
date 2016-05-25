//
//  HomeViewController.m
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/24/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import "HomeViewController.h"
#import "CameraManager.h"
#import "ImageDemonstrateController.h"

@interface HomeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *cameraView;
@property (nonatomic, weak) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, weak) IBOutlet UIButton *chosePhotoButton;
@property (nonatomic, weak) IBOutlet UIView *uiElementsView;
@property (nonatomic, weak) IBOutlet UIView *colorLayerView;
@property (nonatomic, strong) CameraManager *cameraManager;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareViewController];
}

#pragma mark - private methods

- (void)prepareViewController
{
    self.cameraManager = [[CameraManager alloc] initWithFrame:self.cameraView.frame];
    
    if (self.cameraManager)// need to check on nil bc on simulator camera manager will be equal nil
    {
        [self.cameraView.layer addSublayer:self.cameraManager.cameraLayer];
        [self.cameraManager startCameraCapturing];
    }
        
    self.takePhotoButton.layer.borderWidth = 3.f;
    self.takePhotoButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.takePhotoButton.layer.cornerRadius = 5.f;
    self.takePhotoButton.clipsToBounds = YES;
    self.chosePhotoButton.layer.borderWidth = 3.f;
    self.chosePhotoButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.chosePhotoButton.layer.cornerRadius = 5.f;
    self.chosePhotoButton.clipsToBounds = YES;
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)prepareViewForPhoto
{
    self.uiElementsView.hidden = self.colorLayerView.hidden = YES;
}

#pragma mark -  Actions

- (IBAction)takePhotoAction:(id)sender
{
    [self prepareViewForPhoto];
}

- (IBAction)chosePhotoAction:(id)sender
{
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController: self.imagePicker animated:YES completion:NULL];
}

#pragma mark - lazy init

- (UIImagePickerController *)imagePicker
{
    return _imagePicker =_imagePicker ? _imagePicker : [UIImagePickerController new];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    __weak typeof(self) weakself = self;
    [self dismissViewControllerAnimated:self.imagePicker completion:^()
    {
        ImageDemonstrateController *imageVC = [weakself.storyboard instantiateViewControllerWithIdentifier:[ImageDemonstrateController storyBoardID]];
        imageVC.currentImage = image;
        [weakself.navigationController.navigationBar setHidden:YES];
        [weakself.navigationController pushViewController:imageVC animated:YES];
    }];
}

@end
