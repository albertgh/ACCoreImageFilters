//
//  ViewController.m
//  ACCoreImageFilters
//
//  Created by albert on 2019/4/29.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ViewController.h"

#import "ACImageMaskCIFilter.h"
#import "ACImageOpacityCIFilter.h"
#import "ACImageClipCIFilter.h"
#import "ACImageLuminanceCIDetector.h"

#import <OpenGLES/ES2/gl.h>

@interface ViewController ()

@property (nonatomic, strong) UIImageView *originalImageView;

@property (nonatomic, strong) UIImageView *resultImageView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configSubviews];
    
    UIImage *image = [UIImage imageNamed:@"shuijiao_clipped.png"];
    
    self.originalImageView.image = image;
    
    
    [self testClipGlow];
    [self testHardLightWithMask];
    
    //UIColor *avgColor =  [self avgColorFromImage:image];
    //self.view.backgroundColor = avgColor;
    
    [self luminanceFromImage:image];

    //[self testExposure];
}

- (void)configSubviews {
    CGFloat imageEdge = 300.0;
    CGFloat imageX = (self.view.frame.size.width - imageEdge) / 2.0;
    
    self.originalImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.originalImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.originalImageView.backgroundColor = [UIColor whiteColor];
    
    self.originalImageView.clipsToBounds = true;
    self.originalImageView.layer.masksToBounds = true;
    self.originalImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.originalImageView.layer.borderWidth = 2.0;
    
    [self.view addSubview:self.originalImageView];
    self.originalImageView.frame = CGRectMake(imageX,
                                              60.0,
                                              imageEdge,
                                              imageEdge);
    
    
    self.resultImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.resultImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.resultImageView.backgroundColor = [UIColor clearColor];
    
    self.resultImageView.clipsToBounds = true;
    self.resultImageView.layer.masksToBounds = true;
    self.resultImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.resultImageView.layer.borderWidth = 2.0;
    
    [self.view addSubview:self.resultImageView];
    self.resultImageView.frame = CGRectMake(imageX,
                                            self.originalImageView.frame.origin.y + self.originalImageView.frame.size.height + 20.0,
                                            imageEdge,
                                            imageEdge);
}

- (void)testExposure {
    UIImage *originalImage = [UIImage imageNamed:@"shuijiao_clipped.png"];
    
    CIImage *originalCIImage = [[CIImage alloc] initWithImage:originalImage];
    
    CIFilter *exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
    
    //NSDictionary *myFilterAttributes = [exposureFilter attributes];
    //NSLog(@"aa %@", myFilterAttributes);
    
    [exposureFilter setValue:originalCIImage forKey:kCIInputImageKey];
    [exposureFilter setValue:@(5.0) forKey:kCIInputEVKey];
    CIImage *outputImage = [exposureFilter valueForKey:kCIOutputImageKey];
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage
                                     fromRect:outputImage.extent];
    
    UIImage *resImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    self.resultImageView.image = resImage;

}

- (void)testClipGlow {
    UIImage *originalImage = [UIImage imageNamed:@"shuijiao_clipped.png"];
    
    CIImage *originalCIImage = [[CIImage alloc] initWithImage:originalImage];
    
    ACImageMaskCIFilter *filter = [[ACImageMaskCIFilter alloc] init];
    filter.inputImage = originalCIImage;
    filter.maskColor =  [CIColor colorWithCGColor:UIColor.blueColor.CGColor];
    filter.needInvertedMask = true;
    CIImage *invertedMaskCIImage = filter.outputImage;
    
    
    CGFloat blurRadius = (originalImage.size.width * 0.02);
    NSLog(@"blur radius = %@", @(blurRadius));
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setValue:invertedMaskCIImage forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@(blurRadius) forKey:kCIInputRadiusKey];
    CIImage *gaussianBlurInvertedMaskCIImage = gaussianBlurFilter.outputImage;

    CIImage *croppedImage = [gaussianBlurInvertedMaskCIImage imageByCroppingToRect:invertedMaskCIImage.extent];

    
    
    ACImageClipCIFilter *clipFilter = [[ACImageClipCIFilter alloc] init];
    clipFilter.inputImage = croppedImage;
    clipFilter.clipShapeImage = originalCIImage;
    CIImage *glowCIImage = clipFilter.outputImage;

    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:glowCIImage
                                     fromRect:glowCIImage.extent];
    
    UIImage *resImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    self.resultImageView.image = resImage;
}

