//
//  SerectSwitch.m
//  SecretSwitch
//
//  Created by croath on 1/22/14.
//  Copyright (c) 2014 Croath. All rights reserved.
//

#import "SerectSwitch.h"

@implementation SerectSwitch

static UIImageView *imageView;

+ (void)protectSecret{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

+ (void)applicationDidEnterBackground{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = [[[window rootViewController] view] snapshotViewAfterScreenUpdates:NO];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.bounds.size.width/2, view.bounds.size.height/2), NO, 0);
    
    [view drawViewHierarchyInRect:CGRectMake(view.bounds.origin.x,
                                             view.bounds.origin.y,
                                             view.bounds.size.width/2,
                                             view.bounds.size.height/2)
               afterScreenUpdates:YES];
    
    UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:copied];
    
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:inputImage forKey:kCIInputImageKey];
    [blurFilter setValue:[NSNumber numberWithFloat:10.0f]
                  forKey:@"inputRadius"];
    
    
    CIImage *outputImage = [blurFilter valueForKey:kCIOutputImageKey];
    CIContext *context = [CIContext contextWithOptions:nil];
    UIImage *image = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
    
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        [imageView setContentMode:UIViewContentModeScaleToFill];
    }
    [imageView setAlpha:1.f];
    [imageView setImage:image];
    [window addSubview:imageView];
}

+ (void)applicationDidBecomeActive{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [imageView setAlpha:0.f];
                     } completion:^(BOOL finished) {
                         if (finished) {
                             [imageView removeFromSuperview];
                         }
                     }];
}
@end
