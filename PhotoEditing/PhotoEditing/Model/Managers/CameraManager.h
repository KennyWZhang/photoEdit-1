//
//  CameraManager.h
//  PhotoEditing
//
//  Created by Bohdan Savych on 5/24/16.
//  Copyright © 2016 Bohdan Savych. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface CameraManager : NSObject

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *cameraLayer;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)takePhotoWithComplition:(void(^)(UIImage *image))complition;
- (AVCaptureConnection *)captureConnection;
- (void)startCameraCapturing;
- (void)stopCameraCapturing;
- (void)restoreConnection;

@end
