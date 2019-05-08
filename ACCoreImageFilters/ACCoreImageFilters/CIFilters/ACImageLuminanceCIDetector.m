//
//  ACImageLuminanceCIDetector.m
//  ACCoreImageFilters
//
//  Created by albert on 2019/5/7.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ACImageLuminanceCIDetector.h"


@interface ACImageLuminanceCIDetector()

@property (nonatomic, strong) CIKernel *customKernel;

@end


@implementation ACImageLuminanceCIDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.customKernel == nil) {
//            if (@available(iOS 11.0, *)) {
//                NSURL *kernelURL =
//                [[NSBundle bundleForClass:[ACImageLuminanceCIDetector class]]
//                 URLForResource:@"ACImageLuminanceCIDetector"
//                 withExtension:@"metallib"];
//                NSError *error;
//                NSData *data = [NSData dataWithContentsOfURL:kernelURL];
//                self.customKernel =
//                [CIKernel kernelWithFunctionName:@"aCImageLuminance"
//                            fromMetalLibraryData:data
//                                           error:&error];
//                if (self.customKernel == nil) {
//                    return nil;
//                }
//            } else {
                NSBundle *bundle = [NSBundle bundleForClass: [self class]];
                NSURL *kernelURL = [bundle URLForResource:@"ACImageLuminanceCIDetector" withExtension:@"cikernel"];
                
                NSError *error;
                NSString *kernelCode =
                [NSString stringWithContentsOfURL:kernelURL
                                         encoding:NSUTF8StringEncoding
                                            error:&error];
                if (kernelCode == nil) {
                    //NSLog(@"Error loading kernel code string in %@\n%@", NSStringFromSelector(_cmd), error.localizedDescription);
                    //abort();
                    return nil;
                }
                
                NSArray *kernels = [CIKernel kernelsWithString:kernelCode];
                self.customKernel = [kernels objectAtIndex:0];
            //}
        }
    }
    return self;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    CGRect dod = self.inputImage.extent;
    
    return [self.customKernel
            applyWithExtent:dod
            roiCallback:^CGRect(int index, CGRect destRect) {
                return destRect;
            }
            arguments:@[self.inputImage]
            ];
}

- (CGFloat)imageLuminance {
    CIImage *outputImage = self.outputImage;

    CIFilter *filter = [CIFilter filterWithName:@"CIAreaAverage"];
    [filter setValue:outputImage forKey:kCIInputImageKey];
    CGRect inputExtent = outputImage.extent;
    CIVector *extentVector =
    [CIVector vectorWithX:inputExtent.origin.x
                        Y:inputExtent.origin.y
                        Z:inputExtent.size.width
                        W:inputExtent.size.height];
    [filter setValue:extentVector forKey:kCIInputExtentKey];
    CIImage *avgColorImage = filter.outputImage;
    
    size_t rowBytes = 32 ; // ARGB has 4 components
    uint8_t byteBuffer[rowBytes]; // Buffer to render into
    NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
    CIContext *aContext = [CIContext contextWithOptions:options];
    [aContext render:avgColorImage
            toBitmap:byteBuffer
            rowBytes:rowBytes
              bounds:avgColorImage.extent
              format:kCIFormatRGBA8
          colorSpace:nil];
    
    const uint8_t* pixel = &byteBuffer[0];
    float red   = pixel[0] / 255.0;
    float green = pixel[1] / 255.0;
    float blue  = pixel[2] / 255.0;
    float alpha = pixel[3] / 255.0;
    
    return @(red).floatValue;
}

@end

