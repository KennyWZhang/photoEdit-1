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
#import "SVProgressHUD.h"

@interface HomeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *cameraView;
@property (nonatomic, weak) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, weak) IBOutlet UIButton *chosePhotoButton;
@property (nonatomic, weak) IBOutlet UIView *uiElementsView;
@property (nonatomic, weak) IBOutlet UIVisualEffectView *blurView;
@property (nonatomic, weak) IBOutlet UIImageView *backGroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *captureButton;//take and capture are not the same

@property (nonatomic, strong) CameraManager *cameraManager;
@property (nonatomic, strong) UIImagePickerController *imagePicker;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareViewControllerForMenu];
    [self.navigationController.navigationBar setHidden:YES];

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

- (void)prepareViewControllerForPhoto
{
    self.blurView.hidden = self.backGroundImageView.hidden = YES;
    self.takePhotoButton.hidden = self.chosePhotoButton.hidden = YES;
    self.backButton.hidden = self.captureButton.hidden = NO;
}

- (void)prepareViewControllerForMenu
{
    self.blurView.hidden = self.backGroundImageView.hidden = NO;
    self.takePhotoButton.hidden = self.chosePhotoButton.hidden = NO;
    self.backButton.hidden = self.captureButton.hidden = YES;
}

#pragma mark -  Actions

- (IBAction)takePhotoAction:(id)sender
{
    [self prepareViewControllerForPhoto];
}

- (IBAction)chosePhotoAction:(id)sender
{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = YES;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self presentViewController: self.imagePicker animated:YES completion:NULL];
        });
    });
}

- (IBAction)backAction:(id)sender
{
    [self prepareViewControllerForMenu];
}

- (IBAction)capturePhotoAction:(id)sender
{
    __weak typeof(self) weakself = self;
    [self.cameraManager takePhotoWithComplition:^(UIImage *image) {
        ImageDemonstrateController *imageVC = [weakself.storyboard instantiateViewControllerWithIdentifier:[ImageDemonstrateController storyBoardID]];
        imageVC.currentImage = image;
        [weakself.cameraManager restoreConnection];
        [weakself.navigationController pushViewController:imageVC animated:YES];
    }];
}

#pragma mark - lazy init

- (UIImagePickerController *)imagePicker
{
    return _imagePicker = _imagePicker ? _imagePicker : [UIImagePickerController new];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    __weak typeof(self) weakself = self;
    [self dismissViewControllerAnimated:YES completion:^()
    {
        ImageDemonstrateController *imageVC = [weakself.storyboard instantiateViewControllerWithIdentifier:[ImageDemonstrateController storyBoardID]];
        imageVC.currentImage = image;
        [weakself.navigationController.navigationBar setHidden:YES];
        [weakself.navigationController pushViewController:imageVC animated:YES];
    }];
}

@end
