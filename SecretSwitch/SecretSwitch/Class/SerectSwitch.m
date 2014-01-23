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
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [imageView.layer setBorderWidth:1.f];
        [imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [imageView.layer setMasksToBounds:YES];
        [imageView setContentMode:UIViewContentModeScaleToFill];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

+ (void)applicationWillResignActive{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *view = [window.subviews lastObject];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.bounds.size.width/4, view.bounds.size.height/4), NO, 0);
    
    [view drawViewHierarchyInRect:CGRectMake(view.bounds.origin.x,
                                             view.bounds.origin.y,
                                             view.bounds.size.width/4,
                                             view.bounds.size.height/4)
               afterScreenUpdates:NO];
    
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
    
    [imageView setAlpha:1.f];
    [imageView setImage:image];
    [window.subviews.lastObject addSubview:imageView];
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
