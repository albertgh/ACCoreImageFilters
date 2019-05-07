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

@interface ViewController ()

@property (nonatomic, strong) UIImageView *originalImageView;

@property (nonatomic, strong) UIImageView *resultImageView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configSubviews];
    
    self.originalImageView.image = [UIImage imageNamed:@"shuijiao_clipped.png"];
    
    [self testHardLightWithMask];
    
//    UIColor *avgColor =  [self avgColorFromImage:[UIImage imageNamed:@"star.png"]];
//    self.view.backgroundColor = avgColor;

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

- (void)testHardLightWithMask {
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    UIImage *originalImage = [UIImage imageNamed:@"shuijiao_clipped.png"];
    UIImage *maskImage = [self imageMaskBy:originalImage];
    UIImage *customedAlphaMaskImage = [self customedAlphaImageBy:maskImage];
    
    CIImage *sourceImage = [[CIImage alloc] initWithImage:originalImage];
    CIImage *overlayImage = [[CIImage alloc] initWithImage:customedAlphaMaskImage];
    
    CIImage *outputImage;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIHardLightBlendMode"];
    [filter setDefaults];
    [filter setValue:sourceImage forKey:kCIInputImageKey];
    [filter setValue:overlayImage forKey:kCIInputBackgroundImageKey];
    outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *resImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    self.resultImageView.image = resImage;
}

- (UIImage *)imageMaskBy:(UIImage *)image {
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    ACImageMaskCIFilter *filter = [[ACImageMaskCIFilter alloc] init];

    filter.inputImage = ciImage;
    filter.maskColor =  [CIColor colorWithCGColor:UIColor.blueColor.CGColor];
    //filter.needInvertedMask = true;
    
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
    CIImage *outputImage = [filter valueForKey:@"outputImage"];
    


    EAGLContext *aEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    CIContext *aContext = [CIContext contextWithEAGLContext:aEAGLContext options:options];
    
    size_t rowBytes = 32 ; // ARGB has 4 components
    uint8_t byteBuffer[rowBytes]; // Buffer to render into
    
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
    
    //NSLog(@"%f, %f, %f, %f \n", red, green, blue, alpha);
    
    UIColor *averageColor = [UIColor colorWithRed:red
                                            green:green
                                             blue:blue
                                            alpha:alpha];

    return averageColor;
}

@end
