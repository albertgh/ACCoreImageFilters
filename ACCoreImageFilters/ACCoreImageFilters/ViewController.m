//
//  ViewController.m
//  ACCoreImageFilters
//
//  Created by albert on 2019/4/29.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ViewController.h"

#import "ACImageMaskCIFilter.h"


@interface ViewController ()

@property (nonatomic, strong) UIImageView *resultImageView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configSubviews];
    
    [self testCIFilter];
    
    UIColor *avgColor =  [self avgColorFromImage:[UIImage imageNamed:@"star.png"]];
    self.view.backgroundColor = avgColor;

}

- (void)configSubviews {
    CGFloat imageEdge = 300.0;
    CGFloat imageX = (self.view.frame.size.width - imageEdge) / 2.0;
    
    self.resultImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.resultImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.resultImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.resultImageView];
    
    self.resultImageView.frame = CGRectMake(imageX,
                                            120.0,
                                            imageEdge,
                                            imageEdge);
}

- (void)testCIFilter {

    UIImage *image = [UIImage imageNamed:@"star.png"];
    
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    ACImageMaskCIFilter *filter = [[ACImageMaskCIFilter alloc] init];

    filter.inputImage = ciImage;
    filter.maskColor =  [CIColor colorWithCGColor:UIColor.blueColor.CGColor];
    filter.needInvertedMask = true;
    
    CIImage *outputImage = filter.outputImage;
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:outputImage.extent];
    UIImage* resImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    self.resultImageView.image = resImage;
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