- (void)testHardLightWithMask {
    UIImage *originalImage = [UIImage imageNamed:@"shuijiao_clipped.png"];
    UIImage *maskImage = [self imageMaskBy:originalImage needInvertedMask:false];
    UIImage *customedAlphaMaskImage = [self customedAlphaImageBy:maskImage];
    
    CIImage *sourceImage = [[CIImage alloc] initWithImage:originalImage];
    CIImage *overlayImage = [[CIImage alloc] initWithImage:customedAlphaMaskImage];
    
    CIImage *outputImage;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIHardLightBlendMode"];
    [filter setDefaults];
    [filter setValue:sourceImage forKey:kCIInputImageKey];
    [filter setValue:overlayImage forKey:kCIInputBackgroundImageKey];
    outputImage = filter.outputImage;
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage
                                     fromRect:outputImage.extent];
    
    UIImage *resImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    self.resultImageView.image = resImage;
}

- (UIImage *)imageMaskBy:(UIImage *)image needInvertedMask:(BOOL)needInvertedMask {
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    ACImageMaskCIFilter *filter = [[ACImageMaskCIFilter alloc] init];

    filter.inputImage = ciImage;
    filter.maskColor =  [CIColor colorWithCGColor:UIColor.blueColor.CGColor];
    filter.needInvertedMask = needInvertedMask;
    
    CIImage *outputImage = filter.outputImage;
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:outputImage.extent];
    UIImage* resImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return resImage;
}

- (UIImage *)customedAlphaImageBy:(UIImage *)image {
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    ACImageOpacityCIFilter *filter = [[ACImageOpacityCIFilter alloc] init];
    
    filter.inputImage = ciImage;
    filter.alpha = 0.5;
    
    CIImage *outputImage = filter.outputImage;
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:outputImage.extent];
    UIImage* resImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return resImage;
}

- (CGFloat)luminanceFromImage:(UIImage *)image {
    if (!image) {
        return 0.0;
    }
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:image];
    
    ACImageLuminanceCIDetector *filter = [[ACImageLuminanceCIDetector alloc] init];
    filter.inputImage = inputImage;
    
    CGFloat imageLum = [filter imageLuminance];
    
    NSLog(@"lum: %@", @(imageLum));
    
    return imageLum;
}

- (UIColor *)avgColorFromImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:image];

    CIFilter *filter = [CIFilter filterWithName:@"CIAreaAverage"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    CGRect inputExtent = inputImage.extent;
    CIVector *extentVector =
    [CIVector vectorWithX:inputExtent.origin.x
                        Y:inputExtent.origin.y
                        Z:inputExtent.size.width
                        W:inputExtent.size.height];
    [filter setValue:extentVector forKey:kCIInputExtentKey];
    CIImage *outputImage = filter.outputImage;
    
    size_t rowBytes = 32 ; // ARGB has 4 components
    uint8_t byteBuffer[rowBytes]; // Buffer to render into
    NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    CIContext *aContext = [CIContext contextWithOptions:options];
    [aContext render:outputImage
            toBitmap:byteBuffer
            rowBytes:rowBytes
              bounds:outputImage.extent
              format:kCIFormatRGBA8
          colorSpace:nil];
    
    const uint8_t* pixel = &byteBuffer[0];
    float red   = pixel[0] / 255.0;
    float green = pixel[1] / 255.0;
    float blue  = pixel[2] / 255.0;
    float alpha = pixel[3] / 255.0;
    
    NSLog(@"ac_flag %f, %f, %f, %f \n", red, green, blue, alpha);
    

    UIColor *averageColor = [UIColor colorWithRed:red
                                            green:green
                                             blue:blue
                                            alpha:alpha];


    return averageColor;
}

@end
