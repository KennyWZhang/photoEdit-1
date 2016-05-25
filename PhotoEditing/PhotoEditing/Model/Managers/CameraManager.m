//
//  CameraManager.m
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/24/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import "CameraManager.h"
#import <UIKit/UIKit.h>
#import "UIAlertView+Blocks.h"

@interface CameraManager ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;
@property (nonatomic, strong) AVCaptureDeviceInput *input;

@end

@implementation CameraManager


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    
    if (self)
    {
        self.session = [[AVCaptureSession alloc] init];
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.flashMode = AVCaptureFlashModeOff;
        self.devicePosition = AVCaptureDevicePositionBack;
        NSError *error = nil;
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        
        if (error)
        {
            [UIAlertView showErrorWithMessage:NSLocalizedString(@"Please run application on real device, camera is not accessable",nil) handler:nil];
            return nil;
        }
        
        [self.session addInput:self.input];
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [self.session addOutput:output];
        output.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
        self.cameraLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.cameraLayer.frame = frame;
        self.cameraLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.imageOutput setOutputSettings:outputSettings];
        
        if (output && [self.session canAddOutput:self.imageOutput])
            [self.session addOutput:self.imageOutput];
        
        [self.session startRunning];
    }
    
    return self;
}

- (AVCaptureConnection *)captureConnection
{
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in self.imageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection)
            break;
        
    }
    return videoConnection;
}

- (void)takePhotoWithComplition:(void(^)(UIImage *image))complition
{
    [self.cameraLayer.connection setEnabled:NO];//key property for renewing data flow
    AVCaptureConnection *videoConnection = [self captureConnection];
    videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (!imageSampleBuffer)
            return;
        
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        if (self.devicePosition == AVCaptureDevicePositionFront)
        {
            UIImage *flippedImage = [UIImage imageWithCGImage:image.CGImage
                                                        scale:image.scale
                                                  orientation:UIImageOrientationLeftMirrored];
            image = flippedImage;
        }
        complition(image);
    }];
}
- (void)restoreConnection
{
    [self.cameraLayer.connection setEnabled:YES];
}

- (void)stopCameraCapturing
{
    [self.session stopRunning];
}

- (void)startCameraCapturing
{
    [self.session startRunning];
}
@end