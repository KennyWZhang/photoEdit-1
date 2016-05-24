//
//  HomeViewController.m
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/24/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import "HomeViewController.h"
#import "CameraManager.h"

@interface HomeViewController ()

@property (nonatomic, weak) IBOutlet UIView *cameraView;
@property (nonatomic, weak) IBOutlet UIButton *takePhotoButton;
@property (nonatomic, weak) IBOutlet UIButton *chosePhotoButton;
@property (nonatomic, weak) IBOutlet UIView *uiElementsView;
@property (nonatomic, weak) IBOutlet UIView *colorLayerView;
@property (nonatomic, strong) CameraManager *cameraManager;

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

#pragma mark - 

- (IBAction)takePhotoAction:(id)sender
{
    [self prepareViewForPhoto];
}

@end
