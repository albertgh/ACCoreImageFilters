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
            NSURL *kernelURL =
            [[NSBundle mainBundle] URLForResource:@"default"
                                    withExtension:@"metallib"];
            NSError *error;
            NSData *data = [NSData dataWithContentsOfURL:kernelURL];
            self.customKernel =
            [CIKernel kernelWithFunctionName:@"aCImageMask"
                        fromMetalLibraryData:data
                                       error:&error];
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
