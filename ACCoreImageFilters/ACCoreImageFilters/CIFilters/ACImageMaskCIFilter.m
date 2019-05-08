//
//  ACImageMaskCIFilter.m
//  ACCoreImageFilters
//
//  Created by albert on 2019/4/30.
//  Copyright © 2019 albert. All rights reserved.
//

#import "ACImageMaskCIFilter.h"


@interface ACImageMaskCIFilter ()

@property (nonatomic, strong) CIKernel *customKernel;

@end


@implementation ACImageMaskCIFilter

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.customKernel == nil) {
            if (@available(iOS 11.0, *)) {
                NSURL *kernelURL =
                [[NSBundle bundleForClass:[ACImageMaskCIFilter class]]
                 URLForResource:@"ACImageMaskCIFilter"
                 withExtension:@"metallib"];
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:kernelURL];
                self.customKernel =
                [CIKernel kernelWithFunctionName:@"aCImageMask"
                            fromMetalLibraryData:data
                                           error:&error];
                if (self.customKernel == nil) {
                    return nil;
                }
            } else {
                NSBundle *bundle = [NSBundle bundleForClass: [self class]];
                NSURL *kernelURL = [bundle URLForResource:@"ACImageMaskCIFilter" withExtension:@"cikernel"];
                
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
            }
        }
    }
    return self;
}

- (CIImage *)outputImage {
    if (!self.inputImage) {
        return nil;
    }
    
    CGRect dod = self.inputImage.extent;
    
    CIVector *maskColorVector = [CIVector vectorWithX:0.0 Y:0.0 Z:0.0];
    if (self.maskColor) {
        maskColorVector = [CIVector vectorWithX:self.maskColor.red
                                              Y:self.maskColor.green
                                              Z:self.maskColor.blue];
    }
    
    return [self.customKernel
            applyWithExtent:dod
            roiCallback:^CGRect(int index, CGRect destRect) {
                return destRect;
            }
            arguments:@[self.inputImage
                        , maskColorVector
                        , @(self.needInvertedMask)
                        ]
            ];
}


@end
